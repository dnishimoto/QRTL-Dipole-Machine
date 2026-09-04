//
//  File.swift
//  QRTL Dipole Machine
//
//  Created by David Nishimoto on 9/1/26.
//

import Foundation
import SwiftUI


struct ParameterSlider: View {

    let title: String
    let variable: String

    @Binding var value: Double

    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let explanation: String

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            HStack(
                alignment: .firstTextBaseline
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text(title)
                        .font(.subheadline.weight(.semibold))

                    Text(variable)
                        .font(
                            .system(
                                size: 10,
                                design: .monospaced
                            )
                        )
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(formattedValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }

            Slider(
                value: $value,
                in: range,
                step: step
            )

            HStack(
                alignment: .top,
                spacing: 6
            ) {

                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
    }

    private var formattedValue: String {

        switch unit {

        case "":
            return String(
                format: "%.2f",
                value
            )

        case "A":
            return String(
                format: "%.1f A",
                value
            )

        case "m":
            return String(
                format: "%.2f m",
                value
            )

        case "km":
            return String(
                format: "%.2f km",
                value
            )

        case "MW":
            return String(
                format: "%.3f MW",
                value
            )

        case "kHz":
            return String(
                format: "%.3f kHz",
                value
            )

        case "Ω":
            return String(
                format: "%.6g Ω",
                value
            )

        case "°":
            return String(
                format: "%.0f°",
                value
            )

        case "×":
            return String(
                format: "%.2f×",
                value
            )

        case "acres":
            return String(
                format: "%.2f acres",
                value
            )

        default:
            return String(
                format: "%.2f %@",
                value,
                unit
            )
        }
    }
}

