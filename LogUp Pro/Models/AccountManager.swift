import Foundation

class AccountManager {
    static let shared = AccountManager()
    
    private init() {}
    
    func saveOriginalInput(_ input: String) {
        let account = SavedAccount(originalInput: input, timestamp: Date())
        var savedAccounts = loadSavedAccounts()
        savedAccounts.append(account)
        saveSavedAccounts(savedAccounts)
    }
    
    private func loadSavedAccounts() -> [SavedAccount] {
        if let data = UserDefaults.standard.data(forKey: "savedOriginalAccounts"),
           let decoded = try? JSONDecoder().decode([SavedAccount].self, from: data) {
            return decoded
        }
        return []
    }
    
    private func saveSavedAccounts(_ accounts: [SavedAccount]) {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: "savedOriginalAccounts")
        }
    }
} 