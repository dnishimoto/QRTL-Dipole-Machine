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

    func makeUIView(context: Context) -> SCNView {

        let view = SCNView()

        view.scene = makeScene()

        view.backgroundColor = .black

        view.allowsCameraControl = true

        view.autoenablesDefaultLighting = true

        return view
    }

    func updateUIView(
        _ view: SCNView,
        context: Context
    ) {

        guard let scene = view.scene else {
            return
        }

        updateFieldVisualization(scene)
    }

    // MARK: - Scene

    private func makeScene() -> SCNScene {

        let scene = SCNScene()

        // Camera
        let cameraNode = SCNNode()

        cameraNode.camera = SCNCamera()

        cameraNode.position =
            SCNVector3(
                0,
                8,
                22
            )

        let target = SCNVector3(0, 0, 0)
        cameraNode.look(at: target)

        scene.rootNode.addChildNode(cameraNode)

        // Main dipole
        let coilNode = makeDipoleCoil()

        scene.rootNode.addChildNode(coilNode)

        // Coupling region
        let couplingNode =
            makeCouplingRegion()

        scene.rootNode.addChildNode(couplingNode)

        // Field lines
        updateFieldVisualization(scene)

        return scene
    }

    // MARK: - Dipole coil

    private func makeDipoleCoil() -> SCNNode {

        let container = SCNNode()

        let coilRadius: CGFloat = 3.0

        for index in 0..<8 {

            let angle =
                CGFloat(index)
                * 2.0
                * .pi
                / 8.0

            let x =
                cos(angle)
                * coilRadius

            let z =
                sin(angle)
                * coilRadius

            let torus =
                SCNTorus(
                    ringRadius: 0.20,
                    pipeRadius: 0.06
                )

            let node =
                SCNNode(geometry: torus)

            node.position =
                SCNVector3(
                    x,
                    0,
                    z
                )

            node.rotation =
                SCNVector4(
                    1,
                    0,
                    0,
                    Double.pi / 2
                )

            container.addChildNode(node)
        }

        return container
    }

    // MARK: - Coupling region

    private func makeCouplingRegion() -> SCNNode {

        let geometry =
            SCNCylinder(
                radius: 4.0,
                height: 0.08
            )

        let node =
            SCNNode(geometry: geometry)

        node.position =
            SCNVector3(
                0,
                0,
                -8
            )

        return node
    }

    // MARK: - Field visualization

    private func updateFieldVisualization(
        _ scene: SCNScene
    ) {

        scene.rootNode.childNode(
            withName: "FieldLines",
            recursively: false
        )?.removeFromParentNode()

        let fieldContainer = SCNNode()

        fieldContainer.name = "FieldLines"

        let lineCount = 12

        for index in 0..<lineCount {

            let phase =
                Double(index)
                / Double(lineCount)
                * 2.0
                * Double.pi

            let path =
                UIBezierPath()

            let points = 80

            for step in 0..<points {

                let t =
                    Double(step)
                    / Double(points - 1)

                let radius =
                    2.5
                    + t * 9.0

                let x =
                    radius * cos(phase)

                let y =
                    radius * sin(phase)

                let z =
                    t * 12.0 - 6.0

                let field =
                    dipoleFieldAtScenePoint(
                        x: x,
                        y: y,
                        z: z
                    )

                let scale =
                    min(
                        1.0,
                        max(
                            0.05,
                            field / max(
                                Double(pipeline.magneticFieldAtIonosphereTesla),
                                1.0e-20
                            )
                        )
                    )

                let px =
                    CGFloat(x * (0.5 + 0.5 * scale))

                let py =
                    CGFloat(y * (0.5 + 0.5 * scale))

                if step == 0 {
                    path.move(
                        to: CGPoint(
                            x: px,
                            y: py
                        )
                    )
                } else {
                    path.addLine(
                        to: CGPoint(
                            x: px,
                            y: py
                        )
                    )
                }
            }

            let shape =
                SCNShape(
                    path: path,
                    extrusionDepth: 0.015
                )

            let node =
                SCNNode(
                    geometry: shape
                )

            node.position =
                SCNVector3(
                    0,
                    0,
                    0
                )

            fieldContainer.addChildNode(node)
        }

        scene.rootNode.addChildNode(
            fieldContainer
        )
    }

    // MARK: - Dipole field

    private func dipoleFieldAtScenePoint(
        x: Double,
        y: Double,
        z: Double
    ) -> Double {

        let sceneScale =
            PhysicsConstants.couplingDistanceMeters
            / 12.0

        let px = x * sceneScale
        let py = y * sceneScale
        let pz = z * sceneScale

        let rSquared =
            px * px
            + py * py
            + pz * pz

        guard rSquared > 0 else {
            return 0
        }

        let r =
            sqrt(rSquared)

        let m =
            pipeline.magneticMoment

        let mu =
            PhysicsConstants.vacuumPermeability

        let cosTheta =
            pz / r

        let magnitude =
            (mu / (4.0 * Double.pi))
            *
            (m / pow(r, 3.0))
            *
            sqrt(
                1.0
                + 3.0 * cosTheta * cosTheta
            )

        return magnitude
    }
}
