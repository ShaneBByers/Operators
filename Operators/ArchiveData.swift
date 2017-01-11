//
//  ArchiveData.swift
//  Operators
//
//  Created by Shane Byers on 12/11/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

struct ArchiveKey {
    static let easyPuzzlesAvailable = "easyPuzzlesAvailable"
    static let mediumPuzzlesAvailable = "mediumPuzzlesAvailable"
    static let hardPuzzlesAvailable = "hardPuzzlesAvailable"
    
}

class Archive : NSObject, NSCoding {
    var easyPuzzlesAvailable : [Bool]
    var mediumPuzzlesAvailable : [Bool]
    var hardPuzzlesAvailable : [Bool]
    init(easyPuzzles: [Bool], mediumPuzzles: [Bool], hardPuzzles: [Bool]) {
        self.easyPuzzlesAvailable = easyPuzzles
        self.mediumPuzzlesAvailable = mediumPuzzles
        self.hardPuzzlesAvailable = hardPuzzles
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let easy = aDecoder.decodeObject(forKey: ArchiveKey.easyPuzzlesAvailable) as! [Bool]
        let medium = aDecoder.decodeObject(forKey: ArchiveKey.mediumPuzzlesAvailable) as! [Bool]
        let hard = aDecoder.decodeObject(forKey: ArchiveKey.hardPuzzlesAvailable) as! [Bool]

        self.init(easyPuzzles: easy, mediumPuzzles: medium, hardPuzzles: hard)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(easyPuzzlesAvailable, forKey: ArchiveKey.easyPuzzlesAvailable)
        aCoder.encode(mediumPuzzlesAvailable, forKey: ArchiveKey.mediumPuzzlesAvailable)
        aCoder.encode(hardPuzzlesAvailable, forKey: ArchiveKey.hardPuzzlesAvailable)
        
    }
    
}
