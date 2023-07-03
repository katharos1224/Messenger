//
//  ServiceSettings.swift
//  Messenger
//
//  Created by Truong Nguyen Huu on 26/12/2022.
//

import Foundation

public class ServiceSettings {

    private struct Keys {
        static let accessToken = "KEY_ACCESS_TOKEN"
        static let userInfo = "KEY_USER_INFO"
    }

    public static var shared = ServiceSettings()
    private let userDefaults = UserDefaults.standard

    var accessToken: String? {
        get {
            return userDefaults.string(forKey: Keys.accessToken)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.accessToken)
            userDefaults.synchronize()
        }
    }

    var userInfo: UserObject? {
        get {
            userDefaults.loadCodableObject(forkey: Keys.userInfo)
        }
        set {
            userDefaults.storeCodableObject(newValue, forkey: Keys.userInfo)
        }
    }

}

class Constant {
    static var password: String?
}
