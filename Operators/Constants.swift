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
    static var Divide = ""
    static let HyphenDots = "➗"
    static let Slash = "/"
    static let Equals = "="
    static let Wildcard = "✪"
}

class OperatorFunctions {
    static let Add : (Int, Int) -> Int = (+)
    static let Subtract : (Int, Int) -> Int = (-)
    static let Multiply : (Int, Int) -> Int = (*)
    static let Divide : (Int, Int) -> Int = (/)
    static let Equals : (Int, Int) -> Bool = (==)
}

class Fonts {
    static let wRhC = UIFont(name: "CourierNewPS-BoldMT", size: 50)
}

class Filenames {
    static let bestScore = "originalHighScores"
    static let timed = "timedHighScores"
    static let challenge = "challengePuzzles"
    static let settings = "settings"
}
