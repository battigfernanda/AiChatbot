//
//  LoginView.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-16.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager = AWSAuthManager.shared
    @Binding var showChat: Bool
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false  // Toggle between login & sign-up
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Image("epicMediaLogo") // Ensure this is in Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 50)

                Text(isSignUp ? "Create Account" : "Welcome Back")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                VStack(spacing: 15) {
                    if isSignUp {
                        AuthTextField(placeholder: "First Name", text: $firstName, isSecure: false)
                        AuthTextField(placeholder: "Last Name", text: $lastName, isSecure: false)
                    }
                    
                    AuthTextField(placeholder: "Email", text: $email, isSecure: false)
                    AuthTextField(placeholder: "Password", text: $password, isSecure: true)
                    
                    if let error = errorMessage {
                        Text(error).foregroundColor(.red).font(.footnote)
                    }

                    Button(action: handleAuth) {
                        Text(isSignUp ? "Sign Up" : "Login")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gold)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)

                    Button(action: { isSignUp.toggle() }) {
                        Text(isSignUp ? "Already have an account? Login" : "Don't have an account? Sign up")
                            .foregroundColor(.gray)
                    }
                }
                .padding()

                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }

    // Handle login or signup
    private func handleAuth() {
        if isSignUp {
            authManager.signUp(email: email, password: password, firstName: firstName, lastName: lastName) { success, message in
                if success {
                    errorMessage = nil
                    showChat = true
                } else {
                    errorMessage = message
                }
            }
        } else {
            authManager.login(email: email, password: password) { success, message in
                if success {
                    errorMessage = nil
                    showChat = true
                } else {
                    errorMessage = message
                }
            }
        }
    }
}

// Reusable TextField component
struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool

    var body: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
        } else {
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
        }
    }
}
