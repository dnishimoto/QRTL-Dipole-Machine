/*
 QRTL Dipole Electromagnetic Machine
 The QRTL Dipole Electromagnetic Machine is a proposed electromagnetic energy-collection system designed to investigate whether a controlled QRTL dipole electromagnetic field can establish a measurable coupling between an electromagnetic environment and a conductive collector. The machine is conceived as a scalable experimental platform, beginning with a tabletop system and potentially progressing toward a much larger terrestrial collector. The purpose of the machine is to establish a controlled electromagnetic field, provide a defined conductive collection area, gather any resulting electrical current, convert that current into usable electrical power, and continuously measure the complete energy balance. The tabletop system would not be expected to reproduce the power of a large terrestrial installation. Instead, it would provide the experimental evidence needed to determine whether the proposed collection mechanism exists and how strongly it couples energy into the collector.
 The fundamental equipment pipeline of the QRTL Dipole Electromagnetic Machine is electrical input, controlled electromagnetic excitation, QRTL dipole field generation, QRTL coupling region, conductive collector, distributed current collection, central collection terminal, power conditioning, electrical load, and independent energy measurement. Each stage has a defined function. Electrical power enters the field-generation equipment, the excitation system establishes the controlled electromagnetic environment, the QRTL dipole configuration defines the proposed field geometry, the conductive collector provides the receiving surface, the distributed conductor network gathers the electrical response, the central terminal concentrates the collected current, the power-conditioning system converts the signal into an appropriate electrical form, the isolated load receives the useful electrical output, and the measurement system determines how much energy entered and left the complete machine.
 A useful analogy for the equipment pipeline is a water-collection and distribution system. Imagine a controlled water source feeding a large basin. A pump supplies the initial energy, a system of channels directs the water, the basin collects water over a broad area, smaller channels gather the water toward a central outlet, and the outlet delivers the water to a location where it can perform useful work. The QRTL Dipole Electromagnetic Machine follows the same conceptual sequence, except electromagnetic energy replaces water. The electrical supply is analogous to the pump, the electromagnetic excitation system establishes the driving flow, the QRTL dipole field represents the controlled flow environment, the conductive bowl acts as the receiving basin, the distributed conductors act as drainage channels, the central collector acts as the outlet, the power-conditioning system prepares the electrical flow for use, and the electrical load is the final destination. Precision measurement equipment functions like flow meters and pressure gauges, determining exactly how much energy enters the system and how much reaches the destination.
 The analogy also emphasizes an important scientific principle. A larger basin does not create more water simply because it has more surface area. Likewise, creating a stronger electromagnetic field does not automatically create additional electrical energy. The field must provide a physical pathway through which energy can be transferred to the collector. The complete pipeline must therefore be measured before any claim of energy gain can be made. The tabletop QRTL Dipole Electromagnetic Machine is designed specifically to establish that measurement.
 The central component of the tabletop machine would be a shallow conductive bowl approximately one-half to one square meter in area. The bowl would represent the small-scale version of the larger proposed terrestrial collector. Its shallow curved geometry would preserve the conceptual relationship between the QRTL dipole field and the receiving surface. The collector could be fabricated from a suitable conductive sheet or mesh mounted on an electrically insulating support. Beneath or integrated into the surface would be a distributed conductor network that provides multiple electrical paths from the outer portions of the collector toward a central collection terminal.
 The distributed conductor network would operate like the drainage channels in the water analogy. Radial conductors could extend from the perimeter toward the center, while circumferential conductors could connect the radial sections. This would produce a distributed electrical collection network resembling the structure of a wheel. The collector surface would represent the receiving region, the radial conductors would gather electrical activity toward the center, and the central terminal would become the principal electrical outlet. The collector could also be divided into independently monitored sections so that the experiment could determine whether the electrical response is uniform across the surface or concentrated in particular areas.
 The conductive collector would be mounted on an electrically insulating mechanical structure. Materials such as acrylic, polycarbonate, fiberglass, or another appropriate insulating material could be used for the support structure. The purpose would be to prevent the collector from unintentionally contacting the table, building, electromagnetic-field generator, or other conductive objects. Maintaining a defined electrical boundary is essential because unintended grounding or leakage could produce currents that appear to originate from the proposed QRTL collection process.
 The electromagnetic-field generation system would surround or be positioned around the collector according to a defined experimental geometry. For the initial tabletop machine, the field generator should be a low-power, current-limited electromagnetic excitation system rather than a high-voltage Tesla-coil arrangement. Its purpose would be to establish a reproducible electromagnetic field whose strength, frequency, orientation, waveform, and duration can be controlled. The field-generation system would be treated as the known energy source for the experiment, and its electrical consumption would be measured independently.
 A practical signal-generation stage could use a Keysight 33500B Series function generator or a comparable Siglent SDG Series generator. The function generator would provide controlled waveform generation and allow frequency and amplitude to be varied systematically. A suitable laboratory amplifier would then drive the field applicator. The amplifier would be selected according to the experimentally chosen frequency range, required current, voltage, and field strength rather than being selected solely on its nominal power rating.
 The field-generation system would include a precision input-power measurement instrument. A Yokogawa WT310E or comparable laboratory power analyzer could be used to measure the real electrical power entering the field-generation system. This measurement is fundamental to the machine because it establishes the known electrical energy being supplied to the electromagnetic field. Apparent power and reactive power would not be treated as equivalent to useful energy input. The experiment would use real power and integrated energy as the primary accounting quantities.
 An oscilloscope would provide another important measurement function. A Tektronix 4 Series MSO or comparable Keysight InfiniiVision oscilloscope could monitor the excitation waveform and collector waveform. The oscilloscope could be used to observe frequency, amplitude, phase relationships, transients, induced signals, and possible electromagnetic interference. Appropriate differential or isolated measurement methods would be selected according to the voltage and frequency involved.
 The collector output would have its own independent voltage and current measurement system. A Keysight DAQ970A data-acquisition system or National Instruments CompactDAQ system could record collector voltage, collector current, field-generator parameters, environmental measurements, and other experimental variables. A precision shunt resistor or an appropriately rated isolated current transducer could be used for collector-current measurement. A differential or isolated voltage measurement system would measure collector voltage without creating an unintended connection between the collector and field-generation system.
 If the collector produces an alternating signal that is unsuitable for the selected load, the signal could pass through an appropriate rectification and filtering stage. The conditioned output would then be delivered to an isolated electrical load. A programmable electronic load from manufacturers such as BK Precision or ITECH could provide a controlled destination for the collected electrical energy. For very low-power experiments, a precision resistor load could provide an even simpler initial measurement arrangement.
 The electronic load would function like the destination in the water analogy. It would provide a defined place for the collected electrical energy to go. Instead of allowing an open-circuit voltage to be interpreted as power production, the load would force the collector to deliver measurable current. This allows the experiment to determine the actual power available from the collector rather than merely measuring electrical potential.
 The QRTL Dipole Electromagnetic Machine would also include independent electromagnetic sensors around the collector. A calibrated three-axis magnetometer or fluxgate magnetometer could measure the local magnetic environment, while an appropriate electric-field probe could monitor changes in the local electric field. These sensors would establish the relationship between the deliberately generated electromagnetic field and the collector response. Their measurements could also help determine whether an apparent collector signal is simply conventional electromagnetic induction.
 Environmental sensors could measure temperature and humidity and record other relevant environmental conditions. Surface conductivity, leakage current, electrostatic effects, and instrumentation behavior can be influenced by environmental conditions. Recording these variables allows changes in collector output to be compared with environmental changes and provides additional controls for the experiment.
 The complete machine would be divided into an electromagnetic-field section and an independent collection and measurement section. The field-generation system would create the controlled electromagnetic environment while the collector would remain electrically separated from the field generator. Where appropriate, electrical isolation and isolated data acquisition would prevent the measurement system from accidentally becoming an energy-transfer pathway. The objective would be to establish a clear boundary between energy deliberately supplied to the experiment and energy measured at the collector.
 The first experimental stage would be a baseline measurement with the electromagnetic field turned off. The conductive collector would remain connected to the measurement system and isolated load. Natural voltage, current, electrical noise, environmental variation, and background electromagnetic conditions would be recorded. This would establish the natural behavior of the apparatus before deliberate excitation.
 The second stage would operate the electromagnetic-field generator while the collector remained disconnected from the useful load. This would characterize ordinary electromagnetic coupling. Induced voltage, capacitive coupling, radio-frequency pickup, cable coupling, and other conventional electromagnetic effects would be measured. The resulting data would establish the electromagnetic background created by the field generator.
 The third stage would connect the conductive collector to the measurement system and isolated load while the electromagnetic field generator operates. Field strength, frequency, orientation, and waveform would be changed systematically. Collector voltage and current would be recorded simultaneously. The resulting real electrical power would then be compared with the baseline and with the electromagnetic measurements.
 The fourth stage would use a control collector. A nonconductive structure having approximately the same physical geometry could replace the conductive collector. If a similar signal appeared with the nonconductive structure, the observed effect could originate from electromagnetic pickup, instrumentation, cables, or another conventional mechanism rather than from electrical collection by the conductive surface.
 The experiment could automatically alternate between field-on and field-off conditions. The sequence could be randomized so that slow environmental changes would be less likely to be mistaken for a field-related effect. Repeating the measurements many times would allow statistical analysis and would make the result less dependent on a single observation.
 The initial field input should remain low. A starting point around one watt or less would allow the measurement architecture to be characterized before progressively increasing the electromagnetic field. If the system demonstrates a stable and reproducible response, subsequent experiments could investigate higher input levels such as five watts, ten watts, twenty-five watts, and beyond, subject to the ratings of the equipment. The purpose of increasing the input would be to establish the relationship between known electromagnetic input and measured collector output.
 The central quantity would be the experimentally determined coupling between the electromagnetic field and the collector. If the collector produces less real electrical power than the field-generation system consumes, the machine demonstrates ordinary energy transfer with losses. If the collector appears to produce more energy than the measured input, the result would require extensive investigation. Conventional explanations would first need to be eliminated, including electromagnetic induction, capacitive coupling, RF rectification, grounding currents, leakage paths, stored energy, instrument errors, calibration errors, and other forms of unintended energy transfer.
 The complete energy balance would include the field generator, signal generator, amplifier, control electronics, sensors, data-acquisition equipment, power-conditioning electronics, and other significant loads. The machine's useful output would be the real electrical energy delivered to the external load. Net energy would be determined only after the complete input and output energy flows have been independently measured.
 The proposed larger terrestrial QRTL Dipole Electromagnetic Machine would use the same fundamental pipeline at much greater physical scale. A ten-acre collector would encompass approximately forty thousand square meters of surface area. The tabletop machine would represent only a small fraction of this area. However, the output of the large collector cannot be assumed to scale directly with area. Electromagnetic field distribution, collector resistance, environmental conductivity, field frequency, geometry, coupling efficiency, losses, and the physical mechanism responsible for the proposed effect would determine the actual scaling behavior.
 The tabletop experiment would therefore provide the experimental parameter needed for future scaling: the measured coupling relationship between field input, collector geometry, and real electrical output. Instead of assuming that a certain electromagnetic field produces a particular power gain, the experiment would determine that relationship from measurements. The resulting data could then be used to evaluate whether increasing collector area provides a meaningful increase in useful electrical output.
 The analogy to a water pipeline remains useful when considering the larger machine. The tabletop collector is a small receiving basin, while the ten-acre collector would be a vastly larger basin. The distributed conductor network becomes an extensive drainage system, and the central collection terminal becomes the main outlet. However, just as a large basin cannot collect water that never reaches it, a large conductive surface cannot collect electromagnetic energy that is not physically coupled to it. The larger system therefore depends on the existence and strength of the underlying coupling mechanism.
 The QRTL Dipole Electromagnetic Machine is consequently best understood as an experimental energy-coupling platform rather than an assumed energy-generating device. Its purpose is to establish whether the proposed QRTL dipole configuration produces a measurable electrical response and to determine the magnitude of that response. The tabletop version provides a controlled environment in which the fundamental mechanism can be tested before attempting large-scale construction.
 The equipment pipeline can be summarized in physical terms as follows: laboratory electrical power enters the signal-generation system, the signal generator controls the excitation waveform, the amplifier provides the required driving power, the field applicator establishes the QRTL dipole electromagnetic field, the proposed coupling region interacts with the conductive collector, the collector gathers the resulting electrical response, the distributed conductor network directs that response toward the central terminal, the measurement system determines voltage and current, the power-conditioning system prepares the electrical signal for the load, the isolated load receives the useful output, and the data-acquisition system compares the energy delivered with the energy consumed.
 The most important feature of this pipeline is that every major energy transition can be independently measured. This prevents the machine from relying on assumptions about energy gain. The field-generator input is measured independently, the electromagnetic environment is monitored independently, the collector output is measured independently, and the final load receives a measurable amount of electrical power. This creates an experimental chain in which the energy balance can be examined at every stage.
 The first objective of the QRTL Dipole Electromagnetic Machine should therefore be scientific measurement rather than maximum power. A small, repeatable effect that survives careful controls would be considerably more valuable than a large electrical signal that could be explained by conventional electromagnetic coupling. If the experiment produces a measurable effect, the next stage would be to characterize it, reproduce it, identify its dependence on field parameters, and determine whether conventional electromagnetic theory accounts for it.
 If the effect survives those tests, the measured coupling coefficient could provide the basis for investigating progressively larger collectors. The collector area could be increased, the field geometry could be optimized, and the relationship between electromagnetic input and electrical output could be experimentally determined. Only after these parameters are established would it be reasonable to evaluate the feasibility of a much larger terrestrial QRTL Dipole Electromagnetic Machine.
 The QRTL Dipole Electromagnetic Machine therefore provides a complete experimental pathway from a tabletop apparatus to the proposed large-scale collector. It begins with a known electrical input, establishes a controlled QRTL dipole electromagnetic field, provides a conductive receiving surface, gathers the electrical response through a distributed conductor network, converts that response into a measurable load output, and continuously accounts for the energy entering and leaving the system. The water-pipeline analogy captures the fundamental idea: the source supplies the initial flow, the field system directs the flow, the collector receives it, the conductor network concentrates it, the conversion system makes it useful, and the meters determine exactly how much reaches the destination.
 The ultimate test of the QRTL Dipole Electromagnetic Machine is therefore whether the complete pipeline demonstrates a reproducible transfer of real electrical energy into the isolated collector that cannot be explained by the electrical energy already supplied to the field-generation system or by known electromagnetic coupling mechanisms. A negative result would establish an important experimental limit. A positive and independently reproducible result would provide quantitative evidence for further investigation and a measured foundation for evaluating whether the concept can be scaled beyond the tabletop experimental model.

 */

import SwiftUI
import SceneKit

struct ContentView: View {

    // MARK: - Design Target

    @State private var targetNetOutputMW = 10.0

    // MARK: - Primary Excitation Coil

    @State private var primaryTurns = 2_000.0
    @State private var primaryCurrentA = 250.0
    @State private var primaryRadiusM = 20.0
    @State private var primaryResistanceOhms = 0.005

    // MARK: - Upper Shaping Coil

    @State private var upperShapingEnabled = true
    @State private var upperTurns = 800.0
    @State private var upperCurrentA = 80.0
    @State private var upperRadiusM = 16.0
    @State private var upperResistanceOhms = 0.010
    @State private var upperHeightM = 25.0
    @State private var upperPhaseDegrees = 0.0

    // MARK: - Lower Return Coil

    @State private var lowerReturnEnabled = true
    @State private var lowerTurns = 800.0
    @State private var lowerCurrentA = 80.0
    @State private var lowerRadiusM = 16.0
    @State private var lowerResistanceOhms = 0.010
    @State private var lowerHeightM = -25.0
    @State private var lowerPhaseDegrees = 180.0

    // MARK: - Flux Management

    /*
     This is a bounded design factor representing the local effect
     of pole pieces, a high-permeability core, and flux-return geometry.

     It should be treated as a modeling estimate until supported by
     a detailed magnetic-circuit model or measurement.
    */
    @State private var fluxManagementGain = 1.0

    /*
     Fraction of the local field aligned with the coupling-disk normal.
    */
    @State private var couplingAlignmentFactor = 1.0

    // MARK: - Modulation and Drive

    @State private var fieldFrequencyKHz = 10.0
    @State private var resonantDriveEnabled = true
    @State private var resonatorQualityFactor = 200.0

    @State private var switchingAndCoreLossMW = 0.05
    @State private var coolingPowerMW = 0.05
    @State private var auxiliaryPowerMW = 0.10
    @State private var powerElectronicsEfficiency = 0.94

    // MARK: - Coupling Surface

    /*
     The fast analytic flux model assumes:
     - all coils are coaxial along the vertical Y axis;
     - the coupling surface is a horizontal circular disk;
     - coil locations vary along that same axis.
    */
    @State private var couplingAltitudeKm = 20.0
    @State private var couplingRadiusKm = 1.0

    // MARK: - Receiver and Collector

    @State private var receiverTurns = 5_000.0
    @State private var receiverResistanceOhms = 0.10

    @State private var collectorAreaAcres = 10.0
    @State private var collectorConductivitySPerM = 5.8e7
    @State private var collectorThicknessM = 0.010
    @State private var radialSpokeCount = 32.0
    @State private var radialSpokeWidthM = 0.05

    @State private var collectorInductanceH = 0.001
    @State private var collectorCapacitanceF = 1e-6
    @State private var includeACImpedance = true

    @State private var sourceResistanceOhms = 0.10
    @State private var groundReturnResistanceOhms = 0.10
    @State private var radiationResistanceOhms = 0.001
    @State private var loadResistanceOhms = 100.0

    @State private var contactEfficiency = 0.98
    @State private var conversionEfficiency = 0.95

    // MARK: - Separate QRTL Hypothesis

    /*
     This comparison is deliberately isolated from conventional
     flux, voltage, current, and circuit calculations.
    */
    @State private var qrtlHypothesisEnabled = false
    @State private var qrtlHypothesisCoupling = 0.0

    @State private var isRunning = true

    // MARK: - Constants

    private let vacuumPermeability = 4.0 * Double.pi * 1e-7

    // MARK: - Coil Model

    private struct DipoleCoil: Identifiable {

        let id: String
        let centerY: Double
        let turns: Double
        let currentA: Double
        let radiusM: Double
        let resistanceOhms: Double
        let phaseRadians: Double
        let enabled: Bool

        var areaM2: Double {
            Double.pi *
            radiusM *
            radiusM
        }

        /*
         m = N I A
        */
        var magneticMomentAm2: Double {
            turns *
            currentA *
            areaM2
        }
    }

    private var primaryCoil: DipoleCoil {
        DipoleCoil(
            id: "Primary",
            centerY: 0,
            turns: primaryTurns,
            currentA: primaryCurrentA,
            radiusM: primaryRadiusM,
            resistanceOhms: primaryResistanceOhms,
            phaseRadians: 0,
            enabled: true
        )
    }

    private var upperCoil: DipoleCoil {
        DipoleCoil(
            id: "Upper Shaping",
            centerY: upperHeightM,
            turns: upperTurns,
            currentA: upperCurrentA,
            radiusM: upperRadiusM,
            resistanceOhms: upperResistanceOhms,
            phaseRadians: upperPhaseDegrees *
                Double.pi /
                180.0,
            enabled: upperShapingEnabled
        )
    }

    private var lowerCoil: DipoleCoil {
        DipoleCoil(
            id: "Lower Return",
            centerY: lowerHeightM,
            turns: lowerTurns,
            currentA: lowerCurrentA,
            radiusM: lowerRadiusM,
            resistanceOhms: lowerResistanceOhms,
            phaseRadians: lowerPhaseDegrees *
                Double.pi /
                180.0,
            enabled: lowerReturnEnabled
        )
    }

    private var activeCoils: [DipoleCoil] {
        [
            primaryCoil,
            upperCoil,
            lowerCoil
        ]
        .filter(\.enabled)
    }

    // MARK: - Basic Geometry

    private var frequencyHz: Double {
        fieldFrequencyKHz * 1_000.0
    }

    private var angularFrequency: Double {
        2.0 *
        Double.pi *
        frequencyHz
    }

    private var couplingAltitudeM: Double {
        couplingAltitudeKm * 1_000.0
    }

    private var couplingRadiusM: Double {
        couplingRadiusKm * 1_000.0
    }

    private var couplingSurfaceAreaM2: Double {
        Double.pi *
        couplingRadiusM *
        couplingRadiusM
    }

    private var collectorAreaM2: Double {
        collectorAreaAcres * 4_046.8564224
    }

    private var collectorRadiusM: Double {
        guard collectorAreaM2 > 0 else {
            return 0
        }

        return sqrt(
            collectorAreaM2 /
            Double.pi
        )
    }

    // MARK: - Fast Analytic Flux Model

    /*
     For a vertical magnetic dipole m located on the axis of a
     horizontal circular disk, the total normal flux through the disk is:

     Φ = μ₀ m R² / [2(z² + R²)^(3/2)]

     where:
     - R is disk radius,
     - z is axial distance from coil center to disk center,
     - m is dipole moment.

     This is the analytic surface integral of the dipole B_y field
     over a coaxial circular disk. It avoids expensive radial/angular
     numerical integration in SwiftUI's rendering path.
    */
    private func coilFluxPeakWebers(
        _ coil: DipoleCoil
    ) -> Double {
        let z =
            couplingAltitudeM -
            coil.centerY

        let diskRadius = max(
            couplingRadiusM,
            0.001
        )

        let denominator = pow(
            z * z +
            diskRadius * diskRadius,
            1.5
        )

        guard denominator > 0 else {
            return 0
        }

        return vacuumPermeability *
            coil.magneticMomentAm2 *
            diskRadius *
            diskRadius /
            (
                2.0 *
                denominator
            )
    }

    /*
     Combined flux phasor:

     Φ(t) = A sin(ωt) + B cos(ωt)

     A = Σ Φi cos(φi)
     B = Σ Φi sin(φi)

     Peak amplitude = √(A² + B²)
    */
    private var fluxSinComponentWebers: Double {
        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial +
                coilFluxPeakWebers(coil) *
                cos(coil.phaseRadians)
        } * fluxManagementGain *
            couplingAlignmentFactor
    }

    private var fluxCosComponentWebers: Double {
        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial +
                coilFluxPeakWebers(coil) *
                sin(coil.phaseRadians)
        } * fluxManagementGain *
            couplingAlignmentFactor
    }

    private var peakMagneticFluxWebers: Double {
        guard isRunning,
              frequencyHz > 0
        else {
            return 0
        }

        return hypot(
            fluxSinComponentWebers,
            fluxCosComponentWebers
        )
    }

    private func magneticFluxWebers(
        at timeSeconds: Double
    ) -> Double {
        guard isRunning,
              frequencyHz > 0
        else {
            return 0
        }

        let phase =
            angularFrequency *
            timeSeconds

        return fluxSinComponentWebers *
            sin(phase) +
            fluxCosComponentWebers *
            cos(phase)
    }

    /*
     dΦ/dt is the analytic derivative of the phasor form:

     dΦ/dt =
     ω[A cos(ωt) − B sin(ωt)]
    */
    private func fluxChangeRateWebersPerSecond(
        at timeSeconds: Double
    ) -> Double {
        guard isRunning,
              frequencyHz > 0
        else {
            return 0
        }

        let phase =
            angularFrequency *
            timeSeconds

        return angularFrequency *
            (
                fluxSinComponentWebers *
                cos(phase) -
                fluxCosComponentWebers *
                sin(phase)
            )
    }

    private var peakFluxChangeRateWebersPerSecond: Double {
        angularFrequency *
        peakMagneticFluxWebers
    }

    /*
     On-axis B field for a magnetic dipole:

     B_axis = μ₀m / (2πz³)

     This is shown as a fast diagnostic at the coupling-surface center.
    */
    private func coilAxialFieldTesla(
        _ coil: DipoleCoil
    ) -> Double {
        let z =
            couplingAltitudeM -
            coil.centerY

        let distance = max(
            abs(z),
            0.001
        )

        return vacuumPermeability *
            coil.magneticMomentAm2 /
            (
                2.0 *
                Double.pi *
                distance *
                distance *
                distance
            )
    }

    private var fieldAtCouplingCenterTesla: Double {
        let sinComponent = activeCoils.reduce(0.0) {
            partial,
            coil in

            partial +
                coilAxialFieldTesla(coil) *
                cos(coil.phaseRadians)
        }

        let cosComponent = activeCoils.reduce(0.0) {
            partial,
            coil in

            partial +
                coilAxialFieldTesla(coil) *
                sin(coil.phaseRadians)
        }

        return hypot(
            sinComponent,
            cosComponent
        ) * fluxManagementGain
    }

    // MARK: - Faraday Voltage

    /*
     V_peak = N_receiver × |dΦ/dt|_peak
     V_RMS = V_peak / √2
    */
    private var inducedVoltagePeakV: Double {
        receiverTurns *
        peakFluxChangeRateWebersPerSecond
    }

    private var inducedVoltageRMS: Double {
        inducedVoltagePeakV /
        sqrt(2.0)
    }

    // MARK: - Low-Loss Drive Model

    private func coilCopperLossMW(
        _ coil: DipoleCoil
    ) -> Double {
        guard coil.enabled,
              isRunning
        else {
            return 0
        }

        return coil.currentA *
            coil.currentA *
            coil.resistanceOhms /
            1_000_000.0
    }

    private var primaryCopperLossMW: Double {
        coilCopperLossMW(primaryCoil)
    }

    private var upperCopperLossMW: Double {
        coilCopperLossMW(upperCoil)
    }

    private var lowerCopperLossMW: Double {
        coilCopperLossMW(lowerCoil)
    }

    private var totalCopperLossMW: Double {
        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial +
                coilCopperLossMW(coil)
        }
    }

    /*
     Simplified circular-loop inductance estimate:

     L ≈ μ₀N²r[ln(8r/a) − 2]

     a is an estimated winding-bundle radius.
    */
    private func estimatedCoilInductanceH(
        _ coil: DipoleCoil
    ) -> Double {
        let radius = max(
            coil.radiusM,
            0.01
        )

        let bundleRadius = max(
            radius * 0.02,
            0.001
        )

        let geometricTerm = max(
            log(
                8.0 *
                radius /
                bundleRadius
            ) - 2.0,
            0.1
        )

        return vacuumPermeability *
            coil.turns *
            coil.turns *
            radius *
            geometricTerm
    }

    private func storedMagneticEnergyJ(
        _ coil: DipoleCoil
    ) -> Double {
        0.5 *
        estimatedCoilInductanceH(coil) *
        coil.currentA *
        coil.currentA
    }

    private var totalEstimatedInductanceH: Double {
        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial +
                estimatedCoilInductanceH(coil)
        }
    }

    private var totalStoredMagneticEnergyJ: Double {
        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial +
                storedMagneticEnergyJ(coil)
        }
    }

    private var requiredResonantCapacitanceF: Double {
        guard angularFrequency > 0,
              totalEstimatedInductanceH > 0
        else {
            return .infinity
        }

        return 1.0 /
            (
                angularFrequency *
                angularFrequency *
                totalEstimatedInductanceH
            )
    }

    /*
     Resonant maintenance loss:
     P ≈ ωE / Q

     This is a loss estimate only. Resonance does not supply
     real load energy independently.
    */
    private var resonatorMaintenanceLossMW: Double {
        guard isRunning,
              resonantDriveEnabled,
              resonatorQualityFactor > 0
        else {
            return 0
        }

        return angularFrequency *
            totalStoredMagneticEnergyJ /
            resonatorQualityFactor /
            1_000_000.0
    }
/*
 2,000-turn coil
       ↓
 Coil geometry
       ↓
 Inductance (L)
       ↓
 Required coil current (I)
       ↓
 Stored magnetic energy
       ↓
 Resonator Q
       ↓
 Resonator loss
       ↓
 Coil loss + resonator loss + electronics loss
       ↓
 FIELD SYSTEM INPUT
 */
    private var fieldSystemInputMW: Double {

        guard isRunning,
              powerElectronicsEfficiency > 0
        else {
            print("""
            ===== FIELD SYSTEM INPUT =====
            Machine running: \(isRunning)
            Power electronics efficiency: \(powerElectronicsEfficiency)
            RESULT: 0 MW
            ===============================
            """)
            return 0
        }

        let copper = totalCopperLossMW
        let switchingCore = switchingAndCoreLossMW
        let resonator = resonantDriveEnabled
            ? resonatorMaintenanceLossMW
            : 0.0

        let totalLosses = copper + switchingCore + resonator
        let inputMW = totalLosses / powerElectronicsEfficiency

        print("""
        
        ==========================================
                 FIELD SYSTEM INPUT
        ==========================================
        
        Machine running:
            \(isRunning)
        
        Power electronics efficiency:
            \(powerElectronicsEfficiency)
        
        Coil / Copper Loss:
            \(copper) MW
        
        Switching + Core Loss:
            \(switchingCore) MW
        
        Resonant Drive Enabled:
            \(resonantDriveEnabled)
        
        Resonator Maintenance Loss:
            \(resonator) MW
        
        ------------------------------------------
        TOTAL FIELD LOSSES:
            \(totalLosses) MW
        
        FIELD SYSTEM INPUT:
            \(inputMW) MW
        ==========================================
        
        """)

        return inputMW
    }
    // MARK: - Collector Resistance

    private var collectorSpokeCrossSectionM2: Double {
        collectorThicknessM *
        radialSpokeWidthM
    }

    /*
     R = L / (σAN)
    */
    private var collectorDCResistanceOhms: Double {
        let denominator =
            collectorConductivitySPerM *
            collectorSpokeCrossSectionM2 *
            max(
                radialSpokeCount,
                1.0
            )

        guard denominator > 0 else {
            return .infinity
        }

        return collectorRadiusM /
            denominator
    }

    private var skinDepthM: Double {
        guard frequencyHz > 0,
              collectorConductivitySPerM > 0
        else {
            return .infinity
        }

        return sqrt(
            2.0 /
            (
                angularFrequency *
                vacuumPermeability *
                collectorConductivitySPerM
            )
        )
    }

    private var effectiveCollectorThicknessM: Double {
        guard skinDepthM.isFinite else {
            return collectorThicknessM
        }

        return min(
            collectorThicknessM,
            max(
                2.0 * skinDepthM,
                0.000001
            )
        )
    }

    private var collectorACResistanceOhms: Double {
        let effectiveArea =
            radialSpokeWidthM *
            effectiveCollectorThicknessM

        let denominator =
            collectorConductivitySPerM *
            effectiveArea *
            max(
                radialSpokeCount,
                1.0
            )

        guard denominator > 0 else {
            return .infinity
        }

        return collectorRadiusM /
            denominator
    }

    private var collectorResistanceOhms: Double {
        includeACImpedance
            ? collectorACResistanceOhms
            : collectorDCResistanceOhms
    }

    // MARK: - Receiver and Collector Circuit

    private var collectorInductiveReactanceOhms: Double {
        guard includeACImpedance,
              frequencyHz > 0
        else {
            return 0
        }

        return angularFrequency *
            collectorInductanceH
    }

    private var collectorCapacitiveReactanceOhms: Double {
        guard includeACImpedance,
              frequencyHz > 0,
              collectorCapacitanceF > 0
        else {
            return 0
        }

        return -1.0 /
            (
                angularFrequency *
                collectorCapacitanceF
            )
    }

    private var totalCircuitResistanceOhms: Double {
        receiverResistanceOhms +
        sourceResistanceOhms +
        collectorResistanceOhms +
        groundReturnResistanceOhms +
        radiationResistanceOhms +
        loadResistanceOhms
    }

    private var totalCircuitReactanceOhms: Double {
        collectorInductiveReactanceOhms +
        collectorCapacitiveReactanceOhms
    }

    private var totalCircuitImpedanceMagnitudeOhms: Double {
        hypot(
            totalCircuitResistanceOhms,
            totalCircuitReactanceOhms
        )
    }

    /*
     I_RMS = V_RMS / |Z|
    */
    private var machineCurrentRMSA: Double {
        guard isRunning,
              frequencyHz > 0,
              inducedVoltageRMS > 0,
              totalCircuitImpedanceMagnitudeOhms > 0
        else {
            return 0
        }

        return inducedVoltageRMS /
            totalCircuitImpedanceMagnitudeOhms
    }

    private var collectorCurrentA: Double {
        machineCurrentRMSA
    }

    // MARK: - Conventional Electrical Power

    private var receiverCopperLossMW: Double {
        machineCurrentRMSA *
        machineCurrentRMSA *
        receiverResistanceOhms /
        1_000_000.0
    }

    private var sourceResistanceLossMW: Double {
        machineCurrentRMSA *
        machineCurrentRMSA *
        sourceResistanceOhms /
        1_000_000.0
    }

    private var collectorResistiveLossMW: Double {
        collectorCurrentA *
        collectorCurrentA *
        collectorResistanceOhms /
        1_000_000.0
    }

    private var groundReturnLossMW: Double {
        machineCurrentRMSA *
        machineCurrentRMSA *
        groundReturnResistanceOhms /
        1_000_000.0
    }

    private var radiationLossMW: Double {
        machineCurrentRMSA *
        machineCurrentRMSA *
        radiationResistanceOhms /
        1_000_000.0
    }

    private var conventionalLoadElectricalPowerMW: Double {
        machineCurrentRMSA *
        machineCurrentRMSA *
        loadResistanceOhms /
        1_000_000.0
    }

    private var conventionalCircuitSourcePowerMW: Double {
        machineCurrentRMSA *
        machineCurrentRMSA *
        totalCircuitResistanceOhms /
        1_000_000.0
    }

    private var contactLossMW: Double {
        conventionalLoadElectricalPowerMW *
        (
            1.0 -
            contactEfficiency
        )
    }

    private var powerAfterContactMW: Double {
        max(
            0,
            conventionalLoadElectricalPowerMW -
            contactLossMW
        )
    }

    private var conversionLossMW: Double {
        powerAfterContactMW *
        (
            1.0 -
            conversionEfficiency
        )
    }

    private var conventionalGrossOutputMW: Double {
        powerAfterContactMW *
        conversionEfficiency
    }

    private var conventionalNetOutputMW: Double {
        conventionalGrossOutputMW -
        fieldSystemInputMW -
        coolingPowerMW -
        auxiliaryPowerMW
    }

    // MARK: - Separate QRTL Comparison

    private var qrtlHypothesisIncrementMW: Double {
        guard qrtlHypothesisEnabled else {
            return 0
        }

        return conventionalGrossOutputMW *
            qrtlHypothesisCoupling
    }

    private var qrtlComparisonNetOutputMW: Double {
        conventionalNetOutputMW +
        qrtlHypothesisIncrementMW
    }

    // MARK: - Design Metrics

    private var usefulFluxPerInputWbPerW: Double {
        let inputW =
            fieldSystemInputMW *
            1_000_000.0

        guard inputW > 0 else {
            return 0
        }

        return peakMagneticFluxWebers /
            inputW
    }

    private var totalAmpereTurns: Double {
        activeCoils.reduce(0.0) {
            partial,
            coil in

            partial +
            coil.turns *
            coil.currentA
        }
    }

    private var targetPercent: Double {
        guard targetNetOutputMW > 0 else {
            return 0
        }

        return max(
            0,
            conventionalNetOutputMW /
            targetNetOutputMW *
            100.0
        )
    }

    private var targetStatus: String {
        if !isRunning {
            return "Paused: field, voltage, and current are zero"
        }

        if frequencyHz <= 0 {
            return "Static field: dΦ/dt = 0 and induced voltage = 0"
        }

        if conventionalNetOutputMW >= targetNetOutputMW {
            return "Conventional model reaches the 10 MW target"
        }

        return "Conventional model is below the 10 MW target"
    }

    private var targetStatusColor: Color {
        if !isRunning ||
            frequencyHz <= 0 {
            return .secondary
        }

        return conventionalNetOutputMW >= targetNetOutputMW
            ? .green
            : .red
    }

    private var netOutputColor: Color {
        if conventionalNetOutputMW > 0 {
            return .green
        }

        if conventionalNetOutputMW < 0 {
            return .red
        }

        return .secondary
    }

    // MARK: - Main View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    titleSection
                    sceneSection
                    outputSection
                    //designObjectiveSection
                    multiCoilSection
                    fieldFluxSection
                    voltageSection
                    resonanceSection
                    circuitSection
                    collectorSection
                    lossesSection
                    //qrtlSection
                    controlsSection
                    equationSection
                    limitationSection
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - UI Sections

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text("QRTL Dipole")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Low-Loss Multi-Coil Flux Model")
                .font(.title3)
                .fontWeight(.semibold)

            Text(
                "Excitation → 3D Multi-Coil Field → Flux → "
                + "Faraday Voltage → Circuit → Collector → Net Output"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
    }

    private var sceneSection: some View {
        ZStack(alignment: .topLeading) {
            QRTLSceneView(
                running: isRunning,
                primaryTurns: primaryTurns,
                primaryCurrentA: primaryCurrentA,
                primaryRadiusM: primaryRadiusM,
                upperEnabled: upperShapingEnabled,
                upperTurns: upperTurns,
                upperCurrentA: upperCurrentA,
                upperRadiusM: upperRadiusM,
                upperHeightM: upperHeightM,
                upperPhaseDegrees: upperPhaseDegrees,
                lowerEnabled: lowerReturnEnabled,
                lowerTurns: lowerTurns,
                lowerCurrentA: lowerCurrentA,
                lowerRadiusM: lowerRadiusM,
                lowerHeightM: lowerHeightM,
                lowerPhaseDegrees: lowerPhaseDegrees,
                fieldFrequencyKHz: fieldFrequencyKHz,
                couplingAltitudeKm: couplingAltitudeKm,
                couplingRadiusKm: couplingRadiusKm,
                radialSpokeCount: Int(radialSpokeCount),
                fluxManagementGain: fluxManagementGain
            )
            .frame(height: 520)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )

            VStack(alignment: .leading, spacing: 5) {
                Text("3D MULTI-COIL MODEL")
                    .font(.caption)
                    .fontWeight(.bold)

                Text("LOW-LOSS EXCITATION")
                Text("↓")
                Text("PRIMARY + SHAPING COILS")
                Text("↓")
                Text("COMBINED DIPOLE FIELD")
                Text("↓")
                Text("COUPLING FLUX Φ")
                Text("↓")
                Text("FARADAY EMF")
                Text("↓")
                Text("COLLECTOR / LOAD")
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
            Text("CONVENTIONAL OUTPUT")
                .font(.headline)

            HStack {
                OutputValue(
                    title: "Load",
                    valueMW: conventionalLoadElectricalPowerMW
                )

                OutputValue(
                    title: "Gross",
                    valueMW: conventionalGrossOutputMW
                )

                OutputValue(
                    title: "Net",
                    valueMW: conventionalNetOutputMW
                )
            }

            ProgressView(
                value: min(
                    max(
                        targetPercent / 100.0,
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
                    targetNetOutputMW
                )
            )
            .font(.caption)
            .foregroundStyle(netOutputColor)

            Text(targetStatus)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(targetStatusColor)
                .multilineTextAlignment(.center)

            MetricRow(
                name: "Circuit current",
                value: String(
                    format: "%.6f A RMS",
                    machineCurrentRMSA
                )
            )
        }
        .panelStyle()
    }

    private var designObjectiveSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Flux-Focused Objective")
                .font(.headline)

            MetricRow(
                name: "Peak useful flux",
                value: String(
                    format: "%.3e Wb",
                    peakMagneticFluxWebers
                )
            )

            MetricRow(
                name: "Field-system input",
                value: PowerFormatter.string(
                    megawatts: fieldSystemInputMW
                )
            )

            MetricRow(
                name: "Useful flux per field-input watt",
                value: String(
                    format: "%.3e Wb/W",
                    usefulFluxPerInputWbPerW
                )
            )

            MetricRow(
                name: "Active ampere-turns",
                value: String(
                    format: "%.3e A-turns",
                    totalAmpereTurns
                )
            )

            Text(
                "Increase flux through the selected coupling disk per watt "
                + "of field-system input. This is a better design objective "
                + "than merely increasing one coil current."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }

    private var multiCoilSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Multi-Coil Excitation")
                .font(.headline)

            CoilMetricRow(
                name: "Primary excitation",
                turns: primaryTurns,
                currentA: primaryCurrentA,
                radiusM: primaryRadiusM,
                resistanceOhms: primaryResistanceOhms,
                lossMW: primaryCopperLossMW,
                active: true
            )

            CoilMetricRow(
                name: "Upper shaping",
                turns: upperTurns,
                currentA: upperCurrentA,
                radiusM: upperRadiusM,
                resistanceOhms: upperResistanceOhms,
                lossMW: upperCopperLossMW,
                active: upperShapingEnabled
            )

            CoilMetricRow(
                name: "Lower return",
                turns: lowerTurns,
                currentA: lowerCurrentA,
                radiusM: lowerRadiusM,
                resistanceOhms: lowerResistanceOhms,
                lossMW: lowerCopperLossMW,
                active: lowerReturnEnabled
            )

            MetricRow(
                name: "Total copper loss",
                value: PowerFormatter.string(
                    megawatts: totalCopperLossMW
                )
            )

            MetricRow(
                name: "Flux-management gain",
                value: String(
                    format: "%.3f",
                    fluxManagementGain
                )
            )

            MetricRow(
                name: "Coupling alignment",
                value: String(
                    format: "%.3f",
                    couplingAlignmentFactor
                )
            )
        }
        .panelStyle()
    }

    private var fieldFluxSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Field and Coupling Flux")
                .font(.headline)

            MetricRow(
                name: "Coupling altitude",
                value: String(
                    format: "%.3f km",
                    couplingAltitudeKm
                )
            )

            MetricRow(
                name: "Coupling radius",
                value: String(
                    format: "%.3f km",
                    couplingRadiusKm
                )
            )

            MetricRow(
                name: "Coupling disk area",
                value: String(
                    format: "%.3e m²",
                    couplingSurfaceAreaM2
                )
            )

            MetricRow(
                name: "Field at disk center",
                value: String(
                    format: "%.3e T",
                    fieldAtCouplingCenterTesla
                )
            )

            MetricRow(
                name: "Peak integrated flux",
                value: String(
                    format: "%.3e Wb",
                    peakMagneticFluxWebers
                )
            )

            MetricRow(
                name: "Peak dΦ/dt",
                value: String(
                    format: "%.3e Wb/s",
                    peakFluxChangeRateWebersPerSecond
                )
            )

            Text(
                "For the current coaxial coil/disk layout, flux uses the "
                + "analytic axial magnetic-dipole-to-circular-disk integral. "
                + "This is fast enough for interactive SwiftUI updates."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }

    private var voltageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Faraday Receiver Voltage")
                .font(.headline)

            MetricRow(
                name: "Modulation frequency",
                value: String(
                    format: "%.3f kHz",
                    fieldFrequencyKHz
                )
            )

            MetricRow(
                name: "Receiver turns",
                value: String(
                    format: "%.0f",
                    receiverTurns
                )
            )

            MetricRow(
                name: "Peak dΦ/dt",
                value: String(
                    format: "%.3e Wb/s",
                    peakFluxChangeRateWebersPerSecond
                )
            )

            MetricRow(
                name: "Peak induced EMF",
                value: String(
                    format: "%.3e V",
                    inducedVoltagePeakV
                )
            )

            MetricRow(
                name: "RMS source voltage",
                value: String(
                    format: "%.3e V RMS",
                    inducedVoltageRMS
                )
            )
        }
        .panelStyle()
    }

    private var resonanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Resonant Low-Loss Drive")
                .font(.headline)

            MetricRow(
                name: "Resonant drive",
                value: resonantDriveEnabled
                    ? "Enabled"
                    : "Disabled"
            )

            MetricRow(
                name: "Estimated coil inductance",
                value: String(
                    format: "%.3e H",
                    totalEstimatedInductanceH
                )
            )

            MetricRow(
                name: "Required resonance capacitance",
                value: requiredResonantCapacitanceF.isFinite
                    ? String(
                        format: "%.3e F",
                        requiredResonantCapacitanceF
                    )
                    : "Undefined at DC"
            )

            MetricRow(
                name: "Stored magnetic energy",
                value: String(
                    format: "%.3e J",
                    totalStoredMagneticEnergyJ
                )
            )

            MetricRow(
                name: "Resonator Q",
                value: String(
                    format: "%.1f",
                    resonatorQualityFactor
                )
            )

            MetricRow(
                name: "Resonator maintenance loss",
                value: PowerFormatter.string(
                    megawatts: resonatorMaintenanceLossMW
                )
            )

            Text(
                "Resonance reduces reactive drive demand by circulating "
                + "stored energy between inductance and capacitance. "
                + "It does not provide real load energy for free."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }

    private var circuitSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Receiver / Collector Circuit")
                .font(.headline)

            MetricRow(
                name: "Source voltage",
                value: String(
                    format: "%.3e V RMS",
                    inducedVoltageRMS
                )
            )

            MetricRow(
                name: "Receiver resistance",
                value: String(
                    format: "%.6f Ω",
                    receiverResistanceOhms
                )
            )

            MetricRow(
                name: "Collector resistance",
                value: String(
                    format: "%.6f Ω",
                    collectorResistanceOhms
                )
            )

            MetricRow(
                name: "Inductive reactance",
                value: String(
                    format: "%.6f Ω",
                    collectorInductiveReactanceOhms
                )
            )

            MetricRow(
                name: "Capacitive reactance",
                value: String(
                    format: "%.6f Ω",
                    collectorCapacitiveReactanceOhms
                )
            )

            MetricRow(
                name: "Total resistance",
                value: String(
                    format: "%.6f Ω",
                    totalCircuitResistanceOhms
                )
            )

            MetricRow(
                name: "Total reactance",
                value: String(
                    format: "%.6f Ω",
                    totalCircuitReactanceOhms
                )
            )

            MetricRow(
                name: "Total impedance |Z|",
                value: String(
                    format: "%.6f Ω",
                    totalCircuitImpedanceMagnitudeOhms
                )
            )

            MetricRow(
                name: "Circuit current",
                value: String(
                    format: "%.6f A RMS",
                    machineCurrentRMSA
                )
            )
        }
        .panelStyle()
    }

    private var collectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Radial Collector")
                .font(.headline)

            MetricRow(
                name: "Collector current",
                value: String(
                    format: "%.6f A RMS",
                    collectorCurrentA
                )
            )

            MetricRow(
                name: "Collector footprint",
                value: String(
                    format: "%.3f acres",
                    collectorAreaAcres
                )
            )

            MetricRow(
                name: "Equivalent collector radius",
                value: String(
                    format: "%.3f m",
                    collectorRadiusM
                )
            )

            MetricRow(
                name: "Spoke count",
                value: String(
                    format: "%.0f",
                    radialSpokeCount
                )
            )

            MetricRow(
                name: "DC resistance",
                value: String(
                    format: "%.6f Ω",
                    collectorDCResistanceOhms
                )
            )

            MetricRow(
                name: "AC resistance",
                value: String(
                    format: "%.6f Ω",
                    collectorACResistanceOhms
                )
            )

            MetricRow(
                name: "Skin depth",
                value: skinDepthM.isFinite
                    ? String(
                        format: "%.3e m",
                        skinDepthM
                    )
                    : "Not applicable"
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

    private var lossesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Energy Accounting")
                .font(.headline)

            MetricRow(
                name: "Circuit-source power",
                value: PowerFormatter.string(
                    megawatts: conventionalCircuitSourcePowerMW
                )
            )

            MetricRow(
                name: "Load electrical power",
                value: PowerFormatter.string(
                    megawatts: conventionalLoadElectricalPowerMW
                )
            )

            MetricRow(
                name: "− Receiver I²R loss",
                value: PowerFormatter.string(
                    megawatts: receiverCopperLossMW
                )
            )

            MetricRow(
                name: "− Source resistance loss",
                value: PowerFormatter.string(
                    megawatts: sourceResistanceLossMW
                )
            )

            MetricRow(
                name: "− Collector I²R loss",
                value: PowerFormatter.string(
                    megawatts: collectorResistiveLossMW
                )
            )

            MetricRow(
                name: "− Ground return loss",
                value: PowerFormatter.string(
                    megawatts: groundReturnLossMW
                )
            )

            MetricRow(
                name: "− Radiation estimate",
                value: PowerFormatter.string(
                    megawatts: radiationLossMW
                )
            )

            MetricRow(
                name: "− Contact loss",
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
                name: "Gross usable output",
                value: PowerFormatter.string(
                    megawatts: conventionalGrossOutputMW
                )
            )

            MetricRow(
                name: "− Field-system input",
                value: PowerFormatter.string(
                    megawatts: fieldSystemInputMW
                )
            )

            MetricRow(
                name: "− Cooling",
                value: PowerFormatter.string(
                    megawatts: coolingPowerMW
                )
            )

            MetricRow(
                name: "− Auxiliary systems",
                value: PowerFormatter.string(
                    megawatts: auxiliaryPowerMW
                )
            )

            Divider()

            MetricRow(
                name: "Net output",
                value: PowerFormatter.string(
                    megawatts: conventionalNetOutputMW
                )
            )
        }
        .panelStyle()
    }

    private var qrtlSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("QRTL Hypothesis Comparison")
                .font(.headline)

            Toggle(
                "Enable QRTL comparison",
                isOn: $qrtlHypothesisEnabled
            )

            MetricRow(
                name: "QRTL hypothesis coefficient",
                value: String(
                    format: "%.4f",
                    qrtlHypothesisCoupling
                )
            )

            MetricRow(
                name: "Conventional gross output",
                value: PowerFormatter.string(
                    megawatts: conventionalGrossOutputMW
                )
            )

            MetricRow(
                name: "Hypothetical QRTL increment",
                value: PowerFormatter.string(
                    megawatts: qrtlHypothesisIncrementMW
                )
            )

            MetricRow(
                name: "Comparison net output",
                value: PowerFormatter.string(
                    megawatts: qrtlComparisonNetOutputMW
                )
            )

            Text(
                "QRTL is isolated from conventional field, flux, voltage, "
                + "current, and circuit calculations in this model."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .panelStyle()
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Low-Loss Design Controls")
                .font(.headline)

            Text("Target")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Net output target",
                value: $targetNetOutputMW,
                range: 0.1...100.0,
                step: 0.1,
                unit: " MW"
            )

            Text("Primary coil")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Primary turns",
                value: $primaryTurns,
                range: 1.0...100_000.0,
                step: 1.0,
                unit: ""
            )

            ParameterSlider(
                title: "Primary current",
                value: $primaryCurrentA,
                range: 0.0...100_000.0,
                step: 1.0,
                unit: " A"
            )

            ParameterSlider(
                title: "Primary radius",
                value: $primaryRadiusM,
                range: 0.1...1_000.0,
                step: 0.1,
                unit: " m"
            )

            ParameterSlider(
                title: "Primary resistance",
                value: $primaryResistanceOhms,
                range: 0.000001...10.0,
                step: 0.000001,
                unit: " Ω"
            )

            Text("Upper shaping coil")
                .font(.subheadline)
                .fontWeight(.semibold)

            Toggle(
                "Enable upper shaping coil",
                isOn: $upperShapingEnabled
            )

            ParameterSlider(
                title: "Upper turns",
                value: $upperTurns,
                range: 1.0...100_000.0,
                step: 1.0,
                unit: ""
            )

            ParameterSlider(
                title: "Upper current",
                value: $upperCurrentA,
                range: 0.0...100_000.0,
                step: 1.0,
                unit: " A"
            )

            ParameterSlider(
                title: "Upper radius",
                value: $upperRadiusM,
                range: 0.1...1_000.0,
                step: 0.1,
                unit: " m"
            )

            ParameterSlider(
                title: "Upper resistance",
                value: $upperResistanceOhms,
                range: 0.000001...10.0,
                step: 0.000001,
                unit: " Ω"
            )

            ParameterSlider(
                title: "Upper height",
                value: $upperHeightM,
                range: -1_000.0...1_000.0,
                step: 0.1,
                unit: " m"
            )

            ParameterSlider(
                title: "Upper phase",
                value: $upperPhaseDegrees,
                range: -180.0...180.0,
                step: 1.0,
                unit: "°"
            )

            Text("Lower return coil")
                .font(.subheadline)
                .fontWeight(.semibold)

            Toggle(
                "Enable lower return coil",
                isOn: $lowerReturnEnabled
            )

            ParameterSlider(
                title: "Lower turns",
                value: $lowerTurns,
                range: 1.0...100_000.0,
                step: 1.0,
                unit: ""
            )

            ParameterSlider(
                title: "Lower current",
                value: $lowerCurrentA,
                range: 0.0...100_000.0,
                step: 1.0,
                unit: " A"
            )

            ParameterSlider(
                title: "Lower radius",
                value: $lowerRadiusM,
                range: 0.1...1_000.0,
                step: 0.1,
                unit: " m"
            )

            ParameterSlider(
                title: "Lower resistance",
                value: $lowerResistanceOhms,
                range: 0.000001...10.0,
                step: 0.000001,
                unit: " Ω"
            )

            ParameterSlider(
                title: "Lower height",
                value: $lowerHeightM,
                range: -1_000.0...1_000.0,
                step: 0.1,
                unit: " m"
            )

            ParameterSlider(
                title: "Lower phase",
                value: $lowerPhaseDegrees,
                range: -180.0...180.0,
                step: 1.0,
                unit: "°"
            )

            Text("Flux and resonant drive")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Flux-management gain",
                value: $fluxManagementGain,
                range: 0.1...10.0,
                step: 0.01,
                unit: ""
            )

            ParameterSlider(
                title: "Coupling alignment",
                value: $couplingAlignmentFactor,
                range: 0.0...1.0,
                step: 0.01,
                unit: ""
            )

            ParameterSlider(
                title: "Modulation frequency",
                value: $fieldFrequencyKHz,
                range: 0.0...100.0,
                step: 0.1,
                unit: " kHz"
            )

            Toggle(
                "Use resonant drive estimate",
                isOn: $resonantDriveEnabled
            )

            ParameterSlider(
                title: "Resonator Q",
                value: $resonatorQualityFactor,
                range: 1.0...10_000.0,
                step: 1.0,
                unit: ""
            )

            ParameterSlider(
                title: "Switching/core loss",
                value: $switchingAndCoreLossMW,
                range: 0.0...10.0,
                step: 0.001,
                unit: " MW"
            )

            ParameterSlider(
                title: "Cooling power",
                value: $coolingPowerMW,
                range: 0.0...10.0,
                step: 0.001,
                unit: " MW"
            )

            ParameterSlider(
                title: "Auxiliary power",
                value: $auxiliaryPowerMW,
                range: 0.0...10.0,
                step: 0.001,
                unit: " MW"
            )

            ParameterSlider(
                title: "Electronics efficiency",
                value: $powerElectronicsEfficiency,
                range: 0.1...1.0,
                step: 0.01,
                unit: ""
            )

            Text("Coupling disk")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Coupling altitude",
                value: $couplingAltitudeKm,
                range: 0.1...500.0,
                step: 0.1,
                unit: " km"
            )

            ParameterSlider(
                title: "Coupling radius",
                value: $couplingRadiusKm,
                range: 0.001...250.0,
                step: 0.001,
                unit: " km"
            )

            Text("Receiver and collector")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Receiver turns",
                value: $receiverTurns,
                range: 1.0...100_000.0,
                step: 1.0,
                unit: ""
            )

            ParameterSlider(
                title: "Receiver resistance",
                value: $receiverResistanceOhms,
                range: 0.000001...1_000.0,
                step: 0.000001,
                unit: " Ω"
            )

            ParameterSlider(
                title: "Collector footprint",
                value: $collectorAreaAcres,
                range: 0.01...1_000.0,
                step: 0.01,
                unit: " acres"
            )

            ParameterSlider(
                title: "Collector conductivity",
                value: $collectorConductivitySPerM,
                range: 1.0...60_000_000.0,
                step: 1_000.0,
                unit: " S/m"
            )

            ParameterSlider(
                title: "Spoke thickness",
                value: $collectorThicknessM,
                range: 0.0001...1.0,
                step: 0.0001,
                unit: " m"
            )

            ParameterSlider(
                title: "Spoke width",
                value: $radialSpokeWidthM,
                range: 0.001...10.0,
                step: 0.001,
                unit: " m"
            )

            ParameterSlider(
                title: "Spoke count",
                value: $radialSpokeCount,
                range: 1.0...256.0,
                step: 1.0,
                unit: ""
            )

            Toggle(
                "Include AC collector impedance",
                isOn: $includeACImpedance
            )

            ParameterSlider(
                title: "Collector inductance",
                value: $collectorInductanceH,
                range: 0.000001...10.0,
                step: 0.000001,
                unit: " H"
            )

            ParameterSlider(
                title: "Collector capacitance",
                value: $collectorCapacitanceF,
                range: 0.000000001...0.01,
                step: 0.000000001,
                unit: " F"
            )

            Text("Circuit losses")
                .font(.subheadline)
                .fontWeight(.semibold)

            ParameterSlider(
                title: "Source resistance",
                value: $sourceResistanceOhms,
                range: 0.0...10_000.0,
                step: 0.001,
                unit: " Ω"
            )

            ParameterSlider(
                title: "Ground return resistance",
                value: $groundReturnResistanceOhms,
                range: 0.0...10_000.0,
                step: 0.001,
                unit: " Ω"
            )

            ParameterSlider(
                title: "Radiation resistance",
                value: $radiationResistanceOhms,
                range: 0.0...10_000.0,
                step: 0.0001,
                unit: " Ω"
            )

            ParameterSlider(
                title: "Load resistance",
                value: $loadResistanceOhms,
                range: 0.001...100_000.0,
                step: 0.01,
                unit: " Ω"
            )

            ParameterSlider(
                title: "Contact efficiency",
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

            Text("QRTL comparison")
                .font(.subheadline)
                .fontWeight(.semibold)

            Toggle(
                "Enable QRTL comparison",
                isOn: $qrtlHypothesisEnabled
            )

            ParameterSlider(
                title: "QRTL hypothesis coupling",
                value: $qrtlHypothesisCoupling,
                range: 0.0...10.0,
                step: 0.001,
                unit: ""
            )

            Toggle(
                "Energize and animate machine",
                isOn: $isRunning
            )
        }
        .panelStyle()
    }

    private var equationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Physics Pipeline")
                .font(.headline)

            EquationStep(
                number: "1",
                title: "Coil magnetic moment",
                equation: "mᵢ = NᵢIᵢAᵢ"
            )

            EquationStep(
                number: "2",
                title: "Combined flux phasor",
                equation: "Φ(t) = Σ Φᵢ sin(ωt + φᵢ)"
            )

            EquationStep(
                number: "3",
                title: "Coaxial dipole-to-disk flux",
                equation: "Φᵢ = μ₀mᵢR²/[2(z²+R²)³ᐟ²]"
            )

            EquationStep(
                number: "4",
                title: "Flux derivative",
                equation: "dΦ/dt = ω[Acos(ωt) − Bsin(ωt)]"
            )

            EquationStep(
                number: "5",
                title: "Faraday voltage",
                equation: "V = −N_receiver dΦ/dt"
            )

            EquationStep(
                number: "6",
                title: "Circuit impedance",
                equation: "Z = R + j(ωL − 1/(ωC))"
            )

            EquationStep(
                number: "7",
                title: "Circuit current",
                equation: "I_RMS = V_RMS / |Z|"
            )

            EquationStep(
                number: "8",
                title: "Power and losses",
                equation: "P_load = I²R_load; P_loss = I²R"
            )

            EquationStep(
                number: "9",
                title: "Resonator loss estimate",
                equation: "P_res ≈ ωE/Q"
            )

            EquationStep(
                number: "10",
                title: "Design objective",
                equation: "maximize Φ_useful / P_field input"
            )
        }
        .panelStyle()
    }

    private var limitationSection: some View {
        Text(
            "Performance note: this fast version uses the analytic magnetic "
            + "flux integral for coaxial axial dipoles and a horizontal circular "
            + "coupling disk. It is appropriate for fast interactive design "
            + "exploration. Off-axis, tilted, or noncircular geometries require "
            + "a numerical field/surface integration performed outside SwiftUI's "
            + "immediate rendering path. QRTL remains a separate hypothesis "
            + "comparison and is not used to create conventional circuit power."
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - View Styling

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

// MARK: - Power Formatting

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

// MARK: - Supporting Views

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
                .minimumScaleFactor(0.70)
        }
        .font(.subheadline)
    }
}

struct CoilMetricRow: View {

    let name: String
    let turns: Double
    let currentA: Double
    let radiusM: Double
    let resistanceOhms: Double
    let lossMW: Double
    let active: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(
                    active
                        ? "Active"
                        : "Disabled"
                )
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    active
                        ? Color.green
                        : Color.secondary
                )
            }

            Text(
                String(
                    format: "%.0f turns • %.1f A • %.1f m radius • %.6f Ω • %@",
                    turns,
                    currentA,
                    radiusM,
                    resistanceOhms,
                    PowerFormatter.string(
                        megawatts: lossMW
                    )
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        .padding(.vertical, 3)
    }
}

struct ParameterSlider: View {

    let title: String

    @Binding var value: Double

    let range: ClosedRange<Double>
    let step: Double
    let unit: String

    private var decimals: Int {
        if step >= 1.0 {
            return 0
        }

        if step >= 0.1 {
            return 1
        }

        if step >= 0.01 {
            return 2
        }

        if step >= 0.001 {
            return 3
        }

        if step >= 0.0001 {
            return 4
        }

        if step >= 0.000001 {
            return 6
        }

        return 9
    }

    private var formattedValue: String {
        String(
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
                    .minimumScaleFactor(0.65)
            }

            Slider(
                value: $value,
                in: range,
                step: step
            )
        }
    }
}

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



