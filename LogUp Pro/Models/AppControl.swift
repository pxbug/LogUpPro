import Foundation

struct AppControlResponse: Codable {
    let status: Bool
    let data: AppControlData?
    let message: String?
}

struct AppControlData: Codable {
    let isEnabled: Bool
    let message: String
    let version: String
    let forceUpdate: Bool
    let updateUrl: String
    let trollStoreUrl: String
    
    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case message
        case version
        case forceUpdate = "force_update"
        case updateUrl = "update_url"
        case trollStoreUrl = "trollstore_url"
    }
}

class AppControl {
    static let shared = AppControl()
    private let baseUrl = "https://www.xn--fhq57lu5b.vip/api/app_control.php"
    
    func checkAppStatus() async throws -> AppControlResponse {
        guard let url = URL(string: baseUrl) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AppControlResponse.self, from: data)
        return response
    }
} 