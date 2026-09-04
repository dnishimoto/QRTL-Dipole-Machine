
import SwiftUI
import SceneKit

struct ContentView: View {

    @StateObject private var model = QRTLDipoleModel()
    @State private var showingAbout = false

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {

                    titleSection
                    sceneSection
                    outputSection
                    multiCoilSection
                    fieldFluxSection
                    collectorSection
                    controlsSection
                    equationSection
                    limitationSection
                }
                .padding()
            }

            .navigationTitle("QRTL Dipole Energy")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About QRTL Dipole Machine")
                }
            }
        }

        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}


// MARK: - Title

private extension ContentView {

    var titleSection: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("QRTL Dipole Energy System")
                .font(.largeTitle.bold())

            Text("Multi-coil magnetic-field and energy-collection model")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("""
            The simulation models a dipole field, a defined coupling region, a QRTL collection pathway, conversion losses, and net electrical output.
            """)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}


// MARK: - Scene

private extension ContentView {

    var sceneSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionHeader(
                "SYSTEM MODEL",
                analogy: """
                Think of the system as a chain: the coils establish the magnetic field, the coupling region represents where collection occurs, and the electrical conversion stage determines how much modeled power remains available as net output.
                """
            )

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

                couplingAltitudeKm: model.couplingAltitudeKm,
                couplingRadiusKm: model.couplingRadiusKm,

                radialSpokeCount: Int(model.radialSpokeCount),
                fluxManagementGain: model.fluxManagementGain
  

               )
            .frame(
                height: 360
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )

            HStack(
                spacing: 8
            ) {

                systemStage("FIELD GENERATION")

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                systemStage("FIELD COUPLING")

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                systemStage("ENERGY COLLECTION")

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                systemStage("NET OUTPUT")
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }

    func systemStage(_ text: String) -> some View {

        Text(text)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}


// MARK: - Output

private extension ContentView {
 
    var outputSection: some View {


            VStack(
                alignment: .leading,
                spacing: 16
            ) {
                
                sectionHeader(
                    "SYSTEM OUTPUT",
                    analogy: """
                Think of this like a water plant. Gross collected power is the water entering the plant, operating costs are the energy used by the equipment, and net output is what remains after those costs.
                """
                )
                
                VStack(spacing: 4) {
                    
                    Text("QRTL MODELED NET OUTPUT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Text(
                        PowerFormatter.string(
                            megawatts: model.qrtlNetOutputMW
                        )
                    )
                    .font(
                        .system(
                            size: 48,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    
                    Text(
                        String(
                            format: "%.1f kW",
                            model.displayedNetOutputKW
                        )
                    )
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                
                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {
                    
                    HStack {
                        
                        Text("Design Target")
                        
                        Spacer()
                        
                        Text(
                            PowerFormatter.string(
                                megawatts: model.targetNetOutputMW
                            )
                        )
                        .fontWeight(.semibold)
                    }
                    
                    ProgressView(
                        value: min(
                            max(model.targetPercent / 100.0, 0),
                            1
                        )
                    )
                    
                    HStack {
                        
                        Text(
                            String(
                                format: "%.1f%% of target",
                                model.targetPercent
                            )
                        )
                        
                        Spacer()
                        
                        Text(model.targetStatus)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                outputMetric(
                    "QRTL Gross Collected",
                    PowerFormatter.string(
                        megawatts: model.qrtlFieldCollectionPowerMW
                    )
                )
                
                outputMetric(
                    "Captured Field Current",
                    String(
                        format: "%.4e A",
                        model.capturedFieldCurrentA
                    )
                )
                
                outputMetric(
                    "Collection Voltage",
                    String(
                        format: "%.4e V",
                        model.fieldCurrentCollectionVoltageV
                    )
                )
                
                outputMetric(
                    "Operating Costs",
                    String(
                        format: "%.3f MW",
                        model.qrtlOperatingCostsWatts / 1_000_000
                    )
                )
                
                Divider()
                
                Text("CONVENTIONAL FARADAY REFERENCE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                outputMetric(
                    "Faraday Net Output",
                    PowerFormatter.string(
                        megawatts: model.conventionalNetOutputMW
                    )
                )
                
                Text("""
            The QRTL value is a separate modeled collection pathway. The Faraday value is the conventional electromagnetic-induction reference calculated by the model.
            """)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
  
        .panelStyle()
    }

    func outputMetric(
        _ title: String,
        _ value: String
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}


// MARK: - Multi Coil

private extension ContentView {

    var multiCoilSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionHeader(
                "MULTI-COIL FIELD",
                analogy: """
                Imagine several people pushing the same flywheel. Turns and current determine how strongly each coil contributes, while coil position and phase determine how those contributions combine.
                """
            )

            CoilMetricRow(
                title: "Primary",
                turns: model.primaryTurns,
                currentA: model.primaryCurrentA,
                radiusM: model.primaryRadiusM
                 )

            if model.upperShapingEnabled {

                CoilMetricRow(
                    title: "Upper Shaping",
                    turns: model.upperTurns,
                    currentA: model.upperCurrentA,
                    radiusM: model.upperRadiusM
                )
            }

            if model.lowerReturnEnabled {

                CoilMetricRow(
                    title: "Lower Return",
                    turns: model.lowerTurns,
                    currentA: model.lowerCurrentA,
                    radiusM: model.lowerRadiusM
                )
            }

            Divider()

            outputMetric(
                "Total Ampere-Turns",
                String(
                    format: "%.3e AT",
                    model.totalAmpereTurns
                )
            )

            outputMetric(
                "Flux Management Gain",
                String(
                    format: "%.3f×",
                    model.fluxManagementGain
                )
            )

            outputMetric(
                "Coupling Alignment",
                String(
                    format: "%.3f",
                    model.couplingAlignmentFactor
                )
            )

            if model.isFieldPowerLimited {

                Label(
                    "Field system is limited by the configured field-power budget.",
                    systemImage: "exclamationmark.triangle"
                )
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
        .panelStyle()
    }
}


// MARK: - Field and Coupling

private extension ContentView {

    var fieldFluxSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionHeader(
                "FIELD & COUPLING",
                analogy: """
                Think of the magnetic field as an invisible funnel. The coils create the field, and the coupling region is the part of the model where magnetic flux is evaluated for collection.
                """
            )

            outputMetric(
                "Coupling Altitude",
                String(
                    format: "%.2f km",
                    model.couplingAltitudeKm
                )
            )

            outputMetric(
                "Coupling Radius",
                String(
                    format: "%.3f km",
                    model.couplingRadiusKm
                )
            )

            outputMetric(
                "Field at Coupling Center",
                String(
                    format: "%.4e T",
                    model.fieldAtCouplingCenterTesla
                )
            )

            outputMetric(
                "Peak Magnetic Flux",
                String(
                    format: "%.4e Wb",
                    model.peakMagneticFluxWebers
                )
            )
        }
        .panelStyle()
    }
}


// MARK: - Collector

private extension ContentView {

    var collectorSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionHeader(
                "ENERGY COLLECTION",
                analogy: """
                Imagine a receiving network collecting energy from a defined field region. The important quantities here are the modeled collected power and the efficiencies that determine how much survives the conversion chain.
                """
            )

            outputMetric(
                "Collector Area",
                String(
                    format: "%.2f acres",
                    model.collectorAreaAcres
                )
            )

            outputMetric(
                "Collector Current",
                String(
                    format: "%.3e A",
                    model.collectorCurrentA
                )
            )

            outputMetric(
                "Collector Resistance",
                String(
                    format: "%.6g Ω",
                    model.collectorResistanceOhms
                )
            )

            outputMetric(
                "Contact Efficiency",
                String(
                    format: "%.1f%%",
                    model.contactEfficiency * 100
                )
            )

            outputMetric(
                "Conversion Efficiency",
                String(
                    format: "%.1f%%",
                    model.conversionEfficiency * 100
                )
            )
        }
        .panelStyle()
    }
}


// MARK: - Controls

private extension ContentView {

    var controlsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            sectionHeader(
                "POWER OUTPUT CONTROLS",
                analogy: """
                These are the controls that matter most to the modeled net collected power. Each one changes field generation, field coupling, collection, or the conversion chain.
                """
            )

            // MARK: System

            Text("SYSTEM")
                .font(.headline)

            ControlToggle(
                title: "System Running",
                variable: "isRunning",
                explanation: "Turns the modeled system on or off.",
                isOn: $model.isRunning
            )

            ControlToggle(
                title: "QRTL Field Collection",
                variable: "qrtlFieldCollectionEnabled",
                explanation: "Enables the separate QRTL modeled collection pathway.",
                isOn: $model.qrtlFieldCollectionEnabled
            )

            Divider()

            // MARK: Target

            Text("OUTPUT TARGET")
                .font(.headline)

            ParameterSlider(
                title: "Target Net Output",
                variable: "targetNetOutputMW",
                value: $model.targetNetOutputMW,
                range: 0.001...100,
                step: 0.001,
                unit: "MW",
                explanation: "Sets the desired net output target. Increasing it does not create additional power; it raises the target used by the progress indicator."
            )

            Divider()

            // MARK: Primary

            Text("PRIMARY FIELD COIL")
                .font(.headline)

            ParameterSlider(
                title: "Turns",
                variable: "primaryTurns",
                value: $model.primaryTurns,
                range: 1...100_000,
                step: 1,
                unit: "",
                explanation: "Changes the number of primary turns and therefore the modeled magnetic moment."
            )

            ParameterSlider(
                title: "Current",
                variable: "primaryCurrentA",
                value: $model.primaryCurrentA,
                range: 0...100_000,
                step: 1,
                unit: "A",
                explanation: "Changes primary current. Higher current strengthens the modeled field but also increases coil losses."
            )

            ParameterSlider(
                title: "Radius",
                variable: "primaryRadiusM",
                value: $model.primaryRadiusM,
                range: 0.1...1000,
                step: 0.1,
                unit: "m",
                explanation: "Changes coil area and magnetic-field geometry."
            )

            Divider()

            // MARK: Upper

            Text("UPPER SHAPING COIL")
                .font(.headline)

            ControlToggle(
                title: "Enabled",
                variable: "upperShapingEnabled",
                explanation: "Includes or removes the upper shaping coil from the modeled field.",
                isOn: $model.upperShapingEnabled
            )

            ParameterSlider(
                title: "Turns",
                variable: "upperTurns",
                value: $model.upperTurns,
                range: 1...100_000,
                step: 1,
                unit: "",
                explanation: "Changes the upper coil's contribution to the modeled magnetic field."
            )

            ParameterSlider(
                title: "Current",
                variable: "upperCurrentA",
                value: $model.upperCurrentA,
                range: 0...100_000,
                step: 1,
                unit: "A",
                explanation: "Changes the upper coil field contribution and its electrical losses."
            )

            ParameterSlider(
                title: "Radius",
                variable: "upperRadiusM",
                value: $model.upperRadiusM,
                range: 0.1...1000,
                step: 0.1,
                unit: "m",
                explanation: "Changes upper coil area and field geometry."
            )

            ParameterSlider(
                title: "Height",
                variable: "upperHeightM",
                value: $model.upperHeightM,
                range: -1000...1000,
                step: 0.1,
                unit: "m",
                explanation: "Moves the upper coil and changes the spatial distribution of the modeled field."
            )

            ParameterSlider(
                title: "Phase",
                variable: "upperPhaseDegrees",
                value: $model.upperPhaseDegrees,
                range: -180...180,
                step: 1,
                unit: "°",
                explanation: "Changes the upper coil phase and can alter modeled field reinforcement or cancellation."
            )

            Divider()

            // MARK: Lower

            Text("LOWER RETURN COIL")
                .font(.headline)

            ControlToggle(
                title: "Enabled",
                variable: "lowerReturnEnabled",
                explanation: "Includes or removes the lower return coil from the modeled field.",
                isOn: $model.lowerReturnEnabled
            )

            ParameterSlider(
                title: "Turns",
                variable: "lowerTurns",
                value: $model.lowerTurns,
                range: 1...100_000,
                step: 1,
                unit: "",
                explanation: "Changes the lower coil's contribution to the modeled magnetic field."
            )

            ParameterSlider(
                title: "Current",
                variable: "lowerCurrentA",
                value: $model.lowerCurrentA,
                range: 0...100_000,
                step: 1,
                unit: "A",
                explanation: "Changes lower coil field contribution and electrical losses."
            )

            ParameterSlider(
                title: "Radius",
                variable: "lowerRadiusM",
                value: $model.lowerRadiusM,
                range: 0.1...1000,
                step: 0.1,
                unit: "m",
                explanation: "Changes lower coil area and field geometry."
            )

            ParameterSlider(
                title: "Height",
                variable: "lowerHeightM",
                value: $model.lowerHeightM,
                range: -1000...1000,
                step: 0.1,
                unit: "m",
                explanation: "Moves the lower coil and changes the spatial field distribution."
            )

            ParameterSlider(
                title: "Phase",
                variable: "lowerPhaseDegrees",
                value: $model.lowerPhaseDegrees,
                range: -180...180,
                step: 1,
                unit: "°",
                explanation: "Changes the lower coil phase and can alter modeled field reinforcement or cancellation."
            )

            Divider()

            // MARK: Coupling

            Text("FIELD COUPLING")
                .font(.headline)

            ParameterSlider(
                title: "Flux Management Gain",
                variable: "fluxManagementGain",
                value: $model.fluxManagementGain,
                range: 0.1...10,
                step: 0.01,
                unit: "×",
                explanation: "Changes the modeled flux-management multiplier applied to useful magnetic flux."
            )

            ParameterSlider(
                title: "Coupling Alignment",
                variable: "couplingAlignmentFactor",
                value: $model.couplingAlignmentFactor,
                range: 0...1,
                step: 0.01,
                unit: "",
                explanation: "Represents how well the generated field is aligned with the modeled collection region."
            )

            ParameterSlider(
                title: "Coupling Altitude",
                variable: "couplingAltitudeKm",
                value: $model.couplingAltitudeKm,
                range: 0.1...500,
                step: 0.1,
                unit: "km",
                explanation: "Moves the modeled coupling region closer to or farther from the field source."
            )

            ParameterSlider(
                title: "Coupling Radius",
                variable: "couplingRadiusKm",
                value: $model.couplingRadiusKm,
                range: 0.001...250,
                step: 0.001,
                unit: "km",
                explanation: "Changes the size of the modeled region over which collection is evaluated."
            )

            Divider()

            // MARK: Conversion

            Text("POWER CONVERSION")
                .font(.headline)

            ParameterSlider(
                title: "Contact Efficiency",
                variable: "contactEfficiency",
                value: $model.contactEfficiency,
                range: 0.1...1,
                step: 0.01,
                unit: "",
                explanation: "Determines what fraction of modeled QRTL collected power survives the collection/contact interface."
            )

            ParameterSlider(
                title: "Conversion Efficiency",
                variable: "conversionEfficiency",
                value: $model.conversionEfficiency,
                range: 0.1...1,
                step: 0.01,
                unit: "",
                explanation: "Determines what fraction of post-contact modeled power becomes usable electrical output."
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
}


// MARK: - Equations

private extension ContentView {

    var equationSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionHeader(
                "MODEL EQUATIONS",
                analogy: """
                Think of these equations as the rulebook for the simulation. The controls change the inputs, while these relationships determine the calculated field, collection, and output.
                """
            )

            EquationStep(
                title: "Magnetic Moment",
                equation: "m = NIA",
                explanation: "The modeled magnetic moment depends on turns, current, and coil area."
            )

            EquationStep(
                title: "Magnetic Flux",
                equation: "Φ = ∫ B · dA",
                explanation: "Magnetic flux represents the field passing through the modeled collection area."
            )

            EquationStep(
                title: "Faraday EMF",
                equation: "V = −N(dΦ/dt)",
                explanation: "Changing magnetic flux produces the conventional induced voltage used by the Faraday reference pathway."
            )

            EquationStep(
                title: "Circuit Loss",
                equation: "P = I²R",
                explanation: "Resistive losses increase with current and resistance."
            )

            EquationStep(
                title: "QRTL Modeled Collection",
                equation: "P_QRTL = I_captured × V_collection",
                explanation: "The QRTL pathway calculates modeled collection from the captured field-aligned current and modeled collection voltage."
            )

            EquationStep(
                title: "Net Output",
                equation: "P_net = P_converted − P_operating",
                explanation: "Operating costs are subtracted from converted collected power to determine modeled net output."
            )
        }
        .panelStyle()
    }
}


// MARK: - Limitations

private extension ContentView {

    var limitationSection: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            sectionHeader(
                "MODEL SCOPE",
                analogy: """
                Think of this like a flight simulator. It can calculate the behavior represented by its programmed equations, but a simulated result is not the same as experimental confirmation in the physical world.
                """
            )

            Text("""
            The conventional pathway uses electromagnetic-induction relationships. The QRTL collection pathway is modeled separately using the specified field-aligned current, capture efficiency, and collection voltage parameters.

            The QRTL captured current and collection voltage are model inputs rather than experimentally established measurements. Therefore, the QRTL net-power result should be interpreted as a simulation result, not as a demonstrated physical energy source.

            More complete physical validation would require experimental measurements and, where appropriate, numerical electromagnetic modeling of the full three-dimensional geometry.
            """)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }
}


// MARK: - Shared UI

private extension ContentView {

    func sectionHeader(
        _ title: String,
        analogy: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(title)
                .font(.headline)

            HStack(
                alignment: .top,
                spacing: 8
            ) {

                Image(systemName: "lightbulb")
                    .foregroundStyle(.secondary)

                Text(analogy)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
    }
}




// MARK: - Toggle

private struct ControlToggle: View {

    let title: String
    let variable: String
    let explanation: String

    @Binding var isOn: Bool

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Toggle(
                title,
                isOn: $isOn
            )
            .font(.subheadline.weight(.semibold))

            HStack(
                alignment: .top,
                spacing: 6
            ) {

                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text(variable)
                        .font(
                            .system(
                                size: 10,
                                design: .monospaced
                            )
                        )
                        .foregroundStyle(.secondary)

                    Text(explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
            }
            .padding(.leading, 4)
        }
    }
}

private extension View {

    func panelStyle() -> some View {

        self
            .padding()
            .background(
                .thinMaterial,
                in: RoundedRectangle(
                    cornerRadius: 18
                )
            )
    }
}


