//
//  NetworkManager.swift
//  BugKit
//
//  Created by Balavignesh on 03/12/25.
//

#if canImport(UIKit)
import Foundation
import UIKit

@MainActor
class NetworkManager {
    static let shared = NetworkManager()
    
    func uploadBug(email: String, desc: String, images: [UIImage], completion: @escaping (Bool) -> Void) {
        guard let urlString = BugKit.shared.baseUrl,
              let url = URL(string: "\(urlString)/bugs") else {
            print("BugKit Error: Base URL not set")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        let params = ["email": email, "description": desc, "api_key": BugKit.shared.apiKey ?? ""]
        
        for (key, value) in params {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"attachment_\(index)\"; filename=\"image_\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }.resume()
    }
}
#endif
