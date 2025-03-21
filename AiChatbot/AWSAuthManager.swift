//
//  AWSAuthManager.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-16.
//

import Foundation

class AWSAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String? = nil
    @Published var idToken: String? = nil
    @Published var accessToken: String? = nil
    @Published var userFullName: String = "" // ✅ Added userFullName

    static let shared = AWSAuthManager()

    private init() {}

    // ✅ Function to initialize authentication (if needed)
    func initializeAWSAuth(completion: @escaping (Bool) -> Void) {
        // You can add real AWS initialization logic here if needed.
        DispatchQueue.main.async {
            print("AWSMobileClient initialized successfully.")
            completion(true)
        }
    }

    // --------- ✅ SIGN-UP FUNCTION ---------
    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "https://u5by072peg.execute-api.us-east-2.amazonaws.com/prod/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "action": "sign_up",
            "email": email,
            "password": password,
            "first_name": firstName,
            "last_name": lastName
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, error?.localizedDescription ?? "Unknown error")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    self.userFullName = "\(firstName) \(lastName)" // ✅ Save full name after sign-up
                }
                completion(true, "Sign-up successful!")
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(false, errorMessage)
            }
        }.resume()
    }

    // --------- ✅ LOGIN FUNCTION ---------
    // ✅ LOGIN FUNCTION
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "https://u5by072peg.execute-api.us-east-2.amazonaws.com/prod/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "action": "login",
            "email": email,
            "password": password
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, error?.localizedDescription ?? "Unknown error")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let idToken = jsonResponse["IdToken"] as? String,
                   let accessToken = jsonResponse["AccessToken"] as? String,
                   let userAttributes = jsonResponse["UserAttributes"] as? [String: String] {

                    let fullName = "\(userAttributes["given_name"] ?? "") \(userAttributes["family_name"] ?? "")"
                    UserDefaults.standard.setValue(fullName, forKey: "userFullName")

                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        self.idToken = idToken
                        self.accessToken = accessToken
                        self.userFullName = fullName
                    }
                    completion(true, "Login successful!")
                } else {
                    completion(false, "Invalid response format")
                }
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(false, errorMessage)
            }
        }.resume()
    }



    // ✅ Extract user full name from login response
    private func extractUserFullName(from json: [String: Any]) -> String {
        let firstName = json["given_name"] as? String ?? ""
        let lastName = json["family_name"] as? String ?? ""
        return firstName.isEmpty && lastName.isEmpty ? "User" : "\(firstName) \(lastName)"
    }
    
    func getUserFullName() -> String {
        // Check if we already stored the user's full name
        if let fullName = UserDefaults.standard.string(forKey: "userFullName") {
            return fullName
        } else {
            return "User" // Default placeholder if name is not found
        }
    }


    // --------- ✅ LOGOUT FUNCTION ---------
    func logout() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.idToken = nil
            self.accessToken = nil
            self.userFullName = "" // ✅ Clear full name on logout
        }
    }
}
