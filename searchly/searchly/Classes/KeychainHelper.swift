import Security
import Foundation

struct KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    /// Save data to Keychain
    /// - Parameters:
    ///   - key: The key under which data is stored
    ///   - data: The data to store
    func save(key: String, data: Data) {
        // Define query
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data
        ]
        
        // Add data to Keychain
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Read data from Keychain
    /// - Parameter key: The key under which data is stored
    /// - Returns: The data if found, else nil
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
    
    /// Delete data from Keychain
    /// - Parameter key: The key under which data is stored
    func delete(key: String) {
        // Define query
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        
        // Delete item from Keychain
        SecItemDelete(query as CFDictionary)
    }
}
