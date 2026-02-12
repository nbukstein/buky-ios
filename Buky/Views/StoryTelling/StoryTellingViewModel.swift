//
//  CreateStoryViewModel.swift
//  Buky
//
//  Created by Nicolas Bukstein on 5/2/26.
//

import SwiftUI

final class StoryTellingViewModel: ObservableObject {
    @Published var story: Story
    @Published var text: String = ""
    
    @Published var storyBody = ""
    @Published var storyTitle = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var storyText = "" {
        didSet {
            storyBody = bodyForStory(from: storyText)
            storyTitle = titleForStory(storyText)
        }
    }
    
    init(story: Story) {
        self.story = story
    }
    
    @MainActor
    func onAppear() async {
        guard let url = URL(string: "https://buky-smart-stories.vercel.app/api/hello") else { return }
        
        // 1. Configurar la URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2. Definir el cuerpo (Body)
        
//        
//        do {
//            let jsonEncoder = JSONEncoder()
//            let jsonData = try jsonEncoder.encode(story)
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print(jsonString)
//            }
//        } catch {
//            print("Error encoding object: \(error)")
//        }
//        let body: [String: Any] = ["characters": "animals",
//                                   "place": "castlle",
//                                   "language": "Spanish",
//                                   "duration": "10  min",
//                                   "age": "2-4",
//                                   "lesson": "empathy"]
//        
        
        isLoading = true
        storyText = ""
        
        do {
            // 3. Usar bytes(for:) para manejar el stream con un POST
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try jsonEncoder.encode(story)
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            
            // Validar respuesta básica
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                storyText = "Error del servidor."
                return
            }
            
            // 4. Iterar sobre las líneas a medida que llegan
            for try await line in bytes.lines {
                // Aquí puedes limpiar prefijos como "data: " si usas SSE
                let cleanLine = line.replacingOccurrences(of: "data: ", with: "")
                
                if !cleanLine.isEmpty {
                    withAnimation(.linear(duration: 0.1)) {
                        storyText += "\(cleanLine)\n\n"
                    }
                    isLoading = false
                    print(cleanLine)
                }
            }
        } catch {
            storyText = "Error de conexión: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func saveStory() {
        
    }
    
    
    private func bodyForStory(from inputString: String) -> String {
        // The pattern \\[.*?\\] matches:
        // \\[: A literal opening square bracket.
        // .*: Any character (except newline).
        // ?: Makes the match non-greedy (stops at the first closing bracket).
        // \\]: A literal closing square bracket.
        let pattern = "\\[.*?\\]"
        
        return inputString.replacingOccurrences(
            of: pattern,
            with: "",
            options: .regularExpression
        )
    }

    private func titleForStory(_ text: String) -> String {
        let pattern = #"\[(.*?)\]"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            
            // Obtenemos el rango del primer grupo de captura (índice 1)
            if let range = Range(match.range(at: 1), in: text) {
               return String(text[range])
            }
        }
        return ""
    }

}
