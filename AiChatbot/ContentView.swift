//
//  ContentView.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-14.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// Define custom colors
extension Color {
    static let gold = Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255)
    static let botMessageBG = Color.gray.opacity(0.3) // Bot messages background
    static let userMessageBG = Color.blue // User messages background
}

// Main ContentView
struct ContentView: View {
    @ObservedObject var authManager = AWSAuthManager.shared
    @State private var showChat = false

    var body: some View {
        NavigationStack {
            if authManager.isAuthenticated {
                ChatView(userFullName: authManager.getUserFullName())
                    .navigationBarBackButtonHidden(true)
            } else {
                LoginView(showChat: $showChat)
            }
        }
        .onAppear {
            authManager.initializeAWSAuth { success in
                if !success {
                    print("AWSMobileClient failed to initialize.")
                } else {
                    print("AWSMobileClient initialized successfully.")
                }
            }
        }

    }
}

// Chat View 

struct ChatView: View {
    var userFullName: String
    @State private var displayedText = ""

    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Animated Greeting Text
                Text(displayedText)
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .onAppear {
                        animateGreeting()
                    }
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.messages, id: \.id) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.userMessageBG)
                                        .foregroundColor(.white)
                                        .cornerRadius(15)
                                        .padding(.horizontal, 10)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.botMessageBG)
                                        .foregroundColor(.white)
                                        .cornerRadius(15)
                                        .padding(.horizontal, 10)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                Divider()
                MessageInputView(viewModel: viewModel)
            }
        }
    }

    // Animate the greeting text letter by letter
    private func animateGreeting() {
        let greeting = "How can I help you today, \(userFullName)?"
        displayedText = ""
        for (index, char) in greeting.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                displayedText.append(char)
            }
        }
    }
}


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



// Input field & Send button
struct MessageInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Image("epicMediaLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 40)

            Text("Chat with Epic AI")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                TextField("Type a message...", text: $viewModel.userInput)
                    .padding(15)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(25)
                    .foregroundColor(.white)

                Button(action: viewModel.sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                        .padding(15)
                        .background(Color.gold)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.black)
    }
}
