//
//  DefaultAppApp.swift
//  DefaultApp
//
//  Created by Syd Polk on 6/8/22.
//

import SwiftUI

@main
struct DefaultAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
