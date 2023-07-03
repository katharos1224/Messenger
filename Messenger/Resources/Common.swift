//
//  Common.swift
//  SchoolUpTeacher
//
//  Created by Nguyễn Hà on 27/12/2022.
//

import Foundation
import UIKit

public func castToInt(_ data: Any?) -> Int {
    if let data = data as? Int {
        return data
    }
    return 0
}

public func castToString(_ data: Any?) -> String {
    if let data = data {
        return "\(data)"
    }
    return ""
}

public func castToBool(_ data: Any?) -> Bool {
    if let value = data {
        if let boolValue = value as? Bool {
            return boolValue
        }
    }
    return false
}
