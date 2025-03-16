//
//  ContentView.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-14.
//

import SwiftUI

// Define custom colors
extension Color {
    static let gold = Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255)
    static let botMessageBG = Color.gray.opacity(0.3) // Bot messages background
    static let userMessageBG = Color.blue // User messages background
}

// Main Chat View
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Full black background
            
            VStack {
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.messages, id: \ .id) { message in
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
                        .padding(.top, 10)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            scrollView.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                MessageInputView(viewModel: viewModel)
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



// Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// Entry Point
struct ContentView: View {
    var body: some View {
        ChatView()
    }
}
