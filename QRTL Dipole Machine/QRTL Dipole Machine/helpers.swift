//
//  helpers.swift
//  QRTL Dipole Machine
//
//  Created by David Nishimoto on 9/1/26.
//

import Foundation
import SwiftUI

// MARK: - Power Formatter

enum PowerFormatter {

    static func string(megawatts valueMW: Double) -> String {

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


// MARK: - Output Value

struct OutputValue: View {

    let title: String
    let value: String

    var body: some View {

        HStack {

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(
                    .system(
                        .body,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}


// MARK: - Metric Row

struct MetricRow: View {

    let title: String
    let value: String

    var body: some View {

        HStack(alignment: .firstTextBaseline) {

            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            Text(value)
                .font(
                    .system(
                        .subheadline,
                        design: .monospaced
                    )
                )
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 3)
    }
}


// MARK: - Coil Metric Row

struct CoilMetricRow: View {

    let title: String
    let turns: Double
    let current: Double
    let radius: Double
    let moment: Double
    let copperLoss: Double

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 7
        ) {

            Text(title)
                .font(.headline)

            MetricRow(
                title: "Turns",
                value: String(
                    format: "%.0f",
                    turns
                )
            )

            MetricRow(
                title: "Current",
                value: String(
                    format: "%.3f A",
                    current
                )
            )

            MetricRow(
                title: "Radius",
                value: String(
                    format: "%.3f m",
                    radius
                )
            )

            MetricRow(
                title: "Magnetic Moment",
                value: String(
                    format: "%.6e A·m²",
                    moment
                )
            )

            MetricRow(
                title: "Copper Loss",
                value: PowerFormatter.string(
                    megawatts: copperLoss
                )
            )
        }
        .padding(.vertical, 5)
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

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            HStack {

                Text(title)
                    .font(.subheadline)

                Spacer()

                Text(formattedValue)
                    .font(
                        .system(
                            .caption,
                            design: .monospaced
                        )
                    )
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: $value,
                in: range,
                step: step
            )
        }
        .padding(.vertical, 3)
    }

    private var formattedValue: String {

        let number: String

        if step >= 1.0 {

            number = String(
                format: "%.0f",
                value
            )

        } else if step >= 0.1 {

            number = String(
                format: "%.1f",
                value
            )

        } else if step >= 0.01 {

            number = String(
                format: "%.2f",
                value
            )

        } else if step >= 0.001 {

            number = String(
                format: "%.3f",
                value
            )

        } else if step >= 0.000001 {

            number = String(
                format: "%.6f",
                value
            )

        } else {

            number = String(
                format: "%.3e",
                value
            )
        }

        if unit.isEmpty {
            return number
        }

        return "\(number) \(unit)"
    }
}


// MARK: - Equation Step

struct EquationStep: View {

    let number: Int
    let title: String
    let equation: String

    var body: some View {

        HStack(
            alignment: .top,
            spacing: 12
        ) {

            Text("\(number)")
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                    .weight(.bold)
                )
                .frame(
                    width: 28,
                    height: 28
                )
                .background(
                    Circle()
                        .fill(.secondary.opacity(0.15))
                )

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(equation)
                    .font(
                        .system(
                            .body,
                            design: .serif
                        )
                    )
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

