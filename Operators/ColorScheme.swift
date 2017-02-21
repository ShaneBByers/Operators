//
//  ColorScheme.swift
//  Operators
//
//  Created by Shane Byers on 2/21/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import Foundation
import UIKit

struct ColorElements {
    let backgroundColor : UIColor
    let buttonColor : UIColor
    let labelColor : UIColor
}

class SchemeElements {
    static let monochrome = ColorElements(backgroundColor: .darkGray, buttonColor: .green, labelColor: .black)
    static let ocean = ColorElements(backgroundColor: UIColor(red: 50.0/255.0, green: 210.0/255.0, blue: 200.0/255.0, alpha: 1.0), buttonColor: UIColor(red: 75.0/255.0, green: 40.0/255.0, blue: 255.0/255.0, alpha: 1.0), labelColor: UIColor(red: 30.0/255.0, green: 150.0/255.0, blue: 50.0/255.0, alpha: 1.0))
    static let daybreak = ColorElements(backgroundColor: UIColor(red: 255.0/255.0, green: 175.0/255.0, blue: 40.0/255.0, alpha: 1.0), buttonColor: .yellow, labelColor: .red)
}

enum SchemeChoice : String {
    case monochrome = "Monochrome"
    case ocean = "Ocean"
    case daybreak = "Daybreak"
}

class ColorScheme {
    static var scheme : SchemeChoice = .monochrome
    
    static func updateScheme(forView view: UIView) {
        let elements : ColorElements
        switch scheme {
        case .monochrome: elements = SchemeElements.monochrome
        case .ocean: elements = SchemeElements.ocean
        case .daybreak: elements = SchemeElements.daybreak
        }
        for subview in view.subviews {
            let label = subview as? UILabel
            if let label = label {
                label.textColor = elements.labelColor
            }
            let button = subview as? UIButton
            if let button = button {
                button.tintColor = elements.buttonColor
            }
        }
        view.backgroundColor = elements.backgroundColor
    }
}
