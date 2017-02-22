//
//  ChallengeModel.swift
//  Operators
//
//  Created by Shane Byers on 12/3/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

class ChallengeModel {
    static let sharedInstance = ChallengeModel()
    
    var availablePuzzles : [String:[Bool]] = [:]
    
    var equations : [Difficulty:[[String]]] = [:]
    
    let kNumberOfPuzzles = 25
    
    var currentEquation : Equation?
    
    var currentIndex : Int?
    
    var difficulty : Difficulty = .easy
    
    var challengeURL : URL
    
    var archive : ChallengeArchive
    
    init() {

        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        challengeURL = documentURL.appendingPathComponent(Filenames.challenge + ".archive")
        
        let fileExists = fileManager.fileExists(atPath: challengeURL.path)
        
        if fileExists {
            
            archive = NSKeyedUnarchiver.unarchiveObject(withFile: challengeURL.path)! as! ChallengeArchive
            availablePuzzles = archive.availablePuzzles
            
        } else {
            
            availablePuzzles[Difficulty.easy.rawValue] = []
            
            availablePuzzles[Difficulty.medium.rawValue] = []
            
            availablePuzzles[Difficulty.hard.rawValue] = []
            
            for _ in 0..<kNumberOfPuzzles {
                availablePuzzles[Difficulty.easy.rawValue]!.append(false)
                availablePuzzles[Difficulty.medium.rawValue]!.append(false)
                availablePuzzles[Difficulty.hard.rawValue]!.append(false)
            }
            
            availablePuzzles[Difficulty.easy.rawValue]![0] = true
            
            archive = ChallengeArchive(availablePuzzles: availablePuzzles)
            NSKeyedArchiver.archiveRootObject(archive, toFile: challengeURL.path)
        }
        
        if let path = Bundle.main.path(forResource: Filenames.challenge, ofType: "plist") {
            
            if let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] {
                equations[.easy] = dictionary[Difficulty.easy.rawValue] as? [[String]]
                equations[.medium] = dictionary[Difficulty.medium.rawValue] as? [[String]]
                equations[.hard] = dictionary[Difficulty.hard.rawValue] as? [[String]]
            }
        }
    }
    
    func equationAtIndex(index: Int) -> Equation {
        let equationStrings = equations[difficulty]![index]
        
        var expression : [Element] = []
        
        for string in equationStrings {
            expression.append(Element(string))
        }
        
        let solution = expression.popLast()!
        
        let equation = Equation(elements: expression, solution: solution)
        
        currentEquation = equation
        
        currentIndex = index
        
        return equation

    }
    
    func puzzleAvailableAt(index: Int) -> Bool {
        archive = NSKeyedUnarchiver.unarchiveObject(withFile: challengeURL.path)! as! ChallengeArchive
        availablePuzzles = archive.availablePuzzles
        return availablePuzzles[difficulty.rawValue]![index]
    }
    
    func puzzleAtIndex(index: Int) -> [String] {
        return equations[difficulty]![index]
    }
    
    func numberOfPuzzles() -> Int {
        return kNumberOfPuzzles
    }
    
    func currentSolution() -> Int {
        return currentEquation!.solution.number!
    }
    
    func currentPuzzleNumber() -> Int {
        return currentIndex! + 1
    }
    
    func completeCurrentPuzzle() {
        if currentIndex! + 1 < kNumberOfPuzzles {
            availablePuzzles[difficulty.rawValue]![currentIndex! + 1] = true
            archive.availablePuzzles[difficulty.rawValue]![currentIndex! + 1] = true
        } else {
            switch difficulty {
            case .easy:
                changeDifficulty(toDifficulty: .medium)
            case .medium:
                changeDifficulty(toDifficulty: .hard)
            case .hard: break
            case .random: break
            }
            availablePuzzles[difficulty.rawValue]![0] = true
            archive.availablePuzzles[difficulty.rawValue]![0] = true
        }
        
        saveArchive()
    }
    
    func nextEquation() -> Equation {
        currentIndex! += 1
        return equationAtIndex(index: currentIndex!)
    }
    
    func setDifficulty(difficulty diff: Difficulty) -> Bool {
        if difficulty == diff {
            return false
        } else {
            difficulty = diff
            return true
        }
    }
    
    func hasNextPuzzle() -> Bool {
        return currentIndex! != -1 && currentIndex! + 1 < kNumberOfPuzzles
    }
    
    func changeDifficulty(toDifficulty diff: Difficulty) {
        difficulty = diff
        currentIndex = -1
    }
    
    func saveArchive() {
        NSKeyedArchiver.archiveRootObject(archive, toFile: challengeURL.path)
    }
}
