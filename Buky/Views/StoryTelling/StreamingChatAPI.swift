import Foundation
class StreamingChatAPI {
    private let baseURL = "https:localhost:3000"  // ← Cambia esto
    
    func streamMessage(
        _ story: Story,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) async {
        
        guard let url = URL(string: "http://localhost:3000/api/hello") else {
            onError(APIError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(story)
            request.httpBody = jsonData
        } catch {
            onError(error)
            return
        }
        
        // Hacer request con streaming
        do {
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                onError(APIError.invalidResponse)
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                onError(APIError.serverError(httpResponse.statusCode))
                return
            }
            
            var buffer = ""
            
            // Leer bytes uno por uno
            for try await byte in bytes {
                let character = String(UnicodeScalar(byte))
                buffer += character
                
                // Detectar fin de mensaje SSE (doble newline)
                if buffer.hasSuffix("\n\n") {
                    let lines = buffer.components(separatedBy: "\n\n")
                    
                    for line in lines where !line.isEmpty {
                        // Parsear línea SSE
                        if line.hasPrefix("data: ") {
                            let jsonString = line.replacingOccurrences(of: "data: ", with: "")
                            
                            // Check si terminó
                            if jsonString == "[DONE]" {
                                await MainActor.run { onComplete() }
                                return
                            }
                            
                            // Parse JSON
                            if let data = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                
                                if let text = json["text"] as? String {
                                    await MainActor.run { onChunk(text) }
                                }
                                
                                if let error = json["error"] as? String {
                                    await MainActor.run {
                                        onError(APIError.serverMessage(error))
                                    }
                                    return
                                }
                            }
                        }
                    }
                    
                    buffer = ""
                }
            }
            
            // Si llegamos aquí sin [DONE], igual completamos
            await MainActor.run { onComplete() }
            
        } catch {
            await MainActor.run { onError(error) }
        }
    }
}

// MARK: - Models

struct ChatMessage: Codable {
    let role: String  // "user" o "assistant"
    let content: String
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case serverMessage(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .serverError(let code):
            return "Error del servidor: \(code)"
        case .serverMessage(let message):
            return message
        }
    }
}
