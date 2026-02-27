//
//  MyHomeAppApp.swift
//  MyHomeApp
//
//  Created by Dogan Berk BULUR on 27.02.2026.
//

import SwiftUI

@main
struct MyHomeAppApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}
