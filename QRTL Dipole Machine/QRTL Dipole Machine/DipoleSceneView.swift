//
//  DipoleSceneView.swift
//  QRTL Dipole Machine
//
//  Created by David Nishimoto on 9/1/26.
//

import Foundation
import SwiftUI
import SceneKit

struct DipoleSceneView: UIViewRepresentable {

    @ObservedObject var pipeline: RecirculationPipeline

    private var model: QRTLDipoleModel {
        pipeline.dipoleModel
    }

    func makeUIView(context: Context) -> SCNView {

        let view = SCNView()

        view.scene = makeScene()

        view.backgroundColor = .black
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X

        view.isPlaying = true
        view.rendersContinuously = true

        return view
    }

    func updateUIView(
        _ view: SCNView,
        context: Context
    ) {

        guard let scene = view.scene else {
            return
        }

        updateStaticCoils(scene)
        updateFieldVisualization(scene)
        updateCurrentVisualization(scene)
        updateCouplingRegion(scene)
    }

    // ============================================================
    // MARK: - Scene
    // ============================================================

    private func makeScene() -> SCNScene {

        let scene = SCNScene()

        scene.rootNode.addChildNode(
            makeCameraNode()
        )

        scene.rootNode.addChildNode(
            makeAmbientLight()
        )

        scene.rootNode.addChildNode(
            makeKeyLight()
        )

        scene.rootNode.addChildNode(
            makeBasePlane()
        )

        scene.rootNode.addChildNode(
            makeCoilContainer()
        )

        scene.rootNode.addChildNode(
            makeCouplingRegion()
        )

        updateFieldVisualization(scene)
        updateCurrentVisualization(scene)

        return scene
    }

    private func makeCameraNode() -> SCNNode {

        let cameraNode = SCNNode()

        cameraNode.name = "Camera"

        let camera = SCNCamera()

        camera.zFar = 500.0
        camera.zNear = 0.01

        cameraNode.camera = camera

        cameraNode.position = SCNVector3(
            13.0,
            10.0,
            22.0
        )

        cameraNode.look(
            at: SCNVector3(
                0.0,
                1.5,
                0.0
            )
        )

        return cameraNode
    }

    private func makeAmbientLight() -> SCNNode {

        let node = SCNNode()

        node.name = "AmbientLight"

        let light = SCNLight()

        light.type = .ambient
        light.intensity = 350
        light.color = UIColor(
            red: 0.18,
            green: 0.22,
            blue: 0.35,
            alpha: 1.0
        )

        node.light = light

        return node
    }

    private func makeKeyLight() -> SCNNode {

        let node = SCNNode()

        node.name = "KeyLight"

        let light = SCNLight()

        light.type = .omni
        light.intensity = 1_200
        light.color = UIColor.white

        node.light = light

        node.position = SCNVector3(
            8.0,
            12.0,
            10.0
        )

        return node
    }

    private func makeBasePlane() -> SCNNode {

        let plane = SCNCylinder(
            radius: 10.0,
            height: 0.15
        )

        let material = SCNMaterial()

        material.diffuse.contents = UIColor(
            red: 0.04,
            green: 0.06,
            blue: 0.10,
            alpha: 1.0
        )

        material.metalness.contents = 0.7
        material.roughness.contents = 0.45

        plane.materials = [material]

        let node = SCNNode(
            geometry: plane
        )

        node.name = "BasePlane"

        node.position = SCNVector3(
            0.0,
            -1.5,
            0.0
        )

        return node
    }

    // ============================================================
    // MARK: - Coil Geometry
    // ============================================================

    private func makeCoilContainer() -> SCNNode {

        let container = SCNNode()

        container.name = "CoilContainer"

        return container
    }

    private func updateStaticCoils(
        _ scene: SCNScene
    ) {

        guard let container = scene.rootNode.childNode(
            withName: "CoilContainer",
            recursively: false
        ) else {
            return
        }

        container.childNodes.forEach {
            $0.removeFromParentNode()
        }

        container.addChildNode(
            makeCoilNode(
                coil: model.primaryCoil,
                color: .systemCyan,
                sceneHeight: 0.0
            )
        )

        if model.upperShapingEnabled {
            container.addChildNode(
                makeCoilNode(
                    coil: model.upperCoil,
                    color: .systemPurple,
                    sceneHeight: 1.2
                )
            )
        }

        if model.lowerReturnEnabled {
            container.addChildNode(
                makeCoilNode(
                    coil: model.lowerCoil,
                    color: .systemOrange,
                    sceneHeight: -1.2
                )
            )
        }
    }

    private func makeCoilNode(
        coil: QRTLDipoleModel.DipoleCoil,
        color: UIColor,
        sceneHeight: Float
    ) -> SCNNode {

        let container = SCNNode()

        let requestedTurns = max(
            coil.turns,
            1.0
        )

        let visibleTurns = Int(
            min(
                12.0,
                max(
                    3.0,
                    requestedTurns / 150.0
                )
            )
        )

        let radiusScale = Float(
            min(
                4.2,
                max(
                    1.0,
                    coil.radiusM / 7.0
                )
            )
        )

        let coilRadius = CGFloat(radiusScale)

        for index in 0..<visibleTurns {

            let verticalOffset =
                Float(index - visibleTurns / 2)
                * 0.12

            let torus = SCNTorus(
                ringRadius: coilRadius,
                pipeRadius: 0.045
            )

            let material = SCNMaterial()

            material.diffuse.contents = color
            material.emission.contents = color.withAlphaComponent(
                0.35
            )

            material.metalness.contents = 0.75
            material.roughness.contents = 0.28

            torus.materials = [material]

            let turnNode = SCNNode(
                geometry: torus
            )

            turnNode.position = SCNVector3(
                0.0,
                sceneHeight + verticalOffset,
                0.0
            )

            turnNode.rotation = SCNVector4(
                1.0,
                0.0,
                0.0,
                Float.pi / 2.0
            )

            container.addChildNode(turnNode)
        }

        let fieldScale = Float(
            min(
                1.0,
                max(
                    0.15,
                    model.coilPowerScale
                )
            )
        )

        container.opacity = CGFloat(
            0.35 + 0.65 * fieldScale
        )

        return container
    }

    // ============================================================
    // MARK: - Coupling Region
    // ============================================================

    private func makeCouplingRegion() -> SCNNode {

        let disk = SCNCylinder(
            radius: 4.2,
            height: 0.06
        )

        let material = SCNMaterial()

        material.diffuse.contents = UIColor(
            red: 0.10,
            green: 0.25,
            blue: 0.42,
            alpha: 0.55
        )

        material.emission.contents = UIColor(
            red: 0.05,
            green: 0.35,
            blue: 0.80,
            alpha: 0.45
        )

        material.transparency = 0.55

        disk.materials = [material]

        let node = SCNNode(
            geometry: disk
        )

        node.name = "CouplingRegion"

        node.position = SCNVector3(
            0.0,
            7.0,
            0.0
        )

        return node
    }

    private func updateCouplingRegion(
        _ scene: SCNScene
    ) {

        guard let node = scene.rootNode.childNode(
            withName: "CouplingRegion",
            recursively: false
        ) else {
            return
        }

        let modelRadius = max(
            model.couplingRadiusKm,
            0.01
        )

        let normalizedRadius = CGFloat(
            min(
                6.0,
                max(
                    1.6,
                    modelRadius * 1.8
                )
            )
        )

        if let cylinder = node.geometry as? SCNCylinder {
            cylinder.radius = normalizedRadius
        }

        let fieldStrength = model.fieldAtCouplingCenterTesla

        let normalizedIntensity = min(
            1.0,
            max(
                0.12,
                log10(
                    max(
                        fieldStrength,
                        1.0e-30
                    )
                )
                + 30.0
            )
            / 30.0
        )

        node.opacity = CGFloat(
            0.15 + 0.70 * normalizedIntensity
        )
    }

    // ============================================================
    // MARK: - Field-Line Visualization
    // ============================================================

    private func updateFieldVisualization(
        _ scene: SCNScene
    ) {

        scene.rootNode.childNode(
            withName: "FieldLines",
            recursively: false
        )?.removeFromParentNode()

        guard
            model.isRunning,
            model.peakMagneticFluxWebers > 0.0
        else {
            return
        }

        let fieldContainer = SCNNode()

        fieldContainer.name = "FieldLines"

        let lineCount = 18

        for index in 0..<lineCount {

            let phase =
                Double(index)
                / Double(lineCount)
                * 2.0
                * Double.pi

            let lineNode = makeFieldLine(
                phase: phase,
                color: .systemTeal
            )

            fieldContainer.addChildNode(lineNode)
        }

        scene.rootNode.addChildNode(
            fieldContainer
        )
    }

    private func makeFieldLine(
        phase: Double,
        color: UIColor
    ) -> SCNNode {

        let points = makeDipoleFieldLinePoints(
            phase: phase
        )

        let geometry = SCNGeometry.lineGeometry(
            points: points,
            color: color,
            width: 1.5
        )

        let node = SCNNode(
            geometry: geometry
        )

        node.opacity = CGFloat(
            min(
                0.85,
                max(
                    0.18,
                    0.25
                    + 0.60
                    * model.coilPowerScale
                )
            )
        )

        return node
    }

    /// Generates normalized dipole-like field curves.
    ///
    /// Scene distance is visual only; it is not a literal
    /// 100 km-to-meter rendering.
    private func makeDipoleFieldLinePoints(
        phase: Double
    ) -> [SCNVector3] {

        let pointCount = 96

        let startRadius: Double = 0.7
        let endRadius: Double = 6.0

        var points: [SCNVector3] = []

        for index in 0..<pointCount {

            let t =
                Double(index)
                / Double(pointCount - 1)

            let theta =
                0.18
                + t
                * (Double.pi - 0.36)

            let radialDistance =
                startRadius
                + (endRadius - startRadius)
                * pow(
                    sin(theta),
                    1.4
                )

            let x =
                radialDistance
                * sin(theta)
                * cos(phase)

            let z =
                radialDistance
                * sin(theta)
                * sin(phase)

            let y =
                7.0
                * cos(theta)

            points.append(
                SCNVector3(
                    Float(x),
                    Float(y),
                    Float(z)
                )
            )
        }

        return points
    }

    // ============================================================
    // MARK: - QRTL Current Visualization
    // ============================================================

    private func updateCurrentVisualization(
        _ scene: SCNScene
    ) {

        scene.rootNode.childNode(
            withName: "CurrentFlow",
            recursively: false
        )?.removeFromParentNode()

        guard
            pipeline.machineRunning,
            pipeline.visualDownwardCurrentMagnitudeAmps > 0.0
        else {
            return
        }

        let flowContainer = SCNNode()

        flowContainer.name = "CurrentFlow"

        let currentMagnitude =
            pipeline.visualDownwardCurrentMagnitudeAmps

        let count = Int(
            min(
                48.0,
                max(
                    8.0,
                    log10(
                        max(
                            currentMagnitude,
                            1.0
                        )
                    )
                    * 4.0
                )
            )
        )

        for index in 0..<count {

            let t = Double(index) / Double(count)

            let particle = makeCurrentParticle()

            particle.position = SCNVector3(
                0.0,
                Float(7.0 - 7.8 * t),
                0.0
            )

            let delay = Double(index) * 0.05

            let fall = SCNAction.move(
                to: SCNVector3(
                    0.0,
                    -1.0,
                    0.0
                ),
                duration: 1.8
            )

            let reset = SCNAction.move(
                to: SCNVector3(
                    0.0,
                    7.0,
                    0.0
                ),
                duration: 0.0
            )

            particle.runAction(
                SCNAction.repeatForever(
                    SCNAction.sequence(
                        [
                            SCNAction.wait(
                                duration: delay
                            ),
                            fall,
                            reset
                        ]
                    )
                )
            )

            flowContainer.addChildNode(particle)
        }

        scene.rootNode.addChildNode(
            flowContainer
        )
    }

    private func makeCurrentParticle() -> SCNNode {

        let sphere = SCNSphere(
            radius: 0.065
        )

        let material = SCNMaterial()

        material.diffuse.contents = UIColor.systemCyan
        material.emission.contents = UIColor(
            red: 0.0,
            green: 0.75,
            blue: 1.0,
            alpha: 1.0
        )

        sphere.materials = [material]

        return SCNNode(
            geometry: sphere
        )
    }
}

// ================================================================
// MARK: - SceneKit Line Geometry
// ================================================================

private extension SCNGeometry {

    static func lineGeometry(
        points: [SCNVector3],
        color: UIColor,
        width: CGFloat
    ) -> SCNGeometry {

        guard points.count >= 2 else {
            return SCNGeometry()
        }

        let source = SCNGeometrySource(
            vertices: points
        )

        var indices: [Int32] = []

        for index in 0..<(points.count - 1) {
            indices.append(Int32(index))
            indices.append(Int32(index + 1))
        }

        let element = SCNGeometryElement(
            indices: indices,
            primitiveType: .line
        )

        let geometry = SCNGeometry(
            sources: [source],
            elements: [element]
        )

        let material = SCNMaterial()

        material.diffuse.contents = color
        material.emission.contents = color
        material.isDoubleSided = true

        geometry.materials = [material]

        return geometry
    }
}
