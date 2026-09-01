import Foundation
import SwiftUI
import Combine

final class RecirculationPipeline: ObservableObject {

    // ============================================================
    // MARK: - Machine State
    // ============================================================

    @Published var machineRunning: Bool = true

    /// User-requested peak dipole current.
    ///
    /// Use `limitedDipoleCurrentAmps` in all physics calculations
    /// so the model remains within the field-system power budget.
    @Published var dipoleCurrentAmps: Double =
        PhysicsConstants.dipoleCurrentAmps

    @Published var coilResistanceOhms: Double =
        PhysicsConstants.coilResistanceOhms

    @Published var powerElectronicsEfficiency: Double =
        PhysicsConstants.powerElectronicsEfficiency

    @Published var receiverTurns: Double =
        PhysicsConstants.receiverTurns

    @Published var receiverResistanceOhms: Double =
        PhysicsConstants.receiverResistanceOhms

    @Published var resonantDriveEnabled: Bool = false

    @Published var resonatorQualityFactor: Double =
        PhysicsConstants.resonatorQualityFactor

    @Published var fluxUtilization: Double =
        PhysicsConstants.fluxUtilization

    /// Hypothetical QRTL coupling. This remains separate from
    /// conventional electromagnetic input/output accounting.
    @Published var qrtlHypothesisCoupling: Double =
        PhysicsConstants.qrtlHypothesisCoupling

    // ============================================================
    // MARK: - Field Drive Configuration
    // ============================================================

    /// Set to `.dcHold` for a static dipole field.
    ///
    /// `resonantAC` is the only mode that computes conventional
    /// flux-change induction in this simplified model.
    @Published var fieldDriveMode: FieldDriveMode = .dcHold

    /// Used only in `.pulsed` mode.
    ///
    /// 0.0 = coil never energized.
    /// 1.0 = coil continuously energized.
    @Published var fieldDutyCycle: Double = 0.10

    /// Used only in `.resonantAC` mode.
    ///
    /// Values above 1.0 model increased AC copper loss.
    @Published var acResistanceMultiplier: Double = 1.0

    /// Cooling, protection, controller, monitoring, switching
    /// support, and other non-winding field-system consumption.
    @Published var fieldAuxiliaryPowerWatts: Double = 500.0

    /// Absolute wall-input limit for the field system.
    @Published var maximumFieldInputWatts: Double = 20_000.0

    /// Nominal operating target below the hard cap.
    ///
    /// 0.90 means target 18 kW with a 20 kW absolute limit.
    @Published var fieldPowerDesignMargin: Double = 0.90

    // ============================================================
    // MARK: - QRTL Downward Current Model
    // ============================================================

    /// Enables a separately labeled hypothesis-driven current flow.
    @Published var qrtlCurrentSourceEnabled: Bool = true

    /// Positive requested magnitude in amperes.
    ///
    /// The actual field-aligned conventional-current sign is
    /// negative for downward ionosphere-to-ground flow.
    @Published var qrtlDownwardCurrentMagnitudeAmps: Double = 0.0

    /// Hypothetical potential difference used only to report:
    ///
    /// P_QRTL = |V_QRTL × I_QRTL|
    @Published var qrtlFieldAlignedPotentialVolts: Double = 0.0

    // ============================================================
    // MARK: - Visualization Controls
    // ============================================================

    /// Visualization-only scaling for long-distance field lines.
    ///
    /// Do not use this property in force, flux, current, voltage,
    /// power, or energy calculations.
    @Published var visualFieldLineScale: Double = 1.0e14

    /// If true, SceneKit may draw a line/path from the ground
    /// dipole toward the modeled 100 km ionosphere boundary.
    ///
    /// This represents a QRTL geometry visualization, not a claim
    /// that the ground coil dominates Earth's natural field there.
    @Published var showIonosphericFieldLineVisualization: Bool = true

    // ============================================================
    // MARK: - Drive Mode Helpers
    // ============================================================

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

    var targetFieldInputWatts: Double {

        let maximumInput = max(
            0.0,
            maximumFieldInputWatts
        )

        let margin = max(
            0.0,
            min(
                1.0,
                fieldPowerDesignMargin
            )
        )

        return maximumInput * margin
    }

    var effectiveCoilResistanceOhms: Double {

        let dcResistance = max(
            0.0,
            coilResistanceOhms
        )

        switch fieldDriveMode {
   
        case .resonantAC:
            return dcResistance
                * max(
                    1.0,
                    acResistanceMultiplier
                )

        case .dcHold,
             .pulsed:
            return dcResistance
        }
    }

    // ============================================================
    // MARK: - Coil Geometry
    // ============================================================

    var coilRadiusMeters: Double {
        PhysicsConstants.dipoleCoilRadiusMeters
    }

    var coilAreaSquareMeters: Double {
        PhysicsConstants.dipoleCoilAreaSquareMeters
    }

    var coilTurns: Double {
        PhysicsConstants.dipoleTurns
    }

    // ============================================================
    // MARK: - Inductance / Stored Energy
    // ============================================================

    /// Approximate circular-winding inductance.
    ///
    /// Replace the wire-radius assumption with actual winding
    /// geometry for an engineering-grade design.
    var estimatedInductanceHenries: Double {

        let radius = coilRadiusMeters
        let turns = coilTurns
        let wireRadiusMeters = 0.01

        guard
            radius > 0.0,
            turns > 0.0,
            wireRadiusMeters > 0.0
        else {
            return 0.0
        }

        let logarithmicTerm =
            log(
                (8.0 * radius)
                / wireRadiusMeters
            )
            - 2.0

        guard logarithmicTerm > 0.0 else {
            return 0.0
        }

        return
            PhysicsConstants.vacuumPermeability
            * turns
            * turns
            * radius
            * logarithmicTerm
    }

    // ============================================================
    // MARK: - Field Loss Coefficients
    // ============================================================

    var switchingAndCoreLossWatts: Double {

        guard machineRunning else {
            return 0.0
        }

        return
            PhysicsConstants.switchingAndCoreLossMW
            * 1_000_000.0
    }

    var fixedFieldLossWatts: Double {

        switchingAndCoreLossWatts
            + max(
                0.0,
                fieldAuxiliaryPowerWatts
            )
    }

    /// Coefficient C in:
    ///
    /// P_variable = C × I_peak²
    ///
    /// Units: W/A².
    var currentSquaredFieldLossCoefficient: Double {

        let copperCoefficient: Double

        switch fieldDriveMode {
        case .dcHold:
            copperCoefficient =
                effectiveCoilResistanceOhms

        case .pulsed:
            copperCoefficient =
                effectiveCoilResistanceOhms
                * effectiveFieldDutyCycle

        case .resonantAC:
            /// I_RMS² = I_peak² / 2
            copperCoefficient =
                effectiveCoilResistanceOhms
                * 0.5

        }

        let resonatorCoefficient: Double

        if
            fieldDriveMode == .resonantAC,
            resonantDriveEnabled,
            resonatorQualityFactor > 0.0
        {
            /// P = ω × (1/2 L I_peak²) / Q
            resonatorCoefficient =
                angularFrequency
                * 0.5
                * estimatedInductanceHenries
                / resonatorQualityFactor
        } else {
            resonatorCoefficient = 0.0
        }

        return
            copperCoefficient
            + resonatorCoefficient
    }

    /// Maximum peak dipole current permitted under the configured
    /// target wall-input power budget.
    ///
    /// P_wall = (P_fixed + C × I²) / η
    var maximumAllowedDipoleCurrentAmps: Double {

        guard
            machineRunning,
            powerElectronicsEfficiency > 0.0
        else {
            return 0.0
        }

        let availableInternalLossBudget =
            targetFieldInputWatts
            * powerElectronicsEfficiency
            - fixedFieldLossWatts

        let coefficient =
            currentSquaredFieldLossCoefficient

        guard availableInternalLossBudget > 0.0 else {
            return 0.0
        }

        /// Idealized persistent-current mode has no I²R limiter.
        /// Actual engineering limits must still be imposed outside
        /// this power-only model.
        guard coefficient > 1.0e-15 else {
            return Double.greatestFiniteMagnitude
        }

        return sqrt(
            availableInternalLossBudget
            / coefficient
        )
    }

    /// Current used by all field calculations.
    var limitedDipoleCurrentAmps: Double {

        min(
            max(
                0.0,
                dipoleCurrentAmps
            ),
            maximumAllowedDipoleCurrentAmps
        )
    }

    var limitedDipoleCurrentKA: Double {

        limitedDipoleCurrentAmps
            / 1_000.0
    }

    var maximumAllowedDipoleCurrentKA: Double {

        maximumAllowedDipoleCurrentAmps
            / 1_000.0
    }

    var isFieldPowerLimited: Bool {

        dipoleCurrentAmps
            > maximumAllowedDipoleCurrentAmps
    }

  
    var coilRMSCurrentAmps: Double {

        switch fieldDriveMode {
        case .resonantAC:
            return limitedDipoleCurrentAmps
                / sqrt(2.0)

        case .dcHold,
             .pulsed:
            return limitedDipoleCurrentAmps
        }
    }
    /// Average resistive winding loss.
    ///
    /// P = I_RMS² × R_effective × dutyCycle
    var copperLossWatts: Double {

        coilRMSCurrentAmps
            * coilRMSCurrentAmps
            * effectiveCoilResistanceOhms
            * effectiveFieldDutyCycle
    }

    var copperLossMW: Double {

        copperLossWatts
            / 1_000_000.0
    }

    /// Stored field energy:
    ///
    /// E = 1/2 × L × I²
    ///
    /// This is not a continuous maintenance cost.
    var estimatedStoredMagneticEnergyJoules: Double {

        0.5
            * estimatedInductanceHenries
            * limitedDipoleCurrentAmps
            * limitedDipoleCurrentAmps
    }

    /// Resonator loss only exists during deliberate AC operation.
    ///
    /// P_loss = ωE/Q
    var resonatorMaintenanceLossWatts: Double {

        guard
            machineRunning,
            fieldDriveMode == .resonantAC,
            resonantDriveEnabled,
            resonatorQualityFactor > 0.0
        else {
            return 0.0
        }

        return
            angularFrequency
            * estimatedStoredMagneticEnergyJoules
            / resonatorQualityFactor
    }

    var resonatorMaintenanceLossMW: Double {

        resonatorMaintenanceLossWatts
            / 1_000_000.0
    }

    // ============================================================
    // MARK: - Field System Power
    // ============================================================

    var totalFieldLossesWatts: Double {

        guard machineRunning else {
            return 0.0
        }

        return
            copperLossWatts
            + resonatorMaintenanceLossWatts
            + switchingAndCoreLossWatts
            + max(
                0.0,
                fieldAuxiliaryPowerWatts
            )
    }

    /// Wall-plug power consumed by the field system:
    ///
    /// P_input = P_losses / efficiency
    var fieldSystemInputWatts: Double {

        guard
            machineRunning,
            powerElectronicsEfficiency > 0.0
        else {
            return 0.0
        }

        return
            totalFieldLossesWatts
            / powerElectronicsEfficiency
    }

    var fieldSystemInputKW: Double {

        fieldSystemInputWatts
            / 1_000.0
    }

    var fieldSystemInputMW: Double {

        fieldSystemInputWatts
            / 1_000_000.0
    }

    var totalFieldLossesMW: Double {

        totalFieldLossesWatts
            / 1_000_000.0
    }

    var isWithinMaximumFieldPowerBudget: Bool {

        fieldSystemInputWatts
            <= maximumFieldInputWatts
    }

    // ============================================================
    // MARK: - Field System Breakdown
    // ============================================================

    var switchingAndCoreLossMW: Double {

        switchingAndCoreLossWatts
            / 1_000_000.0
    }

    var fieldGeneratorCopperInputMW: Double {

        copperLossMW
    }

    var fieldGeneratorSwitchingCoreInputMW: Double {

        switchingAndCoreLossMW
    }

    var fieldGeneratorResonatorInputMW: Double {

        resonatorMaintenanceLossMW
    }

    var fieldGeneratorAuxiliaryInputMW: Double {

        max(
            0.0,
            fieldAuxiliaryPowerWatts
        )
        / 1_000_000.0
    }

    // ============================================================
    // MARK: - Magnetic Moment
    // ============================================================

    /// m = N × I × A
    var magneticMoment: Double {

        coilTurns
            * limitedDipoleCurrentAmps
            * coilAreaSquareMeters
    }

    /// Compatibility property for existing ContentView code.
    var dipoleMoment: Double {
        magneticMoment
    }

    // ============================================================
    // MARK: - Geometry
    // ============================================================

    /// Distance from the dipole to the modeled coupling region.
    var apexRadius: Double {
        PhysicsConstants.couplingDistanceMeters
    }

    /// Modeled ionospheric altitude.
    var ionosphereAltitude: Double {
        PhysicsConstants.ionosphereAltitude
    }

    // ============================================================
    // MARK: - Magnetic Field
    // ============================================================

    /// On-axis dipole field:
    ///
    /// B = μ₀/(4π) × 2m/r³
    func axialDipoleFieldTesla(
        distanceMeters: Double
    ) -> Double {

        guard
            machineRunning,
            distanceMeters > 0.0
        else {
            return 0.0
        }

        return
            (
                PhysicsConstants.vacuumPermeability
                / (4.0 * Double.pi)
            )
            *
            (
                2.0
                * magneticMoment
                / pow(
                    distanceMeters,
                    3.0
                )
            )
    }

    var apexFieldMagnitude: Double {

        axialDipoleFieldTesla(
            distanceMeters: apexRadius
        )
    }

    var ionosphereFieldMagnitude: Double {

        axialDipoleFieldTesla(
            distanceMeters: ionosphereAltitude
        )
    }

    /// Compatibility property for previous ContentView code.
    var magneticFieldAtIonosphereTesla: Double {

        ionosphereFieldMagnitude
    }

    // ============================================================
    // MARK: - Ionospheric Field Diagnostics
    // ============================================================

    var ionosphereFieldNanotesla: Double {

        ionosphereFieldMagnitude
            * 1.0e9
    }

    var ionosphereFieldPicotesla: Double {

        ionosphereFieldMagnitude
            * 1.0e12
    }

    /// Order-of-magnitude reference only.
    ///
    /// Replace with a position/date-dependent geomagnetic model,
    /// such as IGRF/WMM, if you later add geographic coordinates.
    var earthBackgroundFieldNanotesla: Double {

        50_000.0
    }

    /// Coil field divided by reference Earth background field.
    var ionosphericFieldToEarthFieldRatio: Double {

        guard earthBackgroundFieldNanotesla > 0.0 else {
            return 0.0
        }

        return
            ionosphereFieldNanotesla
            / earthBackgroundFieldNanotesla
    }

    /// Model description appropriate for UI status text.
    var ionosphereCouplingAssessment: String {

        let ratio =
            ionosphericFieldToEarthFieldRatio

        switch ratio {
        case 1.0...:
            return "Modeled coil field is comparable to or exceeds the Earth-field reference."

        case 0.01..<1.0:
            return "Modeled coil field is a significant local perturbation in this simulation."

        case 1.0e-6..<0.01:
            return "Modeled coil field reaches the boundary but is weak relative to Earth background."

        default:
            return "Field is nonzero at 100 km mathematically, but negligible relative to Earth background."
        }
    }

    /// Display-only value for field-line visibility in a 3D scene.
    ///
    /// This must never be used for physical calculations.
    var visualIonosphereFieldStrength: Double {

        ionosphereFieldMagnitude
            * max(
                0.0,
                visualFieldLineScale
            )
    }

    // ============================================================
    // MARK: - Mirror Ratio
    // ============================================================

    /// Rm = B_ionosphere / B_apex
    var mirrorRatio: Double {

        guard apexFieldMagnitude > 0.0 else {
            return 0.0
        }

        return
            ionosphereFieldMagnitude
            / apexFieldMagnitude
    }

    // ============================================================
    // MARK: - Flux / Induction
    // ============================================================

    var couplingAreaSquareMeters: Double {

        coilAreaSquareMeters
    }

    var effectiveFluxUtilization: Double {

        max(
            0.0,
            min(
                1.0,
                fluxUtilization
            )
        )
    }

    /// Φ = B × A × utilization
    var magneticFluxWebers: Double {

        ionosphereFieldMagnitude
            * couplingAreaSquareMeters
            * effectiveFluxUtilization
    }

    /// AC frequency is active only in resonant mode.
    var frequencyHz: Double {

        guard fieldDriveMode == .resonantAC else {
            return 0.0
        }

        return max(
            0.0,
            PhysicsConstants.resonatorFrequencyHz
        )
    }

    /// ω = 2πf
    var angularFrequency: Double {

        2.0
            * Double.pi
            * frequencyHz
    }

    /// |dΦ/dt| = Φω for modeled sinusoidal flux.
    ///
    /// A held DC dipole has no continuous changing flux.
    var changingFluxWebersPerSecond: Double {

        guard fieldDriveMode == .resonantAC else {
            return 0.0
        }

        return
            magneticFluxWebers
            * angularFrequency
    }

    /// |V| = N × |dΦ/dt|
    var inducedVoltageVolts: Double {

        guard
            machineRunning,
            fieldDriveMode == .resonantAC
        else {
            return 0.0
        }

        return
            receiverTurns
            * changingFluxWebersPerSecond
    }

    var receiverCurrentAmps: Double {

        guard
            machineRunning,
            receiverResistanceOhms > 0.0
        else {
            return 0.0
        }

        return
            inducedVoltageVolts
            / receiverResistanceOhms
    }

    var collectorCurrentAmps: Double {

        receiverCurrentAmps
    }

    // ============================================================
    // MARK: - Conventional Receiver Accounting
    // ============================================================

    /// P = V × I
    ///
    /// In the present one-resistor receiver model, this equals
    /// `collectorResistanceLossWatts`.
    var conventionalCapturedPowerWatts: Double {

        inducedVoltageVolts
            * receiverCurrentAmps
    }

    var conventionalCapturedPowerMW: Double {

        conventionalCapturedPowerWatts
            / 1_000_000.0
    }

    /// P_loss = I²R
    ///
    /// This is the same energy as `conventionalCapturedPowerWatts`
    /// in the current one-resistor receiver model.
    var collectorResistanceLossWatts: Double {

        collectorCurrentAmps
            * collectorCurrentAmps
            * receiverResistanceOhms
    }

    var collectorResistanceLossMW: Double {

        collectorResistanceLossWatts
            / 1_000_000.0
    }

    /// A single-resistor receiver has no separately modeled useful
    /// load. Add separate winding and load resistances if needed.
    var usefulReceiverOutputWatts: Double {

        0.0
    }

    // ============================================================
    // MARK: - QRTL Field-Aligned Current
    // ============================================================

    /// Sign convention:
    ///
    /// Positive: conventional current ground → ionosphere.
    /// Negative: conventional current ionosphere → ground.
    ///
    /// This is a hypothesis-model current. It is not created by
    /// Faraday induction in DC Hold mode.
    var qrtlDownwardFieldAlignedCurrentAmps: Double {

        guard
            machineRunning,
            qrtlCurrentSourceEnabled
        else {
            return 0.0
        }

        let coupling = max(
            0.0,
            qrtlHypothesisCoupling
        )

        let magnitude = max(
            0.0,
            qrtlDownwardCurrentMagnitudeAmps
        )

        return -magnitude * coupling
    }

    /// Compatibility name for a field-aligned-current display.
    var facCurrent: Double {

        qrtlDownwardFieldAlignedCurrentAmps
    }

    /// Modeled return path for charge conservation.
    var closureCurrent: Double {

        -facCurrent
    }

    /// 1.0 means equal-magnitude FAC and return current.
    var recirculationConsistency: Double {

        let fieldAlignedMagnitude =
            abs(
                facCurrent
            )

        guard fieldAlignedMagnitude > 1.0e-12 else {
            return 0.0
        }

        return
            abs(
                closureCurrent
            )
            / fieldAlignedMagnitude
    }

    /// Separate hypothesis-only quantity:
    ///
    /// P = |V × I|
    ///
    /// It requires a defined energy reservoir before it can be
    /// interpreted as extractable physical power.
    var qrtlFieldAlignedPowerWatts: Double {

        abs(
            qrtlDownwardFieldAlignedCurrentAmps
            * qrtlFieldAlignedPotentialVolts
        )
    }

    var qrtlFieldAlignedPowerMW: Double {

        qrtlFieldAlignedPowerWatts
            / 1_000_000.0
    }

    /// Compatibility name used by previous UI code.
    var qrtlHypothesisPowerMW: Double {

        qrtlFieldAlignedPowerMW
    }

    // ============================================================
    // MARK: - Net Accounting
    // ============================================================

    var netConventionalPowerMW: Double {

        conventionalCapturedPowerMW
            - collectorResistanceLossMW
            - fieldSystemInputMW
    }

    /// A hypothesis-inclusive display quantity only.
    ///
    /// This must not be presented as conventional net generation.
    var netQRTLModeledPowerMW: Double {

        netConventionalPowerMW
            + qrtlHypothesisPowerMW
    }

    var totalMachineInputMW: Double {

        fieldSystemInputMW
    }

    var totalMachineInputKW: Double {

        fieldSystemInputKW
    }

    var totalCapturedPowerMW: Double {

        conventionalCapturedPowerMW
    }

    var totalCollectorLossMW: Double {

        collectorResistanceLossMW
    }

    // ============================================================
    // MARK: - Reset
    // ============================================================

    func reset() {

        machineRunning = true

        dipoleCurrentAmps =
            PhysicsConstants.dipoleCurrentAmps

        coilResistanceOhms =
            PhysicsConstants.coilResistanceOhms

        powerElectronicsEfficiency =
            PhysicsConstants.powerElectronicsEfficiency

        receiverTurns =
            PhysicsConstants.receiverTurns

        receiverResistanceOhms =
            PhysicsConstants.receiverResistanceOhms

        resonantDriveEnabled = false

        resonatorQualityFactor =
            PhysicsConstants.resonatorQualityFactor

        fluxUtilization =
            PhysicsConstants.fluxUtilization

        qrtlHypothesisCoupling =
            PhysicsConstants.qrtlHypothesisCoupling

        fieldDriveMode = .dcHold

        fieldDutyCycle = 0.10

        acResistanceMultiplier = 1.0

        fieldAuxiliaryPowerWatts = 500.0

        maximumFieldInputWatts = 20_000.0

        fieldPowerDesignMargin = 0.90

        qrtlCurrentSourceEnabled = true

        qrtlDownwardCurrentMagnitudeAmps = 0.0

        qrtlFieldAlignedPotentialVolts = 0.0

        visualFieldLineScale = 1.0e14

        showIonosphericFieldLineVisualization = true
    }
}
