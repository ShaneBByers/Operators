//
//  Constants.swift
//  Operators
//
//  Created by Shane Byers on 11/12/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit


class Symbols {
    static let Add = "➕"
    static let Subtract = "➖"
    static let Multiply = "✖️"
    static let Divide = "➗"
    static let Equals = "="
}

class OperatorFunctions {
    static let Add : (Int, Int) -> Int = (+)
    static let Subtract : (Int, Int) -> Int = (-)
    static let Multiply : (Int, Int) -> Int = (*)
    static let Divide : (Int, Int) -> Int = (/)
    static let Equals : (Int, Int) -> Bool = (==)
}

class Fonts {
    static let smallBold = UIFont(name: "CourierNewPS-BoldMT", size: 30)
    static let largeBold = UIFont(name: "CourierNewPS-BoldMT", size: 50)
    
    static let smallRegular = UIFont(name: "CourierNewPSMT", size: 30)
    static let largeRegular = UIFont(name: "CourierNewPSMT", size: 50)
    
}
