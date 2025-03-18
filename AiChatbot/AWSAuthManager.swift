//
//  AWSAuthManager.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-16.
//

//
//  AWSAuthManager.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-16.
//

import Foundation
import AWSMobileClient

class AWSAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String? = nil
    @Published var userFullName: String = ""

    static let shared = AWSAuthManager()

    private init() {}

    // --------- Initialize AWS Auth (AWS SDK) ---------
    func initializeAWSAuth() {
        AWSMobileClient.default().initialize { (userState, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let userState = userState {
                    switch userState {
                    case .signedIn:
                        self.isAuthenticated = true
                        self.fetchUserAttributes()
                    case .signedOut:
                        self.isAuthenticated = false
                    default:
                        break
                    }
                }
            }
        }
    }

    // --------- SIGN UP FUNCTION ---------
    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Bool, String?) -> Void) {
        let attributes = ["email": email, "given_name": firstName, "family_name": lastName]
        
        AWSMobileClient.default().signUp(username: email, password: password, userAttributes: attributes) { (signUpResult, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }
                completion(true, "Sign-up successful! Please confirm your email.")
            }
        }
    }

    // --------- LOGIN FUNCTION ---------
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        AWSMobileClient.default().signIn(username: email, password: password) { (signInResult, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }
                self.isAuthenticated = true
                self.fetchUserAttributes()
                completion(true, "Login successful!")
            }
        }
    }

    // --------- FETCH USER ATTRIBUTES ---------
    func fetchUserAttributes() {
        AWSMobileClient.default().getUserAttributes { (attributes, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch user attributes:", error.localizedDescription)
                    return
                }
                
                if let attributes = attributes {
                    let firstName = attributes["given_name"] ?? ""
                    let lastName = attributes["family_name"] ?? ""
                    self.userFullName = "\(firstName) \(lastName)"
                }
            }
        }
    }

    // --------- LOGOUT FUNCTION ---------
    func logout() {
        AWSMobileClient.default().signOut { _ in
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.userFullName = ""
            }
        }
    }
}
