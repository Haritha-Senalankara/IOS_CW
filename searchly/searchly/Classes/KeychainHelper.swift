import Security
import Foundation

struct KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    
    func save(key: String, data: Data) {
        // Define query
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    
    func read(key: String) -> Data? {
        // Define query
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as? Data
        } else {
            print("Error reading Keychain: \(status)")
            return nil
        }
    }
    
    func delete(key: String) {
        // Define query
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
