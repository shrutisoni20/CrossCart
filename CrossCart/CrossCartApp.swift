//
//  CrossCartApp.swift
//  CrossCart
//
//  Created by shruti's macbook on 24/04/25.
//

import SwiftUI

@main
struct CrossCartApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
