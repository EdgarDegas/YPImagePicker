//
//  YPMenuItem.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia

final class YPMenuItem: UIView {
    
    var textLabel = UILabel()
    var button = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    func setup() {
        backgroundColor = .clear
        
        sv(
            textLabel,
            button
        )
        
        textLabel.centerInContainer()
        |-(10)-textLabel-(10)-|
        button.fillContainer()
        
        textLabel.style { l in
            l.textAlignment = .center
            l.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
            l.textColor = YPConfig.colors.tintColor
            l.adjustsFontSizeToFitWidth = true
            l.numberOfLines = 2
        }
    }
    
    func selectedColor() -> UIColor {
        return YPImagePickerConfiguration.shared.bottomMenuItemSelectedColour
    }
    
    func unselectedColor() -> UIColor {
        return YPImagePickerConfiguration.shared.bottomMenuItemUnSelectedColour
    }
    
    func select() {
        textLabel.textColor = selectedColor()
    }
    
    func deselect() {
        textLabel.textColor = unselectedColor()
    }
}
