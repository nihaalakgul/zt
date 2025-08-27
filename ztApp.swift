//
//  ztApp.swift
//  zt
//
//  Created by Nihal Akgül on 15.08.2025.
//

import SwiftUI

@main
struct ztApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}

