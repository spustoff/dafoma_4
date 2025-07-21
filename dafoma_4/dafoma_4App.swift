//
//  dafoma_4App.swift
//  dafoma_4
//
//  VoltCase - Quick Access Vault for Technical Notes
//  App Store compliant reference utility
//

import SwiftUI

@main
struct dafoma_4App: App {
    @StateObject private var storageManager = StorageManager()
    
    var body: some Scene {
        WindowGroup {
            VoltCaseMainView()
                .environmentObject(storageManager)
                .preferredColorScheme(.dark)
        }
    }
}
