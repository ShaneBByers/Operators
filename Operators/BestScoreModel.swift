//
//  BestScoreModel.swift
//  Operators
//
//  Created by Shane Byers on 12/9/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

class BestScoreModel {
    static let sharedInstance = BestScoreModel()
    
    var current : Int?
    
    var total : Int = 0
    
    var highScores : [String:Int] = [:]
    
    var bestScoreURL : URL
    
    var archive : BestScoreArchive
    
    init() {
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        bestScoreURL = documentURL.appendingPathComponent("originalHighScores.archive")
        
        let fileExists = fileManager.fileExists(atPath: bestScoreURL.path)
        
        if fileExists {
            archive = NSKeyedUnarchiver.unarchiveObject(withFile: bestScoreURL.path)! as! BestScoreArchive
            highScores = archive.scores
        } else {
            
            highScores[Difficulty.easy.rawValue] = 0
            highScores[Difficulty.medium.rawValue] = 0
            highScores[Difficulty.hard.rawValue] = 0
            highScores[Difficulty.random.rawValue] = 0
            
            archive = BestScoreArchive(highScores: highScores)
            NSKeyedArchiver.archiveRootObject(archive, toFile: bestScoreURL.path)
        }        
    }
    
    func updateScores(withEquation equation: Equation, withSolution solution: Int, forDifficulty difficulty: Difficulty) -> Int? {
        if let correctSolution = equation.solution.number {
            let percentageError = (Double(abs(correctSolution - solution)))/Double(abs(correctSolution) + 10)
            let newScore = Int(100 - ceil(percentageError*100))
            if let currentScore = current {
                if newScore >= 0 && newScore >= currentScore {
                    self.total -= self.current!
                    self.current = newScore
                    self.total += self.current!
                }
            } else {
                if newScore >= 0 {
                    self.current = newScore
                } else {
                    self.current = 0
                }
                self.total += self.current!
            }
        }
        
        if self.total > highScores[difficulty.rawValue]! {
            highScores[difficulty.rawValue] = self.total
            archive.scores = highScores
            saveArchive()
        }
        
        return current
    }
    
    func currentScore() -> Int? {
        return current
    }
    
    func resetCurrentScore() {
        current = nil
    }
    
    func totalScore() -> Int {
        return total
    }
    
    func resetTotalScore() {
        total = 0
    }
    
    func highScore(forDifficulty difficulty: Difficulty) -> Int {
        return highScores[difficulty.rawValue]!
    }
    
    func saveArchive() {
        NSKeyedArchiver.archiveRootObject(archive, toFile: bestScoreURL.path)
    }
}
