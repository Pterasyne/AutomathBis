//
//  automobApp.swift
//  automob
//
//  Created by Pterasyne on 30/09/2026.
//

import SwiftUI

@main
struct automobApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Performance.self)
    }
}
