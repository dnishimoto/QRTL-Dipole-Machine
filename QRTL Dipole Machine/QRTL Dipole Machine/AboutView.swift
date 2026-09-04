
import SwiftUI

struct AboutView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 28) {

                    // ====================================================
                    // HEADER
                    // ====================================================

                    VStack(spacing: 14) {

                        Image(systemName: "atom")
                            .font(.system(size: 58))
                            .symbolRenderingMode(.hierarchical)

                        Text("QRTL Dipole Machine")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text("How the Machine Works")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Text(
                            "A simple explanation of how the simulation "
                            + "creates, shapes, couples, collects, converts, "
                            + "and evaluates electrical power."
                        )
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)

                    // ====================================================
                    // BIG PICTURE
                    // ====================================================

                    bigPictureCard

                    // ====================================================
                    // THE PIPELINE
                    // ====================================================

                    sectionTitle(
                        "The Complete Machine Pipeline",
                        systemImage: "arrow.down"
                    )

                    pipelineOverviewCard

                    // ====================================================
                    // 1. POWER
                    // ====================================================

                    sectionTitle(
                        "1. Power the Machine",
                        systemImage: "bolt.fill"
                    )

                    paragraphCard {

                        Text(
                            "Everything begins with electrical power. The "
                            + "machine does not begin with electricity appearing "
                            + "at the collector. Instead, electrical power is first "
                            + "supplied to the field-generation system. That power "
                            + "causes current to flow through the machine's coils. "
                            + "The coils then create the magnetic field that the "
                            + "rest of the simulation studies."
                        )

                        Text(
                            "A simple way to understand this is to imagine a "
                            + "large water pump. Before the pump is turned on, "
                            + "there is no water being pushed through the system. "
                            + "When power is supplied to the pump, the pump begins "
                            + "moving water. In this analogy, the electrical power "
                            + "is what operates the pump, while the magnetic field "
                            + "is similar to the flow produced by the pump."
                        )

                        Text(
                            "This is an important starting point because the "
                            + "simulation does not treat the machine as a device "
                            + "that creates energy from nothing. The field system "
                            + "requires an input. The purpose of the simulation is "
                            + "to investigate what happens after that controlled "
                            + "magnetic field has been created."
                        )
                    }

                    // ====================================================
                    // 2. PRIMARY COIL
                    // ====================================================

                    sectionTitle(
                        "2. Create the Main Magnetic Field",
                        systemImage: "circle.dotted"
                    )

                    paragraphCard {

                        Text(
                            "The primary coil is the heart of the magnetic system. "
                            + "It consists of many turns of conductor carrying "
                            + "electrical current. When current flows through those "
                            + "turns, a magnetic field is produced. The simulation "
                            + "uses the number of turns, the current, the size of "
                            + "the coil, and its geometry to calculate the modeled "
                            + "magnetic behavior."
                        )

                        Text(
                            "The water-pump analogy helps here. Think of the "
                            + "primary coil as the main pump in a large water "
                            + "system. Increasing the pumping capability changes "
                            + "the amount and strength of flow available to the "
                            + "rest of the system. In the same way, changing the "
                            + "coil current or number of turns changes the magnetic "
                            + "characteristics of the modeled field."
                        )

                        Text(
                            "The important idea is that the primary coil establishes "
                            + "the main magnetic structure. It creates the dipole "
                            + "field around which the rest of the machine is designed."
                        )
                    }

                    // ====================================================
                    // 3. FIELD SHAPING
                    // ====================================================

                    sectionTitle(
                        "3. Shape and Control the Magnetic Field",
                        systemImage: "circle.3.stack"
                    )

                    paragraphCard {

                        Text(
                            "The machine does not rely on the primary coil alone. "
                            + "Additional coils can be positioned above and below "
                            + "the primary coil. These coils provide additional "
                            + "control over the shape, strength, and timing of the "
                            + "combined magnetic field."
                        )

                        Text(
                            "A useful analogy is a water system with one large "
                            + "pump and several adjustable valves or nozzles. "
                            + "The main pump creates the flow, but the valves help "
                            + "control where that flow goes. If a valve is opened, "
                            + "closed, moved, or operated at a different time, the "
                            + "overall flow pattern changes."
                        )

                        Text(
                            "The same concept is applied to the three-coil system. "
                            + "The primary coil provides the main field. The upper "
                            + "coil helps shape the field above the primary coil, "
                            + "while the lower coil helps control the return portion "
                            + "of the field. Their currents, positions, and phases "
                            + "can influence the resulting field geometry."
                        )

                        Text(
                            "Phase is especially useful when the field is changing "
                            + "with time. Phase describes timing. Two coils operating "
                            + "together can reinforce one another, while coils operating "
                            + "at different phases can produce a different combined "
                            + "field pattern. The simulation allows these relationships "
                            + "to be explored rather than assuming that one fixed field "
                            + "configuration is always optimal."
                        )
                    }

                    // ====================================================
                    // 4. FIELD VARIATION
                    // ====================================================

                    sectionTitle(
                        "4. Change the Magnetic Field",
                        systemImage: "waveform"
                    )

                    paragraphCard {

                        Text(
                            "The next important idea is movement or change. A "
                            + "magnetic field can exist without continuously producing "
                            + "electrical power through conventional electromagnetic "
                            + "induction. For conventional induction, the magnetic "
                            + "flux through the receiving system must change with time."
                        )

                        Text(
                            "Imagine a lake. A lake can contain an enormous amount "
                            + "of water, but if the surface is completely still, there "
                            + "is no continuous wave moving across it. Now imagine "
                            + "waves traveling across the lake. The water is changing "
                            + "with time, and that changing motion can interact with "
                            + "objects floating on the surface."
                        )

                        Text(
                            "The same general idea helps explain why the simulation "
                            + "can use AC or pulsed magnetic fields. Instead of creating "
                            + "a field that simply sits at one constant value, the "
                            + "machine can repeatedly change the field. This gives "
                            + "the simulation a time-varying magnetic flux that can "
                            + "be evaluated by the conventional electromagnetic "
                            + "calculation."
                        )

                        formulaBox("V = N × dΦ/dt")

                        Text(
                            "The important part of this relationship is dΦ/dt. "
                            + "It represents how quickly the magnetic flux changes. "
                            + "If the flux changes through the receiver, an induced "
                            + "voltage can be produced. If the magnetic field is "
                            + "completely static, this conventional induction pathway "
                            + "does not provide a continuously changing induced voltage."
                        )
                    }

                    // ====================================================
                    // 5. COUPLING REGION
                    // ====================================================

                    sectionTitle(
                        "5. Extend the Field to the Coupling Region",
                        systemImage: "dot.radiowaves.left.and.right"
                    )

                    paragraphCard {

                        Text(
                            "Once the magnetic field has been created and shaped, "
                            + "the simulation asks what happens farther away from "
                            + "the coils. This is where the coupling region becomes "
                            + "important. The coupling region is a defined area "
                            + "where the simulation evaluates the modeled interaction."
                        )

                        Text(
                            "Imagine placing a large invisible screen above the "
                            + "machine. The coils are on the ground, and the magnetic "
                            + "field extends outward toward the screen. The screen "
                            + "does not create the field. It simply gives the simulation "
                            + "a defined place where the field can be examined."
                        )

                        Text(
                            "The coupling region has characteristics such as an "
                            + "altitude and radius. Moving that region changes the "
                            + "location where the simulation evaluates the field. "
                            + "This is similar to moving a measurement instrument "
                            + "closer to or farther away from a source."
                        )

                        Text(
                            "Distance matters because magnetic fields are not "
                            + "uniform everywhere. The field strength, direction, "
                            + "and geometry can change with distance from the coils. "
                            + "The simulation therefore uses the coil geometry and "
                            + "the coupling-region geometry together when examining "
                            + "the modeled interaction."
                        )
                    }

                    // ====================================================
                    // 6. TWO PATHS
                    // ====================================================

                    sectionTitle(
                        "6. Two Different Energy Paths",
                        systemImage: "arrow.triangle.branch"
                    )

                    twoPathCard

                    // ====================================================
                    // CONVENTIONAL PATH
                    // ====================================================

                    sectionTitle(
                        "The Conventional Electromagnetic Path",
                        systemImage: "arrow.triangle.2.circlepath"
                    )

                    paragraphCard {

                        Text(
                            "The first collection pathway is the conventional "
                            + "electromagnetic pathway. It is based on the familiar "
                            + "principle that changing magnetic flux can produce an "
                            + "induced voltage."
                        )

                        Text(
                            "A bicycle generator is a simple analogy. When the "
                            + "bicycle wheel turns, the generator experiences a "
                            + "changing magnetic interaction. That changing interaction "
                            + "produces an electrical voltage, which can then drive "
                            + "current through an electrical circuit."
                        )

                        Text(
                            "The QRTL Dipole simulation applies the same general "
                            + "electromagnetic concept to its modeled receiver. "
                            + "The changing magnetic field produces a changing flux "
                            + "through the receiving system. The receiver's number "
                            + "of turns, resistance, impedance, and other electrical "
                            + "properties then influence the resulting electrical "
                            + "power."
                        )

                        Text(
                            "This means that a strong magnetic field by itself "
                            + "should not be interpreted as automatically producing "
                            + "continuous electrical power. The conventional mechanism "
                            + "depends on the changing magnetic interaction."
                        )
                    }

                    // ====================================================
                    // QRTL PATH
                    // ====================================================

                    sectionTitle(
                        "The QRTL Field-Current Path",
                        systemImage: "sparkles"
                    )

                    paragraphCard {

                        Text(
                            "The second pathway is the QRTL portion of the simulation. "
                            + "This pathway is intentionally separated from the "
                            + "conventional Faraday calculation because it introduces "
                            + "a different model assumption."
                        )

                        Text(
                            "The simulation allows a field-aligned current to be "
                            + "specified as an input to the QRTL model. The model "
                            + "then applies a capture efficiency to determine how "
                            + "much of that assumed current is captured by the "
                            + "collection system."
                        )

                        formulaBox(
                            "Icaptured = Ifield × Capture Efficiency"
                        )

                        Text(
                            "A simple analogy is a river flowing toward a water "
                            + "wheel. The river represents the modeled field-aligned "
                            + "current. The water wheel represents the collector. "
                            + "The capture efficiency represents how much of the "
                            + "available flow actually reaches the wheel."
                        )

                        Text(
                            "The next part of the model applies a defined collection "
                            + "voltage to the captured current."
                        )

                        formulaBox(
                            "P = Icaptured × Vcollection"
                        )

                        Text(
                            "In the water analogy, the current is like the amount "
                            + "of water flowing through the wheel, while the voltage "
                            + "represents the electrical potential used by the model "
                            + "to calculate power."
                        )

                        Text(
                            "This is a hypothesis pathway. The simulation is not "
                            + "claiming that the specified field-aligned current "
                            + "has already been measured as an available terrestrial "
                            + "energy source. It is asking what the mathematical "
                            + "consequences would be if the modeled current, capture "
                            + "efficiency, and collection voltage were available."
                        )
                    }

                    // ====================================================
                    // WHY SEPARATE THE PATHS
                    // ====================================================

                    sectionTitle(
                        "Why Are the Two Paths Kept Separate?",
                        systemImage: "arrow.left.arrow.right"
                    )

                    paragraphCard {

                        Text(
                            "Keeping the two pathways separate is one of the most "
                            + "important features of the simulation. They answer "
                            + "different questions."
                        )

                        Text(
                            "The conventional pathway asks: Can changing magnetic "
                            + "flux produce an induced electrical voltage and power?"
                        )

                        Text(
                            "The QRTL pathway asks: If a field-aligned current is "
                            + "assumed to exist in the model, and if a collector can "
                            + "capture part of that current at a defined collection "
                            + "voltage, what electrical power would the model calculate?"
                        )

                        Text(
                            "Think of the coupling region as a road intersection. "
                            + "One road is the conventional electromagnetic pathway. "
                            + "The other road is the QRTL hypothesis pathway. They "
                            + "start from the same modeled coupling region, but they "
                            + "use different assumptions to calculate what happens next."
                        )

                        Text(
                            "This separation makes the simulation easier to understand "
                            + "and easier to evaluate. A user can see which results "
                            + "come from conventional electromagnetic induction and "
                            + "which results depend on the additional QRTL assumptions."
                        )
                    }

                    // ====================================================
                    // COLLECTOR
                    // ====================================================

                    sectionTitle(
                        "7. Collect the Modeled Energy",
                        systemImage: "antenna.radiowaves.left.and.right"
                    )

                    paragraphCard {

                        Text(
                            "The collector is the part of the simulated system that "
                            + "attempts to turn the modeled electromagnetic interaction "
                            + "into useful electrical output."
                        )

                        Text(
                            "The water-wheel analogy is useful again. A larger water "
                            + "wheel can interact with more of a flowing stream, but "
                            + "making the wheel larger does not automatically create "
                            + "unlimited power. The amount of available flow, the wheel's "
                            + "design, friction, and the generator attached to it all "
                            + "matter."
                        )

                        Text(
                            "The same principle applies to the simulated collector. "
                            + "The collector has a defined area and electrical geometry. "
                            + "The receiving system has a number of turns, resistance, "
                            + "inductance, capacitance, and other characteristics."
                        )

                        Text(
                            "These properties determine how the modeled interaction "
                            + "is translated into an electrical result. The collector "
                            + "is therefore not simply an ideal connection that takes "
                            + "everything available and turns it into perfect power."
                        )
                    }

                    // ====================================================
                    // RESISTANCE / IMPEDANCE
                    // ====================================================

                    sectionTitle(
                        "8. Electrical Resistance and Impedance",
                        systemImage: "waveform.path.ecg"
                    )

                    paragraphCard {

                        Text(
                            "Real electrical systems have losses. Whenever current "
                            + "flows through resistance, some electrical energy becomes "
                            + "heat. The simulation therefore includes resistance in "
                            + "the electrical model instead of assuming that every "
                            + "electron moves through a perfect conductor."
                        )

                        Text(
                            "A simple analogy is pushing water through a pipe. "
                            + "A pipe creates resistance to the movement of water. "
                            + "Electrical resistance creates opposition to the "
                            + "movement of electrical current."
                        )

                        Text(
                            "When the system operates with changing electrical signals, "
                            + "impedance becomes important as well. Impedance represents "
                            + "the overall opposition a changing electrical signal "
                            + "experiences in a circuit. It can include resistance "
                            + "as well as effects associated with inductance and "
                            + "capacitance."
                        )

                        Text(
                            "That is why the simulation includes electrical properties "
                            + "such as receiver inductance and capacitance. These "
                            + "properties help determine how the receiving system "
                            + "responds to a changing electromagnetic input."
                        )
                    }

                    // ====================================================
                    // CONVERSION
                    // ====================================================

                    sectionTitle(
                        "9. Convert the Collected Power",
                        systemImage: "arrow.up.right.circle.fill"
                    )

                    paragraphCard {

                        Text(
                            "The electrical power calculated at the collection stage "
                            + "is not automatically treated as perfectly usable output. "
                            + "The simulation applies contact and conversion efficiencies "
                            + "to represent the fact that real energy-conversion systems "
                            + "have losses."
                        )

                        Text(
                            "Imagine an automobile engine producing power. The engine "
                            + "does not send every unit of power directly to the wheels. "
                            + "Some energy is lost through the transmission, bearings, "
                            + "cooling system, electronics, friction, and heat."
                        )

                        Text(
                            "The electrical conversion stage works in a similar way. "
                            + "The modeled collected power passes through an efficiency "
                            + "factor before it becomes the useful electrical output "
                            + "used by the final power calculation."
                        )
                    }

                    // ====================================================
                    // MACHINE LOSSES
                    // ====================================================

                    sectionTitle(
                        "10. The Machine Has to Pay Its Own Energy Cost",
                        systemImage: "chart.bar.xaxis"
                    )

                    paragraphCard {

                        Text(
                            "This is one of the most important parts of the entire "
                            + "simulation. It is not enough to calculate how much "
                            + "power the collector receives. The machine itself "
                            + "requires power to operate."
                        )

                        Text(
                            "The coils have electrical resistance. Current flowing "
                            + "through that resistance produces heat. The field system "
                            + "can also have switching losses, core losses, resonator "
                            + "losses, cooling requirements, auxiliary power requirements, "
                            + "and power-electronics losses."
                        )

                        Text(
                            "The automobile analogy makes this easy to understand. "
                            + "Suppose a car engine produces a certain amount of power. "
                            + "The car still needs a cooling system, electrical system, "
                            + "fuel system, transmission, fans, pumps, and electronics. "
                            + "Those systems consume energy."
                        )

                        Text(
                            "The same idea applies to the QRTL Dipole Machine. The "
                            + "machine has to spend energy to create and control the "
                            + "field. That operating cost must be included when "
                            + "evaluating whether the modeled system produces useful "
                            + "net power."
                        )
                    }

                    // ====================================================
                    // NET POWER
                    // ====================================================

                    sectionTitle(
                        "11. Calculate Net Power",
                        systemImage: "gauge.with.dots.needle.100percent"
                    )

                    paragraphCard {

                        Text(
                            "The final question is not simply how much power the "
                            + "collector produced. The more important question is "
                            + "how much power remains after the machine has paid "
                            + "the cost of operating itself."
                        )

                        formulaBox(
                            "Net Power = Converted Power − Operating Power"
                        )

                        Text(
                            "For example, imagine that a hypothetical simulation "
                            + "calculates 12 megawatts of converted electrical output "
                            + "and the machine requires 2 megawatts to operate. The "
                            + "modeled net result would be 10 megawatts."
                        )

                        Text(
                            "But imagine instead that the machine produces 12 megawatts "
                            + "while requiring 15 megawatts to operate. The net result "
                            + "would be negative 3 megawatts. In that case, the modeled "
                            + "system would consume more power than it delivered."
                        )

                        Text(
                            "This is why net power is one of the most important "
                            + "measurements in the application. It forces the simulation "
                            + "to consider both sides of the equation: what comes out "
                            + "and what must be supplied to keep the machine running."
                        )
                    }

                    // ====================================================
                    // FULL PIPELINE
                    // ====================================================

                    sectionTitle(
                        "The Full Energy Journey",
                        systemImage: "point.3.connected.trianglepath.dotted"
                    )

                    fullPipelineCard

                    // ====================================================
                    // USER EXPERIMENTS
                    // ====================================================

                    sectionTitle(
                        "What Can You Experiment With?",
                        systemImage: "slider.horizontal.3"
                    )

                    paragraphCard {

                        Text(
                            "The simulation is designed as an experimental environment. "
                            + "Instead of showing one fixed machine, it allows the user "
                            + "to change important parameters and observe how those "
                            + "changes affect the modeled result."
                        )

                        Text(
                            "Changing the number of coil turns changes the magnetic "
                            + "characteristics of the coils. Changing coil current "
                            + "changes the strength of the modeled field. Moving the "
                            + "upper and lower shaping coils changes the field geometry."
                        )

                        Text(
                            "Changing phase changes the timing relationship between "
                            + "the coils. Changing drive frequency changes how rapidly "
                            + "the AC or pulsed field varies. Moving the coupling altitude "
                            + "changes the location where the interaction is evaluated."
                        )

                        Text(
                            "The QRTL-specific controls provide another experimental "
                            + "dimension. Capture efficiency determines what fraction "
                            + "of the modeled field-aligned current is captured, while "
                            + "collection voltage determines the voltage used in the "
                            + "QRTL power calculation."
                        )

                        Text(
                            "The user can therefore ask a series of simple questions: "
                            + "What happens if the field becomes stronger? What happens "
                            + "if the timing changes? What happens if the coupling region "
                            + "moves? What happens if the assumed capture efficiency is "
                            + "changed? And most importantly, what happens to net power "
                            + "after the machine's operating costs are included?"
                        )
                    }

                    // ====================================================
                    // WHAT THE MODEL SHOWS
                    // ====================================================

                    sectionTitle(
                        "What the Simulation Shows",
                        systemImage: "chart.line.uptrend.xyaxis"
                    )

                    paragraphCard {

                        Text(
                            "A computer simulation calculates the consequences of "
                            + "the mathematical rules and assumptions that have been "
                            + "given to it. If a particular current, voltage, efficiency, "
                            + "coil geometry, or operating condition is entered, the "
                            + "simulation can calculate a corresponding result."
                        )

                        Text(
                            "That result is useful because it allows different "
                            + "conditions to be compared. A user can change one "
                            + "parameter and observe how the calculated output changes. "
                            + "This makes it possible to explore sensitivities, identify "
                            + "important parameters, and study how the different parts "
                            + "of the model interact."
                        )

                        Text(
                            "However, a calculated result and a physical measurement "
                            + "are not the same thing. A simulation can tell us what "
                            + "the model predicts under its assumptions. A physical "
                            + "experiment is required to determine whether nature "
                            + "actually behaves according to those assumptions."
                        )
                    }

                    // ====================================================
                    // IMPORTANT QRTL QUALIFICATION
                    // ====================================================

                    sectionTitle(
                        "What the QRTL Model Means",
                        systemImage: "exclamationmark.triangle"
                    )

                    qualificationCard

                    // ====================================================
                    // SIMPLE ANALOGY
                    // ====================================================

                    sectionTitle(
                        "The Whole Machine as a Water System",
                        systemImage: "drop"
                    )

                    paragraphCard {

                        Text(
                            "If you remember only one analogy, remember the water "
                            + "system. Imagine a giant pump connected to a large "
                            + "network of pipes."
                        )

                        Text(
                            "The electrical input is the energy used to operate "
                            + "the pump. The primary coil is the main pump. The "
                            + "magnetic field is like the water flow. The upper "
                            + "and lower coils are like adjustable valves and "
                            + "flow guides. The coupling region is like a defined "
                            + "area where the flow is measured."
                        )

                        Text(
                            "The collector is like a water wheel. The conventional "
                            + "path asks whether changing flow through the wheel "
                            + "creates electrical power. The QRTL path asks what "
                            + "would happen if the model assumes another directed "
                            + "flow is available at the collection region and the "
                            + "collector can capture some of it."
                        )

                        Text(
                            "The electrical conversion system is like the generator "
                            + "attached to the water wheel. Resistance, impedance, "
                            + "and conversion losses represent the real-world "
                            + "limitations of the equipment."
                        )

                        Text(
                            "Finally, the pump itself consumes energy. The cooling "
                            + "system consumes energy. The controls and electronics "
                            + "consume energy. The question at the end is therefore "
                            + "not simply how much energy reached the water wheel."
                        )

                        Text(
                            "The final question is: after paying for everything "
                            + "needed to operate the system, how much useful power "
                            + "is left?"
                        )
                        .font(.headline)
                    }

                    // ====================================================
                    // FINAL SUMMARY
                    // ====================================================

                    finalSummaryCard

                }
                .padding()
            }

            .navigationTitle("About QRTL")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // ================================================================
    // MARK: - Big Picture Card
    // ================================================================

    private var bigPictureCard: some View {

        VStack(alignment: .leading, spacing: 16) {

            Label(
                "The Big Picture",
                systemImage: "lightbulb.fill"
            )
            .font(.headline)

            Text(
                "Think of the QRTL Dipole Machine as a very large "
                + "magnetic pump."
            )
            .font(.title2.bold())

            Text(
                "The machine uses electrical power to drive coils. "
                + "The coils create a magnetic field. Additional coils "
                + "shape that field. The field extends toward a defined "
                + "coupling region where the simulation examines how "
                + "energy might be collected."
            )

            Text(
                "From there, the simulation follows the collected "
                + "energy through an electrical system and finally "
                + "subtracts the energy required to operate the machine."
            )

            Text(
                "In the simplest possible form:"
            )
            .font(.subheadline.bold())

            Text(
                "Power → Field → Shape → Extend → Couple → Collect → Convert → Net Power"
            )
            .font(.system(.subheadline, design: .monospaced))
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.blue.opacity(0.10))
            )

        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.blue.opacity(0.10))
        )
    }

    // ================================================================
    // MARK: - Pipeline Overview
    // ================================================================

    private var pipelineOverviewCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            pipelineLine("1", "Power the machine")
            pipelineArrow

            pipelineLine("2", "Create the primary magnetic field")
            pipelineArrow

            pipelineLine("3", "Shape the field with additional coils")
            pipelineArrow

            pipelineLine("4", "Change the magnetic flux with AC or pulses")
            pipelineArrow

            pipelineLine("5", "Evaluate the coupling region")
            pipelineArrow

            pipelineLine("6", "Examine conventional and QRTL collection paths")
            pipelineArrow

            pipelineLine("7", "Collect and convert the modeled power")
            pipelineArrow

            pipelineLine("8", "Subtract operating power")
            pipelineArrow

            pipelineLine("9", "Determine net power")

        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.thinMaterial)
        )
    }

    private func pipelineLine(
        _ number: String,
        _ text: String
    ) -> some View {

        HStack(spacing: 12) {

            ZStack {

                Circle()
                    .fill(.blue.opacity(0.15))
                    .frame(width: 32, height: 32)

                Text(number)
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
            }

            Text(text)
                .font(.subheadline.bold())

            Spacer()
        }
    }

    private var pipelineArrow: some View {

        HStack {

            Image(systemName: "arrow.down")
                .foregroundStyle(.secondary)
                .padding(.leading, 8)

            Spacer()
        }
    }

    // ================================================================
    // MARK: - Two Path Card
    // ================================================================

    private var twoPathCard: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text(
                "At the coupling region, the simulation separates "
                + "into two different mathematical pathways."
            )
            .font(.body)

            HStack(alignment: .top, spacing: 12) {

                pathCard(
                    title: "Conventional",
                    icon: "bolt.circle",
                    description:
                        "Changing magnetic flux can produce an induced voltage."
                )

                pathCard(
                    title: "QRTL",
                    icon: "sparkles",
                    description:
                        "A modeled field-aligned current is combined with "
                        + "capture efficiency and collection voltage."
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.thinMaterial)
        )
    }

    private func pathCard(
        title: String,
        icon: String,
        description: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            Image(systemName: icon)
                .font(.title2)

            Text(title)
                .font(.headline)

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.secondary.opacity(0.08))
        )
    }

    // ================================================================
    // MARK: - Full Pipeline
    // ================================================================

    private var fullPipelineCard: some View {

        VStack(alignment: .leading, spacing: 18) {

            Text(
                "Electrical Input"
            )
            .font(.headline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "Primary Coil Creates Magnetic Field"
            )
            .font(.headline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "Upper + Lower Coils Shape the Field"
            )
            .font(.headline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "AC / Pulsed Operation Changes the Field"
            )
            .font(.headline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "Magnetic Field Reaches Coupling Region"
            )
            .font(.headline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "        ┌── Conventional: Changing Flux → Induced Voltage"
            )
            .font(.system(.subheadline, design: .monospaced))

            Text(
                "Coupling"
            )
            .font(.headline)

            Text(
                "        └── QRTL: Field Current → Capture → Voltage → Power"
            )
            .font(.system(.subheadline, design: .monospaced))

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "Collector and Electrical System"
            )
            .font(.headline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "Contact + Conversion Efficiency"
            )
            .font(.headline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "Gross Electrical Output"
            )
            .font(.headline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "− Coil Losses − Switching Losses − Cooling − Auxiliary Power"
            )
            .font(.subheadline)

            Text(
                "↓"
            )
            .foregroundStyle(.secondary)

            Text(
                "NET POWER"
            )
            .font(.title3.bold())

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.blue.opacity(0.08))
        )
    }

    // ================================================================
    // MARK: - Paragraph Card
    // ================================================================

    private func paragraphCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 16) {

            content()

        }
        .font(.body)
        .lineSpacing(3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
        )
    }

    // ================================================================
    // MARK: - Formula
    // ================================================================

    private func formulaBox(
        _ text: String
    ) -> some View {

        Text(text)
            .font(.system(.body, design: .monospaced))
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.10))
            )
    }

    // ================================================================
    // MARK: - Qualification
    // ================================================================

    private var qualificationCard: some View {

        VStack(alignment: .leading, spacing: 16) {

            Label(
                "Important Scientific Distinction",
                systemImage: "exclamationmark.triangle.fill"
            )
            .font(.headline)
            .foregroundStyle(.orange)

            Text(
                "The conventional electromagnetic portion of the "
                + "simulation uses established electromagnetic relationships, "
                + "including the relationship between changing magnetic flux "
                + "and induced voltage."
            )

            Text(
                "The QRTL field-current collection portion is different. "
                + "It is a hypothesis implemented as a mathematical model. "
                + "The field-aligned current, capture efficiency, and collection "
                + "voltage are model inputs used to explore the consequences "
                + "of that hypothesis."
            )
            .foregroundStyle(.secondary)

            Text(
                "A simulation can calculate what happens if those assumptions "
                + "are supplied. It cannot, by itself, establish that the "
                + "assumed field-aligned current exists in nature, that the "
                + "specified collection voltage is physically available, or "
                + "that the selected capture efficiency can be achieved by "
                + "a real machine."
            )
            .foregroundStyle(.secondary)

            Text(
                "The purpose of the QRTL portion is therefore exploratory: "
                + "change the assumptions, run the model, and observe how "
                + "the predicted electrical output changes."
            )
            .foregroundStyle(.secondary)

        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.orange.opacity(0.10))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.orange.opacity(0.30), lineWidth: 1)
        }
    }

    // ================================================================
    // MARK: - Final Summary
    // ================================================================

    private var finalSummaryCard: some View {

        VStack(spacing: 16) {

            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 48))

            Text("The QRTL Dipole Machine in One Story")
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text(
                "The machine starts with electrical power. That power "
                + "drives large coils that create a controlled magnetic "
                + "dipole field. Additional coils shape and control the "
                + "field. AC or pulsed operation can make the magnetic "
                + "flux change with time. The simulation then follows "
                + "the field toward a defined coupling region."
            )
            .multilineTextAlignment(.center)

            Text(
                "At the coupling region, the model examines two different "
                + "possibilities. The conventional pathway evaluates "
                + "electromagnetic induction from changing magnetic flux. "
                + "The QRTL pathway evaluates a separate hypothesis in "
                + "which a modeled field-aligned current interacts with "
                + "a defined collection voltage."
            )
            .multilineTextAlignment(.center)

            Text(
                "The collector and electrical system then determine how "
                + "the modeled interaction becomes electrical output. "
                + "Resistance, impedance, contact efficiency, and conversion "
                + "efficiency are included rather than assuming a perfect "
                + "system."
            )
            .multilineTextAlignment(.center)

            Text(
                "Finally, the simulation subtracts the power required "
                + "to operate the machine. The result is the modeled "
                + "net power."
            )
            .multilineTextAlignment(.center)

            Text(
                "Push → Shape → Extend → Couple → Collect → Convert → "
                + "Pay the operating cost → Measure what remains."
            )
            .font(.headline)
            .multilineTextAlignment(.center)

        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.blue.opacity(0.08))
        )
    }

    // ================================================================
    // MARK: - Section Title
    // ================================================================

    private func sectionTitle(
        _ title: String,
        systemImage: String
    ) -> some View {

        Label(
            title,
            systemImage: systemImage
        )
        .font(.title3.bold())
        .padding(.top, 6)
    }
}
