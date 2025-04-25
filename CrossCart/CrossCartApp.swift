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
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack{
               // ContentView()
                  //  .environment(\.managedObjectContext, persistenceController.container.viewContext)
                LoginView()
            }
        }
    }
}
