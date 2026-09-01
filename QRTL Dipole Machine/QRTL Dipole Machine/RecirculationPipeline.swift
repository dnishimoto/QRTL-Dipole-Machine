import Foundation
import SwiftUI
import Combine

final class RecirculationPipeline: ObservableObject {

    // MARK: - Inputs

    @Published var machineRunning: Bool = true

    @Published var dipoleCurrentAmps: Double =
        PhysicsConstants.dipoleCurrentAmps

    @Published var coilResistanceOhms: Double =
        PhysicsConstants.coilResistanceOhms

    @Published var powerElectronicsEfficiency: Double =
        PhysicsConstants.powerElectronicsEfficiency

    @Published var receiverTurns: Double =
        PhysicsConstants.receiverTurns

    @Published var receiverResistanceOhms: Double =
        PhysicsConstants.receiverResistanceOhms

    @Published var resonantDriveEnabled: Bool = true

    @Published var resonatorQualityFactor: Double =
        PhysicsConstants.resonatorQualityFactor

    @Published var fluxUtilization: Double =
        PhysicsConstants.fluxUtilization

    @Published var qrtlHypothesisCoupling: Double =
        PhysicsConstants.qrtlHypothesisCoupling

    var magneticFieldAtIonosphereTesla: Double {
        guard machineRunning else {
            return 0.0
        }

        let distance = PhysicsConstants.couplingDistanceMeters

        guard distance > 0.0 else {
            return 0.0
        }

        return PhysicsConstants.axialDipoleFieldTesla(
            distanceMeters: distance
        )
    }
    // MARK: - Basic Dipole Properties

    /// Magnetic moment of the primary dipole.
    var magneticMoment: Double {
        PhysicsConstants.dipoleTurns
        * dipoleCurrentAmps
        * PhysicsConstants.dipoleCoilAreaSquareMeters
    }

    /// Compatibility name used by ContentView.
    var dipoleMoment: Double {
        magneticMoment
    }


    // MARK: - Geometry

    /// Distance from the machine to the modeled
    /// coupling region.
    var apexRadius: Double {
        PhysicsConstants.couplingDistanceMeters
    }

    /// Modeled altitude of the ionospheric
    /// coupling region above the machine.
    var ionosphereAltitude: Double {
        PhysicsConstants.ionosphereAltitude
    }


    // MARK: - Magnetic Field

    /// Ideal axial dipole field at the apex/coupling distance.
    ///
    /// B = μ₀ / (4π) × 2m / r³
    var apexFieldMagnitude: Double {

        guard machineRunning else {
            return 0
        }

        let r = apexRadius

        guard r > 0 else {
            return 0
        }

        let mu0 =
            PhysicsConstants.vacuumPermeability

        return
            (mu0 / (4.0 * Double.pi))
            *
            (
                2.0
                * magneticMoment
                / pow(r, 3.0)
            )
    }


    /// Magnetic field at the modeled ionosphere.
    var ionosphereFieldMagnitude: Double {

        guard machineRunning else {
            return 0
        }

        let r = ionosphereAltitude

        guard r > 0 else {
            return 0
        }

        let mu0 =
            PhysicsConstants.vacuumPermeability

        return
            (mu0 / (4.0 * Double.pi))
            *
            (
                2.0
                * magneticMoment
                / pow(r, 3.0)
            )
    }


    // MARK: - Mirror Ratio

    /// Ratio between the modeled ionospheric field
    /// and apex field.
    var mirrorRatio: Double {

        guard apexFieldMagnitude > 0 else {
            return 0
        }

        return
            ionosphereFieldMagnitude
            / apexFieldMagnitude
    }


    // MARK: - Magnetic Flux

    /// Area used for the modeled coupling calculation.
    var couplingAreaSquareMeters: Double {

        PhysicsConstants.dipoleCoilAreaSquareMeters
    }


    /// Clamp flux utilization to a physically meaningful
    /// fractional range.
    var effectiveFluxUtilization: Double {

        max(
            0.0,
            min(
                1.0,
                fluxUtilization
            )
        )
    }


    /// Magnetic flux through the modeled coupling region.
    var magneticFluxWebers: Double {

        ionosphereFieldMagnitude
        * couplingAreaSquareMeters
        * effectiveFluxUtilization
    }


    // MARK: - Changing Magnetic Flux

    /// Frequency of the modeled magnetic-field oscillation.
    var frequencyHz: Double {

        PhysicsConstants.resonatorFrequencyHz
    }


    /// Angular frequency.
    var angularFrequency: Double {

        2.0
        * Double.pi
        * frequencyHz
    }


    /// Peak dΦ/dt for a sinusoidally varying flux.
    var changingFluxWebersPerSecond: Double {

        magneticFluxWebers
        * angularFrequency
    }


    // MARK: - Induced Voltage

    /// Faraday-law induced voltage at the receiver.
    var inducedVoltageVolts: Double {

        guard machineRunning else {
            return 0
        }

        return
            receiverTurns
            * changingFluxWebersPerSecond
    }


    // MARK: - Receiver / Machine Current

    /// Current generated in the receiver circuit.
    var receiverCurrentAmps: Double {

        guard
            machineRunning,
            receiverResistanceOhms > 0
        else {
            return 0
        }

        return
            inducedVoltageVolts
            / receiverResistanceOhms
    }


    // MARK: - Captured Electromagnetic Power

    /// Conventional electromagnetic power captured
    /// by the receiver.
    var conventionalCapturedPowerWatts: Double {

        inducedVoltageVolts
        * receiverCurrentAmps
    }


    var conventionalCapturedPowerMW: Double {

        conventionalCapturedPowerWatts
        / 1_000_000.0
    }


    // MARK: - Collector

    /// Current flowing through the collector.
    var collectorCurrentAmps: Double {

        receiverCurrentAmps
    }


    /// Collector I²R loss.
    var collectorResistanceLossWatts: Double {

        collectorCurrentAmps
        * collectorCurrentAmps
        * receiverResistanceOhms
    }


    var collectorResistanceLossMW: Double {

        collectorResistanceLossWatts
        / 1_000_000.0
    }


    // MARK: - Primary Coil Loss

    /// Resistive loss in the primary dipole winding.
    var copperLossWatts: Double {

        dipoleCurrentAmps
        * dipoleCurrentAmps
        * coilResistanceOhms
    }


    var copperLossMW: Double {

        copperLossWatts
        / 1_000_000.0
    }


    // MARK: - Resonator

    /// Approximate inductance of the primary winding.
    var estimatedInductanceHenries: Double {

        let radius =
            PhysicsConstants.dipoleCoilRadiusMeters

        let turns =
            PhysicsConstants.dipoleTurns

        let wireRadius = 0.01

        guard
            radius > 0,
            wireRadius > 0
        else {
            return 0
        }

        let logarithmicTerm =
            log(
                (8.0 * radius)
                / wireRadius
            )
            - 2.0

        guard logarithmicTerm > 0 else {
            return 0
        }

        return
            PhysicsConstants.vacuumPermeability
            * turns
            * turns
            * radius
            * logarithmicTerm
    }


    /// Estimated magnetic energy stored in the
    /// primary winding.
    var estimatedStoredMagneticEnergyJoules: Double {

        let inductance =
            estimatedInductanceHenries

        return
            0.5
            * inductance
            * dipoleCurrentAmps
            * dipoleCurrentAmps
    }


    /// Power required to maintain the modeled
    /// resonator against its Q-related losses.
    var resonatorMaintenanceLossWatts: Double {

        guard
            machineRunning,
            resonantDriveEnabled,
            resonatorQualityFactor > 0
        else {
            return 0
        }

        return
            angularFrequency
            * estimatedStoredMagneticEnergyJoules
            / resonatorQualityFactor
    }


    var resonatorMaintenanceLossMW: Double {

        resonatorMaintenanceLossWatts
        / 1_000_000.0
    }


    // MARK: - Switching / Core Loss

    var switchingAndCoreLossMW: Double {

        guard machineRunning else {
            return 0
        }

        return
            PhysicsConstants.switchingAndCoreLossMW
    }


    // MARK: - Field System

    /// Total modeled field-system losses.
    var totalFieldLossesMW: Double {

        copperLossMW
        + switchingAndCoreLossMW
        + resonatorMaintenanceLossMW
    }


    /// Electrical input required by the
    /// field-generation system.
    var fieldSystemInputMW: Double {

        guard
            machineRunning,
            powerElectronicsEfficiency > 0
        else {
            return 0
        }

        return
            totalFieldLossesMW
            / powerElectronicsEfficiency
    }


    // MARK: - Field System Input Breakdown

    var fieldGeneratorCopperInputMW: Double {

        copperLossMW
    }


    var fieldGeneratorSwitchingCoreInputMW: Double {

        switchingAndCoreLossMW
    }


    var fieldGeneratorResonatorInputMW: Double {

        resonatorMaintenanceLossMW
    }


    // MARK: - Field-Aligned Current

    /// Modeled field-aligned current.
    ///
    /// This simplified model uses receiver current
    /// as the current entering the modeled coupling path.
    var facCurrent: Double {

        receiverCurrentAmps
    }


    /// Modeled Pedersen / return closure current.
    var closureCurrent: Double {

        receiverCurrentAmps
    }


    // MARK: - Recirculation Consistency

    /// Ratio between closure current and field-aligned current.
    ///
    /// A value of 1.0 means the two modeled currents
    /// are equal.
    var recirculationConsistency: Double {

        guard
            abs(facCurrent) > 1.0e-12
        else {
            return 0
        }

        return
            closureCurrent
            / facCurrent
    }


    // MARK: - QRTL Hypothesis

    /// Additional modeled QRTL contribution.
    ///
    /// This is explicitly a hypothesis/model parameter
    /// and is not conventional electromagnetic power.
    var qrtlHypothesisPowerMW: Double {

        conventionalCapturedPowerMW
        * max(
            0.0,
            qrtlHypothesisCoupling
        )
    }


    // MARK: - Net Conventional Power

    var netConventionalPowerMW: Double {

        conventionalCapturedPowerMW
        - fieldSystemInputMW
        - collectorResistanceLossMW
    }


    // MARK: - Net QRTL Modeled Power

    var netQRTLModeledPowerMW: Double {

        conventionalCapturedPowerMW
        + qrtlHypothesisPowerMW
        - fieldSystemInputMW
        - collectorResistanceLossMW
    }


    // MARK: - Total Electrical Accounting

    var totalMachineInputMW: Double {

        fieldSystemInputMW
    }


    var totalCapturedPowerMW: Double {

        conventionalCapturedPowerMW
    }


    var totalCollectorLossMW: Double {

        collectorResistanceLossMW
    }


    // MARK: - Reset

    func reset() {

        machineRunning = true

        dipoleCurrentAmps =
            PhysicsConstants.dipoleCurrentAmps

        coilResistanceOhms =
            PhysicsConstants.coilResistanceOhms

        powerElectronicsEfficiency =
            PhysicsConstants.powerElectronicsEfficiency

        receiverTurns =
            PhysicsConstants.receiverTurns

        receiverResistanceOhms =
            PhysicsConstants.receiverResistanceOhms

        resonantDriveEnabled = true

        resonatorQualityFactor =
            PhysicsConstants.resonatorQualityFactor

        fluxUtilization =
            PhysicsConstants.fluxUtilization

        qrtlHypothesisCoupling =
            PhysicsConstants.qrtlHypothesisCoupling
    }
}
