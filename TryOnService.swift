import Foundation
import UIKit

class TryOnService: ObservableObject {
    private let apiKey = "ccfeb8a264mshc9a98f9bfcf43b9p1be65ajsn052a2bba2122"
    private let apiHost = "try-on-diffusion.p.rapidapi.com"
    
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
}