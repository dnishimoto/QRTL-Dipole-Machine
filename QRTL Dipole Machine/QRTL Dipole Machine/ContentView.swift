import SwiftUI
import SceneKit

struct ContentView: View {

    // MARK: - Source and QRTL hypothesis

    @State private var ionospherePowerMW = 100.0

    /*
     QRTL is kept explicitly as a hypothesis coefficient.
     It does not establish that a physical energy pathway exists.
    */
    @State private var qrtlCoupling = 0.05

    /*
     Assumed fraction of the stated ionospheric source ceiling
     geometrically available at the defined coupling region.

     This is intentionally separate from qrtlCoupling:
     - couplingRegionAccess: source-access model assumption
     - qrtlCoupling: proposed QRTL capture assumption
    */
    @State private var couplingRegionAccess = 0.50

    // MARK: - Dipole generator

    @State private var fieldStrengthTesla = 1.0
    @State private var fieldFrequencyKHz = 10.0

    @State private var coilTurns = 200.0
    @State private var coilCurrentA = 500.0
    @State private var coilResistanceOhms = 2.0
    @State private var powerElectronicsEfficiency = 0.92
    @State private var auxiliaryPowerMW = 0.20

    // MARK: - Defined coupling region

    @State private var couplingAltitudeKm = 100.0
    @State private var couplingRadiusKm = 25.0

    /*
     The fieldStrengthTesla value is interpreted as the modeled
     field at this generator reference radius.
    */
    @State private var generatorReferenceRadiusM = 3.0

    /*
     Represents modeled field geometry/alignment across the
     coupling disk, from 0 to 1.
    */
    @State private var fluxGeometryFactor = 0.25

    /*
     Scale used only to normalize the Faraday-law induced-voltage
     proxy into a bounded time-varying access factor.
    */
    @State private var inducedVoltageScaleKV = 1.0

    // MARK: - Radial collector network

    @State private var collectorAreaAcres = 10.0
    @State private var collectorVoltageKV = 100.0

    @State private var collectorConductivitySPerM = 0.05
    @State private var collectorThicknessM = 0.10
    @State private var radialSpokeCount = 32.0
    @State private var radialSpokeWidthM = 2.0

    @State private var contactEfficiency = 0.98
    @State private var conversionEfficiency = 0.95

    @State private var isRunning = true

    private let targetPowerMW = 10.0

    // MARK: - Geometry

    private var collectorAreaM2: Double {
        collectorAreaAcres * 4_046.8564224
    }

    private var collectorRadiusM: Double {
        guard collectorAreaM2 > 0 else {
            return 0
        }

        return sqrt(collectorAreaM2 / Double.pi)
    }

    private var couplingAltitudeM: Double {
        couplingAltitudeKm * 1_000.0
    }

    private var couplingRadiusM: Double {
        couplingRadiusKm * 1_000.0
    }

    private var couplingSurfaceAreaM2: Double {
        Double.pi * couplingRadiusM * couplingRadiusM
    }

    // MARK: - Magnetic field and flux diagnostics

    /*
     Simplified axial dipole field proxy:

     B(r) = B₀ × (r₀ / r)³

     It is intentionally a first-order diagnostic, not a full
     Earth-ionosphere or plasma electromagnetic field solver.
    */
    private var fieldAtCouplingTesla: Double {
        let distanceM = max(couplingAltitudeM, 1.0)
        let referenceM = max(generatorReferenceRadiusM, 0.01)

        return fieldStrengthTesla *
            pow(referenceM / distanceM, 3.0)
    }

    /*
     Defined coupling-surface magnetic flux:

     Φ = ∫ B · dA

     First-order axial surface approximation:

     Φ ≈ B_coupling × A_coupling × geometryFactor
    */
    private var magneticFluxWebers: Double {
        fieldAtCouplingTesla *
            couplingSurfaceAreaM2 *
            fluxGeometryFactor
    }

    private var generatorReferenceFluxWebers: Double {
        let referenceArea =
            Double.pi *
            generatorReferenceRadiusM *
            generatorReferenceRadiusM

        return fieldStrengthTesla * referenceArea
    }

    /*
     This raw ratio is a field-decay diagnostic only.
     It becomes extremely small for a compact generator evaluated
     at a high-altitude coupling region.
    */
    private var rawFluxExtensionFactor: Double {
        guard generatorReferenceFluxWebers > 0 else {
            return 0
        }

        return max(
            0,
            magneticFluxWebers /
            generatorReferenceFluxWebers
        )
    }

    /*
     A display/model score with logarithmic compression.

     The raw ratio is preserved and displayed separately above.
     This score allows the user to inspect a distant coupling
     region without every modeled output formatting as 0.000000.

     Approximate mapping:
     1e-15 -> 0.00
     1e-12 -> 0.20
     1e-9  -> 0.40
     1e-6  -> 0.60
     1e-3  -> 0.80
     1e0   -> 1.00
    */
    private var fluxReachScore: Double {
        guard rawFluxExtensionFactor > 0 else {
            return 0
        }

        let decades = log10(rawFluxExtensionFactor)

        return min(
            max(
                (decades + 15.0) / 15.0,
                0
            ),
            1
        )
    }

    // MARK: - Time-varying field

    private var frequencyHz: Double {
        fieldFrequencyKHz * 1_000.0
    }

    /*
     For sinusoidal flux:

     |dΦ/dt|peak = 2πfΦpeak

     f = 0 correctly produces a static field with dΦ/dt = 0.
    */
    private var fluxChangeRateWebersPerSecond: Double {
        guard isRunning, frequencyHz > 0 else {
            return 0
        }

        return 2.0 *
            Double.pi *
            frequencyHz *
            magneticFluxWebers
    }

    /*
     Faraday-law induced voltage proxy:

     V_induced = N × |dΦ/dt|
    */
    private var inducedInteractionVoltageV: Double {
        coilTurns * fluxChangeRateWebersPerSecond
    }

    /*
     Bounded access factor derived from the induced-voltage proxy:

     F_time = V_induced / (V_induced + V_scale)

     This is zero for static magnetic fields.
    */
    private var timeVaryingAccessFactor: Double {
        let scaleV = inducedVoltageScaleKV * 1_000.0

        guard scaleV > 0 else {
            return 0
        }

        return inducedInteractionVoltageV /
            (inducedInteractionVoltageV + scaleV)
    }

    // MARK: - Generator energy input

    /*
     Two equivalent coils:

     P_copper = 2 × I²R
    */
    private var coilCopperLossMW: Double {
        guard isRunning else {
            return 0
        }

        return 2.0 *
            coilCurrentA *
            coilCurrentA *
            coilResistanceOhms /
            1_000_000.0
    }

    /*
     Field-generator input includes electronics loss:

     P_generator = P_copper / η_electronics
    */
    private var fieldGeneratorInputMW: Double {
        guard isRunning, powerElectronicsEfficiency > 0 else {
            return 0
        }

        return coilCopperLossMW /
            powerElectronicsEfficiency
    }

    // MARK: - Interaction and capture

    /*
     Revised source path:

     P_accessible =
       P_ionosphere
       × couplingRegionAccess
       × fluxReachScore

     P_time =
       P_accessible
       × timeVaryingAccessFactor

     P_QRTL =
       P_time
       × η_QRTL

     The raw flux ratio remains a displayed physical diagnostic,
     while the region-access parameter is explicitly labeled as
     a model assumption.
    */
    private var fluxAccessibleIonosphericPowerMW: Double {
        guard isRunning else {
            return 0
        }

        return ionospherePowerMW *
            couplingRegionAccess *
            fluxReachScore
    }

    private var timeVaryingInteractionPowerMW: Double {
        fluxAccessibleIonosphericPowerMW *
            timeVaryingAccessFactor
    }

    private var qrtlCapturedPowerMW: Double {
        timeVaryingInteractionPowerMW *
            qrtlCoupling
    }

    // MARK: - Collector resistance model

    /*
     A_spoke = thickness × width
     R_spoke = L / (σ × A_spoke)
     R_network = R_spoke / N_spokes
    */
    private var collectorSpokeLengthM: Double {
        collectorRadiusM
    }

    private var collectorSpokeCrossSectionM2: Double {
        collectorThicknessM * radialSpokeWidthM
    }

    private var singleSpokeResistanceOhms: Double {
        let denominator =
            collectorConductivitySPerM *
            collectorSpokeCrossSectionM2

        guard denominator > 0 else {
            return .infinity
        }

        return collectorSpokeLengthM / denominator
    }

    private var collectorNetworkResistanceOhms: Double {
        guard radialSpokeCount > 0 else {
            return .infinity
        }

        return singleSpokeResistanceOhms /
            radialSpokeCount
    }

    private var collectorSourcePowerW: Double {
        qrtlCapturedPowerMW * 1_000_000.0
    }

    private var collectorVoltageV: Double {
        collectorVoltageKV * 1_000.0
    }

    /*
     Source balance including network resistance:

     P_source = V × I + I²R

     Solved for I:

     I = (-V + √(V² + 4RP)) / (2R)
    */
    private var collectorCurrentA: Double {
        let powerW = collectorSourcePowerW
        let voltageV = collectorVoltageV
        let resistance = collectorNetworkResistanceOhms

        guard powerW > 0, voltageV > 0 else {
            return 0
        }

        guard resistance.isFinite, resistance > 0 else {
            return powerW / voltageV
        }

        let discriminant =
            voltageV * voltageV +
            4.0 * resistance * powerW

        return max(
            0,
            (
                -voltageV +
                sqrt(discriminant)
            ) /
            (2.0 * resistance)
        )
    }

    private var collectorResistiveLossMW: Double {
        guard collectorNetworkResistanceOhms.isFinite else {
            return 0
        }

        return collectorCurrentA *
            collectorCurrentA *
            collectorNetworkResistanceOhms /
            1_000_000.0
    }

    private var collectorDeliveredPowerMW: Double {
        max(
            0,
            qrtlCapturedPowerMW -
            collectorResistiveLossMW
        )
    }

    private var contactLossMW: Double {
        max(
            0,
            collectorDeliveredPowerMW *
            (1.0 - contactEfficiency)
        )
    }

    private var powerBeforeConversionMW: Double {
        max(
            0,
            collectorDeliveredPowerMW -
            contactLossMW
        )
    }

    private var conversionLossMW: Double {
        max(
            0,
            powerBeforeConversionMW *
            (1.0 - conversionEfficiency)
        )
    }

    private var grossOutputMW: Double {
        powerBeforeConversionMW *
            conversionEfficiency
    }

    /*
     Complete accounting:

     captured power
       − collector I²R loss
       − contact loss
       − conversion loss
       − field-generator input
       − auxiliary input
       = net output
    */
    private var netOutputMW: Double {
        grossOutputMW -
            fieldGeneratorInputMW -
            auxiliaryPowerMW
    }

    private var currentDensityPerSpokeAperM2: Double {
        guard collectorSpokeCrossSectionM2 > 0 else {
            return 0
        }

        let currentPerSpoke =
            collectorCurrentA /
            max(radialSpokeCount, 1)

        return currentPerSpoke /
            collectorSpokeCrossSectionM2
    }

    private var grossPathEfficiency: Double {
        guard ionospherePowerMW > 0 else {
            return 0
        }

        return grossOutputMW / ionospherePowerMW
    }

    private var targetPercent: Double {
        guard targetPowerMW > 0 else {
            return 0
        }

        return max(
            0,
            netOutputMW /
            targetPowerMW *
            100.0
        )
    }

    private var netOutputColor: Color {
        if netOutputMW > 0 {
            return .green
        }

        if netOutputMW < 0 {
            return .red
        }

        return .secondary
    }

    private var fieldModeText: String {
        if !isRunning {
            return "Paused"
        }

        if frequencyHz == 0 {
            return "Static field — dΦ/dt = 0"
        }

        return "Time-varying field"
    }

    // MARK: - Main view

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    titleSection
                    simulationScene
                    outputSection
                    fluxSection
                    generatorSection
                    interactionSection
                    collectorSection
                    accountingSection
                    controlsSection
                    equationsSection
                    energyFlowSection
                    limitationSection
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - View sections

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text("QRTL Dipole")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Flux-Coupled Electromagnetic Model")
                .font(.title3)
                .fontWeight(.semibold)

            Text(
                "Electrical Input → Dipole Field → Coupling-Surface Flux → "
                + "Time-Varying Interaction → QRTL Hypothesis → "
                + "Radial Collector → Net Output"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
    }

    private var simulationScene: some View {
        ZStack(alignment: .topLeading) {
            QRTLSceneView(
                running: isRunning,
                fieldStrengthTesla: fieldStrengthTesla,
                fieldFrequencyKHz: fieldFrequencyKHz,
                couplingAltitudeKm: couplingAltitudeKm,
                couplingRadiusKm: couplingRadiusKm,
                radialSpokeCount: Int(radialSpokeCount)
            )
            .frame(height: 520)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )

            VStack(alignment: .leading, spacing: 5) {
                Text("3D FIELD MODEL")
                    .font(.caption)
                    .fontWeight(.bold)

                Text("POWER INPUT")
                Text("↓")
                Text("N / S DIPOLE COILS")
                Text("↓")
                Text("Φ THROUGH COUPLING SURFACE")
                Text("↓")
                Text("QRTL HYPOTHESIS")
                Text("↓")
                Text("RADIAL COLLECTOR NETWORK")
                Text("↓")
                Text("POWER CONDITIONING")
                Text("↓")
                Text("LOAD")
            }
            .font(.caption2)
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 12
                )
            )
            .padding(12)
        }
    }

    private var outputSection: some View {
        VStack(spacing: 14) {
            Text("SIMULATED ELECTRICAL OUTPUT")
                .font(.headline)

            HStack {
                OutputValue(
                    title: "Captured",
                    valueMW: qrtlCapturedPowerMW
                )

                OutputValue(
                    title: "Gross",
                    valueMW: grossOutputMW
                )

                OutputValue(
                    title: "Net",
                    valueMW: netOutputMW
                )
            }

            ProgressView(
                value: min(
                    max(
                        netOutputMW /
                        targetPowerMW,
                        0
                    ),
                    1
                )
            )
            .tint(netOutputColor)

            Text(
                String(
                    format: "%.2f%% of %.1f MW target",
                    targetPercent,
                    targetPowerMW
                )
            )
            .font(.caption)
            .foregroundStyle(netOutputColor)
        }
        .panelStyle()
    }

    private var fluxSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Magnetic Flux at Coupling Region")
                .font(.headline)

            MetricRow(
                name: "Field state",
                value: fieldModeText
            )

            MetricRow(
                name: "Coupling altitude",
                value: String(
                    format: "%.2f km",
                    couplingAltitudeKm
                )
            )

            MetricRow(
                name: "Coupling-region radius",
                value: String(
                    format: "%.2f km",
                    couplingRadiusKm
                )
            )

            MetricRow(
                name: "Coupling surface area",
                value: String(
                    format: "%.3e m²",
                    couplingSurfaceAreaM2
                )
            )

            MetricRow(
                name: "Field at coupling surface",
                value: String(
                    format: "%.3e T",
                    fieldAtCouplingTesla
                )
            )

            MetricRow(
                name: "Magnetic flux Φ = ∫B·dA",
                value: String(
                    format: "%.3e Wb",
                    magneticFluxWebers
                )
            )

            MetricRow(
                name: "Raw Φ coupling / Φ reference",
                value: String(
                    format: "%.3e",
                    rawFluxExtensionFactor
                )
            )

            MetricRow(
                name: "Flux reach score",
                value: String(
                    format: "%.3f",
                    fluxReachScore
                )
            )

            MetricRow(
                name: "Peak dΦ/dt",
                value: String(
                    format: "%.3e Wb/s",
                    fluxChangeRateWebersPerSecond
                )
            )

            MetricRow(
                name: "Induced-voltage proxy",
                value: String(
                    format: "%.3e V",
                    inducedInteractionVoltageV
                )
            )

            MetricRow(
                name: "Time-varying access factor",
                value: String(
                    format: "%.3e",
                    timeVaryingAccessFactor
                )
            )
        }
        .panelStyle()
    }

    private var generatorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Field Generator Power")
                .font(.headline)

            MetricRow(
                name: "Modeled coils",
                value: "2"
            )

            MetricRow(
                name: "Coil turns",
                value: String(
                    format: "%.0f",
                    coilTurns
                )
            )

            MetricRow(
                name: "Coil current",
                value: String(
                    format: "%.2f A",
                    coilCurrentA
                )
            )

            MetricRow(
                name: "Resistance per coil",
                value: String(
                    format: "%.4f Ω",
                    coilResistanceOhms
                )
            )

            MetricRow(
                name: "Copper loss: 2I²R",
                value: PowerFormatter.string(
                    megawatts: coilCopperLossMW
                )
            )

            MetricRow(
                name: "Electronics efficiency",
                value: String(
                    format: "%.2f%%",
                    powerElectronicsEfficiency * 100.0
                )
            )

            MetricRow(
                name: "Field-generator input",
                value: PowerFormatter.string(
                    megawatts: fieldGeneratorInputMW
                )
            )

            MetricRow(
                name: "Auxiliary input",
                value: PowerFormatter.string(
                    megawatts: auxiliaryPowerMW
                )
            )
        }
        .panelStyle()
    }

    private var interactionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Interaction and QRTL Model")
                .font(.headline)

            MetricRow(
                name: "Ionospheric power ceiling",
                value: PowerFormatter.string(
                    megawatts: ionospherePowerMW
                )
            )

            MetricRow(
                name: "Coupling-region access assumption",
                value: String(
                    format: "%.2f%%",
                    couplingRegionAccess * 100.0
                )
            )

            MetricRow(
                name: "Flux-accessible power",
                value: PowerFormatter.string(
                    megawatts: fluxAccessibleIonosphericPowerMW
                )
            )

            MetricRow(
                name: "Time-varying interaction",
                value: PowerFormatter.string(
                    megawatts: timeVaryingInteractionPowerMW
                )
            )

            MetricRow(
                name: "QRTL hypothesis coefficient",
                value: String(
                    format: "%.6f",
                    qrtlCoupling
                )
            )

            MetricRow(
                name: "Captured before collector loss",
                value: PowerFormatter.string(
                    megawatts: qrtlCapturedPowerMW
                )
            )
        }
        .panelStyle()
    }

    private var collectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Radial Collector Network")
                .font(.headline)

            MetricRow(
                name: "Collection footprint",
                value: String(
                    format: "%.3f acres",
                    collectorAreaAcres
                )
            )

            MetricRow(
                name: "Collector area",
                value: String(
                    format: "%.2f m²",
                    collectorAreaM2
                )
            )

            MetricRow(
                name: "Equivalent radius",
                value: String(
                    format: "%.2f m",
                    collectorRadiusM
                )
            )

            MetricRow(
                name: "Parallel radial spokes",
                value: String(
                    format: "%.0f",
                    radialSpokeCount
                )
            )

            MetricRow(
                name: "Spoke length",
                value: String(
                    format: "%.2f m",
                    collectorSpokeLengthM
                )
            )

            MetricRow(
                name: "Conductivity",
                value: String(
                    format: "%.5f S/m",
                    collectorConductivitySPerM
                )
            )

            MetricRow(
                name: "Spoke cross-section",
                value: String(
                    format: "%.6f m²",
                    collectorSpokeCrossSectionM2
                )
            )

            MetricRow(
                name: "Single-spoke resistance",
                value: String(
                    format: "%.6f Ω",
                    singleSpokeResistanceOhms
                )
            )

            MetricRow(
                name: "Network resistance",
                value: String(
                    format: "%.6f Ω",
                    collectorNetworkResistanceOhms
                )
            )

            MetricRow(
                name: "Collector current",
                value: String(
                    format: "%.6f A",
                    collectorCurrentA
                )
            )

            MetricRow(
                name: "Current density per spoke",
                value: String(
                    format: "%.6f A/m²",
                    currentDensityPerSpokeAperM2
                )
            )

            MetricRow(
                name: "Collector I²R loss",
                value: PowerFormatter.string(
                    megawatts: collectorResistiveLossMW
                )
            )
        }
        .panelStyle()
    }

    private var accountingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Complete Energy Accounting")
                .font(.headline)

            MetricRow(
                name: "Captured power",
                value: PowerFormatter.string(
                    megawatts: qrtlCapturedPowerMW
                )
            )

            MetricRow(
                name: "− Collector I²R loss",
                value: PowerFormatter.string(
                    megawatts: collectorResistiveLossMW
                )
            )

            MetricRow(
                name: "− Contact/interface loss",
                value: PowerFormatter.string(
                    megawatts: contactLossMW
                )
            )

            MetricRow(
                name: "− Conversion loss",
                value: PowerFormatter.string(
                    megawatts: conversionLossMW
                )
            )

            MetricRow(
                name: "− Field-generator input",
                value: PowerFormatter.string(
                    megawatts: fieldGeneratorInputMW
                )
            )

            MetricRow(
                name: "− Auxiliary input",
                value: PowerFormatter.string(
                    megawatts: auxiliaryPowerMW
                )
            )

            Divider()

            MetricRow(
                name: "Net output",
                value: PowerFormatter.string(
                    megawatts: netOutputMW
                )
            )

            MetricRow(
                name: "Gross source-to-load efficiency",
                value: String(
                    format: "%.6f%%",
                    grossPathEfficiency * 100.0
                )
            )
        }
        .panelStyle()
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Model Parameters")
                .font(.headline)

            Text("Dipole and coupling surface")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Generator field strength",
                value: $fieldStrengthTesla,
                range: 0.001...10.0,
                step: 0.001,
                unit: " T"
            )

            ParameterSlider(
                title: "Field frequency",
                value: $fieldFrequencyKHz,
                range: 0.0...100.0,
                step: 0.1,
                unit: " kHz"
            )

            ParameterSlider(
                title: "Coupling altitude",
                value: $couplingAltitudeKm,
                range: 1.0...500.0,
                step: 1.0,
                unit: " km"
            )

            ParameterSlider(
                title: "Coupling-region radius",
                value: $couplingRadiusKm,
                range: 0.1...250.0,
                step: 0.1,
                unit: " km"
            )

            ParameterSlider(
                title: "Generator reference radius",
                value: $generatorReferenceRadiusM,
                range: 0.1...50.0,
                step: 0.1,
                unit: " m"
            )

            ParameterSlider(
                title: "Flux geometry factor",
                value: $fluxGeometryFactor,
                range: 0.001...1.0,
                step: 0.001,
                unit: ""
            )

            ParameterSlider(
                title: "Coupling-region access assumption",
                value: $couplingRegionAccess,
                range: 0.0...1.0,
                step: 0.01,
                unit: ""
            )

            ParameterSlider(
                title: "Induced-voltage scale",
                value: $inducedVoltageScaleKV,
                range: 0.1...1_000.0,
                step: 0.1,
                unit: " kV"
            )

            Text("Field generator")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Coil turns",
                value: $coilTurns,
                range: 1.0...10_000.0,
                step: 1.0,
                unit: ""
            )

            ParameterSlider(
                title: "Coil current",
                value: $coilCurrentA,
                range: 0.0...10_000.0,
                step: 1.0,
                unit: " A"
            )

            ParameterSlider(
                title: "Resistance per coil",
                value: $coilResistanceOhms,
                range: 0.001...100.0,
                step: 0.001,
                unit: " Ω"
            )

            ParameterSlider(
                title: "Power-electronics efficiency",
                value: $powerElectronicsEfficiency,
                range: 0.1...1.0,
                step: 0.01,
                unit: ""
            )

            ParameterSlider(
                title: "Auxiliary power",
                value: $auxiliaryPowerMW,
                range: 0.0...50.0,
                step: 0.01,
                unit: " MW"
            )

            Text("Ionosphere and QRTL hypothesis")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Ionospheric power ceiling",
                value: $ionospherePowerMW,
                range: 1.0...1_000.0,
                step: 1.0,
                unit: " MW"
            )

            ParameterSlider(
                title: "QRTL hypothesis coupling",
                value: $qrtlCoupling,
                range: 0.0...1.0,
                step: 0.001,
                unit: ""
            )

            Text("Radial collector network")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Collector footprint",
                value: $collectorAreaAcres,
                range: 0.01...100.0,
                step: 0.01,
                unit: " acres"
            )

            ParameterSlider(
                title: "Collector voltage",
                value: $collectorVoltageKV,
                range: 1.0...1_000.0,
                step: 1.0,
                unit: " kV"
            )

            ParameterSlider(
                title: "Collector conductivity",
                value: $collectorConductivitySPerM,
                range: 0.001...10.0,
                step: 0.001,
                unit: " S/m"
            )

            ParameterSlider(
                title: "Collector thickness",
                value: $collectorThicknessM,
                range: 0.001...2.0,
                step: 0.001,
                unit: " m"
            )

            ParameterSlider(
                title: "Radial spoke count",
                value: $radialSpokeCount,
                range: 1.0...256.0,
                step: 1.0,
                unit: ""
            )

            ParameterSlider(
                title: "Radial spoke width",
                value: $radialSpokeWidthM,
                range: 0.01...20.0,
                step: 0.01,
                unit: " m"
            )

            ParameterSlider(
                title: "Contact/interface efficiency",
                value: $contactEfficiency,
                range: 0.1...1.0,
                step: 0.01,
                unit: ""
            )

            ParameterSlider(
                title: "Conversion efficiency",
                value: $conversionEfficiency,
                range: 0.1...1.0,
                step: 0.01,
                unit: ""
            )

            Toggle(
                "Energize and animate field",
                isOn: $isRunning
            )
        }
        .panelStyle()
    }

    private var equationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Equation Pipeline")
                .font(.headline)

            EquationStep(
                number: "1",
                title: "Axial dipole field proxy",
                equation: "B(r) = B₀(r₀ / r)³"
            )

            EquationStep(
                number: "2",
                title: "Flux through coupling surface",
                equation: "Φ = ∫ B · dA ≈ B A g"
            )

            EquationStep(
                number: "3",
                title: "Time-varying flux",
                equation: "|dΦ/dt| = 2πfΦ"
            )

            EquationStep(
                number: "4",
                title: "Induced-voltage proxy",
                equation: "V = N|dΦ/dt|"
            )

            EquationStep(
                number: "5",
                title: "Coupling-region access",
                equation: "P_access = P_ionosphere a_region F_reach"
            )

            EquationStep(
                number: "6",
                title: "QRTL hypothesis capture",
                equation: "P_capture = P_access F_time η_QRTL"
            )

            EquationStep(
                number: "7",
                title: "Collector resistance",
                equation: "R = L / (σ A N)"
            )

            EquationStep(
                number: "8",
                title: "Collector loss",
                equation: "P_loss = I²R"
            )

            EquationStep(
                number: "9",
                title: "Generator copper loss",
                equation: "P_coils = 2I²R"
            )

            EquationStep(
                number: "10",
                title: "Net output",
                equation: "P_net = P_gross − P_generator − P_aux"
            )
        }
        .panelStyle()
    }

    private var energyFlowSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Energy Flow")
                .font(.headline)

            EnergyBar(
                title: "Ionospheric ceiling",
                valueMW: ionospherePowerMW,
                maximumMW: max(
                    ionospherePowerMW,
                    1
                )
            )

            EnergyBar(
                title: "Flux-accessible",
                valueMW: fluxAccessibleIonosphericPowerMW,
                maximumMW: max(
                    ionospherePowerMW,
                    1
                )
            )

            EnergyBar(
                title: "Time-varying interaction",
                valueMW: timeVaryingInteractionPowerMW,
                maximumMW: max(
                    ionospherePowerMW,
                    1
                )
            )

            EnergyBar(
                title: "QRTL captured",
                valueMW: qrtlCapturedPowerMW,
                maximumMW: max(
                    ionospherePowerMW,
                    1
                )
            )

            EnergyBar(
                title: "Collector delivered",
                valueMW: collectorDeliveredPowerMW,
                maximumMW: max(
                    ionospherePowerMW,
                    1
                )
            )

            EnergyBar(
                title: "Gross output",
                valueMW: grossOutputMW,
                maximumMW: max(
                    ionospherePowerMW,
                    1
                )
            )

            EnergyBar(
                title: "Field-generator input",
                valueMW: fieldGeneratorInputMW,
                maximumMW: max(
                    ionospherePowerMW,
                    1
                )
            )

            EnergyBar(
                title: "Net output",
                valueMW: max(
                    netOutputMW,
                    0
                ),
                maximumMW: max(
                    ionospherePowerMW,
                    1
                )
            )
        }
        .panelStyle()
    }

    private var limitationSection: some View {
        Text(
            "Model limitation: the dipole-field expression, flux geometry, "
            + "coupling-region access, induced-voltage scale, available ionospheric "
            + "power, and QRTL coefficient are model assumptions. This app explicitly "
            + "accounts for flux extension, time-varying excitation, generator input, "
            + "and collector I²R loss; it does not establish an ionosphere-to-ground "
            + "net-power pathway."
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - Shared View Style

private extension View {

    func panelStyle() -> some View {
        padding()
            .background(.thinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
    }
}

// MARK: - Power Formatter

enum PowerFormatter {

    static func string(
        megawatts valueMW: Double
    ) -> String {
        let sign = valueMW < 0 ? "−" : ""
        let watts = abs(valueMW) * 1_000_000.0

        switch watts {
        case 1_000_000.0...:
            return String(
                format: "%@%.4f MW",
                sign,
                watts / 1_000_000.0
            )

        case 1_000.0...:
            return String(
                format: "%@%.3f kW",
                sign,
                watts / 1_000.0
            )

        case 1.0...:
            return String(
                format: "%@%.3f W",
                sign,
                watts
            )

        case 0.001...:
            return String(
                format: "%@%.3f mW",
                sign,
                watts * 1_000.0
            )

        case 0.000001...:
            return String(
                format: "%@%.3f µW",
                sign,
                watts * 1_000_000.0
            )

        default:
            return String(
                format: "%@%.3e W",
                sign,
                watts
            )
        }
    }
}

// MARK: - Output Value

struct OutputValue: View {

    let title: String
    let valueMW: Double

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(
                PowerFormatter.string(
                    megawatts: valueMW
                )
            )
            .font(.headline)
            .fontWeight(.bold)
            .monospacedDigit()
            .minimumScaleFactor(0.65)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Metric Row

struct MetricRow: View {

    let name: String
    let value: String

    var body: some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: 12
        ) {
            Text(name)

            Spacer(minLength: 8)

            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .font(.subheadline)
    }
}

// MARK: - Parameter Slider

struct ParameterSlider: View {

    let title: String

    @Binding var value: Double

    let range: ClosedRange<Double>
    let step: Double
    let unit: String

    private var formattedValue: String {
        let decimals: Int

        if step >= 1.0 {
            decimals = 0
        } else if step >= 0.1 {
            decimals = 1
        } else if step >= 0.01 {
            decimals = 2
        } else {
            decimals = 3
        }

        return String(
            format: "%.\(decimals)f%@",
            value,
            unit
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                Text(title)

                Spacer(minLength: 8)

                Text(formattedValue)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: $value,
                in: range,
                step: step
            )
        }
    }
}

// MARK: - Equation Step

struct EquationStep: View {

    let number: String
    let title: String
    let equation: String

    var body: some View {
        HStack(
            alignment: .top,
            spacing: 12
        ) {
            Text(number)
                .fontWeight(.bold)
                .frame(width: 25)

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(equation)
                    .font(
                        .system(
                            .body,
                            design: .monospaced
                        )
                    )
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Energy Bar

struct EnergyBar: View {

    let title: String
    let valueMW: Double
    let maximumMW: Double

    private var fraction: Double {
        guard maximumMW > 0 else {
            return 0
        }

        return min(
            max(valueMW / maximumMW, 0),
            1
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.caption)

                Spacer()

                Text(
                    PowerFormatter.string(
                        megawatts: valueMW
                    )
                )
                .font(.caption)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(
                        cornerRadius: 5
                    )
                    .fill(
                        Color.secondary.opacity(0.15)
                    )

                    RoundedRectangle(
                        cornerRadius: 5
                    )
                    .fill(
                        Color.accentColor.opacity(0.78)
                    )
                    .frame(
                        width:
                            geometry.size.width *
                            fraction
                    )
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - SceneKit View

struct QRTLSceneView: UIViewRepresentable {

    let running: Bool
    let fieldStrengthTesla: Double
    let fieldFrequencyKHz: Double
    let couplingAltitudeKm: Double
    let couplingRadiusKm: Double
    let radialSpokeCount: Int

    func makeUIView(
        context: Context
    ) -> SCNView {
        let view = SCNView()

        view.backgroundColor = UIColor(
            red: 0.01,
            green: 0.02,
            blue: 0.05,
            alpha: 1
        )

        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 60

        let scene = SCNScene()

        scene.background.contents = UIColor(
            red: 0.005,
            green: 0.008,
            blue: 0.025,
            alpha: 1
        )

        view.scene = scene

        buildScene(
            scene: scene,
            fieldStrengthTesla: fieldStrengthTesla,
            couplingAltitudeKm: couplingAltitudeKm,
            couplingRadiusKm: couplingRadiusKm,
            radialSpokeCount: radialSpokeCount
        )

        updateScene(view: view)

        return view
    }

    func updateUIView(
        _ view: SCNView,
        context: Context
    ) {
        updateScene(view: view)
    }

    private func updateScene(
        view: SCNView
    ) {
        guard let root = view.scene?.rootNode else {
            return
        }

        let normalizedStrength = CGFloat(
            min(
                max(
                    fieldStrengthTesla / 10.0,
                    0.0
                ),
                1.0
            )
        )

        if let fieldContainer = root.childNode(
            withName: "FieldContainer",
            recursively: true
        ) {
            fieldContainer.opacity = running ? 1.0 : 0.10

            fieldContainer.enumerateChildNodes { node, _ in
                node.geometry?.firstMaterial?.emission.intensity =
                    0.35 +
                    normalizedStrength * 1.65
            }
        }

        if let dipole = root.childNode(
            withName: "QRTLDipole",
            recursively: true
        ) {
            dipole.opacity = running ? 1.0 : 0.50

            dipole.enumerateChildNodes { node, _ in
                guard let name = node.name else {
                    return
                }

                if name.contains("ExcitationCoil") {
                    node.geometry?.firstMaterial?.emission.intensity =
                        0.35 +
                        normalizedStrength * 2.10
                }
            }

            if let upperAssembly = dipole.childNode(
                withName: "UpperCoilAssembly",
                recursively: true
            ) {
                configureCoilRotation(
                    node: upperAssembly,
                    running: running,
                    frequencyKHz: fieldFrequencyKHz,
                    key: "upperCoilRotation"
                )
            }

            if let lowerAssembly = dipole.childNode(
                withName: "LowerCoilAssembly",
                recursively: true
            ) {
                configureCoilRotation(
                    node: lowerAssembly,
                    running: running,
                    frequencyKHz: fieldFrequencyKHz,
                    key: "lowerCoilRotation"
                )
            }
        }
    }

    private func buildScene(
        scene: SCNScene,
        fieldStrengthTesla: Double,
        couplingAltitudeKm: Double,
        couplingRadiusKm: Double,
        radialSpokeCount: Int
    ) {
        let root = scene.rootNode

        createCamera(root: root)
        createLights(root: root)
        createGround(root: root)
        createIonosphere(root: root)

        createCouplingSurface(
            root: root,
            altitudeKm: couplingAltitudeKm,
            radiusKm: couplingRadiusKm
        )

        let fieldContainer = SCNNode()
        fieldContainer.name = "FieldContainer"

        root.addChildNode(fieldContainer)

        createFieldLines(
            container: fieldContainer,
            strengthTesla: fieldStrengthTesla
        )

        let dipole = SCNNode()
        dipole.name = "QRTLDipole"

        root.addChildNode(dipole)

        createDipole(container: dipole)

        createCollector(
            root: root,
            spokeCount: radialSpokeCount
        )

        createCurrentPath(root: root)
        createTerminal(root: root)
        createPowerConditioning(root: root)
        createLoad(root: root)
        createLabels(root: root)
    }

    // MARK: - Scene Setup

    private func createCamera(
        root: SCNNode
    ) {
        let node = SCNNode()
        let camera = SCNCamera()

        camera.fieldOfView = 58
        camera.zNear = 0.1
        camera.zFar = 500

        node.camera = camera
        node.position = SCNVector3(
            0,
            18,
            38
        )

        node.look(
            at: SCNVector3(
                0,
                8,
                0
            )
        )

        root.addChildNode(node)
    }

    private func createLights(
        root: SCNNode
    ) {
        let ambientNode = SCNNode()
        let ambient = SCNLight()

        ambient.type = .ambient
        ambient.intensity = 700
        ambientNode.light = ambient

        root.addChildNode(ambientNode)

        let omniNode = SCNNode()
        let omni = SCNLight()

        omni.type = .omni
        omni.intensity = 1_200

        omniNode.position = SCNVector3(
            0,
            20,
            15
        )

        omniNode.light = omni

        root.addChildNode(omniNode)
    }

    private func createGround(
        root: SCNNode
    ) {
        let geometry = SCNFloor()

        geometry.reflectivity = 0.08

        geometry.firstMaterial?.diffuse.contents = UIColor(
            white: 0.06,
            alpha: 1
        )

        root.addChildNode(
            SCNNode(
                geometry: geometry
            )
        )
    }

    private func createIonosphere(
        root: SCNNode
    ) {
        let geometry = SCNSphere(
            radius: 14
        )

        geometry.firstMaterial = transparentMaterial(
            UIColor.systemTeal,
            opacity: 0.06
        )

        let node = SCNNode(
            geometry: geometry
        )

        node.name = "Ionosphere"

        node.position = SCNVector3(
            0,
            20,
            0
        )

        root.addChildNode(node)
    }

    private func createCouplingSurface(
        root: SCNNode,
        altitudeKm: Double,
        radiusKm: Double
    ) {
        let sceneAltitude = Float(
            min(
                max(
                    altitudeKm / 10.0,
                    12.0
                ),
                28.0
            )
        )

        let sceneRadius = CGFloat(
            min(
                max(
                    radiusKm / 4.0,
                    3.0
                ),
                12.0
            )
        )

        let disk = SCNCylinder(
            radius: sceneRadius,
            height: 0.08
        )

        disk.firstMaterial = transparentMaterial(
            UIColor.systemYellow,
            opacity: 0.20
        )

        let diskNode = SCNNode(
            geometry: disk
        )

        diskNode.name = "CouplingSurface"

        diskNode.position = SCNVector3(
            0,
            sceneAltitude,
            0
        )

        root.addChildNode(diskNode)

        let rim = SCNTorus(
            ringRadius: sceneRadius,
            pipeRadius: 0.06
        )

        rim.firstMaterial = emissiveMaterial(
            UIColor.systemYellow
        )

        let rimNode = SCNNode(
            geometry: rim
        )

        rimNode.position = diskNode.position

        root.addChildNode(rimNode)

        addLabel(
            "COUPLING SURFACE Φ",
            position: SCNVector3(
                0,
                sceneAltitude + 1.0,
                0
            ),
            root: root
        )
    }

    // MARK: - Field Visualization

    private func createFieldLines(
        container: SCNNode,
        strengthTesla: Double
    ) {
        let count = 20

        let lineRadius = CGFloat(
            0.018 +
            min(
                max(
                    strengthTesla,
                    0.001
                ),
                10.0
            ) * 0.008
        )

        for index in 0..<count {
            let angle =
                Float(index) /
                Float(count) *
                Float.pi *
                2.0

            let radialScale = Float(
                2.8 +
                Double(index % 4) * 1.15
            )

            let x = cos(angle) * radialScale
            let z = sin(angle) * radialScale

            let points: [SCNVector3] = [
                SCNVector3(
                    x * 0.32,
                    8.65,
                    z * 0.32
                ),
                SCNVector3(
                    x,
                    11.8,
                    z
                ),
                SCNVector3(
                    x * 1.65,
                    16.2,
                    z * 1.65
                ),
                SCNVector3(
                    x * 1.25,
                    20.0,
                    z * 1.25
                ),
                SCNVector3(
                    x * 0.72,
                    13.0,
                    z * 0.72
                ),
                SCNVector3(
                    x * 0.32,
                    3.35,
                    z * 0.32
                )
            ]

            let fieldLine = lineNode(
                points: points,
                radius: lineRadius,
                color: UIColor.systemCyan
            )

            fieldLine.name = "MagneticFluxLine"

            container.addChildNode(fieldLine)

            addMovingParticle(
                to: container,
                points: points,
                delay: Double(index) * 0.08,
                color: UIColor.white
            )
        }
    }

    // MARK: - Dipole Generator

    private func createDipole(
        container: SCNNode
    ) {
        let upperPoleY: Float = 8.4
        let lowerPoleY: Float = 3.6

        let coreGeometry = SCNCylinder(
            radius: 0.72,
            height: 5.8
        )

        coreGeometry.firstMaterial = metallicMaterial(
            UIColor(
                red: 0.16,
                green: 0.18,
                blue: 0.22,
                alpha: 1
            )
        )

        let core = SCNNode(
            geometry: coreGeometry
        )

        core.name = "FerromagneticCore"

        core.position = SCNVector3(
            0,
            6.0,
            0
        )

        container.addChildNode(core)

        createPolePiece(
            name: "NorthPole",
            position: SCNVector3(
                0,
                upperPoleY,
                0
            ),
            color: UIColor.systemRed,
            container: container
        )

        createPolePiece(
            name: "SouthPole",
            position: SCNVector3(
                0,
                lowerPoleY,
                0
            ),
            color: UIColor.systemBlue,
            container: container
        )

        let upperAssembly = SCNNode()
        upperAssembly.name = "UpperCoilAssembly"

        upperAssembly.position = SCNVector3(
            0,
            7.25,
            0
        )

        container.addChildNode(upperAssembly)

        let lowerAssembly = SCNNode()
        lowerAssembly.name = "LowerCoilAssembly"

        lowerAssembly.position = SCNVector3(
            0,
            4.75,
            0
        )

        container.addChildNode(lowerAssembly)

        createExcitationCoil(
            name: "UpperExcitationCoil",
            color: UIColor.systemPink,
            turns: 8,
            assembly: upperAssembly
        )

        createExcitationCoil(
            name: "LowerExcitationCoil",
            color: UIColor.systemCyan,
            turns: 8,
            assembly: lowerAssembly
        )

        createInsulatorRing(
            position: SCNVector3(
                0,
                7.25,
                0
            ),
            container: container
        )

        createInsulatorRing(
            position: SCNVector3(
                0,
                4.75,
                0
            ),
            container: container
        )

        createBusBar(
            from: SCNVector3(
                -3.8,
                7.25,
                0
            ),
            to: SCNVector3(
                -1.9,
                7.25,
                0
            ),
            color: UIColor.systemOrange,
            container: container
        )

        createBusBar(
            from: SCNVector3(
                -3.8,
                4.75,
                0
            ),
            to: SCNVector3(
                -1.9,
                4.75,
                0
            ),
            color: UIColor.systemOrange,
            container: container
        )

        let controllerGeometry = SCNBox(
            width: 1.7,
            height: 2.3,
            length: 1.5,
            chamferRadius: 0.14
        )

        controllerGeometry.firstMaterial = metallicMaterial(
            UIColor(
                red: 0.12,
                green: 0.14,
                blue: 0.18,
                alpha: 1
            )
        )

        let controller = SCNNode(
            geometry: controllerGeometry
        )

        controller.position = SCNVector3(
            -4.7,
            5.95,
            0
        )

        container.addChildNode(controller)

        let lampGeometry = SCNSphere(
            radius: 0.15
        )

        lampGeometry.firstMaterial = emissiveMaterial(
            UIColor.systemOrange
        )

        let lamp = SCNNode(
            geometry: lampGeometry
        )

        lamp.position = SCNVector3(
            -4.7,
            6.3,
            0.78
        )

        container.addChildNode(lamp)
    }

    private func createPolePiece(
        name: String,
        position: SCNVector3,
        color: UIColor,
        container: SCNNode
    ) {
        let poleGeometry = SCNCylinder(
            radius: 1.55,
            height: 0.62
        )

        poleGeometry.firstMaterial = metallicMaterial(
            UIColor(
                red: 0.20,
                green: 0.22,
                blue: 0.26,
                alpha: 1
            )
        )

        let pole = SCNNode(
            geometry: poleGeometry
        )

        pole.name = name
        pole.position = position

        container.addChildNode(pole)

        let faceGeometry = SCNCylinder(
            radius: 1.20,
            height: 0.16
        )

        faceGeometry.firstMaterial = emissiveMaterial(
            color
        )

        let face = SCNNode(
            geometry: faceGeometry
        )

        face.name = "\(name)FieldFace"
        face.position = position

        container.addChildNode(face)
    }

    private func createExcitationCoil(
        name: String,
        color: UIColor,
        turns: Int,
        assembly: SCNNode
    ) {
        let coilRadius: CGFloat = 2.15
        let turnSpacing: Float = 0.18

        for index in 0..<turns {
            let geometry = SCNTorus(
                ringRadius: coilRadius,
                pipeRadius: 0.075
            )

            let material = emissiveMaterial(
                color
            )

            material.emission.intensity = 1.15

            geometry.firstMaterial = material

            let ring = SCNNode(
                geometry: geometry
            )

            ring.name = "\(name)_ExcitationCoil_\(index)"

            let offset =
                Float(index - turns / 2) *
                turnSpacing

            ring.position = SCNVector3(
                0,
                offset,
                0
            )

            assembly.addChildNode(ring)
        }

        let housingGeometry = SCNTorus(
            ringRadius: coilRadius + 0.32,
            pipeRadius: 0.10
        )

        housingGeometry.firstMaterial = metallicMaterial(
            UIColor(
                red: 0.20,
                green: 0.22,
                blue: 0.27,
                alpha: 1
            )
        )

        let housing = SCNNode(
            geometry: housingGeometry
        )

        housing.name = "\(name)_Housing"

        assembly.addChildNode(housing)
    }

    private func createInsulatorRing(
        position: SCNVector3,
        container: SCNNode
    ) {
        let geometry = SCNTorus(
            ringRadius: 1.55,
            pipeRadius: 0.12
        )

        geometry.firstMaterial = metallicMaterial(
            UIColor(
                red: 0.85,
                green: 0.85,
                blue: 0.88,
                alpha: 1
            )
        )

        let node = SCNNode(
            geometry: geometry
        )

        node.position = position

        container.addChildNode(node)
    }

    private func createBusBar(
        from start: SCNVector3,
        to end: SCNVector3,
        color: UIColor,
        container: SCNNode
    ) {
        let geometry = SCNCylinder(
            radius: 0.11,
            height: CGFloat(
                SCNVector3.distance(
                    start,
                    end
                )
            )
        )

        geometry.firstMaterial = emissiveMaterial(
            color
        )

        let node = SCNNode(
            geometry: geometry
        )

        node.position = (start + end) * 0.5

        node.look(
            at: end,
            up: SCNVector3(
                0,
                1,
                0
            ),
            localFront: SCNVector3(
                0,
                1,
                0
            )
        )

        container.addChildNode(node)
    }

    private func configureCoilRotation(
        node: SCNNode,
        running: Bool,
        frequencyKHz: Double,
        key: String
    ) {
        node.removeAnimation(
            forKey: key
        )

        guard running, frequencyKHz > 0 else {
            return
        }

        let normalizedFrequency = min(
            max(
                frequencyKHz / 100.0,
                0.01
            ),
            1.0
        )

        let rotation = CABasicAnimation(
            keyPath: "rotation"
        )

        rotation.fromValue = NSValue(
            scnVector4: SCNVector4(
                0,
                1,
                0,
                0
            )
        )

        rotation.toValue = NSValue(
            scnVector4: SCNVector4(
                0,
                1,
                0,
                Float.pi * 2.0
            )
        )

        rotation.duration = max(
            0.45,
            3.0 - normalizedFrequency * 2.4
        )

        rotation.repeatCount = .infinity

        node.addAnimation(
            rotation,
            forKey: key
        )
    }

    // MARK: - Collector Network

    private func createCollector(
        root: SCNNode,
        spokeCount: Int
    ) {
        let collectorGeometry = SCNCylinder(
            radius: 9,
            height: 0.18
        )

        collectorGeometry.firstMaterial = metallicMaterial(
            UIColor(
                white: 0.55,
                alpha: 1
            )
        )

        let collector = SCNNode(
            geometry: collectorGeometry
        )

        collector.name = "RadialCollectorNetwork"

        collector.position = SCNVector3(
            0,
            0.5,
            0
        )

        root.addChildNode(collector)

        let outerRing = SCNTorus(
            ringRadius: 7.5,
            pipeRadius: 0.12
        )

        outerRing.firstMaterial = emissiveMaterial(
            UIColor.systemCyan
        )

        let outerRingNode = SCNNode(
            geometry: outerRing
        )

        outerRingNode.position = SCNVector3(
            0,
            0.70,
            0
        )

        root.addChildNode(outerRingNode)

        let visibleSpokeCount = min(
            max(
                spokeCount,
                4
            ),
            64
        )

        for index in 0..<visibleSpokeCount {
            let angle =
                Float(index) /
                Float(visibleSpokeCount) *
                Float.pi *
                2.0

            let length: Float = 8.0

            let conductor = lineNode(
                points: [
                    SCNVector3(
                        cos(angle) * length,
                        0.67,
                        sin(angle) * length
                    ),
                    SCNVector3(
                        0,
                        0.67,
                        0
                    )
                ],
                radius: 0.045,
                color: UIColor.systemCyan
            )

            root.addChildNode(conductor)
        }

        for radius in stride(
            from: 2.0,
            through: 7.0,
            by: 1.25
        ) {
            let geometry = SCNTorus(
                ringRadius: CGFloat(radius),
                pipeRadius: 0.03
            )

            geometry.firstMaterial = metallicMaterial(
                UIColor.systemGray
            )

            let ring = SCNNode(
                geometry: geometry
            )

            ring.position = SCNVector3(
                0,
                0.69,
                0
            )

            root.addChildNode(ring)
        }
    }

    private func createCurrentPath(
        root: SCNNode
    ) {
        let points: [SCNVector3] = [
            SCNVector3(0, 0.67, 0),
            SCNVector3(0, -1.5, 0),
            SCNVector3(0, -3.5, 0),
            SCNVector3(4, -4.5, 0),
            SCNVector3(8, -4.5, 0)
        ]

        let currentPath = lineNode(
            points: points,
            radius: 0.14,
            color: UIColor.systemYellow
        )

        root.addChildNode(currentPath)

        addMovingParticle(
            to: root,
            points: points,
            delay: 0,
            color: UIColor.systemYellow
        )
    }

    private func createTerminal(
        root: SCNNode
    ) {
        let geometry = SCNSphere(
            radius: 0.55
        )

        geometry.firstMaterial = emissiveMaterial(
            UIColor.systemYellow
        )

        let terminal = SCNNode(
            geometry: geometry
        )

        terminal.position = SCNVector3(
            0,
            -2,
            0
        )

        root.addChildNode(terminal)
    }

    private func createPowerConditioning(
        root: SCNNode
    ) {
        let geometry = SCNBox(
            width: 4,
            height: 2.5,
            length: 2.5,
            chamferRadius: 0.2
        )

        geometry.firstMaterial = metallicMaterial(
            UIColor.systemGray
        )

        let node = SCNNode(
            geometry: geometry
        )

        node.position = SCNVector3(
            7,
            3,
            0
        )

        root.addChildNode(node)
    }

    private func createLoad(
        root: SCNNode
    ) {
        let geometry = SCNBox(
            width: 4,
            height: 2,
            length: 2,
            chamferRadius: 0.2
        )

        geometry.firstMaterial = emissiveMaterial(
            UIColor.systemGreen
        )

        let node = SCNNode(
            geometry: geometry
        )

        node.position = SCNVector3(
            7,
            0,
            0
        )

        root.addChildNode(node)
    }

    // MARK: - Scene Labels

    private func createLabels(
        root: SCNNode
    ) {
        addLabel(
            "IONOSPHERIC REGION",
            position: SCNVector3(
                -5,
                30,
                0
            ),
            root: root
        )

        addLabel(
            "NORTH POLE / COIL",
            position: SCNVector3(
                -6,
                9,
                0
            ),
            root: root
        )

        addLabel(
            "SOUTH POLE / COIL",
            position: SCNVector3(
                -6,
                3,
                0
            ),
            root: root
        )

        addLabel(
            "RADIAL COLLECTOR",
            position: SCNVector3(
                -5,
                1.5,
                0
            ),
            root: root
        )

        addLabel(
            "POWER CONDITIONING",
            position: SCNVector3(
                7,
                4.8,
                0
            ),
            root: root
        )

        addLabel(
            "LOAD",
            position: SCNVector3(
                7,
                1.7,
                0
            ),
            root: root
        )
    }

    private func addLabel(
        _ text: String,
        position: SCNVector3,
        root: SCNNode
    ) {
        let geometry = SCNText(
            string: text,
            extrusionDepth: 0.01
        )

        geometry.font = UIFont.systemFont(
            ofSize: 0.42,
            weight: .bold
        )

        geometry.flatness = 0.1

        geometry.firstMaterial = emissiveMaterial(
            UIColor.white
        )

        let label = SCNNode(
            geometry: geometry
        )

        label.position = position

        let bounds = geometry.boundingBox

        let width =
            bounds.max.x -
            bounds.min.x

        label.pivot = SCNMatrix4MakeTranslation(
            width / 2.0,
            0,
            0
        )

        root.addChildNode(label)
    }

    // MARK: - Line and Particle Helpers

    private func addMovingParticle(
        to parent: SCNNode,
        points: [SCNVector3],
        delay: Double,
        color: UIColor
    ) {
        guard points.count >= 2 else {
            return
        }

        let geometry = SCNSphere(
            radius: 0.09
        )

        geometry.firstMaterial = emissiveMaterial(
            color
        )

        let particle = SCNNode(
            geometry: geometry
        )

        particle.position = points[0]

        parent.addChildNode(particle)

        var actions: [SCNAction] = []

        for index in 0..<(points.count - 1) {
            let start = points[index]
            let end = points[index + 1]

            let distance = SCNVector3.distance(
                start,
                end
            )

            let duration = TimeInterval(
                max(
                    Double(distance) * 0.08,
                    0.05
                )
            )

            actions.append(
                SCNAction.move(
                    to: end,
                    duration: duration
                )
            )
        }

        actions.append(
            SCNAction.move(
                to: points[0],
                duration: 0
            )
        )

        let sequence = SCNAction.sequence(
            actions
        )

        particle.runAction(
            SCNAction.sequence([
                SCNAction.wait(
                    duration: delay
                ),
                SCNAction.repeatForever(
                    sequence
                )
            ])
        )
    }

    private func lineNode(
        points: [SCNVector3],
        radius: CGFloat,
        color: UIColor
    ) -> SCNNode {
        let container = SCNNode()

        guard points.count >= 2 else {
            return container
        }

        for index in 0..<(points.count - 1) {
            let segment = cylinderBetween(
                start: points[index],
                end: points[index + 1],
                radius: radius,
                color: color
            )

            container.addChildNode(segment)
        }

        return container
    }

    private func cylinderBetween(
        start: SCNVector3,
        end: SCNVector3,
        radius: CGFloat,
        color: UIColor
    ) -> SCNNode {
        let length = SCNVector3.distance(
            start,
            end
        )

        let geometry = SCNCylinder(
            radius: radius,
            height: CGFloat(length)
        )

        geometry.firstMaterial = emissiveMaterial(
            color
        )

        let node = SCNNode(
            geometry: geometry
        )

        node.position = (start + end) * 0.5

        node.look(
            at: end,
            up: SCNVector3(
                0,
                1,
                0
            ),
            localFront: SCNVector3(
                0,
                1,
                0
            )
        )

        return node
    }

    // MARK: - Materials

    private func emissiveMaterial(
        _ color: UIColor
    ) -> SCNMaterial {
        let material = SCNMaterial()

        material.diffuse.contents = color
        material.emission.contents = color

        return material
    }

    private func metallicMaterial(
        _ color: UIColor
    ) -> SCNMaterial {
        let material = SCNMaterial()

        material.diffuse.contents = color
        material.metalness.contents = 0.8
        material.roughness.contents = 0.25

        return material
    }

    private func transparentMaterial(
        _ color: UIColor,
        opacity: CGFloat
    ) -> SCNMaterial {
        let material = SCNMaterial()

        material.diffuse.contents = color
        material.transparency = opacity
        material.blendMode = .add

        return material
    }
}

// MARK: - SCNVector3 Math

extension SCNVector3 {

    static func + (
        lhs: SCNVector3,
        rhs: SCNVector3
    ) -> SCNVector3 {
        SCNVector3(
            lhs.x + rhs.x,
            lhs.y + rhs.y,
            lhs.z + rhs.z
        )
    }

    static func - (
        lhs: SCNVector3,
        rhs: SCNVector3
    ) -> SCNVector3 {
        SCNVector3(
            lhs.x - rhs.x,
            lhs.y - rhs.y,
            lhs.z - rhs.z
        )
    }

    static func * (
        lhs: SCNVector3,
        rhs: Float
    ) -> SCNVector3 {
        SCNVector3(
            lhs.x * rhs,
            lhs.y * rhs,
            lhs.z * rhs
        )
    }

    static func distance(
        _ start: SCNVector3,
        _ end: SCNVector3
    ) -> Float {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z

        return sqrt(
            dx * dx +
            dy * dy +
            dz * dz
        )
    }
}

// MARK: - SCNNode Orientation

extension SCNNode {

    func look(
        at target: SCNVector3,
        up: SCNVector3 = SCNVector3(
            0,
            1,
            0
        ),
        localFront: SCNVector3 = SCNVector3(
            0,
            0,
            -1
        )
    ) {
        let position = worldPosition

        let direction = SCNVector3(
            target.x - position.x,
            target.y - position.y,
            target.z - position.z
        )

        let directionLength = sqrt(
            direction.x * direction.x +
            direction.y * direction.y +
            direction.z * direction.z
        )

        guard directionLength > 0.000001 else {
            return
        }

        let normalizedDirection = SCNVector3(
            direction.x / directionLength,
            direction.y / directionLength,
            direction.z / directionLength
        )

        let frontLength = sqrt(
            localFront.x * localFront.x +
            localFront.y * localFront.y +
            localFront.z * localFront.z
        )

        guard frontLength > 0.000001 else {
            return
        }

        let normalizedFront = SCNVector3(
            localFront.x / frontLength,
            localFront.y / frontLength,
            localFront.z / frontLength
        )

        let axis = SCNVector3(
            normalizedFront.y * normalizedDirection.z
                - normalizedFront.z * normalizedDirection.y,

            normalizedFront.z * normalizedDirection.x
                - normalizedFront.x * normalizedDirection.z,

            normalizedFront.x * normalizedDirection.y
                - normalizedFront.y * normalizedDirection.x
        )

        let axisLength = sqrt(
            axis.x * axis.x +
            axis.y * axis.y +
            axis.z * axis.z
        )

        let dot = max(
            -1.0,
            min(
                1.0,
                normalizedFront.x * normalizedDirection.x +
                normalizedFront.y * normalizedDirection.y +
                normalizedFront.z * normalizedDirection.z
            )
        )

        let angle = acos(dot)

        if axisLength > 0.000001 {
            rotation = SCNVector4(
                axis.x / axisLength,
                axis.y / axisLength,
                axis.z / axisLength,
                angle
            )
        } else if dot < 0 {
            rotation = SCNVector4(
                up.x,
                up.y,
                up.z,
                Float.pi
            )
        }
    }
}
