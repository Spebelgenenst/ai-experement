import Foundation

/// MAIN APP:

await AI_ExperimentApp.main.run()

struct AI_ExperimentApp {
    private init() {}
    static let main = AI_ExperimentApp()
    
    func run() async {
        do {
            let prompt = try getPrompt()
            let credentials = try getCredentials()
            
            print("Enter the Message to Send: ")
            let messageString = readLine() ?? "Nothing provided"
            
            let webhook = WebHook(content: messageString, files: [
                // Add File URL's here
            ], username: "Uwu dc bot :3", embeds: [
                WebHook.Embed(title: "Embed Title", description: "Embed Description")
            ])
            let webhookSender = WebHookSender(webhookURL: credentials.discordWebHook)
            try await webhookSender.send(webhook)
        } catch {
            print("--- ERROR OCCURED ---")
            print(error.localizedDescription)
        }
    }
    func getCredentials() throws -> Credentials {
        let credentialsURL = Bundle.module.url(forResource: "credentials", withExtension: "json")!
        let credentialsData = try Data(contentsOf: credentialsURL)
        return try JSONDecoder().decode(Credentials.self, from: credentialsData)
    }
    func getPrompt() throws -> String {
        let promptURL = Bundle.module.url(forResource: "prompt", withExtension: "md")!
        print(promptURL)
        return try String(contentsOf: promptURL, encoding: .utf8)
    }
}


/// MODELS AND CLASSES:

struct Credentials: Codable {
    var geminiApiKey: String
    var discordWebHook: URL
}

class WebHookSender {
    init(webhookURL: URL) {
        self.webhookURL = webhookURL
    }
    var webhookURL: URL
    
    func send(_ content: WebHook) async throws {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        var payload = [String: Any]()
        
        if let content = content.content {
            payload["content"] = content
        }
        if let username = content.username {
            payload["username"] = username
        }
        
        if let avatar = content.avatarURL {
            payload["avatar_url"] = avatar.absoluteString
        }
        
        if let embeds = content.embeds {
            let encoder = JSONEncoder()
            let embedData = try encoder.encode(embeds)
            let embedJson = try JSONSerialization.jsonObject(with: embedData)
            payload["embeds"] = embedJson
        }
        
        let payloadData = try JSONSerialization.data(withJSONObject: payload)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"payload_json\"\r\n\r\n".data(using: .utf8)!)
        body.append(payloadData)
        body.append("\r\n".data(using: .utf8)!)
        
        // add files
        for (index, fileURL) in content.files.enumerated() {
            let fileData = try Data(contentsOf: fileURL)
            let filename = fileURL.lastPathComponent
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files[\(index)]\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        if let string = String(data: responseData, encoding: .utf8) {
            print(string)
        }
    }
}

struct WebHook {
    var content: String?
    var files: [URL]
    var avatarURL: URL?
    var username: String?
    var embeds: [Embed]?
    
    struct Embed: Codable {
        var title: String?
        var description: String?
        var url: String?
        var color: Int?
        var timestamp: String?
        var author: Author?
        var footer: Footer?
        var fields: [Field]?
        
        struct Author: Codable {
            var name: String?
            var url: String?
            var icon_url: String?
        }
        
        struct Footer: Codable {
            var text: String?
            var icon_url: String?
        }
        
        struct Field: Codable {
            var name: String
            var value: String
            var inline: Bool?
        }
    }
}
