
import SwiftUI
import SceneKit

struct ContentView: View {

    @StateObject private var model = QRTLDipoleModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    titleSection

                    sceneSection

                    outputSection

                    multiCoilSection

                    fieldFluxSection

                    voltageSection

                    resonanceSection

                    circuitSection

                    collectorSection

                    lossesSection


                    controlsSection

                    equationSection

                    limitationSection
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("QRTL Dipole Energy System")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Multi-coil magnetic-field and induction model")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .panelStyle()
    }

    // MARK: - Scene

    private var sceneSection: some View {
        VStack(spacing: 12) {

            QRTLSceneView(
                running: model.isRunning,

                primaryTurns: model.primaryTurns,
                primaryCurrentA: model.primaryCurrentA,
                primaryRadiusM: model.primaryRadiusM,

                upperEnabled: model.upperShapingEnabled,
                upperTurns: model.upperTurns,
                upperCurrentA: model.upperCurrentA,
                upperRadiusM: model.upperRadiusM,
                upperHeightM: model.upperHeightM,
                upperPhaseDegrees: model.upperPhaseDegrees,

                lowerEnabled: model.lowerReturnEnabled,
                lowerTurns: model.lowerTurns,
                lowerCurrentA: model.lowerCurrentA,
                lowerRadiusM: model.lowerRadiusM,
                lowerHeightM: model.lowerHeightM,
                lowerPhaseDegrees: model.lowerPhaseDegrees,

                fieldFrequencyKHz: model.fieldFrequencyKHz,
                couplingAltitudeKm: model.couplingAltitudeKm,
                couplingRadiusKm: model.couplingRadiusKm,
                radialSpokeCount: Int(model.radialSpokeCount),
                fluxManagementGain: model.fluxManagementGain
            )
            .frame(height: 520)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )

            VStack(spacing: 4) {
                Text("3D MULTI-COIL MODEL")
                Text("↓")
                Text("LOW-LOSS EXCITATION")
                Text("↓")
                Text("PRIMARY + SHAPING COILS")
                Text("↓")
                Text("COMBINED DIPOLE FIELD")
                Text("↓")
                Text("COUPLING FLUX Φ")
                Text("↓")
                Text("FARADAY EMF")
                Text("↓")
                Text("COLLECTOR / LOAD")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .panelStyle()
    }

    // MARK: - Output


    private var outputSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("CONVENTIONAL OUTPUT")

            OutputValue(
                title: "Load",
                value: PowerFormatter.string(
                    megawatts: model.conventionalLoadElectricalPowerMW
                )
            )

            OutputValue(
                title: "Gross",
                value: PowerFormatter.string(
                    megawatts: model.conventionalGrossOutputMW
                )
            )

            OutputValue(
                title: "Power Gathered",
                value: PowerFormatter.string(
                    megawatts: model.conventionalCapturedPowerMW
                )
            )

            OutputValue(
                title: "Net",
                value: PowerFormatter.string(
                    megawatts: model.conventionalNetOutputMW
                )
            )

            // MARK: - Energy Cost Breakdown

            VStack(alignment: .leading, spacing: 8) {

                Text("ENERGY COST BREAKDOWN")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                MetricRow(
                    title: "Copper Loss",
                    value: PowerFormatter.string(
                        megawatts: model.totalCopperLossMW
                    )
                )

                MetricRow(
                    title: "Switching & Core Loss",
                    value: PowerFormatter.string(
                        megawatts: model.switchingAndCoreLossMW
                    )
                )

                MetricRow(
                    title: "Resonator Loss",
                    value: PowerFormatter.string(
                        megawatts: model.resonatorMaintenanceLossMW
                    )
                )

                MetricRow(
                    title: "Power Electronics Loss",
                    value: PowerFormatter.string(
                        megawatts:
                            max(
                                0.0,
                                model.fieldSystemInputMW
                                -
                                (
                                    model.totalCopperLossMW
                                    +
                                    model.switchingAndCoreLossMW
                                    +
                                    model.resonatorMaintenanceLossMW
                                )
                                /
                                max(
                                    model.powerElectronicsEfficiency,
                                    0.000001
                                )
                                *
                                (
                                    1.0
                                    -
                                    model.powerElectronicsEfficiency
                                )
                            )
                    )
                )

                Divider()

                MetricRow(
                    title: "Cooling",
                    value: PowerFormatter.string(
                        megawatts: model.coolingPowerMW
                    )
                )

                MetricRow(
                    title: "Auxiliary",
                    value: PowerFormatter.string(
                        megawatts: model.auxiliaryPowerMW
                    )
                )

                Divider()

                MetricRow(
                    title: "Field-System Input",
                    value: PowerFormatter.string(
                        megawatts: model.fieldSystemInputMW
                    )
                )

                MetricRow(
                    title: "Total Operating Costs",
                    value: PowerFormatter.string(
                        megawatts:
                            model.fieldSystemInputMW
                            + model.coolingPowerMW
                            + model.auxiliaryPowerMW
                    )
                )
            }
            .padding(.top, 4)

            ProgressView(
                value: min(
                    max(model.targetPercent / 100.0, 0.0),
                    1.0
                )
            )

            Text(model.targetStatus)
                .font(.caption)
                .foregroundStyle(
                    targetReached
                        ? .green
                        : .secondary
                )

            Divider()

            MetricRow(
                title: "Circuit Current",
                value: String(
                    format: "%.3f A",
                    model.machineCurrentRMSA
                )
            )

            MetricRow(
                title: "Power Gathered",
                value: PowerFormatter.string(
                    megawatts:
                        model.conventionalCapturedPowerMW
                )
            )

            MetricRow(
                title: "Collector Current",
                value: String(
                    format: "%.3f A",
                    model.collectorCurrentA
                )
            )
        }
        .panelStyle()
    }


    private var targetReached: Bool {
        model.isRunning
            && model.frequencyHz > 0
            && model.conventionalNetOutputMW
                >= model.targetNetOutputMW
    }

    // MARK: - Multi Coil

    private var multiCoilSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("MULTI-COIL SYSTEM")

            CoilMetricRow(
                title: "Primary",
                turns: model.primaryTurns,
                current: model.coilPeakCurrentA(
                    model.primaryCoil
                ),
                radius: model.primaryRadiusM,
                moment: model.primaryCoil.magneticMomentAm2(
                    scale: model.coilPowerScale
                ),
                copperLoss: model.primaryCopperLossMW
            )

            CoilMetricRow(
                title: "Upper Shaping",
                turns: model.upperTurns,
                current: model.coilPeakCurrentA(
                    model.upperCoil
                ),
                radius: model.upperRadiusM,
                moment: model.upperCoil.magneticMomentAm2(
                    scale: model.coilPowerScale
                ),
                copperLoss: model.upperCopperLossMW
            )

            CoilMetricRow(
                title: "Lower Return",
                turns: model.lowerTurns,
                current: model.coilPeakCurrentA(
                    model.lowerCoil
                ),
                radius: model.lowerRadiusM,
                moment: model.lowerCoil.magneticMomentAm2(
                    scale: model.coilPowerScale
                ),
                copperLoss: model.lowerCopperLossMW
            )

            Divider()

            MetricRow(
                title: "Coil Power Scale",
                value: String(
                    format: "%.2f%%",
                    model.coilPowerScale * 100.0
                )
            )

            MetricRow(
                title: "Total Ampere-Turns",
                value: String(
                    format: "%.3e A-turns",
                    model.totalAmpereTurns
                )
            )

            MetricRow(
                title: "Total Copper Loss",
                value: PowerFormatter.string(
                    megawatts: model.totalCopperLossMW
                )
            )

            MetricRow(
                title: "Flux Management Gain",
                value: String(
                    format: "%.3f×",
                    model.fluxManagementGain
                )
            )

            MetricRow(
                title: "Coupling Alignment",
                value: String(
                    format: "%.1f%%",
                    model.couplingAlignmentFactor * 100.0
                )
            )

            if model.isFieldPowerLimited {
                Text(
                    "Coil currents are reduced automatically to remain within the configured field-power budget."
                )
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
        .panelStyle()
    }
    // MARK: - Field / Flux

    private var fieldFluxSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("FIELD & FLUX")

            MetricRow(
                title: "Coupling Altitude",
                value: String(
                    format: "%.3f km",
                    model.couplingAltitudeKm
                )
            )

            MetricRow(
                title: "Coupling Radius",
                value: String(
                    format: "%.3f km",
                    model.couplingRadiusKm
                )
            )

            MetricRow(
                title: "Coupling Disk Area",
                value: String(
                    format: "%.3e m²",
                    model.couplingSurfaceAreaM2
                )
            )

            MetricRow(
                title: "Field at Coupling Center",
                value: String(
                    format: "%.6e T",
                    model.fieldAtCouplingCenterTesla
                )
            )

            MetricRow(
                title: "Peak Integrated Flux",
                value: String(
                    format: "%.6e Wb",
                    model.peakMagneticFluxWebers
                )
            )

            MetricRow(
                title: "Peak dΦ/dt",
                value: String(
                    format: "%.6e Wb/s",
                    model.peakFluxChangeRateWebersPerSecond
                )
            )
        }
        .panelStyle()
    }

    // MARK: - Voltage

    private var voltageSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("INDUCED VOLTAGE")

            MetricRow(
                title: "Frequency",
                value: String(
                    format: "%.3f kHz",
                    model.fieldFrequencyKHz
                )
            )

            MetricRow(
                title: "Receiver Turns",
                value: String(
                    format: "%.0f",
                    model.receiverTurns
                )
            )

            MetricRow(
                title: "Peak dΦ/dt",
                value: String(
                    format: "%.6e Wb/s",
                    model.peakFluxChangeRateWebersPerSecond
                )
            )

            MetricRow(
                title: "Peak Induced EMF",
                value: String(
                    format: "%.6e V",
                    model.inducedVoltagePeakV
                )
            )

            MetricRow(
                title: "RMS Source Voltage",
                value: String(
                    format: "%.6e V",
                    model.inducedVoltageRMS
                )
            )
        }
        .panelStyle()
    }

    // MARK: - Resonance

    private var resonanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("RESONANCE")

            Toggle(
                "Resonant Drive Enabled",
                isOn: $model.resonantDriveEnabled
            )

            MetricRow(
                title: "Total Inductance",
                value: String(
                    format: "%.6e H",
                    model.totalEstimatedInductanceH
                )
            )

            MetricRow(
                title: "Required Capacitance",
                value: model.requiredResonantCapacitanceF.isFinite
                    ? String(
                        format: "%.6e F",
                        model.requiredResonantCapacitanceF
                    )
                    : "∞"
            )

            MetricRow(
                title: "Stored Magnetic Energy",
                value: String(
                    format: "%.6e J",
                    model.totalStoredMagneticEnergyJ
                )
            )

            MetricRow(
                title: "Quality Factor",
                value: String(
                    format: "%.1f",
                    model.resonatorQualityFactor
                )
            )

            MetricRow(
                title: "Maintenance Loss",
                value: PowerFormatter.string(
                    megawatts:
                        model.resonatorMaintenanceLossMW
                )
            )

            Text(
                "The resonator model estimates the maintenance power associated with stored magnetic energy and the specified quality factor."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }

    // MARK: - Circuit

    private var circuitSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("COLLECTOR CIRCUIT")

            MetricRow(
                title: "RMS Source Voltage",
                value: String(
                    format: "%.6e V",
                    model.inducedVoltageRMS
                )
            )

            MetricRow(
                title: "Receiver Resistance",
                value: String(
                    format: "%.6f Ω",
                    model.receiverResistanceOhms
                )
            )

            MetricRow(
                title: "Collector Resistance",
                value: String(
                    format: "%.6f Ω",
                    model.collectorResistanceOhms
                )
            )

            MetricRow(
                title: "Inductive Reactance",
                value: String(
                    format: "%.6f Ω",
                    model.collectorInductiveReactanceOhms
                )
            )

            MetricRow(
                title: "Capacitive Reactance",
                value: String(
                    format: "%.6f Ω",
                    model.collectorCapacitiveReactanceOhms
                )
            )

            MetricRow(
                title: "Total Resistance",
                value: String(
                    format: "%.6f Ω",
                    model.totalCircuitResistanceOhms
                )
            )

            MetricRow(
                title: "Total Reactance",
                value: String(
                    format: "%.6f Ω",
                    model.totalCircuitReactanceOhms
                )
            )

            MetricRow(
                title: "|Z|",
                value: String(
                    format: "%.6f Ω",
                    model.totalCircuitImpedanceMagnitudeOhms
                )
            )

            MetricRow(
                title: "Circuit Current",
                value: String(
                    format: "%.6f A",
                    model.machineCurrentRMSA
                )
            )
        }
        .panelStyle()
    }

    // MARK: - Collector

    private var collectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("COLLECTOR")

            MetricRow(
                title: "Collector Current",
                value: String(
                    format: "%.6f A",
                    model.collectorCurrentA
                )
            )

            MetricRow(
                title: "Footprint",
                value: String(
                    format: "%.3f acres",
                    model.collectorAreaAcres
                )
            )

            MetricRow(
                title: "Equivalent Radius",
                value: String(
                    format: "%.3f m",
                    model.collectorRadiusM
                )
            )

            MetricRow(
                title: "Radial Spokes",
                value: String(
                    format: "%.0f",
                    model.radialSpokeCount
                )
            )

            MetricRow(
                title: "DC Resistance",
                value: String(
                    format: "%.6e Ω",
                    model.collectorDCResistanceOhms
                )
            )

            MetricRow(
                title: "AC Resistance",
                value: String(
                    format: "%.6e Ω",
                    model.collectorACResistanceOhms
                )
            )

            MetricRow(
                title: "Skin Depth",
                value: model.skinDepthM.isFinite
                    ? String(
                        format: "%.6e m",
                        model.skinDepthM
                    )
                    : "∞"
            )

          }
        .panelStyle()
    }

    // MARK: - Losses

    private var lossesSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("POWER BALANCE & LOSSES")

            MetricRow(
                title: "Field-System Input",
                value: PowerFormatter.string(
                    megawatts:
                        model.fieldSystemInputMW
                )
            )

            MetricRow(
                title: "Load Electrical Power",
                value: PowerFormatter.string(
                    megawatts:
                        model.conventionalLoadElectricalPowerMW
                )
            )

            Divider()

            MetricRow(
                title: "Gross Usable Output",
                value: PowerFormatter.string(
                    megawatts:
                        model.conventionalGrossOutputMW
                )
            )

            MetricRow(
                title: "Cooling",
                value: PowerFormatter.string(
                    megawatts:
                        model.coolingPowerMW
                )
            )

            MetricRow(
                title: "Auxiliary",
                value: PowerFormatter.string(
                    megawatts:
                        model.auxiliaryPowerMW
                )
            )

            MetricRow(
                title: "Net Output",
                value: PowerFormatter.string(
                    megawatts:
                        model.conventionalNetOutputMW
                )
            )
        }
        .panelStyle()
    }



 

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            sectionHeader("SYSTEM CONTROLS")

            Toggle(
                "System Running",
                isOn: $model.isRunning
            )

            Divider()

            Text("Design Target")
                .font(.headline)

            ParameterSlider(
                title: "Target Net Output",
                value: $model.targetNetOutputMW,
                range: 0.1...100.0,
                step: 0.1,
                unit: "MW"
            )

            Divider()

            Text("Primary Excitation Coil")
                .font(.headline)

            ParameterSlider(
                title: "Turns",
                value: $model.primaryTurns,
                range: 1...100_000,
                step: 1,
                unit: ""
            )

            ParameterSlider(
                title: "Current",
                value: $model.primaryCurrentA,
                range: 0...100_000,
                step: 1,
                unit: "A"
            )

            ParameterSlider(
                title: "Radius",
                value: $model.primaryRadiusM,
                range: 0.1...1000,
                step: 0.1,
                unit: "m"
            )

            ParameterSlider(
                title: "Resistance",
                value: $model.primaryResistanceOhms,
                range: 0.000001...10,
                step: 0.000001,
                unit: "Ω"
            )

            Divider()

            Text("Upper Shaping Coil")
                .font(.headline)

            Toggle(
                "Enabled",
                isOn: $model.upperShapingEnabled
            )

            ParameterSlider(
                title: "Turns",
                value: $model.upperTurns,
                range: 1...100_000,
                step: 1,
                unit: ""
            )

            ParameterSlider(
                title: "Current",
                value: $model.upperCurrentA,
                range: 0...100_000,
                step: 1,
                unit: "A"
            )

            ParameterSlider(
                title: "Radius",
                value: $model.upperRadiusM,
                range: 0.1...1000,
                step: 0.1,
                unit: "m"
            )

            ParameterSlider(
                title: "Resistance",
                value: $model.upperResistanceOhms,
                range: 0.000001...10,
                step: 0.000001,
                unit: "Ω"
            )

            ParameterSlider(
                title: "Height",
                value: $model.upperHeightM,
                range: -1000...1000,
                step: 0.1,
                unit: "m"
            )

            ParameterSlider(
                title: "Phase",
                value: $model.upperPhaseDegrees,
                range: -180...180,
                step: 1,
                unit: "°"
            )

            Divider()

            Text("Lower Return Coil")
                .font(.headline)

            Toggle(
                "Enabled",
                isOn: $model.lowerReturnEnabled
            )

            ParameterSlider(
                title: "Turns",
                value: $model.lowerTurns,
                range: 1...100_000,
                step: 1,
                unit: ""
            )

            ParameterSlider(
                title: "Current",
                value: $model.lowerCurrentA,
                range: 0...100_000,
                step: 1,
                unit: "A"
            )

            ParameterSlider(
                title: "Radius",
                value: $model.lowerRadiusM,
                range: 0.1...1000,
                step: 0.1,
                unit: "m"
            )

            ParameterSlider(
                title: "Resistance",
                value: $model.lowerResistanceOhms,
                range: 0.000001...10,
                step: 0.000001,
                unit: "Ω"
            )

            ParameterSlider(
                title: "Height",
                value: $model.lowerHeightM,
                range: -1000...1000,
                step: 0.1,
                unit: "m"
            )

            ParameterSlider(
                title: "Phase",
                value: $model.lowerPhaseDegrees,
                range: -180...180,
                step: 1,
                unit: "°"
            )

            Divider()

            Text("Flux Management")
                .font(.headline)

            ParameterSlider(
                title: "Flux Gain",
                value: $model.fluxManagementGain,
                range: 0.1...10,
                step: 0.01,
                unit: "×"
            )

            ParameterSlider(
                title: "Coupling Alignment",
                value: $model.couplingAlignmentFactor,
                range: 0...1,
                step: 0.01,
                unit: "%"
            )

            Divider()

            Text("Modulation & Drive")
                .font(.headline)

            ParameterSlider(
                title: "Field Frequency",
                value: $model.fieldFrequencyKHz,
                range: 0...100,
                step: 0.1,
                unit: "kHz"
            )

            ParameterSlider(
                title: "Resonator Q",
                value: $model.resonatorQualityFactor,
                range: 1...10_000,
                step: 1,
                unit: ""
            )

      
            ParameterSlider(
                title: "Power Electronics Efficiency",
                value: $model.powerElectronicsEfficiency,
                range: 0.1...1,
                step: 0.01,
                unit: "%"
            )

            Divider()

            Text("Coupling Surface")
                .font(.headline)

            ParameterSlider(
                title: "Altitude",
                value: $model.couplingAltitudeKm,
                range: 0.1...500,
                step: 0.1,
                unit: "km"
            )

            ParameterSlider(
                title: "Radius",
                value: $model.couplingRadiusKm,
                range: 0.001...250,
                step: 0.001,
                unit: "km"
            )

            Divider()

            Text("Receiver")
                .font(.headline)

            ParameterSlider(
                title: "Receiver Turns",
                value: $model.receiverTurns,
                range: 1...100_000,
                step: 1,
                unit: ""
            )

            ParameterSlider(
                title: "Receiver Resistance",
                value: $model.receiverResistanceOhms,
                range: 0.000001...1000,
                step: 0.000001,
                unit: "Ω"
            )

            Divider()

            Text("Collector")
                .font(.headline)

            ParameterSlider(
                title: "Collector Area",
                value: $model.collectorAreaAcres,
                range: 0.01...1000,
                step: 0.01,
                unit: "acres"
            )

            ParameterSlider(
                title: "Conductivity",
                value: $model.collectorConductivitySPerM,
                range: 1...60_000_000,
                step: 1000,
                unit: "S/m"
            )

            ParameterSlider(
                title: "Spoke Thickness",
                value: $model.collectorThicknessM,
                range: 0.0001...1,
                step: 0.0001,
                unit: "m"
            )

            ParameterSlider(
                title: "Spoke Width",
                value: $model.radialSpokeWidthM,
                range: 0.001...10,
                step: 0.001,
                unit: "m"
            )

            ParameterSlider(
                title: "Spoke Count",
                value: $model.radialSpokeCount,
                range: 1...256,
                step: 1,
                unit: ""
            )

            Toggle(
                "Include AC Impedance",
                isOn: $model.includeACImpedance
            )

            ParameterSlider(
                title: "Collector Inductance",
                value: $model.collectorInductanceH,
                range: 0.000001...10,
                step: 0.000001,
                unit: "H"
            )

            ParameterSlider(
                title: "Collector Capacitance",
                value: $model.collectorCapacitanceF,
                range: 0.000000001...0.01,
                step: 0.000000001,
                unit: "F"
            )

            Divider()

            Text("Circuit")
                .font(.headline)

            ParameterSlider(
                title: "Source Resistance",
                value: $model.sourceResistanceOhms,
                range: 0...10_000,
                step: 0.001,
                unit: "Ω"
            )

            ParameterSlider(
                title: "Ground Return Resistance",
                value: $model.groundReturnResistanceOhms,
                range: 0...10_000,
                step: 0.001,
                unit: "Ω"
            )

            ParameterSlider(
                title: "Radiation Resistance",
                value: $model.radiationResistanceOhms,
                range: 0...10_000,
                step: 0.0001,
                unit: "Ω"
            )

            ParameterSlider(
                title: "Load Resistance",
                value: $model.loadResistanceOhms,
                range: 0.001...100_000,
                step: 0.01,
                unit: "Ω"
            )

            ParameterSlider(
                title: "Contact Efficiency",
                value: $model.contactEfficiency,
                range: 0.1...1,
                step: 0.01,
                unit: "%"
            )

            ParameterSlider(
                title: "Conversion Efficiency",
                value: $model.conversionEfficiency,
                range: 0.1...1,
                step: 0.01,
                unit: "%"
            )

            Divider()

            Button {
                model.reset()
            } label: {
                Label(
                    "Reset Simulation",
                    systemImage: "arrow.counterclockwise"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .panelStyle()
    }

    // MARK: - Equations

    private var equationSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            sectionHeader("MODEL EQUATIONS")

            EquationStep(
                number: 1,
                title: "Coil Magnetic Moment",
                equation: "mᵢ = NᵢIᵢAᵢ"
            )

            EquationStep(
                number: 2,
                title: "Combined Flux",
                equation: "Φ(t) = Σ Φᵢ sin(ωt + φᵢ)"
            )

            EquationStep(
                number: 3,
                title: "Dipole-to-Disk Flux",
                equation: "Φᵢ = μ₀mᵢR² / [2(z² + R²)³ᐟ²]"
            )

            EquationStep(
                number: 4,
                title: "Flux Derivative",
                equation: "dΦ/dt = ω[A cos(ωt) − B sin(ωt)]"
            )

            EquationStep(
                number: 5,
                title: "Faraday EMF",
                equation: "V = −Nᵣ dΦ/dt"
            )

            EquationStep(
                number: 6,
                title: "Circuit Impedance",
                equation: "Z = R + j(ωL − 1/(ωC))"
            )

            EquationStep(
                number: 7,
                title: "Circuit Current",
                equation: "Iᵣₘₛ = Vᵣₘₛ / |Z|"
            )

            EquationStep(
                number: 8,
                title: "Power",
                equation: "P = I²R"
            )

            EquationStep(
                number: 9,
                title: "Resonator Loss",
                equation: "Pᵣₑₛ ≈ ωE/Q"
            )

            EquationStep(
                number: 10,
                title: "Design Objective",
                equation: "maximize Φᵤₛₑfᵤₗ / Pᵢₙ"
            )
        }
        .panelStyle()
    }

    // MARK: - Limitations

    private var limitationSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            sectionHeader("MODEL LIMITATIONS")

            Text(
                """
                The interactive model uses an analytic coaxial dipole-to-circular-disk approximation for rapid parameter exploration.

                The magnetic-flux calculation assumes axial alignment and an idealized circular coupling surface. Off-axis, tilted, noncircular, or fully distributed geometries would require numerical field integration.

                The QRTL section is intentionally separated from the conventional electromagnetic calculation and represents a hypothesis/comparison model rather than an established contribution to the conventional circuit output.
                """
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }

    // MARK: - Section Header

    private func sectionHeader(
        _ title: String
    ) -> some View {

        Text(title)
            .font(.headline)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }
}

// MARK: - View Styling

private extension View {

    func panelStyle() -> some View {
        self
            .padding()
            .background(.thinMaterial)
            .clipShape(
                RoundedRectangle(cornerRadius: 18)
            )
    }
}

