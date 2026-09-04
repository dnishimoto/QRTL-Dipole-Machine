//
//  File.swift
//  QRTL Dipole Machine
//
//  Created by David Nishimoto on 9/1/26.
//

import Foundation
import SwiftUI

struct CoilMetricRow: View {

    let title: String
    let turns: Double
    let currentA: Double
    let radiusM: Double

    var body: some View {
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Coil Parameters")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(Int(turns)) turns")
                    .font(.caption)
                    .fontWeight(.medium)

                Text(
                    String(
                        format: "%.1f A",
                        currentA
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(
                    String(
                        format: "%.1f m radius",
                        radiusM
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
