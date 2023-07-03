//
//  PasswordManager.swift
//  Messenger
//
//  Created by Truong Nguyen Huu on 31/12/2022.
//

//import Foundation
//
//final class PasswordManager {
//    static func getPassword(for account: String, server: String) -> Data? {
////        guard let data =
//        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
//                                    kSecAttrAccount as String: account,
//                                    kSecReturnData as String: kCFBooleanTrue,
//                                    kSecAttrServer as String: server]
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        return result as? Data
//
//    }
//
//    static func get(for account: String, server: String) -> String? {
//        guard let data = getPassword(for: account, server: server) else {
//            return nil
//        }
//        let password = String(decoding: data, as: UTF8.self)
//        return password
//    }
//
//    static func save(_ password: String, for account: String, server: String) {
//        let password = password.data(using: String.Encoding.utf8)!
//        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
//                                    kSecAttrAccount as String: account,
//                                    kSecValueData as String: password,
//                                    kSecAttrServer as String: server]
//        let status = SecItemAdd(query as CFDictionary, nil)
//        guard status == errSecSuccess else { return print("save error") }
//    }
//}

import Security
import UIKit

class KeyChain {

    class func save(key: String, data: Data) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)
    }

    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}

extension Data {

    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
