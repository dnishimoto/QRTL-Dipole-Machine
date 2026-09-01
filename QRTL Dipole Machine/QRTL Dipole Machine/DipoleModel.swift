import Foundation
import SwiftUI
import Combine


final class QRTLDipoleModel: ObservableObject {

    // ============================================================
    // MARK: - Design Target
    // ============================================================

    /// QRTL display target.
    ///
    /// 0.020 MW = 20 kW.
    @Published var targetNetOutputMW: Double = 0.020

    // ============================================================
    // MARK: - Field Drive
    // ============================================================

    /// DC Hold is the low-cost default.
    @Published var fieldDriveMode: FieldDriveMode = .dcHold

    /// Set to zero for DC Hold.
    ///
    /// 0.001 kHz = 1 Hz.
    @Published var fieldFrequencyKHz: Double = 0.0

    /// Only matters during `.resonantAC`.
    @Published var resonantDriveEnabled: Bool = false

    @Published var resonatorQualityFactor: Double = 200.0

    /// Used only for `.pulsed`.
    @Published var fieldDutyCycle: Double = 0.10

    /// Applied only in `.resonantAC`.
    @Published var acResistanceMultiplier: Double = 1.0

    // ============================================================
    // MARK: - Power Budget
    // ============================================================

    /// Hard wall-plug ceiling for the field system.
    @Published var maximumFieldInputWatts: Double = 20_000.0

    /// Target headroom under the hard ceiling.
    ///
    /// 0.90 × 20 kW = 18 kW target.
    @Published var fieldPowerDesignMargin: Double = 0.90

    /// Fixed loss values are stored in watts to avoid MW/W mixing.
    @Published var switchingAndCoreLossWatts: Double = 500.0

    /// Included in the field-system power budget.
    @Published var fieldAuxiliaryPowerWatts: Double = 500.0

    /// These remain separate machine operating costs and are
    /// subtracted only in final net-output properties.
    @Published var coolingPowerWatts: Double = 500.0
    @Published var auxiliaryPowerWatts: Double = 1_000.0

    @Published var powerElectronicsEfficiency: Double = 0.94

    // ============================================================
    // MARK: - Primary Excitation Coil
    // ============================================================

    @Published var primaryTurns: Double = 2_000.0
    @Published var primaryCurrentA: Double = 250.0
    @Published var primaryRadiusM: Double = 20.0
    @Published var primaryResistanceOhms: Double = 0.005

    // ============================================================
    // MARK: - Upper Shaping Coil
    // ============================================================

    @Published var upperShapingEnabled: Bool = true
    @Published var upperTurns: Double = 800.0
    @Published var upperCurrentA: Double = 80.0
    @Published var upperRadiusM: Double = 16.0
    @Published var upperResistanceOhms: Double = 0.010
    @Published var upperHeightM: Double = 25.0
    @Published var upperPhaseDegrees: Double = 0.0

    // ============================================================
    // MARK: - Lower Return Coil
    // ============================================================

    @Published var lowerReturnEnabled: Bool = true
    @Published var lowerTurns: Double = 800.0
    @Published var lowerCurrentA: Double = 80.0
    @Published var lowerRadiusM: Double = 16.0
    @Published var lowerResistanceOhms: Double = 0.010
    @Published var lowerHeightM: Double = -25.0
    @Published var lowerPhaseDegrees: Double = 180.0

    // ============================================================
    // MARK: - Flux Management
    // ============================================================

    @Published var fluxManagementGain: Double = 1.0
    @Published var couplingAlignmentFactor: Double = 1.0

    // ============================================================
    // MARK: - Coupling Surface
    // ============================================================

    @Published var couplingAltitudeKm: Double = 20.0
    @Published var couplingRadiusKm: Double = 1.0

    // ============================================================
    // MARK: - Receiver / Collector
    // ============================================================

    @Published var receiverTurns: Double = 5_000.0
    @Published var receiverResistanceOhms: Double = 0.10

    @Published var collectorAreaAcres: Double = 10.0
    @Published var collectorConductivitySPerM: Double = 5.8e7
    @Published var collectorThicknessM: Double = 0.010
    @Published var radialSpokeCount: Double = 32.0
    @Published var radialSpokeWidthM: Double = 0.05

    @Published var collectorInductanceH: Double = 0.001
    @Published var collectorCapacitanceF: Double = 1.0e-6
    @Published var includeACImpedance: Bool = true

    @Published var sourceResistanceOhms: Double = 0.10
    @Published var groundReturnResistanceOhms: Double = 0.10
    @Published var radiationResistanceOhms: Double = 0.001
    @Published var loadResistanceOhms: Double = 100.0

    @Published var contactEfficiency: Double = 0.98
    @Published var conversionEfficiency: Double = 0.95

    // ============================================================
    // MARK: - QRTL Hypothesis Collection
    // ============================================================

    /// Explicit QRTL model input—not conventional measured current.
    @Published var fieldAlignedCurrentA: Double = 1.0e19

    /// Clamped to 0...1.
    @Published var fieldCurrentCaptureEfficiency: Double = 0.01

    /// Explicit modeled QRTL collection-interface voltage.
    @Published var fieldCollectionVoltageV: Double = 1.1e-10

    @Published var qrtlFieldCollectionEnabled: Bool = true

    // ============================================================
    // MARK: - Machine State
    // ============================================================

    @Published var isRunning: Bool = true

    let vacuumPermeability: Double =
        4.0 * Double.pi * 1.0e-7

    // ============================================================
    // MARK: - Coil Model
    // ============================================================

    struct DipoleCoil: Identifiable {

        let id: String
        let centerY: Double
        let turns: Double
        let requestedCurrentA: Double
        let radiusM: Double
        let resistanceOhms: Double
        let phaseRadians: Double
        let enabled: Bool

        var areaM2: Double {
            Double.pi * radiusM * radiusM
        }

        func currentA(
            scale: Double
        ) -> Double {

            requestedCurrentA
                * max(
                    0.0,
                    min(
                        1.0,
                        scale
                    )
                )
        }

        func magneticMomentAm2(
            scale: Double
        ) -> Double {

            turns
                * currentA(scale: scale)
                * areaM2
        }
    }

    // ============================================================
    // MARK: - Requested Coil Definitions
    // ============================================================

    var primaryCoil: DipoleCoil {
        DipoleCoil(
            id: "Primary",
            centerY: 0.0,
            turns: primaryTurns,
            requestedCurrentA: primaryCurrentA,
            radiusM: primaryRadiusM,
            resistanceOhms: primaryResistanceOhms,
            phaseRadians: 0.0,
            enabled: true
        )
    }

    var upperCoil: DipoleCoil {
        DipoleCoil(
            id: "Upper Shaping",
            centerY: upperHeightM,
            turns: upperTurns,
            requestedCurrentA: upperCurrentA,
            radiusM: upperRadiusM,
            resistanceOhms: upperResistanceOhms,
            phaseRadians: upperPhaseDegrees * Double.pi / 180.0,
            enabled: upperShapingEnabled
        )
    }

    var lowerCoil: DipoleCoil {
        DipoleCoil(
            id: "Lower Return",
            centerY: lowerHeightM,
            turns: lowerTurns,
            requestedCurrentA: lowerCurrentA,
            radiusM: lowerRadiusM,
            resistanceOhms: lowerResistanceOhms,
            phaseRadians: lowerPhaseDegrees * Double.pi / 180.0,
            enabled: lowerReturnEnabled
        )
    }

    var requestedActiveCoils: [DipoleCoil] {
        [
            primaryCoil,
            upperCoil,
            lowerCoil
        ]
        .filter(\.enabled)
    }

    /// Active coils with the 20 kW-derived scale applied.
    ///
    /// Coil geometry and requested current remain stored separately.
    var activeCoils: [DipoleCoil] {
        requestedActiveCoils
    }

    // ============================================================
    // MARK: - Geometry and Drive
    // ============================================================

    var requestedFrequencyHz: Double {
        max(fieldFrequencyKHz, 0.0) * 1_000.0
    }

    /// AC frequency active only in deliberate resonant operation.
    var frequencyHz: Double {

        guard
            fieldDriveMode == .resonantAC,
            resonantDriveEnabled
        else {
            return 0.0
        }

        return requestedFrequencyHz
    }

    /// Single source of truth for "is the field actually changing".
    ///
    /// Every dΦ/dt-dependent quantity below should gate on this
    /// property instead of re-deriving `frequencyHz > 0.0` itself.
    /// DC Hold and Pulsed both yield `false` here — see
    /// `FieldDriveMode.summary` in DataStructures.swift, which
    /// documents Pulsed as a copper-loss duty-cycle effect only,
    /// not a Faraday-induction source.
    var isACDriveActive: Bool {
        frequencyHz > 0.0
    }

    var angularFrequency: Double {
        2.0 * Double.pi * frequencyHz
    }

    var effectiveFieldDutyCycle: Double {

        switch fieldDriveMode {
        case .dcHold,
             .resonantAC:
            return 1.0

        case .pulsed:
            return max(
                0.0,
                min(
                    1.0,
                    fieldDutyCycle
                )
            )
        }
    }

    var couplingAltitudeM: Double {
        max(couplingAltitudeKm, 0.0) * 1_000.0
    }

    var couplingRadiusM: Double {
        max(couplingRadiusKm, 0.0) * 1_000.0
    }

    var couplingSurfaceAreaM2: Double {
        Double.pi * couplingRadiusM * couplingRadiusM
    }

    var collectorAreaM2: Double {
        max(collectorAreaAcres, 0.0) * 4_046.8564224
    }

    var collectorRadiusM: Double {

        guard collectorAreaM2 > 0.0 else {
            return 0.0
        }

        return sqrt(
            collectorAreaM2 / Double.pi
        )
    }

    // ============================================================
    // MARK: - Power Budget
    // ============================================================

    var targetFieldInputWatts: Double {

        max(0.0, maximumFieldInputWatts)
            *
            max(
                0.0,
                min(
                    1.0,
                    fieldPowerDesignMargin
                )
            )
    }

    var switchingAndCoreLossMW: Double {
        switchingAndCoreLossWatts / 1_000_000.0
    }

    var coolingPowerMW: Double {
        coolingPowerWatts / 1_000_000.0
    }

    var auxiliaryPowerMW: Double {
        auxiliaryPowerWatts / 1_000_000.0
    }

    /// Fixed losses included inside field-system wall-input budget.
    var fixedFieldLossWatts: Double {

        max(0.0, switchingAndCoreLossWatts)
            + max(0.0, fieldAuxiliaryPowerWatts)
    }

    func coilEffectiveResistanceOhms(
        _ coil: DipoleCoil
    ) -> Double {

        let resistance = max(
            coil.resistanceOhms,
            0.0
        )

        guard fieldDriveMode == .resonantAC else {
            return resistance
        }

        return resistance
            * max(
                1.0,
                acResistanceMultiplier
            )
    }

    /// Current RMS multiplier relative to requested peak current.
    var currentRMSFactor: Double {

        fieldDriveMode == .resonantAC
            ? 1.0 / sqrt(2.0)
            : 1.0
    }

    /// Variable copper-loss coefficient at requested coil currents.
    ///
    /// Returns loss in W at `coilPowerScale == 1`.
    var requestedCopperLossWatts: Double {

        requestedActiveCoils.reduce(0.0) {
            partial,
            coil in

            let rmsCurrent =
                coil.requestedCurrentA
                * currentRMSFactor

            let loss =
                rmsCurrent
                * rmsCurrent
                * coilEffectiveResistanceOhms(coil)
                * effectiveFieldDutyCycle

            return partial + loss
        }
    }

    func estimatedCoilInductanceH(
        _ coil: DipoleCoil
    ) -> Double {

        let radius = max(coil.radiusM, 0.01)
        let bundleRadius = max(radius * 0.02, 0.001)

        let geometricTerm = max(
            log(
                8.0
                * radius
                / bundleRadius
            )
            - 2.0,
            0.1
        )

        return
            vacuumPermeability
            * coil.turns
            * coil.turns
            * radius
            * geometricTerm
    }

    /// Stored energy at requested currents.
    var requestedStoredMagneticEnergyJ: Double {

        requestedActiveCoils.reduce(0.0) {
            partial,
            coil in

            let energy =
                0.5
                * estimatedCoilInductanceH(coil)
                * coil.requestedCurrentA
                * coil.requestedCurrentA

            return partial + energy
        }
    }

    /// Resonator loss at requested current amplitudes.
    ///
    /// It scales with current², just like copper loss.
    var requestedResonatorLossWatts: Double {

        guard
            isRunning,
            fieldDriveMode == .resonantAC,
            resonantDriveEnabled,
            resonatorQualityFactor > 0.0
        else {
            return 0.0
        }

        return
            angularFrequency
            * requestedStoredMagneticEnergyJ
            / resonatorQualityFactor
    }

    /// Current-dependent loss at full requested currents.
    var requestedVariableFieldLossWatts: Double {

        requestedCopperLossWatts
            + requestedResonatorLossWatts
    }

    /// Uniform 0...1 scaling factor applied to all coil currents.
    ///
    /// Because copper and resonator loss scale as I²:
    ///
    /// scale = √(available variable loss / requested variable loss)
    var coilPowerScale: Double {

        guard
            isRunning,
            powerElectronicsEfficiency > 0.0
        else {
            return 0.0
        }

        let allowedInternalLoss =
            targetFieldInputWatts
            * powerElectronicsEfficiency

        let allowedVariableLoss =
            allowedInternalLoss
            - fixedFieldLossWatts

        guard allowedVariableLoss > 0.0 else {
            return 0.0
        }

        guard requestedVariableFieldLossWatts > 1.0e-12 else {
            return 1.0
        }

        return min(
            1.0,
            sqrt(
                allowedVariableLoss
                / requestedVariableFieldLossWatts
            )
        )
    }

    var isFieldPowerLimited: Bool {
        coilPowerScale < 0.999_999
    }

    // ============================================================
    // MARK: - Coil Current, Loss, and Energy
    // ============================================================

    func coilPeakCurrentA(
        _ coil: DipoleCoil
    ) -> Double {

        coil.currentA(
            scale: coilPowerScale
        )
    }

    func coilRMSCurrentA(
        _ coil: DipoleCoil
    ) -> Double {

        coilPeakCurrentA(coil)
            * currentRMSFactor
    }

    func coilCopperLossWatts(
        _ coil: DipoleCoil
    ) -> Double {

        guard
            isRunning,
            coil.enabled
        else {
            return 0.0
        }

        let current = coilRMSCurrentA(coil)

        return
            current
            * current
            * coilEffectiveResistanceOhms(coil)
            * effectiveFieldDutyCycle
    }

    func coilCopperLossMW(
        _ coil: DipoleCoil
    ) -> Double {
        coilCopperLossWatts(coil) / 1_000_000.0
    }

    var primaryCopperLossMW: Double {
        coilCopperLossMW(primaryCoil)
    }

    var upperCopperLossMW: Double {
        coilCopperLossMW(upperCoil)
    }

    var lowerCopperLossMW: Double {
        coilCopperLossMW(lowerCoil)
    }

    var totalCopperLossWatts: Double {

        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial
                + coilCopperLossWatts(coil)
        }
    }

    var totalCopperLossMW: Double {
        totalCopperLossWatts / 1_000_000.0
    }

    var totalEstimatedInductanceH: Double {

        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial
                + estimatedCoilInductanceH(coil)
        }
    }

    var totalStoredMagneticEnergyJ: Double {

        activeCoils.reduce(0.0) {
            partial,
            coil in

            let current = coilPeakCurrentA(coil)

            let energy =
                0.5
                * estimatedCoilInductanceH(coil)
                * current
                * current

            return partial + energy
        }
    }

    var requiredResonantCapacitanceF: Double {

        guard
            angularFrequency > 0.0,
            totalEstimatedInductanceH > 0.0
        else {
            return .infinity
        }

        return
            1.0
            /
            (
                angularFrequency
                * angularFrequency
                * totalEstimatedInductanceH
            )
    }

    var resonatorMaintenanceLossWatts: Double {

        guard
            isRunning,
            fieldDriveMode == .resonantAC,
            resonantDriveEnabled,
            resonatorQualityFactor > 0.0
        else {
            return 0.0
        }

        return
            angularFrequency
            * totalStoredMagneticEnergyJ
            / resonatorQualityFactor
    }

    var resonatorMaintenanceLossMW: Double {
        resonatorMaintenanceLossWatts / 1_000_000.0
    }

    // ============================================================
    // MARK: - Field System Input
    // ============================================================

    var totalFieldLossesWatts: Double {

        guard isRunning else {
            return 0.0
        }

        return
            totalCopperLossWatts
            + resonatorMaintenanceLossWatts
            + fixedFieldLossWatts
    }

    /// Wall input:
    ///
    /// P_input = P_losses / efficiency
    var fieldSystemInputWatts: Double {

        guard
            isRunning,
            powerElectronicsEfficiency > 0.0
        else {
            return 0.0
        }

        return
            totalFieldLossesWatts
            / powerElectronicsEfficiency
    }

    var fieldSystemInputKW: Double {
        fieldSystemInputWatts / 1_000.0
    }

    var fieldSystemInputMW: Double {
        fieldSystemInputWatts / 1_000_000.0
    }

    var isWithinMaximumFieldPowerBudget: Bool {
        fieldSystemInputWatts <= maximumFieldInputWatts
    }

    // ============================================================
    // MARK: - Magnetic Flux
    // ============================================================

    func coilFluxPeakWebers(
        _ coil: DipoleCoil
    ) -> Double {

        let distance = abs(
            couplingAltitudeM
            - coil.centerY
        )

        let radius = max(
            couplingRadiusM,
            0.001
        )

        guard distance > 0.0 else {
            return 0.0
        }

        let geometricTerm =
            (1.0 / distance)
            -
            (
                1.0
                /
                sqrt(
                    distance
                    * distance
                    +
                    radius
                    * radius
                )
            )

        return
            0.5
            * vacuumPermeability
            * coil.magneticMomentAm2(
                scale: coilPowerScale
            )
            * geometricTerm
    }

    var fluxInPhaseWebers: Double {

        let flux = activeCoils.reduce(0.0) {
            partial,
            coil in

            partial
                + coilFluxPeakWebers(coil)
                * cos(coil.phaseRadians)
        }

        return
            flux
            * fluxManagementGain
            * couplingAlignmentFactor
    }

    var fluxQuadratureWebers: Double {

        let flux = activeCoils.reduce(0.0) {
            partial,
            coil in

            partial
                + coilFluxPeakWebers(coil)
                * sin(coil.phaseRadians)
        }

        return
            flux
            * fluxManagementGain
            * couplingAlignmentFactor
    }

    /// Nonzero for a live DC field as well as AC.
    var peakMagneticFluxWebers: Double {

        guard isRunning else {
            return 0.0
        }

        return hypot(
            fluxInPhaseWebers,
            fluxQuadratureWebers
        )
    }

    func magneticFluxWebers(
        at timeSeconds: Double
    ) -> Double {

        guard isRunning else {
            return 0.0
        }

        guard isACDriveActive else {
            return fluxInPhaseWebers
        }

        let phase = angularFrequency * timeSeconds

        return
            fluxInPhaseWebers
            * sin(phase)
            +
            fluxQuadratureWebers
            * cos(phase)
    }

    var peakFluxChangeRateWebersPerSecond: Double {

        guard
            isRunning,
            isACDriveActive
        else {
            return 0.0
        }

        return
            angularFrequency
            * peakMagneticFluxWebers
    }

    func fluxChangeRateWebersPerSecond(
        at timeSeconds: Double
    ) -> Double {

        guard
            isRunning,
            isACDriveActive
        else {
            return 0.0
        }

        let phase = angularFrequency * timeSeconds

        return
            angularFrequency
            *
            (
                fluxInPhaseWebers
                * cos(phase)
                -
                fluxQuadratureWebers
                * sin(phase)
            )
    }

    // ============================================================
    // MARK: - Magnetic Field
    // ============================================================

    func coilAxialFieldTesla(
        _ coil: DipoleCoil
    ) -> Double {

        let distance = max(
            abs(
                couplingAltitudeM
                - coil.centerY
            ),
            0.001
        )

        return
            vacuumPermeability
            * coil.magneticMomentAm2(
                scale: coilPowerScale
            )
            /
            (
                2.0
                * Double.pi
                * distance
                * distance
                * distance
            )
    }

    var fieldAtCouplingCenterTesla: Double {

        let inPhase = activeCoils.reduce(0.0) {
            partial,
            coil in

            partial
                + coilAxialFieldTesla(coil)
                * cos(coil.phaseRadians)
        }

        let quadrature = activeCoils.reduce(0.0) {
            partial,
            coil in

            partial
                + coilAxialFieldTesla(coil)
                * sin(coil.phaseRadians)
        }

        return
            hypot(
                inPhase,
                quadrature
            )
            * fluxManagementGain
            * couplingAlignmentFactor
    }

    // ============================================================
    // MARK: - Conventional Faraday Induction
    // ============================================================

    var inducedVoltagePeakV: Double {

        guard receiverTurns > 0.0 else {
            return 0.0
        }

        return
            receiverTurns
            * peakFluxChangeRateWebersPerSecond
    }

    var inducedVoltageRMS: Double {
        inducedVoltagePeakV / sqrt(2.0)
    }

    // ============================================================
    // MARK: - Collector Resistance
    // ============================================================

    var collectorSpokeCrossSectionM2: Double {

        max(collectorThicknessM, 0.0)
            * max(radialSpokeWidthM, 0.0)
    }

    var collectorDCResistanceOhms: Double {

        let denominator =
            collectorConductivitySPerM
            * collectorSpokeCrossSectionM2
            * max(radialSpokeCount, 1.0)

        guard denominator > 0.0 else {
            return .infinity
        }

        return collectorRadiusM / denominator
    }

    var skinDepthM: Double {

        guard
            isACDriveActive,
            collectorConductivitySPerM > 0.0
        else {
            return .infinity
        }

        return sqrt(
            2.0
            /
            (
                angularFrequency
                * vacuumPermeability
                * collectorConductivitySPerM
            )
        )
    }

    var effectiveCollectorThicknessM: Double {

        guard skinDepthM.isFinite else {
            return max(collectorThicknessM, 0.0)
        }

        return min(
            max(collectorThicknessM, 0.0),
            max(
                2.0 * skinDepthM,
                1.0e-6
            )
        )
    }

    var collectorACResistanceOhms: Double {

        let effectiveArea =
            max(radialSpokeWidthM, 0.0)
            * effectiveCollectorThicknessM

        let denominator =
            collectorConductivitySPerM
            * effectiveArea
            * max(radialSpokeCount, 1.0)

        guard denominator > 0.0 else {
            return .infinity
        }

        return collectorRadiusM / denominator
    }

    var collectorResistanceOhms: Double {

        includeACImpedance
        ? collectorACResistanceOhms
        : collectorDCResistanceOhms
    }

    // ============================================================
    // MARK: - Conventional Circuit
    // ============================================================

    var collectorInductiveReactanceOhms: Double {

        guard
            includeACImpedance,
            isACDriveActive
        else {
            return 0.0
        }

        return
            angularFrequency
            * max(collectorInductanceH, 0.0)
    }

    var collectorCapacitiveReactanceOhms: Double {

        guard
            includeACImpedance,
            isACDriveActive,
            collectorCapacitanceF > 0.0
        else {
            return 0.0
        }

        return
            -1.0
            /
            (
                angularFrequency
                * collectorCapacitanceF
            )
    }

    var totalCircuitResistanceOhms: Double {

        max(receiverResistanceOhms, 0.0)
            + max(sourceResistanceOhms, 0.0)
            + max(collectorResistanceOhms, 0.0)
            + max(groundReturnResistanceOhms, 0.0)
            + max(radiationResistanceOhms, 0.0)
            + max(loadResistanceOhms, 0.0)
    }

    var totalCircuitReactanceOhms: Double {

        collectorInductiveReactanceOhms
            + collectorCapacitiveReactanceOhms
    }

    var totalCircuitImpedanceMagnitudeOhms: Double {

        hypot(
            totalCircuitResistanceOhms,
            totalCircuitReactanceOhms
        )
    }

    var machineCurrentRMSA: Double {

        guard
            isRunning,
            isACDriveActive,
            inducedVoltageRMS > 0.0,
            totalCircuitImpedanceMagnitudeOhms > 0.0
        else {
            return 0.0
        }

        return
            inducedVoltageRMS
            / totalCircuitImpedanceMagnitudeOhms
    }

    var collectorCurrentA: Double {
        machineCurrentRMSA
    }

    // ============================================================
    // MARK: - Conventional Power
    // ============================================================

    var conventionalLoadElectricalPowerMW: Double {

        machineCurrentRMSA
            * machineCurrentRMSA
            * max(loadResistanceOhms, 0.0)
            / 1_000_000.0
    }

    var conventionalCapturedPowerWatts: Double {

        inducedVoltageRMS
            * machineCurrentRMSA
    }

    var conventionalCapturedPowerMW: Double {
        conventionalCapturedPowerWatts / 1_000_000.0
    }

    var conventionalGrossOutputMW: Double {

        let contactAdjusted =
            conventionalLoadElectricalPowerMW
            * max(
                0.0,
                min(
                    1.0,
                    contactEfficiency
                )
            )

        return
            contactAdjusted
            * max(
                0.0,
                min(
                    1.0,
                    conversionEfficiency
                )
            )
    }

    // ============================================================
    // MARK: - QRTL Field-Current Collection
    // ============================================================

    var fieldAlignedCurrent: Double {

        guard
            isRunning,
            qrtlFieldCollectionEnabled
        else {
            return 0.0
        }

        return max(
            fieldAlignedCurrentA,
            0.0
        )
    }

    var capturedFieldCurrentA: Double {

        fieldAlignedCurrent
            * max(
                0.0,
                min(
                    1.0,
                    fieldCurrentCaptureEfficiency
                )
            )
    }

    var fieldCurrentCollectionVoltageV: Double {

        guard
            isRunning,
            qrtlFieldCollectionEnabled
        else {
            return 0.0
        }

        return max(
            fieldCollectionVoltageV,
            0.0
        )
    }

    /// Explicit QRTL hypothesis:
    ///
    /// P = I_captured × V_collection
    var qrtlFieldCollectionPowerW: Double {

        capturedFieldCurrentA
            * fieldCurrentCollectionVoltageV
    }

    var qrtlFieldCollectionPowerMW: Double {
        qrtlFieldCollectionPowerW / 1_000_000.0
    }

    var qrtlPowerAfterContactMW: Double {

        qrtlFieldCollectionPowerMW
            * max(
                0.0,
                min(
                    1.0,
                    contactEfficiency
                )
            )
    }

    var qrtlConvertedCollectedPowerMW: Double {

        qrtlPowerAfterContactMW
            * max(
                0.0,
                min(
                    1.0,
                    conversionEfficiency
                )
            )
    }

    var qrtlCollectionConversionLossMW: Double {

        max(
            0.0,
            qrtlFieldCollectionPowerMW
            - qrtlConvertedCollectedPowerMW
        )
    }

    // ============================================================
    // MARK: - Power Gathered Display
    // ============================================================

    var conventionalPowerGatheredMW: Double {
        conventionalCapturedPowerMW
    }

    var qrtlPowerGatheredMW: Double {
        qrtlFieldCollectionPowerMW
    }

    /// Use this for the UI “Power Gathered” metric.
    var displayedPowerGatheredMW: Double {

        qrtlFieldCollectionEnabled
        ? qrtlPowerGatheredMW
        : conventionalPowerGatheredMW
    }

    var displayedPowerGatheredKW: Double {
        displayedPowerGatheredMW * 1_000.0
    }

    var powerGatheredLabel: String {

        qrtlFieldCollectionEnabled
        ? "QRTL Modeled Power Gathered"
        : "Conventional Faraday Power Gathered"
    }

    // ============================================================
    // MARK: - Net Output
    // ============================================================

    var qrtlNetOutputMW: Double {

        guard
            isRunning,
            qrtlFieldCollectionEnabled
        else {
            return 0.0
        }

        let operatingCostsMW =
            fieldSystemInputMW
            + coolingPowerMW
            + auxiliaryPowerMW

        return max(
            0.0,
            qrtlConvertedCollectedPowerMW
            - operatingCostsMW
        )
    }

    var conventionalNetOutputMW: Double {

        conventionalGrossOutputMW
            - fieldSystemInputMW
            - coolingPowerMW
            - auxiliaryPowerMW
    }

    var qrtlComparisonNetOutputMW: Double {

        qrtlFieldCollectionEnabled
        ? qrtlNetOutputMW
        : conventionalNetOutputMW
    }

    // ============================================================
    // MARK: - Diagnostics
    // ============================================================

    var qrtlCurrentCaptureRatio: Double {

        guard fieldAlignedCurrent > 0.0 else {
            return 0.0
        }

        return
            capturedFieldCurrentA
            / fieldAlignedCurrent
    }

    var qrtlIVPowerCheckMW: Double {

        capturedFieldCurrentA
            * fieldCurrentCollectionVoltageV
            / 1_000_000.0
    }

    var qrtlPowerConsistencyErrorW: Double {

        abs(
            qrtlFieldCollectionPowerW
            -
            (
                capturedFieldCurrentA
                * fieldCurrentCollectionVoltageV
            )
        )
    }

    var usefulFluxPerInputWbPerW: Double {

        guard fieldSystemInputWatts > 0.0 else {
            return 0.0
        }

        return
            peakMagneticFluxWebers
            / fieldSystemInputWatts
    }

    var totalAmpereTurns: Double {

        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial
                + coil.turns
                * coilPeakCurrentA(coil)
        }
    }

    var targetPercent: Double {

        guard targetNetOutputMW > 0.0 else {
            return 0.0
        }

        return max(
            0.0,
            qrtlComparisonNetOutputMW
            / targetNetOutputMW
            * 100.0
        )
    }

    var targetStatus: String {

        guard isRunning else {
            return "Paused"
        }

        if qrtlFieldCollectionEnabled {
            return qrtlNetOutputMW >= targetNetOutputMW
                ? "QRTL modeled net output reaches target"
                : "QRTL modeled net output is below target"
        }

        if !isACDriveActive {
            return
                "Static field: flux is present, but dΦ/dt and Faraday output are zero."
        }

        return conventionalNetOutputMW >= targetNetOutputMW
            ? "Conventional model reaches target"
            : "Conventional model is below target"
    }

    // ============================================================
    // MARK: - Reset
    // ============================================================

    func reset() {

        targetNetOutputMW = 0.020

        fieldDriveMode = .dcHold
        fieldFrequencyKHz = 0.0
        resonantDriveEnabled = false
        resonatorQualityFactor = 200.0
        fieldDutyCycle = 0.10
        acResistanceMultiplier = 1.0

        maximumFieldInputWatts = 20_000.0
        fieldPowerDesignMargin = 0.90

        switchingAndCoreLossWatts = 500.0
        fieldAuxiliaryPowerWatts = 500.0
        coolingPowerWatts = 500.0
        auxiliaryPowerWatts = 1_000.0
        powerElectronicsEfficiency = 0.94

        primaryTurns = 2_000.0
        primaryCurrentA = 250.0
        primaryRadiusM = 20.0
        primaryResistanceOhms = 0.005

        upperShapingEnabled = true
        upperTurns = 800.0
        upperCurrentA = 80.0
        upperRadiusM = 16.0
        upperResistanceOhms = 0.010
        upperHeightM = 25.0
        upperPhaseDegrees = 0.0

        lowerReturnEnabled = true
        lowerTurns = 800.0
        lowerCurrentA = 80.0
        lowerRadiusM = 16.0
        lowerResistanceOhms = 0.010
        lowerHeightM = -25.0
        lowerPhaseDegrees = 180.0

        fluxManagementGain = 1.0
        couplingAlignmentFactor = 1.0

        couplingAltitudeKm = 20.0
        couplingRadiusKm = 1.0

        receiverTurns = 5_000.0
        receiverResistanceOhms = 0.10

        collectorAreaAcres = 10.0
        collectorConductivitySPerM = 5.8e7
        collectorThicknessM = 0.010
        radialSpokeCount = 32.0
        radialSpokeWidthM = 0.05

        collectorInductanceH = 0.001
        collectorCapacitanceF = 1.0e-6
        includeACImpedance = true

        sourceResistanceOhms = 0.10
        groundReturnResistanceOhms = 0.10
        radiationResistanceOhms = 0.001
        loadResistanceOhms = 100.0

        contactEfficiency = 0.98
        conversionEfficiency = 0.95

        fieldAlignedCurrentA = 1.0e19
        fieldCurrentCaptureEfficiency = 0.01
        fieldCollectionVoltageV = 1.1e-10
        qrtlFieldCollectionEnabled = true

        isRunning = true
    }
}
