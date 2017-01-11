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
    
    var availablePuzzles : [Difficulty:[Bool]] = [:]
    
    var equations : [Difficulty:[[String]]] = [:]
    
    let kNumberOfPuzzles = 25
    
    let plistName = "challengePuzzles"
    
    var currentEquation : Equation?
    
    var currentIndex : Int?
    
    var difficulty : Difficulty = .easy
    
    var challengeURL : URL
    
    var archive : Archive
    
    init() {

        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        challengeURL = documentURL.appendingPathComponent(plistName + ".archive")
        
        let fileExists = fileManager.fileExists(atPath: challengeURL.path)
        
        if fileExists {
            
            archive = NSKeyedUnarchiver.unarchiveObject(withFile: challengeURL.path)! as! Archive
            availablePuzzles[.easy] = archive.easyPuzzlesAvailable
            availablePuzzles[.medium] = archive.mediumPuzzlesAvailable
            availablePuzzles[.hard] = archive.hardPuzzlesAvailable
            
        } else {
            
            availablePuzzles[.easy] = []
            
            availablePuzzles[.medium] = []
            
            availablePuzzles[.hard] = []
            
            for _ in 0..<kNumberOfPuzzles {
                availablePuzzles[.easy]!.append(true)
                availablePuzzles[.medium]!.append(false)
                availablePuzzles[.hard]!.append(false)
            }
            
            availablePuzzles[.easy]![24] = false
            
            archive = Archive(easyPuzzles: availablePuzzles[.easy]!, mediumPuzzles: availablePuzzles[.medium]!, hardPuzzles: availablePuzzles[.hard]!)
            NSKeyedArchiver.archiveRootObject(archive, toFile: challengeURL.path)
        }
        
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
            
            if let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] {
                let easyEquations = dictionary["easy"] as! [[String]]
                let mediumEquations = dictionary["medium"] as! [[String]]
                let hardEquations = dictionary["hard"] as! [[String]]
                equations[.easy] = easyEquations
                equations[.medium] = mediumEquations
                equations[.hard] = hardEquations
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
        return availablePuzzles[difficulty]![index]
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
            availablePuzzles[difficulty]![currentIndex! + 1] = true
            switch difficulty {
            case .easy: archive.easyPuzzlesAvailable[currentIndex! + 1] = true
            case .medium: archive.mediumPuzzlesAvailable[currentIndex! + 1] = true
            case .hard: archive.hardPuzzlesAvailable[currentIndex! + 1] = true
            }
        } else {
            switch difficulty {
            case .easy:
                changeDifficulty(toDifficulty: .medium)
            case .medium:
                changeDifficulty(toDifficulty: .hard)
            case .hard: break
            }
            availablePuzzles[difficulty]![0] = true
            switch difficulty {
            case .easy: archive.easyPuzzlesAvailable[0] = true
            case .medium: archive.mediumPuzzlesAvailable[0] = true
            case .hard: archive.hardPuzzlesAvailable[0] = true
            }
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
