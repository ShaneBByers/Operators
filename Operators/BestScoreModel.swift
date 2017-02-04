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
    
    func updateScores(withEquation equation: Equation, withSolution solution: Int) -> Int? {
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
}
