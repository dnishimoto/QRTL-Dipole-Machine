//
//  RecirculationPipeline.swift
//  QRTL Dipole Machine
//
//  Derived recirculation state.
//
//  All dipole, field, flux, induction, loss, power-budget,
//  and QRTL collection equations live in QRTLDipoleModel.
//

import Foundation
import Combine

@MainActor
final class RecirculationPipeline: ObservableObject {

    // ============================================================
    // MARK: - Source Model
    // ============================================================

    /// Single source of truth for the dipole system.
    ///
    /// Do not duplicate magnetic, power, or coil parameters here.
    let dipoleModel: QRTLDipoleModel

    private var cancellables = Set<AnyCancellable>()

    // ============================================================
    // MARK: - Published Recirculation State
    // ============================================================

    /// Optional additional closure-path efficiency.
    ///
    /// This represents the fraction of the modeled field-aligned
    /// current that successfully closes through the return path.
    @Published var closureEfficiency: Double = 1.0

    /// Optional display multiplier only.
    ///
    /// Keep this at 1.0 for direct physical-model display.
    @Published var currentVisualizationScale: Double = 1.0

    // ============================================================
    // MARK: - Initialization
    // ============================================================

    init(
        dipoleModel: QRTLDipoleModel
    ) {
        self.dipoleModel = dipoleModel

        dipoleModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // ============================================================
    // MARK: - Machine State
    // ============================================================

    var machineRunning: Bool {
        dipoleModel.isRunning
    }

    var isRunning: Bool {
        dipoleModel.isRunning
    }

    // ============================================================
    // MARK: - Field-Aligned Current
    // ============================================================

    /// QRTLDipoleModel's field-aligned current assumption.
    ///
    /// Positive current is retained as the model's current magnitude.
    var fieldAlignedCurrentAmps: Double {

        dipoleModel.fieldAlignedCurrent
    }

    /// Current captured by the modeled collection interface.
    var capturedFieldCurrentAmps: Double {

        dipoleModel.capturedFieldCurrentA
    }

    /// Downward conventional-current sign convention:
    ///
    /// Negative = ionosphere → ground.
    ///
    /// This does not claim conventional ionospheric current
    /// generation; it simply provides a consistent visual/current
    /// direction for the QRTL simulation.
    var downwardFieldAlignedCurrentAmps: Double {

        -capturedFieldCurrentAmps
    }

    /// Compatibility name for views that expect FAC current.
    var facCurrent: Double {

        downwardFieldAlignedCurrentAmps
    }

    // ============================================================
    // MARK: - Return / Closure Current
    // ============================================================

    var effectiveClosureEfficiency: Double {

        max(
            0.0,
            min(
                1.0,
                closureEfficiency
            )
        )
    }

    /// Return current opposite to the downward field-aligned
    /// current. Positive means ground → ionosphere under the
    /// current-sign convention used here.
    var closureCurrent: Double {

        -facCurrent
            * effectiveClosureEfficiency
    }

    /// Difference between outgoing/downward and return-current
    /// magnitudes.
    ///
    /// A value of 0 A means the modeled loop closes exactly.
    var closureCurrentMismatchAmps: Double {

        abs(
            abs(facCurrent)
            - abs(closureCurrent)
        )
    }

    /// Magnitude ratio:
    ///
    /// 1.0 = exact current closure.
    var recirculationConsistency: Double {

        let facMagnitude = abs(facCurrent)

        guard facMagnitude > 1.0e-12 else {
            return 0.0
        }

        return abs(closureCurrent)
            / facMagnitude
    }

    /// A simple 0...1 closure score for UI presentation.
    var recirculationClosureScore: Double {

        max(
            0.0,
            min(
                1.0,
                recirculationConsistency
            )
        )
    }

    // ============================================================
    // MARK: - Display / Visualization
    // ============================================================

    var effectiveVisualizationScale: Double {

        max(
            0.0,
            currentVisualizationScale
        )
    }

    /// Display-only downward current magnitude.
    ///
    /// Do not use this in power or energy equations.
    var visualDownwardCurrentMagnitudeAmps: Double {

        abs(downwardFieldAlignedCurrentAmps)
            * effectiveVisualizationScale
    }

    /// Display-only upward return-current magnitude.
    ///
    /// Do not use this in power or energy equations.
    var visualClosureCurrentMagnitudeAmps: Double {

        abs(closureCurrent)
            * effectiveVisualizationScale
    }

    var currentDirectionDescription: String {

        guard machineRunning else {
            return "Recirculation pipeline paused."
        }

        guard abs(facCurrent) > 1.0e-12 else {
            return "No modeled field-aligned current."
        }

        return
            "Modeled conventional current flows downward "
            + "(ionosphere → ground); closure current flows upward."
    }

    var recirculationStatus: String {

        guard machineRunning else {
            return "Paused"
        }

        guard abs(facCurrent) > 1.0e-12 else {
            return "No field-aligned current"
        }

        if recirculationConsistency >= 0.999 {
            return "Current loop closed"
        }

        return String(
            format: "Closure %.1f%%",
            recirculationConsistency * 100.0
        )
    }

    // ============================================================
    // MARK: - Compatibility Read-Only Proxies
    // ============================================================

    /// All of these are proxies into QRTLDipoleModel.
    /// They prevent old UI code from needing immediate rewrites,
    /// while maintaining one source of truth.

    var fieldSystemInputWatts: Double {
        dipoleModel.fieldSystemInputWatts
    }

    var fieldSystemInputKW: Double {
        dipoleModel.fieldSystemInputKW
    }

    var fieldSystemInputMW: Double {
        dipoleModel.fieldSystemInputMW
    }

    var maximumFieldInputWatts: Double {
        dipoleModel.maximumFieldInputWatts
    }

    var isWithinMaximumFieldPowerBudget: Bool {
        dipoleModel.isWithinMaximumFieldPowerBudget
    }

    var isFieldPowerLimited: Bool {
        dipoleModel.isFieldPowerLimited
    }

    var fieldAtCouplingCenterTesla: Double {
        dipoleModel.fieldAtCouplingCenterTesla
    }

    var peakMagneticFluxWebers: Double {
        dipoleModel.peakMagneticFluxWebers
    }

    var displayedPowerGatheredMW: Double {
        dipoleModel.displayedPowerGatheredMW
    }

    var displayedPowerGatheredKW: Double {
        dipoleModel.displayedPowerGatheredKW
    }

    var powerGatheredLabel: String {
        dipoleModel.powerGatheredLabel
    }

    var qrtlFieldCollectionPowerMW: Double {
        dipoleModel.qrtlFieldCollectionPowerMW
    }

    var qrtlNetOutputMW: Double {
        dipoleModel.qrtlNetOutputMW
    }

    var qrtlComparisonNetOutputMW: Double {
        dipoleModel.qrtlComparisonNetOutputMW
    }

    var targetStatus: String {
        dipoleModel.targetStatus
    }

    // ============================================================
    // MARK: - Reset
    // ============================================================

    /// Resets only pipeline-specific display/closure state.
    ///
    /// Call `dipoleModel.reset()` separately when you intend to
    /// reset field coils, losses, voltage, QRTL assumptions, and
    /// all dipole-machine configuration.
    func resetPipeline() {

        closureEfficiency = 1.0
        currentVisualizationScale = 1.0
    }

    /// Convenience reset for callers that previously expected
    /// the pipeline reset to reset the complete machine.
    func reset() {

        dipoleModel.reset()
        resetPipeline()
    }
}
