import Foundation

class StreamingChatAPI {
//    private let baseURL = "http://localhost:3000"  // ← Local
    private let baseURL = "https://buky-smart-stories.vercel.app"
    
    func streamMessage(
        _ story: Story,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) async {
        
        guard let url = URL(string: "\(baseURL)/api/hello") else {
            await MainActor.run { onError(APIError.invalidURL) }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("utf-8", forHTTPHeaderField: "Accept-Charset")
        request.timeoutInterval = 60
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(story)
            request.httpBody = jsonData
        } catch {
            await MainActor.run { onError(error) }
            return
        }
        
        // Hacer request con streaming
        do {
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { onError(APIError.invalidResponse) }
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                await MainActor.run { onError(APIError.serverError(httpResponse.statusCode)) }
                return
            }
            
            // ✅ CAMBIO CLAVE: Usar Data buffer en lugar de String
            var dataBuffer = Data()
            
            // Leer bytes y acumular
            for try await byte in bytes {
                dataBuffer.append(byte)
                
                // ✅ CAMBIO CLAVE: Intentar decodificar como UTF-8
                guard let currentString = String(data: dataBuffer, encoding: .utf8) else {
                    // Si no se puede decodificar, seguir acumulando bytes
                    // (podemos estar en medio de un carácter multi-byte)
                    continue
                }
                
                // Detectar fin de mensaje SSE (doble newline)
                if currentString.contains("\n\n") {
                    let parts = currentString.components(separatedBy: "\n\n")
                    
                    // Procesar todas las partes completas (excepto la última que puede estar incompleta)
                    for i in 0..<(parts.count - 1) {
                        let part = parts[i]
                        
                        if part.hasPrefix("data: ") {
                            let jsonString = part.replacingOccurrences(of: "data: ", with: "")
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Check si terminó
                            if jsonString == "[DONE]" {
                                await MainActor.run { onComplete() }
                                return
                            }
                            
                            // Parse JSON
                            if let jsonData = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                
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
                    
                    // ✅ CAMBIO CLAVE: Mantener la última parte como nuevo buffer
                    if let lastPart = parts.last, !lastPart.isEmpty {
                        dataBuffer = Data(lastPart.utf8)
                    } else {
                        dataBuffer = Data()
                    }
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
