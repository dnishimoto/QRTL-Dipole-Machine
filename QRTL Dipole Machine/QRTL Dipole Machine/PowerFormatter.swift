//
//  PowerFormatter.swift
//  QRTL Dipole Machine
//
//  Created by David Nishimoto on 9/1/26.
//

import Foundation

enum PowerFormatter {

    static func string(
        megawatts: Double
    ) -> String {

        let watts = megawatts * 1_000_000.0
        let magnitude = abs(watts)

        if magnitude >= 1_000_000.0 {
            return String(
                format: "%.3f MW",
                megawatts
            )
        }

        if magnitude >= 1_000.0 {
            return String(
                format: "%.2f kW",
                watts / 1_000.0
            )
        }

        return String(
            format: "%.1f W",
            watts
        )
    }
}
