//
//  UIView+Extension.swift
//  AppPit
//
//  Created by Nguyễn Hà on 01/08/2022.
//

import Foundation
import UIKit

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set(value) {
            layer.cornerRadius = value
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set(value) {
            layer.borderWidth = value
        }
    }

    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set(value) {
            layer.borderColor = value.cgColor
        }
    }

    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }

    /* The opacity of the shadow. Defaults to 0. Specifying a value outside the [0,1]
     range will give undefined results. Animatable. */
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }

    /// The shadow offset. Defaults to (0, -3). Animatable.
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }

    /// The blur radius used to create the shadow. Defaults to 3. Animatable.
    @IBInspectable var shadowRadius: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }

    func roundCorners(cornerRadius: CACornerMask, radius: CGFloat) {
        clipsToBounds = true
        if #available(iOS 11.0, *) {
            self.layer.cornerRadius = 10
            self.layer.maskedCorners = cornerRadius
        }
     }

    func roundCorners(corners: UIRectCorner, radius: CGFloat, bound: CGRect?) {
        guard let bound = bound else {return}
        let path = UIBezierPath(roundedRect: bound, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        // setup MASK
        self.layer.mask = nil
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bound
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer

        // setup Border for Mask
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = 0.5
        borderLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bound
        self.layer.addSublayer(borderLayer)
    }

}

extension UIButton {
    func titleForState(_ state: UIControl.State = .normal) -> String? {
        if let title = self.title(for: state) {
            return title
        }

        if let attribTitle = self.attributedTitle(for: state) {
            return attribTitle.string
        }

        return nil
    }
}
