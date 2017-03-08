//
//  Enumerations.swift
//  Operators
//
//  Created by Shane Byers on 12/2/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

enum Difficulty: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case random = "Random"
}

enum GameType {
    case original
    case challenge
    case timed
}

enum Hint: Double {
    case random = 0.1
    case custom = 0.2
    case uses = 0.15
}
