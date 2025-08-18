//
//  KeychainManager.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 30/07/25.
//

import Security
import Foundation

class KeychainManager {
    static let shared = KeychainManager()

    func saveCredential(service: String, account: String, password: String) -> Bool {
        let passwordData = password.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData,
            kSecAttrAccessGroup as String: "27A2DW4KWX.com.allcaps.AllCapabilitiesDemo"
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain Error Code: \(status)")
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                print("Error Message: \(errorMessage)")
            }
        } else {
            print("Credential saved: service=\(service), account=\(account)")
        }
        return status == errSecSuccess
    }

    func getPassword(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: "27A2DW4KWX.com.allcaps.AllCapabilitiesDemo"
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            print("Keychain Get Error: \(status)")
            return nil
        }
        let password = String(data: data, encoding: .utf8)
        print("Retrieved password for \(account): \(password ?? "nil")")
        return password
    }

    func getAllAccounts(service: String) -> [String]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecAttrAccessGroup as String: "27A2DW4KWX.com.allcaps.AllCapabilitiesDemo"
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let items = item as? [[String: Any]] else {
            print("Keychain Get Accounts Error: \(status)")
            return nil
        }
        let accounts = items.compactMap { $0[kSecAttrAccount as String] as? String }
        print("Retrieved accounts for \(service): \(accounts)")
        return accounts
    }
}
