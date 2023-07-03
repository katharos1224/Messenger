//
//  DefaultButton.swift
//  SchoolUpTeacher
//
//  Created by Nguyễn Hà on 27/12/2022.
//

import UIKit

class DefaultButton: UIButton {

    @IBInspectable
    var typeThin: Bool = false

    @IBInspectable
    var isEnabledInteraction: Bool = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configUI()
    }
    
    private func configUI() {
        self.layer.cornerRadius = self.frame.height / 2
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        if typeThin {
            self.setTitleColor(UIColor.primaryColor, for: .normal)
            self.backgroundColor = .clear
        } else {
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = UIColor.primaryColor
            self.isUserInteractionEnabled = isEnabledInteraction
        }
    }

    private func updateLayerProperties() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3.0
        self.layer.masksToBounds = false
    }
}
