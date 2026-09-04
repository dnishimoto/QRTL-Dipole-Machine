import SwiftUI
import SceneKit
import UIKit

struct QRTLSceneView: UIViewRepresentable {

    // MARK: - Inputs

    let running: Bool

    let primaryTurns: Double
    let primaryCurrentA: Double
    let primaryRadiusM: Double

    let upperEnabled: Bool
    let upperTurns: Double
    let upperCurrentA: Double
    let upperRadiusM: Double
    let upperHeightM: Double
    let upperPhaseDegrees: Double

    let lowerEnabled: Bool
    let lowerTurns: Double
    let lowerCurrentA: Double
    let lowerRadiusM: Double
    let lowerHeightM: Double
    let lowerPhaseDegrees: Double

    let couplingAltitudeKm: Double
    let couplingRadiusKm: Double

    let radialSpokeCount: Int
    let fluxManagementGain: Double

    // MARK: - Scene Coil

    private struct SceneCoil {

        let position: SIMD3<Double>
        let turns: Double
        let current: Double
        let radius: Double
        let phase: Double
        let enabled: Bool
    }

    // MARK: - Coil Configuration

    private var sceneCoils: [SceneCoil] {

        let machineCenterY = 6.0

        return [

            SceneCoil(
                position: SIMD3(
                    0,
                    machineCenterY,
                    0
                ),
                turns: primaryTurns,
                current: running ? primaryCurrentA : 0,
                radius: primaryRadiusM,
                phase: 0,
                enabled: true
            ),

            SceneCoil(
                position: SIMD3(
                    0,
                    machineCenterY + upperHeightM / 10.0,
                    0
                ),
                turns: upperTurns,
                current: running ? upperCurrentA : 0,
                radius: upperRadiusM,
                phase: upperPhaseDegrees * .pi / 180.0,
                enabled: upperEnabled
            ),

            SceneCoil(
                position: SIMD3(
                    0,
                    machineCenterY + lowerHeightM / 10.0,
                    0
                ),
                turns: lowerTurns,
                current: running ? lowerCurrentA : 0,
                radius: lowerRadiusM,
                phase: lowerPhaseDegrees * .pi / 180.0,
                enabled: lowerEnabled
            )
        ]
    }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> SCNView {

        let view = SCNView()

        view.backgroundColor = UIColor(
            red: 0.015,
            green: 0.025,
            blue: 0.055,
            alpha: 1
        )

        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 60

        let scene = SCNScene()

        scene.background.contents = UIColor(
            red: 0.015,
            green: 0.025,
            blue: 0.055,
            alpha: 1
        )

        view.scene = scene

        createCamera(in: scene)
        createLights(in: scene)
        createGround(in: scene)
        createIonosphere(in: scene)
        createCouplingSurface(in: scene)

        createMachine(in: scene)
        createFieldLines(in: scene)

        createCollector(in: scene)
        createCurrentPath(in: scene)
        createPowerConditioning(in: scene)
        createLoad(in: scene)

        createLabels(in: scene)

        return view
    }

    func updateUIView(
        _ view: SCNView,
        context: Context
    ) {

        guard let scene = view.scene else {
            return
        }

        // Rebuild dynamic field visualization.

        scene.rootNode.childNode(
            withName: "FieldContainer",
            recursively: false
        )?.removeFromParentNode()

        scene.rootNode.childNode(
            withName: "DipoleMachine",
            recursively: false
        )?.removeFromParentNode()

        scene.rootNode.childNode(
            withName: "CouplingSurface",
            recursively: false
        )?.removeFromParentNode()

        createMachine(in: scene)
        createFieldLines(in: scene)
        createCouplingSurface(in: scene)

        // Update running-state appearance.

        let machineOpacity = running ? 1.0 : 0.35

        scene.rootNode.childNode(
            withName: "DipoleMachine",
            recursively: false
        )?.opacity = machineOpacity

        scene.rootNode.childNode(
            withName: "FieldContainer",
            recursively: false
        )?.opacity = running ? 1.0 : 0.20
    }

    // MARK: - Camera

    private func createCamera(
        in scene: SCNScene
    ) {
        let cameraNode = SCNNode()

        cameraNode.name = "Camera"

        let camera = SCNCamera()

        /// Narrower than the current 48° lens:
        /// less distortion and a more intentional technical render.
        camera.fieldOfView = 42.0

        camera.zNear = 0.1
        camera.zFar = 500.0

        /// Gives a subtle cinematic depth effect without making
        /// labels and the collector unusably blurry.
        camera.wantsDepthOfField = true
        camera.focusDistance = 30.0
        camera.fStop = 5.6
        camera.apertureBladeCount = 6

        cameraNode.camera = camera

        /// Three-quarter elevated view:
        /// - X positive: power path on the right remains visible.
        /// - Z positive: visible depth around coils/field lines.
        /// - Y elevated: collector, coils, and coupling surface all fit.
        cameraNode.position = SCNVector3(
            25.0,
            18.0,
            64.0
        )

        let targetNode = SCNNode()

        targetNode.name = "CameraTarget"

        /// Aim near the visual center:
        /// collector/base at y≈0,
        /// machine centered near y≈6,
        /// coupling plane at y≈12...28,
        /// hardware extends right to x≈25.
        targetNode.position = SCNVector3(
            5.0,
            10.0,
            0.0
        )

        scene.rootNode.addChildNode(targetNode)

        let lookAt = SCNLookAtConstraint(
            target: targetNode
        )

        lookAt.isGimbalLockEnabled = true

        cameraNode.constraints = [lookAt]

        scene.rootNode.addChildNode(cameraNode)
    }
    // MARK: - Lights

    private func createLights(
        in scene: SCNScene
    ) {

        let key = SCNNode()

        let keyLight = SCNLight()

        keyLight.type = .omni
        keyLight.intensity = 1100
        keyLight.color = UIColor.white
        keyLight.attenuationStartDistance = 10
        keyLight.attenuationEndDistance = 150

        key.light = keyLight

        key.position = SCNVector3(
            20,
            35,
            30
        )

        scene.rootNode.addChildNode(key)

        let fill = SCNNode()

        let fillLight = SCNLight()

        fillLight.type = .omni
        fillLight.intensity = 650
        fillLight.color = UIColor(
            red: 0.55,
            green: 0.70,
            blue: 1.0,
            alpha: 1
        )

        fillLight.attenuationStartDistance = 10
        fillLight.attenuationEndDistance = 120

        fill.light = fillLight

        fill.position = SCNVector3(
            -30,
            15,
            -20
        )

        scene.rootNode.addChildNode(fill)

        let ambient = SCNNode()

        let ambientLight = SCNLight()

        ambientLight.type = .ambient
        ambientLight.intensity = 300
        ambientLight.color = UIColor(
            red: 0.35,
            green: 0.40,
            blue: 0.55,
            alpha: 1
        )

        ambient.light = ambientLight

        scene.rootNode.addChildNode(ambient)
    }

    // MARK: - Ground

    private func createGround(
        in scene: SCNScene
    ) {

        let plane = SCNPlane(
            width: 90,
            height: 90
        )

        let material = SCNMaterial()

        material.diffuse.contents = UIColor(
            red: 0.025,
            green: 0.035,
            blue: 0.060,
            alpha: 1
        )

        material.metalness.contents = 0.35
        material.roughness.contents = 0.65

        plane.materials = [material]

        let node = SCNNode(
            geometry: plane
        )

        node.eulerAngles.x = -.pi / 2

        node.position = SCNVector3(
            0,
            0,
            0
        )

        scene.rootNode.addChildNode(node)
    }

    // MARK: - Ionosphere

    private func createIonosphere(
        in scene: SCNScene
    ) {

        let sphere = SCNSphere(
            radius: 28
        )

        sphere.segmentCount = 64

        let material = SCNMaterial()

        material.diffuse.contents = UIColor(
            red: 0.05,
            green: 0.18,
            blue: 0.45,
            alpha: 0.08
        )

        material.emission.contents = UIColor(
            red: 0.05,
            green: 0.25,
            blue: 0.85,
            alpha: 0.10
        )

        material.transparency = 0.08
        material.isDoubleSided = true
        material.blendMode = .add

        sphere.materials = [material]

        let node = SCNNode(
            geometry: sphere
        )

        node.position = SCNVector3(
            0,
            6,
            0
        )

        node.name = "Ionosphere"

        scene.rootNode.addChildNode(node)
    }

    // MARK: - Coupling Surface

    private func createCouplingSurface(
        in scene: SCNScene
    ) {

        let altitudeScene = min(
            max(
                couplingAltitudeKm / 10.0,
                12.0
            ),
            28.0
        )

        let radiusScene = min(
            max(
                couplingRadiusKm / 4.0,
                3.0
            ),
            12.0
        )

        let disk = SCNCylinder(
            radius: CGFloat(radiusScene),
            height: 0.08
        )

        disk.radialSegmentCount = 96

        let material = SCNMaterial()

        material.diffuse.contents = UIColor(
            red: 0.15,
            green: 0.65,
            blue: 1.0,
            alpha: 0.12
        )

        material.emission.contents = UIColor(
            red: 0.05,
            green: 0.35,
            blue: 1.0,
            alpha: 0.35
        )

        material.transparency = 0.45
        material.blendMode = .add
        material.isDoubleSided = true

        disk.materials = [material]

        let node = SCNNode(
            geometry: disk
        )

        node.name = "CouplingSurface"

        node.position = SCNVector3(
            0,
            Float(altitudeScene),
            0
        )

        scene.rootNode.addChildNode(node)

        let ring = SCNTorus(
            ringRadius: CGFloat(radiusScene),
            pipeRadius: 0.025
        )

        let ringMaterial = SCNMaterial()

        ringMaterial.diffuse.contents = UIColor(
            red: 0.15,
            green: 0.70,
            blue: 1.0,
            alpha: 0.75
        )

        ringMaterial.emission.contents = UIColor(
            red: 0.05,
            green: 0.45,
            blue: 1.0,
            alpha: 1
        )

        ring.materials = [ringMaterial]

        let ringNode = SCNNode(
            geometry: ring
        )

        ringNode.name = "CouplingBoundary"

        ringNode.position = node.position

        scene.rootNode.addChildNode(ringNode)
    }

    // MARK: - Dipole Machine

    private func createMachine(
        in scene: SCNScene
    ) {

        let container = SCNNode()

        container.name = "DipoleMachine"

        // Central body.

        let body = SCNCylinder(
            radius: 2.8,
            height: 5.0
        )

        body.radialSegmentCount = 64

        body.materials = [
            material(
                color: UIColor(
                    red: 0.20,
                    green: 0.22,
                    blue: 0.27,
                    alpha: 1
                ),
                metalness: 0.85,
                roughness: 0.25
            )
        ]

        let bodyNode = SCNNode(
            geometry: body
        )

        bodyNode.position = SCNVector3(
            0,
            6,
            0
        )

        container.addChildNode(bodyNode)

        // North pole.

        let north = SCNCylinder(
            radius: 3.2,
            height: 1.2
        )

        north.radialSegmentCount = 64

        north.materials = [
            material(
                color: UIColor(
                    red: 0.85,
                    green: 0.10,
                    blue: 0.08,
                    alpha: 1
                ),
                metalness: 0.55,
                roughness: 0.25
            )
        ]

        let northNode = SCNNode(
            geometry: north
        )

        northNode.position = SCNVector3(
            0,
            8.4,
            0
        )

        container.addChildNode(northNode)

        // South pole.

        let south = SCNCylinder(
            radius: 3.2,
            height: 1.2
        )

        south.radialSegmentCount = 64

        south.materials = [
            material(
                color: UIColor(
                    red: 0.08,
                    green: 0.25,
                    blue: 0.90,
                    alpha: 1
                ),
                metalness: 0.55,
                roughness: 0.25
            )
        ]

        let southNode = SCNNode(
            geometry: south
        )

        southNode.position = SCNVector3(
            0,
            3.6,
            0
        )

        container.addChildNode(southNode)

        // Primary coil.

        createCoilRings(
            parent: container,
            coil: sceneCoils[0],
            color: UIColor(
                red: 1.0,
                green: 0.45,
                blue: 0.05,
                alpha: 1
            ),
            name: "PrimaryCoil"
        )

        // Upper shaping coil.

        if upperEnabled {

            createCoilRings(
                parent: container,
                coil: sceneCoils[1],
                color: UIColor(
                    red: 1.0,
                    green: 0.20,
                    blue: 0.70,
                    alpha: 1
                ),
                name: "UpperShapingCoil"
            )
        }

        // Lower return coil.

        if lowerEnabled {

            createCoilRings(
                parent: container,
                coil: sceneCoils[2],
                color: UIColor(
                    red: 0.50,
                    green: 0.20,
                    blue: 1.0,
                    alpha: 1
                ),
                name: "LowerReturnCoil"
            )
        }

        scene.rootNode.addChildNode(container)
    }

    // MARK: - Coil Rings

    private func createCoilRings(
        parent: SCNNode,
        coil: SceneCoil,
        color: UIColor,
        name: String
    ) {

        let visibleRadius = min(
            max(
                coil.radius / 8.0,
                2.8
            ),
            9.0
        )

        let ringCount = min(
            max(
                Int(abs(coil.turns) / 200.0),
                4
            ),
            18
        )

        for index in 0..<ringCount {

            let torus = SCNTorus(
                ringRadius: CGFloat(visibleRadius),
                pipeRadius: 0.055
            )

            let material = SCNMaterial()

            material.diffuse.contents = color
            material.emission.contents = color
            material.emission.intensity = 0.65
            material.metalness.contents = 0.7
            material.roughness.contents = 0.25

            torus.materials = [material]

            let node = SCNNode(
                geometry: torus
            )

            let offset = Double(index - ringCount / 2) * 0.12

            node.position = SCNVector3(
                0,
                Float(coil.position.y + offset),
                0
            )

            node.name = name

            parent.addChildNode(node)
        }
    }

    // MARK: - Field Lines

    private func createFieldLines(
        in scene: SCNScene
    ) {

        let container = SCNNode()

        container.name = "FieldContainer"

        let seedCount = 16

        let seedRadius = 3.8

        for index in 0..<seedCount {

            let theta =
                (Double(index) /
                 Double(seedCount)) *
                2.0 *
                Double.pi

            let seed = SIMD3<Double>(
                cos(theta) * seedRadius,
                6.0,
                sin(theta) * seedRadius
            )

            let forward = integrateFieldLine(
                from: seed,
                direction: 1
            )

            let backward = integrateFieldLine(
                from: seed,
                direction: -1
            )

            var complete: [SIMD3<Double>] = []

            complete.append(
                contentsOf: backward.reversed()
            )

            complete.append(seed)

            complete.append(
                contentsOf: forward
            )

            createFieldLine(
                parent: container,
                points: complete
            )
        }

        scene.rootNode.addChildNode(container)
    }

    private func integrateFieldLine(
        from start: SIMD3<Double>,
        direction: Double
    ) -> [SIMD3<Double>] {

        var points: [SIMD3<Double>] = []

        var position = start

        let step = 0.35

        for _ in 0..<100 {

            let field = combinedField(
                at: position
            )

            let magnitude = vectorLength(field)

            if magnitude < 1e-30 {
                break
            }

            let directionVector = vectorScale(
                field,
                direction / magnitude
            )

            position = vectorAdd(
                position,
                vectorScale(
                    directionVector,
                    step
                )
            )

            points.append(position)

            let distanceFromOrigin = sqrt(
                position.x * position.x +
                position.y * position.y +
                position.z * position.z
            )

            if distanceFromOrigin > 32 {
                break
            }

            if position.y < -4 ||
                position.y > 34 {

                break
            }
        }

        return points
    }

    private func createFieldLine(
        parent: SCNNode,
        points: [SIMD3<Double>]
    ) {

        guard points.count > 1 else {
            return
        }

        for index in 0..<(points.count - 1) {

            let a = points[index]
            let b = points[index + 1]

            let start = SCNVector3(
                Float(a.x),
                Float(a.y),
                Float(a.z)
            )

            let end = SCNVector3(
                Float(b.x),
                Float(b.y),
                Float(b.z)
            )

            let node = lineNode(
                from: start,
                to: end,
                radius: 0.025,
                color: UIColor(
                    red: 0.20,
                    green: 0.65,
                    blue: 1.0,
                    alpha: 0.45
                )
            )

            parent.addChildNode(node)
        }
    }

    // MARK: - Magnetic Field

    private func combinedField(
        at point: SIMD3<Double>
    ) -> SIMD3<Double> {

        var result = SIMD3<Double>(
            0,
            0,
            0
        )

        for coil in sceneCoils {

            guard coil.enabled else {
                continue
            }

            result = vectorAdd(
                result,
                fieldFromCoil(
                    coil,
                    at: point
                )
            )
        }

        return vectorScale(
            result,
            max(
                fluxManagementGain,
                0
            )
        )
    }

    private func fieldFromCoil(
        _ coil: SceneCoil,
        at point: SIMD3<Double>
    ) -> SIMD3<Double> {

        let relative = vectorSubtract(
            point,
            coil.position
        )

        let r = vectorLength(
            relative
        )

        guard r > 0.25 else {
            return SIMD3<Double>(
                0,
                0,
                0
            )
        }

        let area =
            Double.pi *
            coil.radius *
            coil.radius

        let magneticMomentMagnitude =
            coil.turns *
            coil.current *
            area

        // Dipole moment aligned with the Y axis.

        let moment = SIMD3<Double>(
            0,
            magneticMomentMagnitude,
            0
        )

        let rHat = vectorScale(
            relative,
            1.0 / r
        )

        let dotProduct =
            rHat.x * moment.x +
            rHat.y * moment.y +
            rHat.z * moment.z

        let term1 = vectorScale(
            rHat,
            3.0 * dotProduct
        )

        let numerator = vectorSubtract(
            term1,
            moment
        )

        let mu0Over4Pi =
            1.0e-7

        let scale =
            mu0Over4Pi /
            pow(r, 3)

        let phaseFactor =
            cos(coil.phase)

        return vectorScale(
            numerator,
            scale * phaseFactor
        )
    }

    // MARK: - Collector

    private func createCollector(
        in scene: SCNScene
    ) {

        let collector = SCNCylinder(
            radius: 9.0,
            height: 0.25
        )

        collector.radialSegmentCount = 96

        collector.materials = [
            material(
                color: UIColor(
                    red: 0.18,
                    green: 0.20,
                    blue: 0.23,
                    alpha: 1
                ),
                metalness: 0.8,
                roughness: 0.30
            )
        ]

        let node = SCNNode(
            geometry: collector
        )

        node.name = "Collector"

        node.position = SCNVector3(
            0,
            0.5,
            0
        )

        scene.rootNode.addChildNode(node)

        let count = min(
            max(
                radialSpokeCount,
                4
            ),
            48
        )

        for index in 0..<count {

            let angle =
                Float(index) /
                Float(count) *
                Float.pi *
                2

            let spokeLength: Float = 8.5

            let end = SCNVector3(
                cos(angle) * spokeLength,
                0.68,
                sin(angle) * spokeLength
            )

            let start = SCNVector3(
                0,
                0.68,
                0
            )

            let spoke = lineNode(
                from: start,
                to: end,
                radius: 0.055,
                color: UIColor(
                    red: 0.95,
                    green: 0.75,
                    blue: 0.15,
                    alpha: 0.9
                )
            )

            node.addChildNode(spoke)
        }
    }

    // MARK: - Current Path

    private func createCurrentPath(
        in scene: SCNScene
    ) {

        let start = SCNVector3(
            0,
            0.75,
            0
        )

        let end = SCNVector3(
            14,
            0.75,
            0
        )

        let path = lineNode(
            from: start,
            to: end,
            radius: 0.12,
            color: UIColor(
                red: 1.0,
                green: 0.75,
                blue: 0.10,
                alpha: 1
            )
        )

        path.name = "CollectorCurrentPath"

        scene.rootNode.addChildNode(path)
    }

    // MARK: - Power Conditioning

    private func createPowerConditioning(
        in scene: SCNScene
    ) {

        let box = SCNBox(
            width: 5,
            height: 2.5,
            length: 4,
            chamferRadius: 0.25
        )

        box.materials = [
            material(
                color: UIColor(
                    red: 0.28,
                    green: 0.30,
                    blue: 0.34,
                    alpha: 1
                ),
                metalness: 0.5,
                roughness: 0.35
            )
        ]

        let node = SCNNode(
            geometry: box
        )

        node.name = "PowerConditioning"

        node.position = SCNVector3(
            17,
            1.8,
            0
        )

        scene.rootNode.addChildNode(node)

        let connection = lineNode(
            from: SCNVector3(
                14,
                0.75,
                0
            ),
            to: SCNVector3(
                14.5,
                1.8,
                0
            ),
            radius: 0.10,
            color: UIColor(
                red: 1.0,
                green: 0.75,
                blue: 0.10,
                alpha: 1
            )
        )

        scene.rootNode.addChildNode(connection)
    }

    // MARK: - Load

    private func createLoad(
        in scene: SCNScene
    ) {

        let box = SCNBox(
            width: 4,
            height: 3,
            length: 4,
            chamferRadius: 0.3
        )

        box.materials = [
            material(
                color: UIColor(
                    red: 0.12,
                    green: 0.65,
                    blue: 0.25,
                    alpha: 1
                ),
                metalness: 0.45,
                roughness: 0.3
            )
        ]

        let node = SCNNode(
            geometry: box
        )

        node.name = "ElectricalLoad"

        node.position = SCNVector3(
            25,
            2,
            0
        )

        scene.rootNode.addChildNode(node)

        let cable = lineNode(
            from: SCNVector3(
                19.5,
                1.8,
                0
            ),
            to: SCNVector3(
                23,
                2,
                0
            ),
            radius: 0.10,
            color: UIColor(
                red: 0.95,
                green: 0.80,
                blue: 0.15,
                alpha: 1
            )
        )

        scene.rootNode.addChildNode(cable)
    }

    // MARK: - Labels

    private func createLabels(
        in scene: SCNScene
    ) {

        createText(
            "QRTL DIPOLE",
            at: SCNVector3(
                -5,
                11,
                0
            ),
            scale: 0.0045,
            color: UIColor.white,
            in: scene
        )

        createText(
            "COUPLING REGION",
            at: SCNVector3(
                -5,
                20,
                0
            ),
            scale: 0.0038,
            color: UIColor(
                red: 0.30,
                green: 0.70,
                blue: 1,
                alpha: 1
            ),
            in: scene
        )

        createText(
            "COLLECTOR",
            at: SCNVector3(
                -3,
                1.3,
                0
            ),
            scale: 0.0035,
            color: UIColor(
                red: 1,
                green: 0.80,
                blue: 0.20,
                alpha: 1
            ),
            in: scene
        )

        createText(
            "POWER CONDITIONING",
            at: SCNVector3(
                14.5,
                4,
                0
            ),
            scale: 0.003,
            color: UIColor.white,
            in: scene
        )

        createText(
            "LOAD",
            at: SCNVector3(
                23.5,
                4.5,
                0
            ),
            scale: 0.0035,
            color: UIColor(
                red: 0.30,
                green: 1,
                blue: 0.40,
                alpha: 1
            ),
            in: scene
        )
    }

    private func createText(
        _ string: String,
        at position: SCNVector3,
        scale: Float,
        color: UIColor,
        in scene: SCNScene
    ) {
        let text = SCNText(
            string: string,
            extrusionDepth: 0.01
        )

        text.font = UIFont.systemFont(
            ofSize: 10.0,
            weight: .semibold
        )

        text.flatness = 0.2
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue

        text.firstMaterial = material(
            color: color,
            metalness: 0.0,
            roughness: 0.5
        )

        let node = SCNNode(
            geometry: text
        )

        let bounds = text.boundingBox

        let centerX =
            (bounds.min.x + bounds.max.x)
            * 0.5

        let centerY =
            (bounds.min.y + bounds.max.y)
            * 0.5

        node.pivot = SCNMatrix4MakeTranslation(
            centerX,
            centerY,
            0.0
        )

        node.position = position

        node.scale = SCNVector3(
            scale,
            scale,
            scale
        )

        node.constraints = [
            SCNBillboardConstraint()
        ]

        scene.rootNode.addChildNode(node)
    }

    // MARK: - Line Node

    private func lineNode(
        from start: SCNVector3,
        to end: SCNVector3,
        radius: CGFloat,
        color: UIColor
    ) -> SCNNode {

        let length = vectorDistance(
            start,
            end
        )

        let cylinder = SCNCylinder(
            radius: radius,
            height: CGFloat(length)
        )

        cylinder.radialSegmentCount = 12

        cylinder.materials = [
            material(
                color: color,
                metalness: 0.3,
                roughness: 0.35
            )
        ]

        let node = SCNNode(
            geometry: cylinder
        )

        node.position = SCNVector3(
            (start.x + end.x) / 2,
            (start.y + end.y) / 2,
            (start.z + end.z) / 2
        )

        orient(
            node,
            from: start,
            to: end
        )

        return node
    }

    // MARK: - Orientation

    private func orient(
        _ node: SCNNode,
        from start: SCNVector3,
        to end: SCNVector3
    ) {

        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z

        let length = sqrt(
            dx * dx +
            dy * dy +
            dz * dz
        )

        guard length > 0.00001 else {
            return
        }

        let direction = SCNVector3(
            dx / length,
            dy / length,
            dz / length
        )

        let up = SCNVector3(
            0,
            1,
            0
        )

        let dot =
            up.x * direction.x +
            up.y * direction.y +
            up.z * direction.z

        if abs(dot - 1) < 0.00001 {

            node.eulerAngles = SCNVector3(
                0,
                0,
                0
            )

            return
        }

        if abs(dot + 1) < 0.00001 {

            node.eulerAngles = SCNVector3(
                Float.pi,
                0,
                0
            )

            return
        }

        let axis = SCNVector3(
            up.y * direction.z - up.z * direction.y,
            up.z * direction.x - up.x * direction.z,
            up.x * direction.y - up.y * direction.x
        )

        let axisLength = sqrt(
            axis.x * axis.x +
            axis.y * axis.y +
            axis.z * axis.z
        )

        guard axisLength > 0.00001 else {
            return
        }

        let normalizedAxis = SCNVector3(
            axis.x / axisLength,
            axis.y / axisLength,
            axis.z / axisLength
        )

        let angle = acos(
            max(
                -1,
                min(
                    1,
                    dot
                )
            )
        )

        node.rotation = SCNVector4(
            normalizedAxis.x,
            normalizedAxis.y,
            normalizedAxis.z,
            angle
        )
    }

    private func orient(
        _ node: SCNNode,
        toward target: SCNVector3
    ) {

        let start = node.position

        let dx = target.x - start.x
        let dy = target.y - start.y
        let dz = target.z - start.z

        let length = sqrt(
            dx * dx +
            dy * dy +
            dz * dz
        )

        guard length > 0.00001 else {
            return
        }

        let direction = SCNVector3(
            dx / length,
            dy / length,
            dz / length
        )

        let yaw = atan2(
            direction.x,
            direction.z
        )

        let horizontalLength = sqrt(
            direction.x * direction.x +
            direction.z * direction.z
        )

        let pitch = atan2(
            direction.y,
            horizontalLength
        )

        node.eulerAngles = SCNVector3(
            -pitch,
            yaw,
            0
        )
    }

    // MARK: - Materials

    private func material(
        color: UIColor,
        metalness: CGFloat,
        roughness: CGFloat
    ) -> SCNMaterial {

        let material = SCNMaterial()

        material.diffuse.contents = color
        material.metalness.contents = metalness
        material.roughness.contents = roughness

        return material
    }

    // MARK: - Vector Math

    private func vectorAdd(
        _ a: SIMD3<Double>,
        _ b: SIMD3<Double>
    ) -> SIMD3<Double> {

        SIMD3<Double>(
            a.x + b.x,
            a.y + b.y,
            a.z + b.z
        )
    }

    private func vectorSubtract(
        _ a: SIMD3<Double>,
        _ b: SIMD3<Double>
    ) -> SIMD3<Double> {

        SIMD3<Double>(
            a.x - b.x,
            a.y - b.y,
            a.z - b.z
        )
    }

    private func vectorScale(
        _ value: SIMD3<Double>,
        _ scalar: Double
    ) -> SIMD3<Double> {

        SIMD3<Double>(
            value.x * scalar,
            value.y * scalar,
            value.z * scalar
        )
    }

    private func vectorLength(
        _ value: SIMD3<Double>
    ) -> Double {

        sqrt(
            value.x * value.x +
            value.y * value.y +
            value.z * value.z
        )
    }

    private func vectorDistance(
        _ a: SCNVector3,
        _ b: SCNVector3
    ) -> Float {

        let dx = b.x - a.x
        let dy = b.y - a.y
        let dz = b.z - a.z

        return sqrt(
            dx * dx +
            dy * dy +
            dz * dz
        )
    }
}
