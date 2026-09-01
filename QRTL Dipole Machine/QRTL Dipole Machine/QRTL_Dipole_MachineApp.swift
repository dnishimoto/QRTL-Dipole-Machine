//
//  QRTL_Dipole_MachineApp.swift
//  QRTL Dipole Machine
//
//  Created by David Nishimoto on 9/1/26.
//

import SwiftUI
import CoreData

@main
struct QRTL_Dipole_MachineApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
