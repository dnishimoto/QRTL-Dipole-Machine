//
//  File.swift
//  QRTL Dipole Machine
//
//  Created by David Nishimoto on 9/1/26.
//

import Foundation
import UIKit
import SwiftUI
import SceneKit

struct QRTLSceneView: UIViewRepresentable {

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

    let fieldFrequencyKHz: Double
    let couplingAltitudeKm: Double
    let couplingRadiusKm: Double
    let radialSpokeCount: Int
    let fluxManagementGain: Double

    private let vacuumPermeability = 4.0 * Double.pi * 1e-7

    private struct SceneCoil {

        let position: SIMD3<Double>
        let turns: Double
        let currentA: Double
        let radiusM: Double
        let phaseRadians: Double
        let enabled: Bool
    }

    private var frequencyHz: Double {
        fieldFrequencyKHz * 1_000.0
    }

    private var angularFrequency: Double {
        2.0 *
        Double.pi *
        frequencyHz
    }

    private var sceneCoils: [SceneCoil] {
        [
            SceneCoil(
                position: SIMD3<Double>(
                    0,
                    0,
                    0
                ),
                turns: primaryTurns,
                currentA: primaryCurrentA,
                radiusM: primaryRadiusM,
                phaseRadians: 0,
                enabled: true
            ),

            SceneCoil(
                position: SIMD3<Double>(
                    0,
                    upperHeightM / 10.0,
                    0
                ),
                turns: upperTurns,
                currentA: upperCurrentA,
                radiusM: upperRadiusM,
                phaseRadians: upperPhaseDegrees *
                    Double.pi /
                    180.0,
                enabled: upperEnabled
            ),

            SceneCoil(
                position: SIMD3<Double>(
                    0,
                    lowerHeightM / 10.0,
                    0
                ),
                turns: lowerTurns,
                currentA: lowerCurrentA,
                radiusM: lowerRadiusM,
                phaseRadians: lowerPhaseDegrees *
                    Double.pi /
                    180.0,
                enabled: lowerEnabled
            )
        ]
        .filter(\.enabled)
    }

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

        buildScene(scene: scene)

        return view
    }

    /*
     This intentionally avoids rebuilding all SceneKit geometry when
     a SwiftUI slider changes. Rebuilding many tubes/particles during
     every update was the primary white-screen/performance problem.
    */
    func updateUIView(
        _ view: SCNView,
        context: Context
    ) {
        guard let root = view.scene?.rootNode else {
            return
        }

        if let fieldContainer = root.childNode(
            withName: "FieldContainer",
            recursively: true
        ) {
            fieldContainer.opacity = running ? 1.0 : 0.10
        }

        if let machine = root.childNode(
            withName: "DipoleMachine",
            recursively: true
        ) {
            machine.opacity = running ? 1.0 : 0.50
        }
    }

    private func buildScene(
        scene: SCNScene
    ) {
        let root = scene.rootNode

        createCamera(root: root)
        createLights(root: root)
        createGround(root: root)
        createIonosphere(root: root)
        createCouplingSurface(root: root)

        let fieldContainer = SCNNode()
        fieldContainer.name = "FieldContainer"
        fieldContainer.opacity = running ? 1.0 : 0.10

        root.addChildNode(fieldContainer)

        createFieldLines(
            container: fieldContainer
        )

        let machine = SCNNode()
        machine.name = "DipoleMachine"
        machine.opacity = running ? 1.0 : 0.50

        root.addChildNode(machine)

        createPrimaryMachine(root: machine)

        if upperEnabled {
            createShapingCoil(
                positionY: Float(
                    upperHeightM / 10.0
                ),
                color: UIColor.systemPink,
                root: machine
            )
        }

        if lowerEnabled {
            createShapingCoil(
                positionY: Float(
                    lowerHeightM / 10.0
                ),
                color: UIColor.systemPurple,
                root: machine
            )
        }

        createCollector(root: root)
        createCurrentPath(root: root)
        createPowerConditioning(root: root)
        createLoad(root: root)
        createLabels(root: root)
    }

    // MARK: - Static Scene Setup

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
        let floor = SCNFloor()

        floor.reflectivity = 0.08

        floor.firstMaterial?.diffuse.contents = UIColor(
            white: 0.06,
            alpha: 1
        )

        root.addChildNode(
            SCNNode(
                geometry: floor
            )
        )
    }

    private func createIonosphere(
        root: SCNNode
    ) {
        let sphere = SCNSphere(
            radius: 14
        )

        sphere.firstMaterial = transparentMaterial(
            UIColor.systemTeal,
            opacity: 0.06
        )

        let node = SCNNode(
            geometry: sphere
        )

        node.position = SCNVector3(
            0,
            20,
            0
        )

        root.addChildNode(node)
    }

    private func createCouplingSurface(
        root: SCNNode
    ) {
        let altitude = Float(
            min(
                max(
                    couplingAltitudeKm / 10.0,
                    12.0
                ),
                28.0
            )
        )

        let radius = CGFloat(
            min(
                max(
                    couplingRadiusKm / 4.0,
                    3.0
                ),
                12.0
            )
        )

        let disk = SCNCylinder(
            radius: radius,
            height: 0.08
        )

        disk.firstMaterial = transparentMaterial(
            UIColor.systemYellow,
            opacity: 0.20
        )

        let diskNode = SCNNode(
            geometry: disk
        )

        diskNode.position = SCNVector3(
            0,
            altitude,
            0
        )

        root.addChildNode(diskNode)

        let rim = SCNTorus(
            ringRadius: radius,
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
    }

    // MARK: - Fast Field-Line Visuals

    private func fieldFromCoil(
        _ coil: SceneCoil,
        at position: SIMD3<Double>,
        phaseRadians: Double
    ) -> SIMD3<Double> {
        let displacement =
            position -
            coil.position

        let rSquared =
            displacement.x * displacement.x +
            displacement.y * displacement.y +
            displacement.z * displacement.z

        guard rSquared > 1e-10 else {
            return .zero
        }

        let r = sqrt(rSquared)

        let rHat =
            displacement / r

        let area =
            Double.pi *
            coil.radiusM *
            coil.radiusM

        let momentMagnitude =
            coil.turns *
            coil.currentA *
            area

        let moment = SIMD3<Double>(
            0,
            momentMagnitude,
            0
        )

        let dot =
            moment.x * rHat.x +
            moment.y * rHat.y +
            moment.z * rHat.z

        let bracket =
            rHat * (3.0 * dot) -
            moment

        let scale =
            vacuumPermeability /
            (
                4.0 *
                Double.pi *
                r *
                r *
                r
            )

        let amplitude =
            sin(
                phaseRadians +
                coil.phaseRadians
            )

        return bracket *
            scale *
            amplitude
    }

    private func combinedField(
        at position: SIMD3<Double>,
        phaseRadians: Double
    ) -> SIMD3<Double> {
        sceneCoils.reduce(
            SIMD3<Double>.zero
        ) {
            partial,
            coil in

            partial +
                fieldFromCoil(
                    coil,
                    at: position,
                    phaseRadians: phaseRadians
                )
        } * fluxManagementGain
    }

    /*
     The visual field uses only 12 seeds and 80 integration steps.
     This is deliberately bounded to avoid slow SceneKit startup.
    */
    private func createFieldLines(
        container: SCNNode
    ) {
        guard running,
              frequencyHz > 0
        else {
            return
        }

        let seedCount = 12
        let maxSteps = 80
        let stepSize = 0.40
        let phase = Double.pi / 2.0

        for seedIndex in 0..<seedCount {
            let angle =
                2.0 *
                Double.pi *
                Double(seedIndex) /
                Double(seedCount)

            let seed = SIMD3<Double>(
                1.75 * cos(angle),
                6.0,
                1.75 * sin(angle)
            )

            var forward: [SCNVector3] = []
            var backward: [SCNVector3] = []

            integrateFieldLine(
                start: seed,
                directionSign: 1.0,
                phaseRadians: phase,
                maxSteps: maxSteps,
                stepSize: stepSize,
                output: &forward
            )

            integrateFieldLine(
                start: seed,
                directionSign: -1.0,
                phaseRadians: phase,
                maxSteps: maxSteps,
                stepSize: stepSize,
                output: &backward
            )

            let points =
                Array(backward.reversed()) +
                forward

            guard points.count >= 2 else {
                continue
            }

            let line = lineNode(
                points: points,
                radius: 0.025,
                color: UIColor.systemCyan
            )

            container.addChildNode(line)
        }
    }

    private func integrateFieldLine(
        start: SIMD3<Double>,
        directionSign: Double,
        phaseRadians: Double,
        maxSteps: Int,
        stepSize: Double,
        output: inout [SCNVector3]
    ) {
        var position = start

        for _ in 0..<maxSteps {
            let field = combinedField(
                at: position,
                phaseRadians: phaseRadians
            )

            let magnitude = sqrt(
                field.x * field.x +
                field.y * field.y +
                field.z * field.z
            )

            guard magnitude > 1e-30 else {
                break
            }

            output.append(
                SCNVector3(
                    Float(position.x),
                    Float(position.y),
                    Float(position.z)
                )
            )

            let direction =
                field / magnitude

            position +=
                direction *
                (
                    directionSign *
                    stepSize
                )

            let distance = sqrt(
                position.x * position.x +
                position.y * position.y +
                position.z * position.z
            )

            if distance > 28.0 ||
                position.y < -6.0 ||
                position.y > 32.0 {
                break
            }
        }
    }

    // MARK: - Machine Geometry

    private func createPrimaryMachine(
        root: SCNNode
    ) {
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

        core.position = SCNVector3(
            0,
            6.0,
            0
        )

        root.addChildNode(core)

        createPole(
            position: SCNVector3(
                0,
                8.4,
                0
            ),
            color: UIColor.systemRed,
            root: root
        )

        createPole(
            position: SCNVector3(
                0,
                3.6,
                0
            ),
            color: UIColor.systemBlue,
            root: root
        )

        createCoilRings(
            position: SCNVector3(
                0,
                6.0,
                0
            ),
            color: UIColor.systemOrange,
            ringRadius: 2.4,
            count: 10,
            root: root
        )
    }

    private func createShapingCoil(
        positionY: Float,
        color: UIColor,
        root: SCNNode
    ) {
        createCoilRings(
            position: SCNVector3(
                0,
                positionY,
                0
            ),
            color: color,
            ringRadius: 1.8,
            count: 6,
            root: root
        )
    }

    private func createPole(
        position: SCNVector3,
        color: UIColor,
        root: SCNNode
    ) {
        let body = SCNCylinder(
            radius: 1.55,
            height: 0.62
        )

        body.firstMaterial = metallicMaterial(
            UIColor(
                red: 0.20,
                green: 0.22,
                blue: 0.26,
                alpha: 1
            )
        )

        let pole = SCNNode(
            geometry: body
        )

        pole.position = position
        root.addChildNode(pole)

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

        face.position = position
        root.addChildNode(face)
    }

    private func createCoilRings(
        position: SCNVector3,
        color: UIColor,
        ringRadius: CGFloat,
        count: Int,
        root: SCNNode
    ) {
        let assembly = SCNNode()
        assembly.position = position

        root.addChildNode(assembly)

        for index in 0..<count {
            let geometry = SCNTorus(
                ringRadius: ringRadius,
                pipeRadius: 0.075
            )

            geometry.firstMaterial = emissiveMaterial(
                color
            )

            let ring = SCNNode(
                geometry: geometry
            )

            ring.position = SCNVector3(
                0,
                Float(index - count / 2) * 0.16,
                0
            )

            assembly.addChildNode(ring)
        }
    }

    private func createCollector(
        root: SCNNode
    ) {
        let disk = SCNCylinder(
            radius: 9,
            height: 0.18
        )

        disk.firstMaterial = metallicMaterial(
            UIColor(
                white: 0.55,
                alpha: 1
            )
        )

        let collector = SCNNode(
            geometry: disk
        )

        collector.position = SCNVector3(
            0,
            0.5,
            0
        )

        root.addChildNode(collector)

        let visibleSpokeCount = min(
            max(
                radialSpokeCount,
                4
            ),
            48
        )

        for index in 0..<visibleSpokeCount {
            let angle =
                Float(index) /
                Float(visibleSpokeCount) *
                Float.pi *
                2.0

            let end = SCNVector3(
                cos(angle) * 8.0,
                0.67,
                sin(angle) * 8.0
            )

            let spoke = lineNode(
                points: [
                    end,
                    SCNVector3(
                        0,
                        0.67,
                        0
                    )
                ],
                radius: 0.045,
                color: UIColor.systemCyan
            )

            root.addChildNode(spoke)
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

        root.addChildNode(
            lineNode(
                points: points,
                radius: 0.14,
                color: UIColor.systemYellow
            )
        )
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
            "PRIMARY DIPOLE",
            position: SCNVector3(
                -6,
                8.5,
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

    // MARK: - Scene Helpers

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

        geometry.firstMaterial = emissiveMaterial(
            UIColor.white
        )

        let node = SCNNode(
            geometry: geometry
        )

        node.position = position

        let bounds = geometry.boundingBox

        node.pivot = SCNMatrix4MakeTranslation(
            (
                bounds.max.x -
                bounds.min.x
            ) / 2.0,
            0,
            0
        )

        root.addChildNode(node)
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
            container.addChildNode(
                cylinderBetween(
                    start: points[index],
                    end: points[index + 1],
                    radius: radius,
                    color: color
                )
            )
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

// MARK: - SceneKit Math

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

// MARK: - SceneKit Orientation

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

