//
//  ChatbotService.swift
//  AiChatbot
//
//  Created by Fernanda Battig on 2025-03-14.
//

import Foundation

class ChatbotService {
    let apiURL = "https://u5by072peg.execute-api.us-east-2.amazonaws.com/prod/chat"
    
    struct ChatbotResponse: Codable {
        let response: String?
        let error: String?
    }
    
    func getChatbotResponse(for message: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion("Error: Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["message": message, "user_id": "12345"]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion("Error: Failed to encode request body.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion("Error: Could not reach chatbot server.")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ChatbotResponse.self, from: data)
                DispatchQueue.main.async {
                    if let botResponse = decodedResponse.response {
                        completion(botResponse)
                    } else if let errorMessage = decodedResponse.error {
                        completion("Error: \(errorMessage)")
                    } else {
                        completion("Error: Unknown response format.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Error: Failed to parse chatbot response.")
                }
            }
        }.resume()
    }
}
