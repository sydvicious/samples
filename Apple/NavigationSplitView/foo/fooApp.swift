//
//  fooApp.swift
//  foo
//
//  Created by Syd Polk on 6/30/22.
//

import SwiftUI

@main
struct fooApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
