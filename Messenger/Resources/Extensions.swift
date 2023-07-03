//
//  Extensions.swift
//  Messenger
//
//  Created by Katharos on 16/11/2022.
//

import Foundation
import UIKit

extension UIView {
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.height + frame.origin.y
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.width + frame.origin.x
    }
}
extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogInNotification")
}

extension UserDefaults {
    func storeCodableObject<T>(_ object: T, forkey: String) where T: Codable {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: forkey)
        }
    }

    func loadCodableObject<T>(forkey: String) -> T? where T: Codable {
        if let data = self.data(forKey: forkey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(T.self, from: data)
        }
        return nil
    }
}

extension UIColor {
    
    static let primaryColor = UIColor.color(named: "primary_color")
    
    private static func color(named: String) -> UIColor {
        return UIColor(named: named) ?? UIColor.black
    }
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
