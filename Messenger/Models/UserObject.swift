//
//  UserObject.swift
//  Messenger
//
//  Created by Katharos on 18/12/2022.
//

import Foundation

class UserObject: Codable {
    var email: String?
    var name: String?
    var isUsingBiometricAuth: Bool = false
    var isSavedPass: Bool = false
    var isLogout: Bool = false
    
    init() {}

    init(email: String?, name: String?) {
        self.email = email
        self.name = name
    }
    
    init(email: String?, name: String?, isUsingBiometricAuth: Bool, isSavePass: Bool, isLogout: Bool) {
        self.email = email
        self.name = name
        self.isUsingBiometricAuth = isUsingBiometricAuth
        self.isSavedPass = isSavePass
        self.isLogout = isLogout

    }
    
    private enum CodingKeys: String, CodingKey {
        case email
        case name
        case isUsingBiometricAuth = "is_using_biometric_auth"
        case isSavedPass = "is_saved_pass"
        case isLogout = "is_logout"
    }
}

