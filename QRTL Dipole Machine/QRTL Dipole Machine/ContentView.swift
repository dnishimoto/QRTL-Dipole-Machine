/*
 Think of the equipment as a **large electromagnetic field generator plus a collector**, rather than as a Tesla coil.

 The proposed physical equipment would have these major sections:

 1. **Power supply**

    A grid-connected or other electrical power source provides the energy needed to establish and control the magnetic field. This input must be measured separately because it is an operating cost and part of the machine's energy balance.

 2. **Dipole field generator**

    This is the central component. You would need a pair of large electromagnetic poles separated vertically—conceptually a **north/south dipole**. Large coils carrying controlled current would create the magnetic field. An iron or other magnetic core could concentrate the field near the machine, although extending a strong field many kilometers upward is a much harder engineering problem.

 3. **Large excitation coils**

    Instead of a small Tesla-coil winding, the machine would use substantial coils designed to produce a controlled magnetic field. The important parameters would be **number of turns, coil radius, current, conductor size, magnetic-core properties, and electrical power**.

 4. **Field-control electronics**

    Power electronics would control the current through the coils. If you want frequency to matter in your simulation, this is where it belongs. The controller could vary the excitation waveform and frequency rather than simply displaying frequency as a cosmetic parameter.

 5. **Vertical magnetic-flux structure**

    This is the part your simulation should emphasize. The dipole produces magnetic field lines that extend outward and upward. The proposed mechanism assumes that these field lines provide a coupling pathway toward the ionosphere.

    **Electrical power → coil current → magnetic field → extended flux structure → proposed ionospheric interaction**

 6. **Ionospheric coupling region**

    There would not necessarily be a physical piece of equipment located in the ionosphere. In the model, this is the region where the machine's generated electromagnetic field interacts with the surrounding ionospheric electromagnetic environment.

 7. **Ground collector**

    At the bottom, you would have a distributed conductive collection structure surrounding the dipole. Rather than imagining a huge solid 10-acre metal plate, your design could investigate a **radial network of conductors/electrodes** connected to a central terminal. That makes the geometry much more interesting because the collector can be distributed over the surface while the electromagnetic structure extends vertically.

 8. **Central terminal and power conditioning**

    Currents collected by the distributed network would be brought to a central electrical terminal and then passed through rectification, regulation, transformation, and other power-conditioning equipment before reaching the load.

 ### The key idea for your simulation

 I would change the visual concept from:

 **IONOSPHERE → giant collector → electricity**

 to:

 **POWER SUPPLY → ELECTROMAGNETIC DIPOLE → EXTENDED MAGNETIC FLUX → IONOSPHERIC COUPLING REGION → GROUND COLLECTION NETWORK → CENTRAL TERMINAL → POWER CONDITIONING → LOAD**

 The **dipole should be the star of the simulation**. The collector is the receiving network at the bottom; it should not be portrayed as though simply increasing its acreage automatically captures more ionospheric energy.

 And one major caution: creating a magnetic field does **not by itself establish that energy will flow from the ionosphere into the machine**. The simulation should explicitly model that as the proposed QRTL coupling mechanism and keep the field-generation input power visible, so the app can distinguish **field creation** from **actual net energy capture**.

 */
import SwiftUI
import SceneKit
import Combine

struct ContentView: View {

    // MARK: - Simulation State

    @State private var ionospherePowerMW: Double = 100.0
    @State private var qrtlCoupling: Double = 0.05
    @State private var collectorEfficiency: Double = 0.45
    @State private var conversionEfficiency: Double = 0.95
    @State private var machineConsumptionMW: Double = 2.0

    @State private var collectorAreaAcres: Double = 10.0
    @State private var collectorVoltageKV: Double = 100.0

    @State private var fieldStrength: Double = 1.0
    @State private var fieldFrequencyKHz: Double = 10.0

    @State private var isRunning = true

    private let targetPowerMW = 10.0

    // MARK: - Calculations

    private var coupledPowerMW: Double {
        ionospherePowerMW * qrtlCoupling
    }

    private var collectorPowerMW: Double {
        coupledPowerMW * collectorEfficiency
    }

    private var grossOutputMW: Double {
        collectorPowerMW * conversionEfficiency
    }

    private var netOutputMW: Double {
        grossOutputMW - machineConsumptionMW
    }

    private var targetPercent: Double {
        guard targetPowerMW > 0 else { return 0 }
        return max(0, netOutputMW / targetPowerMW * 100.0)
    }

    private var collectorCurrentA: Double {
        let voltage = collectorVoltageKV * 1_000.0

        guard voltage > 0 else {
            return 0
        }

        return grossOutputMW * 1_000_000.0 / voltage
    }

    private var collectorAreaM2: Double {
        collectorAreaAcres * 4046.8564224
    }

    private var currentDensity: Double {
        guard collectorAreaM2 > 0 else {
            return 0
        }

        return collectorCurrentA / collectorAreaM2
    }

    private var requiredExternalPowerMW: Double {

        let efficiency =
            qrtlCoupling *
            collectorEfficiency *
            conversionEfficiency

        guard efficiency > 0 else {
            return .infinity
        }

        return targetPowerMW / efficiency
    }

    private var pathEfficiency: Double {
        qrtlCoupling *
        collectorEfficiency *
        conversionEfficiency
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 18) {

                    // ---------------------------------------------------------
                    // TITLE
                    // ---------------------------------------------------------

                    VStack(spacing: 6) {

                        Text("QRTL Dipole")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Electromagnetic Machine")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(
                            "Ionosphere → QRTL Dipole → Conductive Collector → Electrical Output"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }

                    // ---------------------------------------------------------
                    // 3D MACHINE
                    // ---------------------------------------------------------

                    ZStack(alignment: .topLeading) {

                        QRTLSceneView(
                            running: isRunning,
                            fieldStrength: fieldStrength
                        )
                        .frame(height: 520)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 20)
                        )

                        VStack(alignment: .leading, spacing: 5) {

                            Text("3D FIELD MODEL")
                                .font(.caption)
                                .fontWeight(.bold)

                            Text("IONOSPHERE")
                            Text("↓")

                            Text("QRTL DIPOLE")
                            Text("↓")

                            Text("CONDUCTIVE COLLECTOR")
                            Text("↓")

                            Text("CENTRAL TERMINAL")
                            Text("↓")

                            Text("10 MW LOAD")
                        }
                        .font(.caption2)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                        .padding(12)
                    }

                    // ---------------------------------------------------------
                    // OUTPUT
                    // ---------------------------------------------------------

                    VStack(spacing: 14) {

                        Text("SIMULATED ELECTRICAL OUTPUT")
                            .font(.headline)

                        HStack {

                            OutputValue(
                                title: "Gross",
                                value: String(
                                    format: "%.3f MW",
                                    grossOutputMW
                                )
                            )

                            OutputValue(
                                title: "Net",
                                value: String(
                                    format: "%.3f MW",
                                    netOutputMW
                                )
                            )

                            OutputValue(
                                title: "Target",
                                value: String(
                                    format: "%.1f%%",
                                    targetPercent
                                )
                            )
                        }

                        ProgressView(
                            value: min(
                                max(netOutputMW / targetPowerMW, 0),
                                1
                            )
                        )

                        Text(
                            "10 MW design target"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )

                    // ---------------------------------------------------------
                    // ELECTRICAL OUTPUT
                    // ---------------------------------------------------------

                    VStack(alignment: .leading, spacing: 10) {

                        Text("Collector Electrical Model")
                            .font(.headline)

                        MetricRow(
                            name: "Collector voltage",
                            value: String(
                                format: "%.1f kV",
                                collectorVoltageKV
                            )
                        )

                        MetricRow(
                            name: "Collector current",
                            value: String(
                                format: "%.2f A",
                                collectorCurrentA
                            )
                        )

                        MetricRow(
                            name: "Collector area",
                            value: String(
                                format: "%.2f acres",
                                collectorAreaAcres
                            )
                        )

                        MetricRow(
                            name: "Collector area",
                            value: String(
                                format: "%.0f m²",
                                collectorAreaM2
                            )
                        )

                        MetricRow(
                            name: "Current density",
                            value: String(
                                format: "%.6f A/m²",
                                currentDensity
                            )
                        )

                        MetricRow(
                            name: "Machine consumption",
                            value: String(
                                format: "%.2f MW",
                                machineConsumptionMW
                            )
                        )
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )

                    // ---------------------------------------------------------
                    // EXTERNAL ENERGY
                    // ---------------------------------------------------------

                    VStack(alignment: .leading, spacing: 10) {

                        Text("External Energy Model")
                            .font(.headline)

                        MetricRow(
                            name: "Available ionospheric power",
                            value: String(
                                format: "%.2f MW",
                                ionospherePowerMW
                            )
                        )

                        MetricRow(
                            name: "QRTL coupled power",
                            value: String(
                                format: "%.2f MW",
                                coupledPowerMW
                            )
                        )

                        MetricRow(
                            name: "Collector power",
                            value: String(
                                format: "%.2f MW",
                                collectorPowerMW
                            )
                        )

                        MetricRow(
                            name: "Path efficiency",
                            value: String(
                                format: "%.3f%%",
                                pathEfficiency * 100
                            )
                        )

                        MetricRow(
                            name: "External power required for 10 MW",
                            value: String(
                                format: "%.2f MW",
                                requiredExternalPowerMW
                            )
                        )
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )

                    // ---------------------------------------------------------
                    // CONTROLS
                    // ---------------------------------------------------------

                    VStack(alignment: .leading, spacing: 16) {

                        Text("Machine Parameters")
                            .font(.headline)

                        ParameterSlider(
                            title: "Ionospheric power",
                            value: $ionospherePowerMW,
                            range: 1...1000,
                            step: 1,
                            unit: " MW"
                        )

                        ParameterSlider(
                            title: "QRTL coupling",
                            value: $qrtlCoupling,
                            range: 0.001...1.0,
                            step: 0.001,
                            unit: ""
                        )

                        ParameterSlider(
                            title: "Collector efficiency",
                            value: $collectorEfficiency,
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

                        ParameterSlider(
                            title: "Machine consumption",
                            value: $machineConsumptionMW,
                            range: 0...50,
                            step: 0.1,
                            unit: " MW"
                        )

                        ParameterSlider(
                            title: "Collector area",
                            value: $collectorAreaAcres,
                            range: 0.01...10,
                            step: 0.01,
                            unit: " acres"
                        )

                        ParameterSlider(
                            title: "Collector voltage",
                            value: $collectorVoltageKV,
                            range: 1...1000,
                            step: 1,
                            unit: " kV"
                        )

                        ParameterSlider(
                            title: "Field strength",
                            value: $fieldStrength,
                            range: 0.1...10,
                            step: 0.1,
                            unit: ""
                        )

                        ParameterSlider(
                            title: "Field frequency",
                            value: $fieldFrequencyKHz,
                            range: 1...100,
                            step: 1,
                            unit: " kHz"
                        )

                        Toggle(
                            "Animate electromagnetic field",
                            isOn: $isRunning
                        )
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )

                    // ---------------------------------------------------------
                    // EQUATION PIPELINE
                    // ---------------------------------------------------------

                    VStack(alignment: .leading, spacing: 14) {

                        Text("Equation Pipeline")
                            .font(.headline)

                        EquationStep(
                            number: "1",
                            title: "Electromagnetic Energy Flux",
                            equation: "S = E × H"
                        )

                        EquationStep(
                            number: "2",
                            title: "Available External Power",
                            equation: "Pₑₓₜ = ∫ S · dA"
                        )

                        EquationStep(
                            number: "3",
                            title: "QRTL Coupling",
                            equation: "P_QRTL = Pₑₓₜ × η_QRTL"
                        )

                        EquationStep(
                            number: "4",
                            title: "Collector Power",
                            equation: "P_C = P_QRTL × η_C"
                        )

                        EquationStep(
                            number: "5",
                            title: "Electrical Power",
                            equation: "P = V × I"
                        )

                        EquationStep(
                            number: "6",
                            title: "Current",
                            equation: "I = P / V"
                        )

                        EquationStep(
                            number: "7",
                            title: "Resistive Loss",
                            equation: "P_loss = I²R"
                        )

                        EquationStep(
                            number: "8",
                            title: "Net Output",
                            equation: "P_net = P_out − P_machine"
                        )

                        Divider()

                        Text(
                            "Complete modeled pathway:"
                        )
                        .font(.caption)
                        .fontWeight(.bold)

                        Text(
                            "Ionosphere → Electromagnetic Flux → QRTL Coupling → "
                            + "Collector → Current → Power Conditioning → Load → Net Power"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )

                    // ---------------------------------------------------------
                    // ENERGY ACCOUNTING
                    // ---------------------------------------------------------

                    VStack(alignment: .leading, spacing: 10) {

                        Text("Energy Accounting")
                            .font(.headline)

                        EnergyBar(
                            title: "External",
                            value: ionospherePowerMW,
                            maximum: max(ionospherePowerMW, 1)
                        )

                        EnergyBar(
                            title: "QRTL Coupled",
                            value: coupledPowerMW,
                            maximum: max(ionospherePowerMW, 1)
                        )

                        EnergyBar(
                            title: "Collector",
                            value: collectorPowerMW,
                            maximum: max(ionospherePowerMW, 1)
                        )

                        EnergyBar(
                            title: "Gross Output",
                            value: grossOutputMW,
                            maximum: max(ionospherePowerMW, 1)
                        )

                        EnergyBar(
                            title: "Net Output",
                            value: max(netOutputMW, 0),
                            maximum: max(ionospherePowerMW, 1)
                        )
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )

                    // ---------------------------------------------------------
                    // DISCLAIMER
                    // ---------------------------------------------------------

                    Text(
                        "The QRTL coupling coefficient is a user-defined "
                        + "hypothesis parameter. The simulation calculates "
                        + "predicted output from the supplied assumptions; "
                        + "it does not establish that a physical ionosphere-to-ground "
                        + "10 MW energy pathway exists."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


// MARK: - 3D Scene

struct QRTLSceneView: UIViewRepresentable {

    let running: Bool
    let fieldStrength: Double

    func makeUIView(context: Context) -> SCNView {

        let view = SCNView()

        view.backgroundColor = UIColor(
            red: 0.015,
            green: 0.02,
            blue: 0.05,
            alpha: 1
        )

        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X

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
            fieldStrength: fieldStrength
        )

        return view
    }

    func updateUIView(
        _ view: SCNView,
        context: Context
    ) {

        guard let root = view.scene?.rootNode else {
            return
        }

        if let fieldNode = root.childNode(
            withName: "FieldContainer",
            recursively: true
        ) {

            fieldNode.opacity = running ? 1.0 : 0.25
        }
    }

    // MARK: Scene Construction

    private func buildScene(
        scene: SCNScene,
        fieldStrength: Double
    ) {

        let root = scene.rootNode

        // ---------------------------------------------------------
        // CAMERA
        // ---------------------------------------------------------

        let cameraNode = SCNNode()

        let camera = SCNCamera()

        camera.fieldOfView = 58
        camera.zNear = 0.1
        camera.zFar = 500

        cameraNode.camera = camera

        cameraNode.position = SCNVector3(
            0,
            18,
            38
        )
        
        let target = SCNVector3(
            0,
            2,
            0
        )

        cameraNode.look(
            at: target,
            up: SCNVector3(0, 1, 0),
            localFront: SCNVector3(0, 0, -1)
        )

        root.addChildNode(cameraNode)

        // ---------------------------------------------------------
        // LIGHTS
        // ---------------------------------------------------------

        let ambient = SCNNode()

        let ambientLight = SCNLight()

        ambientLight.type = .ambient
        ambientLight.intensity = 700

        ambient.light = ambientLight

        root.addChildNode(ambient)

        let omni = SCNNode()

        let omniLight = SCNLight()

        omniLight.type = .omni
        omniLight.intensity = 1200

        omni.position = SCNVector3(
            0,
            20,
            15
        )

        omni.light = omniLight

        root.addChildNode(omni)

        // ---------------------------------------------------------
        // GROUND
        // ---------------------------------------------------------

        let ground = SCNFloor()

        ground.reflectivity = 0.08
        ground.firstMaterial?.diffuse.contents =
            UIColor(
                white: 0.06,
                alpha: 1
            )

        let groundNode = SCNNode(
            geometry: ground
        )

        root.addChildNode(groundNode)

        // ---------------------------------------------------------
        // IONOSPHERE
        // ---------------------------------------------------------

        let ionosphereGeometry =
            SCNSphere(radius: 14)

        ionosphereGeometry.firstMaterial =
            transparentMaterial(
                UIColor.systemTeal,
                opacity: 0.08
            )

        let ionosphereNode =
            SCNNode(
                geometry: ionosphereGeometry
            )

        ionosphereNode.name = "Ionosphere"

        ionosphereNode.position =
            SCNVector3(
                0,
                17,
                0
            )

        root.addChildNode(ionosphereNode)

        // ---------------------------------------------------------
        // FIELD CONTAINER
        // ---------------------------------------------------------

        let fieldContainer = SCNNode()

        fieldContainer.name = "FieldContainer"

        root.addChildNode(fieldContainer)

        buildFieldLines(
            container: fieldContainer,
            strength: fieldStrength
        )

        // ---------------------------------------------------------
        // QRTL DIPOLE
        // ---------------------------------------------------------

        let dipoleContainer = SCNNode()

        dipoleContainer.name = "QRTLDipole"

        root.addChildNode(dipoleContainer)

        createDipole(
            container: dipoleContainer
        )

        // ---------------------------------------------------------
        // COLLECTOR
        // ---------------------------------------------------------

        createCollector(
            root: root
        )

        // ---------------------------------------------------------
        // CURRENT PATHS
        // ---------------------------------------------------------

        createCurrentPaths(
            root: root
        )

        // ---------------------------------------------------------
        // CENTRAL TERMINAL
        // ---------------------------------------------------------

        createTerminal(
            root: root
        )

        // ---------------------------------------------------------
        // POWER CONDITIONING
        // ---------------------------------------------------------

        createPowerConditioning(
            root: root
        )

        // ---------------------------------------------------------
        // LOAD
        // ---------------------------------------------------------

        createLoad(
            root: root
        )

        // ---------------------------------------------------------
        // LABELS
        // ---------------------------------------------------------

        addLabel(
            "IONOSPHERE",
            position: SCNVector3(
                -5,
                28,
                0
            ),
            root: root
        )

        addLabel(
            "QRTL DIPOLE",
            position: SCNVector3(
                -5,
                10,
                0
            ),
            root: root
        )

        addLabel(
            "CONDUCTIVE COLLECTOR",
            position: SCNVector3(
                -7,
                1,
                0
            ),
            root: root
        )

        addLabel(
            "CENTRAL TERMINAL",
            position: SCNVector3(
                -6,
                -2,
                0
            ),
            root: root
        )

        addLabel(
            "POWER CONDITIONING",
            position: SCNVector3(
                8,
                3,
                0
            ),
            root: root
        )

        addLabel(
            "10 MW LOAD",
            position: SCNVector3(
                8,
                1,
                0
            ),
            root: root
        )
    }

    // MARK: - Field Lines

    private func buildFieldLines(
        container: SCNNode,
        strength: Double
    ) {

        let count = 18

        for i in 0..<count {

            let angle =
                Float(i) /
                Float(count) *
                Float.pi * 2

            let radius: CGFloat = 7.0

            let points: [SCNVector3] = [

                SCNVector3(
                    Float(cos(angle)) * Float(radius),
                    19,
                    Float(sin(angle)) * Float(radius)
                ),

                SCNVector3(
                    Float(cos(angle)) * 5,
                    14,
                    Float(sin(angle)) * 5
                ),

                SCNVector3(
                    Float(cos(angle)) * 3,
                    9,
                    Float(sin(angle)) * 3
                ),

                SCNVector3(
                    Float(cos(angle)) * 2,
                    4,
                    Float(sin(angle)) * 2
                )
            ]

            let line = lineNode(
                points: points,
                radius: 0.025 + CGFloat(strength) * 0.01
            )

            container.addChildNode(line)

            addMovingParticle(
                to: container,
                points: points,
                delay: Double(i) * 0.08
            )
        }
    }

    // MARK: - Dipole

    private func createDipole(
        container: SCNNode
    ) {

        let upperGeometry =
            SCNSphere(radius: 1.8)

        upperGeometry.firstMaterial =
            emissiveMaterial(
                UIColor.systemPink
            )

        let upper =
            SCNNode(
                geometry: upperGeometry
            )

        upper.position =
            SCNVector3(
                0,
                8,
                0
            )

        container.addChildNode(upper)

        let lowerGeometry =
            SCNSphere(radius: 1.8)

        lowerGeometry.firstMaterial =
            emissiveMaterial(
                UIColor.systemBlue
            )

        let lower =
            SCNNode(
                geometry: lowerGeometry
            )

        lower.position =
            SCNVector3(
                0,
                4,
                0
            )

        container.addChildNode(lower)

        let centerGeometry =
            SCNCylinder(
                radius: 0.65,
                height: 4
            )

        centerGeometry.firstMaterial =
            metallicMaterial(
                UIColor.darkGray
            )

        let center =
            SCNNode(
                geometry: centerGeometry
            )

        center.position =
            SCNVector3(
                0,
                6,
                0
            )

        container.addChildNode(center)

        let ringGeometry =
            SCNTorus(
                ringRadius: 3.2,
                pipeRadius: 0.08
            )

        ringGeometry.firstMaterial =
            emissiveMaterial(
                UIColor.systemPurple
            )

        let ring =
            SCNNode(
                geometry: ringGeometry
            )

        ring.position =
            SCNVector3(
                0,
                6,
                0
            )

        container.addChildNode(ring)

        let rotation =
            CABasicAnimation(
                keyPath: "rotation"
            )

        rotation.fromValue =
            NSValue(
                scnVector4: SCNVector4(
                    0,
                    1,
                    0,
                    0
                )
            )

        rotation.toValue =
            NSValue(
                scnVector4: SCNVector4(
                    0,
                    1,
                    0,
                    Float.pi * 2
                )
            )

        rotation.duration = 5
        rotation.repeatCount = .infinity

        ring.addAnimation(
            rotation,
            forKey: "dipoleRotation"
        )
    }

    // MARK: - Collector

    private func createCollector(
        root: SCNNode
    ) {

        let collectorGeometry =
            SCNCylinder(
                radius: 9,
                height: 0.18
            )

        collectorGeometry.firstMaterial =
            metallicMaterial(
                UIColor(
                    white: 0.55,
                    alpha: 1
                )
            )

        let collector =
            SCNNode(
                geometry: collectorGeometry
            )

        collector.name = "ConductiveCollector"

        collector.position =
            SCNVector3(
                0,
                0.5,
                0
            )

        root.addChildNode(collector)

        // Shallow bowl appearance

        let bowlGeometry =
            SCNTorus(
                ringRadius: 7.5,
                pipeRadius: 0.12
            )

        bowlGeometry.firstMaterial =
            emissiveMaterial(
                UIColor.systemCyan
            )

        let bowl =
            SCNNode(
                geometry: bowlGeometry
            )

        bowl.position =
            SCNVector3(
                0,
                0.7,
                0
            )

        root.addChildNode(bowl)

        // Radial collection conductors

        for i in 0..<16 {

            let angle =
                Float(i) /
                16 *
                Float.pi * 2

            let length: Float = 8

            let points = [

                SCNVector3(
                    cos(angle) * length,
                    0.65,
                    sin(angle) * length
                ),

                SCNVector3(
                    0,
                    0.65,
                    0
                )
            ]

            let conductor =
                lineNode(
                    points: points,
                    radius: 0.055
                )

            root.addChildNode(
                conductor
            )
        }

        // Circumferential rings

        for radius in stride(
            from: 2.0,
            through: 7.0,
            by: 1.0
        ) {

            let torus =
                SCNTorus(
                    ringRadius: CGFloat(radius),
                    pipeRadius: 0.035
                )

            torus.firstMaterial =
                metallicMaterial(
                    UIColor.systemGray
                )

            let node =
                SCNNode(
                    geometry: torus
                )

            node.position =
                SCNVector3(
                    0,
                    0.67,
                    0
                )

            root.addChildNode(node)
        }
    }

    // MARK: - Current Paths

    private func createCurrentPaths(
        root: SCNNode
    ) {

        let pathPoints = [

            SCNVector3(
                0,
                0.65,
                0
            ),

            SCNVector3(
                0,
                -1.5,
                0
            ),

            SCNVector3(
                0,
                -3.5,
                0
            ),

            SCNVector3(
                4,
                -4.5,
                0
            ),

            SCNVector3(
                8,
                -4.5,
                0
            )
        ]

        let current =
            lineNode(
                points: pathPoints,
                radius: 0.14
            )

        root.addChildNode(current)

        addMovingParticle(
            to: root,
            points: pathPoints,
            delay: 0
        )
    }

    // MARK: - Terminal

    private func createTerminal(
        root: SCNNode
    ) {

        let geometry =
            SCNSphere(
                radius: 0.55
            )

        geometry.firstMaterial =
            emissiveMaterial(
                UIColor.systemYellow
            )

        let node =
            SCNNode(
                geometry: geometry
            )

        node.position =
            SCNVector3(
                0,
                -2,
                0
            )

        root.addChildNode(node)
    }

    // MARK: - Power Conditioning

    private func createPowerConditioning(
        root: SCNNode
    ) {

        let box =
            SCNBox(
                width: 4,
                height: 2.5,
                length: 2.5,
                chamferRadius: 0.2
            )

        box.firstMaterial =
            metallicMaterial(
                UIColor.systemGray
            )

        let node =
            SCNNode(
                geometry: box
            )

        node.position =
            SCNVector3(
                7,
                3,
                0
            )

        root.addChildNode(node)
    }

    // MARK: - Load

    private func createLoad(
        root: SCNNode
    ) {

        let geometry =
            SCNBox(
                width: 4,
                height: 2,
                length: 2,
                chamferRadius: 0.2
            )

        geometry.firstMaterial =
            emissiveMaterial(
                UIColor.systemGreen
            )

        let node =
            SCNNode(
                geometry: geometry
            )

        node.position =
            SCNVector3(
                7,
                0,
                0
            )

        root.addChildNode(node)
    }

    // MARK: - Moving Energy Particle

    private func addMovingParticle(
        to parent: SCNNode,
        points: [SCNVector3],
        delay: Double
    ) {

        guard points.count >= 2 else {
            return
        }

        let geometry =
            SCNSphere(
                radius: 0.09
            )

        geometry.firstMaterial =
            emissiveMaterial(
                UIColor.white
            )

        let particle =
            SCNNode(
                geometry: geometry
            )

        particle.position =
            points[0]

        parent.addChildNode(particle)

        var actions: [SCNAction] = []

        for i in 0..<(points.count - 1) {

            let destination =
                points[i + 1]

            let distance =
                SCNVector3.distance(
                    points[i],
                    destination
                )

            let duration =
                TimeInterval(
                    max(
                        Double(distance) * 0.08,
                        0.05
                    )
                )

            actions.append(
                SCNAction.move(
                    to: destination,
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

        let sequence =
            SCNAction.sequence(actions)

        let repeatAction =
            SCNAction.repeatForever(sequence)

        particle.runAction(
            SCNAction.sequence([
                SCNAction.wait(
                    duration: delay
                ),
                repeatAction
            ])
        )
    }

    // MARK: - Line

    private func lineNode(
        points: [SCNVector3],
        radius: CGFloat
    ) -> SCNNode {

        let container = SCNNode()

        guard points.count >= 2 else {
            return container
        }

        for i in 0..<(points.count - 1) {

            let start = points[i]
            let end = points[i + 1]

            let segment =
                cylinderBetween(
                    start: start,
                    end: end,
                    radius: radius
                )

            container.addChildNode(segment)
        }

        return container
    }

    // MARK: - Cylinder Between Points

    private func cylinderBetween(
        start: SCNVector3,
        end: SCNVector3,
        radius: CGFloat
    ) -> SCNNode {

        let vector =
            end - start

        let length =
            vector.length

        let cylinder =
            SCNCylinder(
                radius: radius,
                height: CGFloat(length)
            )

        cylinder.firstMaterial =
            emissiveMaterial(
                UIColor.systemCyan
            )

        let node =
            SCNNode(
                geometry: cylinder
            )

        node.position =
            (start + end) * 0.5

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

    // MARK: - Labels

    private func addLabel(
        _ text: String,
        position: SCNVector3,
        root: SCNNode
    ) {

        let textGeometry =
            SCNText(
                string: text,
                extrusionDepth: 0.01
            )

        textGeometry.font =
            UIFont.systemFont(
                ofSize: 0.45,
                weight: .bold
            )

        textGeometry.flatness = 0.1

        textGeometry.firstMaterial =
            emissiveMaterial(
                UIColor.white
            )

        let node =
            SCNNode(
                geometry: textGeometry
            )

        node.position = position

        let (min, max) =
            textGeometry.boundingBox

        let width =
            max.x - min.x

        node.pivot =
            SCNMatrix4MakeTranslation(
                width / 2,
                0,
                0
            )

        root.addChildNode(node)
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


// MARK: - Output Value

struct OutputValue: View {

    let title: String
    let value: String

    var body: some View {

        VStack(spacing: 5) {

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
    }
}


// MARK: - Metric Row

struct MetricRow: View {

    let name: String
    let value: String

    var body: some View {

        HStack {

            Text(name)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
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

    var body: some View {

        VStack(alignment: .leading, spacing: 5) {

            HStack {

                Text(title)

                Spacer()

                Text(
                    String(
                        format: "%.3f%@",
                        value,
                        unit
                    )
                )
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

        HStack(alignment: .top, spacing: 12) {

            Text(number)
                .fontWeight(.bold)
                .frame(width: 25)

            VStack(alignment: .leading, spacing: 3) {

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(equation)
                    .font(.system(
                        .body,
                        design: .monospaced
                    ))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}


// MARK: - Energy Bar

struct EnergyBar: View {

    let title: String
    let value: Double
    let maximum: Double

    private var fraction: Double {

        guard maximum > 0 else {
            return 0
        }

        return min(
            max(value / maximum, 0),
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
                    String(
                        format: "%.3f MW",
                        value
                    )
                )
                .font(.caption)
                .monospacedDigit()
            }

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    RoundedRectangle(
                        cornerRadius: 5
                    )
                    .fill(.secondary.opacity(0.15))

                    RoundedRectangle(
                        cornerRadius: 5
                    )
                    .fill(.primary.opacity(0.65))
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


// MARK: - SceneKit Helpers

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

    var length: Float {

        sqrt(
            x * x +
            y * y +
            z * z
        )
    }

    static func distance(
        _ a: SCNVector3,
        _ b: SCNVector3
    ) -> Float {

        (b - a).length
    }

    func normalized() -> SCNVector3 {

        let l = length

        guard l > 0 else {
            return SCNVector3Zero
        }

        return self * (1.0 / l)
    }

    func look(
        at target: SCNVector3,
        up: SCNVector3,
        localFront: SCNVector3
    ) {

        let direction =
            (target - self).normalized()

        let defaultDirection =
            localFront.normalized()

        let axis =
            SCNVector3(
                defaultDirection.y * direction.z -
                defaultDirection.z * direction.y,

                defaultDirection.z * direction.x -
                defaultDirection.x * direction.z,

                defaultDirection.x * direction.y -
                defaultDirection.y * direction.x
            )

        let dot =
            defaultDirection.x * direction.x +
            defaultDirection.y * direction.y +
            defaultDirection.z * direction.z

        let clampedDot =
            max(
                min(dot, 1),
                -1
            )

        let angle =
            acos(
                clampedDot
            )

        let axisLength =
            axis.length

        if axisLength > 0.0001 {

            selfNodeRotation(
                axis: axis.normalized(),
                angle: angle
            )
        }
    }

    private func selfNodeRotation(
        axis: SCNVector3,
        angle: Float
    ) {
        // This helper is intentionally left empty because
        // SCNNode.look(at:) is implemented below through
        // the SCNNode extension.
    }
}


// MARK: - SCNNode Look Helper

extension SCNNode {

    func look(
        at target: SCNVector3,
        up: SCNVector3 = SCNVector3(0, 1, 0),
        localFront: SCNVector3 = SCNVector3(0, 0, -1)
    ) {

        let worldPosition = self.worldPosition

        // Direction from the node to the target.
        let dx = target.x - worldPosition.x
        let dy = target.y - worldPosition.y
        let dz = target.z - worldPosition.z

        let directionLength = sqrt(
            dx * dx +
            dy * dy +
            dz * dz
        )

        guard directionLength > 0.000001 else {
            return
        }

        let direction = SCNVector3(
            dx / directionLength,
            dy / directionLength,
            dz / directionLength
        )

        // Normalize the local front vector.
        let frontLength = sqrt(
            localFront.x * localFront.x +
            localFront.y * localFront.y +
            localFront.z * localFront.z
        )

        guard frontLength > 0.000001 else {
            return
        }

        let front = SCNVector3(
            localFront.x / frontLength,
            localFront.y / frontLength,
            localFront.z / frontLength
        )

        // Cross product: rotation axis.
        let axis = SCNVector3(
            front.y * direction.z -
            front.z * direction.y,

            front.z * direction.x -
            front.x * direction.z,

            front.x * direction.y -
            front.y * direction.x
        )

        let axisLength = sqrt(
            axis.x * axis.x +
            axis.y * axis.y +
            axis.z * axis.z
        )

        // Dot product determines rotation angle.
        let rawDot =
            front.x * direction.x +
            front.y * direction.y +
            front.z * direction.z

        let clampedDot = max(
            -1.0,
            min(1.0, rawDot)
        )

        let angle = acos(clampedDot)

        if axisLength > 0.000001 {

            let normalizedAxis = SCNVector3(
                axis.x / axisLength,
                axis.y / axisLength,
                axis.z / axisLength
            )

            self.rotation = SCNVector4(
                normalizedAxis.x,
                normalizedAxis.y,
                normalizedAxis.z,
                angle
            )

        } else if clampedDot < 0 {

            // The front vector and target direction point
            // in exactly opposite directions.
            //
            // Use the supplied up vector as the rotation axis.

            let upLength = sqrt(
                up.x * up.x +
                up.y * up.y +
                up.z * up.z
            )

            if upLength > 0.000001 {

                self.rotation = SCNVector4(
                    up.x / upLength,
                    up.y / upLength,
                    up.z / upLength,
                    Float.pi
                )
            }
        }
    }
}
