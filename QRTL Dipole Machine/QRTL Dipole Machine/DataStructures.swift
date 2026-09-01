import Foundation

enum FieldDriveMode: String, CaseIterable, Identifiable {

    case dcHold
    case pulsed
    case resonantAC

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .dcHold:
            return "DC Hold"

        case .pulsed:
            return "Pulsed"

        case .resonantAC:
            return "Resonant AC"
        }
    }

    var summary: String {
        switch self {
        case .dcHold:
            return "Static field with nonzero flux and zero Faraday-induced voltage."

        case .pulsed:
            return "Intermittent field with average copper heating reduced by duty cycle."

        case .resonantAC:
            return "Alternating field with conventional induction and resonator loss."
        }
    }
}

enum PhysicsConstants {

    // MARK: - Fundamental Constants

    static let vacuumPermeability: Double =
        4.0 * Double.pi * 1.0e-7

    static let speedOfLight: Double =
        299_792_458.0

    // Compatibility alias used by existing ContentView code.
    static let mu0: Double =
        vacuumPermeability


    // MARK: - Earth

    /// Mean Earth radius in meters.
    static let earthRadius: Double =
        6_371_000.0


    // MARK: - Ionospheric / L-Shell Model

    /// Modeled recirculation L-shell.
    ///
    /// This is a simulation parameter.
    static let recirculationLShell: Double =
        6.0

    /// Modeled Pedersen conductance in siemens.
    static let pedersenConductance: Double =
        5.0

    /// Modeled polar-cap potential difference in volts.
    ///
    /// This is a simulation input, not a measured
    /// output of the machine.
    static let polarCapPotentialDrop: Double =
        50_000.0

    /// Modeled separation between magnetic footpoints.
    static let footpointSeparation: Double =
        1_000_000.0


    // MARK: - Ionosphere Geometry

    /// Distance from the dipole machine to the
    /// modeled ionospheric coupling region.
    ///
    /// 100 km = 100,000 meters.
    static let couplingDistanceMeters: Double =
        100_000.0

    /// Compatibility property used by
    /// RecirculationPipeline and ContentView.
    ///
    /// This represents the modeled ionospheric
    /// altitude above the machine in this simplified
    /// geometry.
    static let ionosphereAltitude: Double =
        couplingDistanceMeters


    // MARK: - Dipole Machine

    /// Number of turns in the primary dipole winding.
    static let dipoleTurns: Double =
        2_000.0

    /// Primary coil radius in meters.
    static let dipoleCoilRadiusMeters: Double =
        10.0

    /// Primary coil area in square meters.
    static var dipoleCoilAreaSquareMeters: Double {

        Double.pi
            * dipoleCoilRadiusMeters
            * dipoleCoilRadiusMeters
    }

    /// Nominal primary dipole-coil current.
    static let dipoleCurrentAmps: Double =
        500.0


    // MARK: - Electrical System

    /// Primary coil DC resistance.
    static let coilResistanceOhms: Double =
        0.002

    /// Power-electronics efficiency.
    static let powerElectronicsEfficiency: Double =
        0.94

    /// Switching and core losses in MW.
    static let switchingAndCoreLossMW: Double =
        0.05


    // MARK: - Resonator

    /// Resonant operating frequency.
    static let resonatorFrequencyHz: Double =
        10.0

    /// Modeled resonator quality factor.
    static let resonatorQualityFactor: Double =
        100.0


    // MARK: - QRTL Hypothesis

    /// Modeled QRTL hypothesis coupling.
    ///
    /// This is explicitly a hypothesis/model parameter.
    /// It is NOT an experimentally established efficiency.
    static let qrtlHypothesisCoupling: Double =
        0.10


    // MARK: - Coupling Region

    /// Fraction of generated flux assumed to intersect
    /// the modeled receiver.
    ///
    /// Explicit simulation assumption.
    static let fluxUtilization: Double =
        0.10

    /// Number of receiver turns.
    static let receiverTurns: Double =
        2_000.0

    /// Receiver resistance in ohms.
    static let receiverResistanceOhms: Double =
        0.01


    // MARK: - Derived Dipole Quantities

    /// Magnetic moment:
    ///
    /// m = N × I × A
    static var magneticMomentAmpereMetersSquared: Double {

        dipoleTurns
            * dipoleCurrentAmps
            * dipoleCoilAreaSquareMeters
    }

    /// Compatibility name for pipeline code.
    static var dipoleMoment: Double {

        magneticMomentAmpereMetersSquared
    }


    // MARK: - Dipole Magnetic Field

    /// Ideal axial magnetic-field magnitude
    /// of the modeled magnetic dipole.
    ///
    /// B = μ₀ / (4π) × 2m / r³
    static func axialDipoleFieldTesla(
        distanceMeters: Double
    ) -> Double {

        guard distanceMeters > 0 else {
            return 0
        }

        let m =
            magneticMomentAmpereMetersSquared

        return
            (vacuumPermeability / (4.0 * Double.pi))
            *
            (2.0 * m / pow(distanceMeters, 3.0))
    }


    /// Magnetic field at the modeled ionospheric
    /// coupling distance.
    static var ionosphereFieldTesla: Double {

        axialDipoleFieldTesla(
            distanceMeters: couplingDistanceMeters
        )
    }


    // MARK: - Coil Copper Loss

    /// Primary coil copper loss in megawatts.
    ///
    /// P = I²R
    static var copperLossMW: Double {

        let lossWatts =
            dipoleCurrentAmps
            * dipoleCurrentAmps
            * coilResistanceOhms

        return lossWatts / 1_000_000.0
    }


    // MARK: - Dipole Magnetic Energy

    /// Approximate stored magnetic energy.
    ///
    /// E = 1/2 L I²
    ///
    /// The pipeline supplies the modeled inductance.
    static func magneticEnergyJoules(
        inductanceHenries: Double
    ) -> Double {

        guard inductanceHenries >= 0 else {
            return 0
        }

        return
            0.5
            * inductanceHenries
            * dipoleCurrentAmps
            * dipoleCurrentAmps
    }


    // MARK: - Resonator Loss

    /// Approximate resonator maintenance power.
    ///
    /// P = ωE / Q
    ///
    /// This remains separate from conventional
    /// electromagnetic power captured by the receiver.
    static func resonatorLossWatts(
        storedEnergyJoules: Double
    ) -> Double {

        guard resonatorQualityFactor > 0 else {
            return 0
        }

        let omega =
            2.0
            * Double.pi
            * resonatorFrequencyHz

        return
            omega
            * storedEnergyJoules
            / resonatorQualityFactor
    }
}
