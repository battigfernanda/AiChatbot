//
//  ChatViewModel.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-14.
//

import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var userInput: String = ""

    private let chatbotService = ChatbotService()

    func sendMessage() {
        guard !userInput.isEmpty else { return }

        // Add user's message to chat
        let userMessage = ChatMessage(text: userInput, isUser: true)
        messages.append(userMessage)

        let userText = userInput // Store message before clearing
        userInput = "" // Clear input field

        // Call AI API
        chatbotService.getChatbotResponse(for: userText) { response in
            DispatchQueue.main.async {
                let botResponse = ChatMessage(text: response, isUser: false)
                self.messages.append(botResponse)
            }
        }
    }
}
