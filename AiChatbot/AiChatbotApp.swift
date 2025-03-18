//
//  AiChatbotApp.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-14.
//

import SwiftUI

@main
struct AiChatbotApp: App {
    @StateObject private var appState = AppState()  // Global state

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)  // Pass to all views
        }
    }
}

// App-wide state
class AppState: ObservableObject {
    @Published var userFullName: String = ""
    @Published var showChat: Bool = false
}
