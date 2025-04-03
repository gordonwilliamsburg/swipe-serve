import Foundation
import UIKit

class TryOnService: ObservableObject {
    private let apiKey = "ccfeb8a264mshc9a98f9bfcf43b9p1be65ajsn052a2bba2122"
    private let apiHost = "try-on-diffusion.p.rapidapi.com"
    private let bgRemovalBaseURL = "https://not-lain-background-removal.hf.space"
    
    @Published var isLoading = false
    
    func generateTryOn(userPhoto: UIImage, clothingImage: UIImage) async throws -> UIImage {
        let url = URL(string: "https://try-on-diffusion.p.rapidapi.com/try-on-file")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        
        // Create form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Add user photo
        if let avatarData = userPhoto.jpegData(compressionQuality: 0.8) {
            data.append(createFormData(boundary: boundary, name: "avatar_image", fileName: "avatar.jpg", mimeType: "image/jpeg", fileData: avatarData))
        }
        
        // Add clothing image
        if let clothingData = clothingImage.jpegData(compressionQuality: 0.8) {
            data.append(createFormData(boundary: boundary, name: "clothing_image", fileName: "clothing.jpg", mimeType: "image/jpeg", fileData: clothingData))
        }
        
        // Add closing boundary
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        guard let generatedImage = UIImage(data: responseData) else {
            throw NSError(domain: "TryOnService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data received"])
        }
        
        return generatedImage
    }
    
    private func createFormData(boundary: String, name: String, fileName: String, mimeType: String, fileData: Data) -> Data {
        var data = Data()
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        
        return data
    }




    func removeBackground(from image: UIImage) async throws -> UIImage {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        throw NSError(domain: "TryOnService", code: -1, 
            userInfo: [NSLocalizedDescriptionKey: "Failed to prepare image"])
    }
    
    // Initial request setup
    let url = URL(string: "https://universal-background-removal.p.rapidapi.com/cutout/universal/common-image")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Headers
    request.setValue("multipart/form-data; boundary=Boundary", forHTTPHeaderField: "Content-Type")
    request.setValue("ccfeb8a264mshc9a98f9bfcf43b9p1be65ajsn052a2bba2122", forHTTPHeaderField: "x-rapidapi-key")
    request.setValue("universal-background-removal.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
    
    // Create form data
    let boundary = "Boundary"
    var body = Data()
    
    // Add image data
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n".data(using: .utf8)!)
    
    // Add return_form parameter
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"return_form\"\r\n\r\n".data(using: .utf8)!)
    body.append("whiteBK".data(using: .utf8)!)
    body.append("\r\n".data(using: .utf8)!)
    
    // Add closing boundary
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    request.httpBody = body
    
    print("Sending initial request...")
    
    // Make initial request
    let (responseData, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "TryOnService", code: -1, 
            userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }
    
    print("Response status code:", httpResponse.statusCode)
    
    guard httpResponse.statusCode == 200,
          let jsonString = String(data: responseData, encoding: .utf8) else {
        let errorMessage = String(data: responseData, encoding: .utf8) ?? "Unknown error"
        throw NSError(domain: "TryOnService", code: httpResponse.statusCode, 
            userInfo: [NSLocalizedDescriptionKey: "Server error: \(errorMessage)"])
    }
    
    print("Response JSON:", jsonString)
    
    // Parse the JSON response
    guard let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
          let data = json["data"] as? [String: Any],
          let imageUrl = data["image_url"] as? String,
          let processedImageUrl = URL(string: imageUrl) else {
        throw NSError(domain: "TryOnService", code: -1, 
            userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL from response"])
    }
    
    print("Downloading image from:", imageUrl)
    
    // Download the actual image
    let (processedImageData, processedImageResponse) = try await URLSession.shared.data(from: processedImageUrl)
    
    guard let httpImageResponse = processedImageResponse as? HTTPURLResponse,
          httpImageResponse.statusCode == 200 else {
        throw NSError(domain: "TryOnService", code: -1, 
            userInfo: [NSLocalizedDescriptionKey: "Failed to download processed image"])
    }
    
    guard let processedImage = UIImage(data: processedImageData) else {
        throw NSError(domain: "TryOnService", code: -1, 
            userInfo: [NSLocalizedDescriptionKey: "Failed to create image from downloaded data"])
    }
    
    return processedImage
}
}