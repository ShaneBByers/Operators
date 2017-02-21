//
//  ArchiveData.swift
//  Operators
//
//  Created by Shane Byers on 12/11/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

struct ArchiveKey {
    static let availablePuzzles = "availablePuzzles"
    static let originalHighScores = "originalHighScores"
    static let timedHighScores = "timedHighScores"
    static let divisionSymbol = "divisionSymbol"
    static let colorScheme = "colorScheme"
}

class ChallengeArchive : NSObject, NSCoding {
    var availablePuzzles : [String:[Bool]]
    init(availablePuzzles : [String:[Bool]]) {
        self.availablePuzzles = availablePuzzles
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let puzzles = aDecoder.decodeObject(forKey: ArchiveKey.availablePuzzles) as! [String:[Bool]]
        self.init(availablePuzzles : puzzles)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(availablePuzzles, forKey: ArchiveKey.availablePuzzles)
    }
    
}

class BestScoreArchive : NSObject, NSCoding {
    var scores : [String:Int]
    
    init(highScores: [String:Int]) {
        self.scores = highScores
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let highScores = aDecoder.decodeObject(forKey: ArchiveKey.originalHighScores) as! [String:Int]
        
        self.init(highScores: highScores)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(scores, forKey: ArchiveKey.originalHighScores)
    }
}

class TimedArchive : NSObject, NSCoding {
    var scores : [String:[Int:Int]]
    
    init(highScores: [String:[Int:Int]]) {
        self.scores = highScores
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let highScores = aDecoder.decodeObject(forKey: ArchiveKey.timedHighScores) as! [String:[Int:Int]]
        
        self.init(highScores: highScores)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(scores, forKey: ArchiveKey.timedHighScores)
    }
}

class SettingsArchive : NSObject, NSCoding {
    var divisionSymbol : String
    var colorScheme : String
    
    init(divisionSymbol : String, colorScheme: String) {
        self.divisionSymbol = divisionSymbol
        self.colorScheme = colorScheme
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let symbol = aDecoder.decodeObject(forKey: ArchiveKey.divisionSymbol) as! String
        let scheme = aDecoder.decodeObject(forKey: ArchiveKey.colorScheme) as! String
        
        self.init(divisionSymbol: symbol, colorScheme: scheme)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(divisionSymbol, forKey: ArchiveKey.divisionSymbol)
        aCoder.encode(colorScheme, forKey: ArchiveKey.colorScheme)
    }
}
