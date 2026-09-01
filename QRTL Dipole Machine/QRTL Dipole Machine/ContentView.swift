

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
                    resonanceSection
                    collectorSection
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

            Text("Multi-coil magnetic-field and energy-collection model")
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
            .frame(height: 500)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )

            VStack(spacing: 4) {

                Text("MULTI-COIL FIELD")
                Text("↓")
                Text("COUPLING REGION")
                Text("↓")
                Text("ENERGY COLLECTION")
                Text("↓")
                Text("ELECTRICAL OUTPUT")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .panelStyle()
    }

    // MARK: - Main Output

    private var outputSection: some View {

        VStack(alignment: .leading, spacing: 14) {

            sectionHeader("SYSTEM OUTPUT")

            VStack(spacing: 4) {

                Text("QRTL MODELED NET OUTPUT")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(
                    PowerFormatter.string(
                        megawatts: model.qrtlNetOutputMW
                    )
                )
                .font(
                    .system(
                        size: 38,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    model.targetReached
                        ? .green
                        : .primary
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            Divider()

            MetricRow(
                title: "Design Target",
                value: PowerFormatter.string(
                    megawatts:
                        model.targetNetOutputMW
                )
            )

            ProgressView(
                value: min(
                    max(model.targetPercent / 100.0, 0.0),
                    1.0
                )
            )

            Text(model.targetStatus)
                .font(.caption)
                .foregroundStyle(
                    model.targetReached
                        ? .green
                        : .secondary
                )

            Divider()

            MetricRow(
                title: "QRTL Gross Collected",
                value: PowerFormatter.string(
                    megawatts:
                        model.qrtlFieldCollectionPowerMW
                )
            )

            MetricRow(
                title: "Captured Field Current",
                value: String(
                    format: "%.3e A",
                    model.capturedFieldCurrentA
                )
            )

            MetricRow(
                title: "Collection Voltage",
                value: String(
                    format: "%.3e V",
                    model.fieldCurrentCollectionVoltageV
                )
            )

            MetricRow(
                title: "Operating Costs",
                value: PowerFormatter.string(
                    megawatts:
                        model.qrtlOperatingCostsWatts
                        / 1_000_000.0
                )
            )

            Divider()

            Text("CONVENTIONAL FARADAY REFERENCE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            MetricRow(
                title: "Faraday Net Output",
                value: PowerFormatter.string(
                    megawatts:
                        model.conventionalNetOutputMW
                )
            )

            Text(
                "The QRTL pathway is shown as a separate modeled collection pathway. The conventional reference follows the Faraday induction calculation."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }

    // MARK: - Multi-Coil

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
                title: "Total Ampere-Turns",
                value: String(
                    format: "%.3e A-turns",
                    model.totalAmpereTurns
                )
            )

            MetricRow(
                title: "Flux Management",
                value: String(
                    format: "%.2f×",
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
                    "Coil currents are automatically reduced to remain within the field-power budget."
                )
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
        .panelStyle()
    }

    // MARK: - Field & Flux

    private var fieldFluxSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            sectionHeader("FIELD & COUPLING")

            MetricRow(
                title: "Coupling Altitude",
                value: String(
                    format: "%.2f km",
                    model.couplingAltitudeKm
                )
            )

            MetricRow(
                title: "Coupling Radius",
                value: String(
                    format: "%.2f km",
                    model.couplingRadiusKm
                )
            )

            MetricRow(
                title: "Field Strength",
                value: String(
                    format: "%.4e T",
                    model.fieldAtCouplingCenterTesla
                )
            )

            MetricRow(
                title: "Peak Magnetic Flux",
                value: String(
                    format: "%.4e Wb",
                    model.peakMagneticFluxWebers
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
                title: "Field Frequency",
                value: String(
                    format: "%.3f kHz",
                    model.fieldFrequencyKHz
                )
            )

            MetricRow(
                title: "Resonator Q",
                value: String(
                    format: "%.1f",
                    model.resonatorQualityFactor
                )
            )

            MetricRow(
                title: "Stored Magnetic Energy",
                value: String(
                    format: "%.4e J",
                    model.totalStoredMagneticEnergyJ
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
                title: "Collector Area",
                value: String(
                    format: "%.2f acres",
                    model.collectorAreaAcres
                )
            )

            MetricRow(
                title: "Collector Current",
                value: String(
                    format: "%.4f A",
                    model.collectorCurrentA
                )
            )

            MetricRow(
                title: "Collector Resistance",
                value: String(
                    format: "%.4e Ω",
                    model.collectorResistanceOhms
                )
            )

            MetricRow(
                title: "Radial Spokes",
                value: String(
                    format: "%.0f",
                    model.radialSpokeCount
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

            Toggle(
                "QRTL Field Collection",
                isOn: $model.qrtlFieldCollectionEnabled
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

            Text("Flux & Coupling")
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

            Text("Drive & Resonance")
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

            Text("Receiver & Collector")
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
                title: "Ground Return",
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
                title: "Magnetic Moment",
                equation: "m = NIA"
            )

            EquationStep(
                number: 2,
                title: "Magnetic Flux",
                equation: "Φ = ∫ B · dA"
            )

            EquationStep(
                number: 3,
                title: "Faraday EMF",
                equation: "V = −N dΦ/dt"
            )

            EquationStep(
                number: 4,
                title: "Circuit Power",
                equation: "P = I²R"
            )

            EquationStep(
                number: 5,
                title: "QRTL Modeled Collection",
                equation: "P_QRTL = I_captured × V_collection"
            )

            EquationStep(
                number: 6,
                title: "QRTL Net Output",
                equation: "P_net = P_converted − P_operating"
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
                The conventional electromagnetic model uses an analytic dipole-to-circular-disk approximation for rapid parameter exploration.

                The QRTL field-collection pathway is modeled separately from the conventional Faraday induction pathway and represents a hypothesis/comparison model rather than an experimentally established source of electrical power.
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

