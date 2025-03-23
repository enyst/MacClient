//
//  MacClientApp.swift
//  MacClient
//
//  Created by Engel Nyst on 2025-03-23.
//

import SwiftUI

@main
struct MacClientApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
