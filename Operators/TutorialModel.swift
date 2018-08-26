//
//  TutorialModel.swift
//  Operators
//
//  Created by Shane Byers on 4/26/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import Foundation

class TutorialModel {
    static let sharedInstance = TutorialModel()
    
    private var equations : [[String]] = []
    
    private var currentEquation : Equation?
    
    private var puzzle : Int = 0
    
    private var step : Int = 0
    
    private let scoreBooster : Int = 10
    
    private let maxScore : Double = 100
    
    private var currentScore : Int = 0
    
    private var totalScore : Int = 0
    
    private var pointsMultiplier = (range: 0..<200, multiplier: 1.0)
    
    init() {
        
        if let path = Bundle.main.path(forResource: Filenames.tutorial, ofType: "plist") {
            
            if let puzzles = NSArray(contentsOfFile: path) as? [Any] {
                for puzzle in puzzles {
                    equations.append(puzzle as! [String])
                }
            }
        }
    }
    
    func getCurrentPuzzle() -> Equation {
        let equationStrings = equations[puzzle]
        
        var expression : [Element] = []
        
        for string in equationStrings {
            expression.append(Element(string))
        }
        
        let solution = expression.popLast()!
        
        let equation = Equation(elements: expression, solution: solution)
        
        currentEquation = equation
        
        return equation
    }
    
    func updateTotalScore(withSolution solution: Int) {
        if let correctSolution = currentEquation!.solution.number {
            let percentageError = (Double(abs(correctSolution - solution)))/Double(abs(correctSolution) + scoreBooster)
            let newScore = Int(round(maxScore-ceil(percentageError*maxScore)))
            let addedScore = Int(round(Double(newScore)))
            if addedScore >= 0 {
                self.currentScore = newScore
            } else {
                self.currentScore = 0
            }
            self.totalScore += self.currentScore
        }
    }
    
    func getTotalScore() -> Int {
        return totalScore
    }
    
    func puzzleComplete() {
        step = 0
        
        puzzle += 1
    }
    
    func currentSolution() -> Int {
        return currentEquation!.solution.number!
    }
    
    func nextStep() {
        step += 1
    }
    
    func puzzleNumber() -> Int {
        return puzzle + 1
    }
    
    func stepNumber() -> Int {
        return step
    }
    
    func status(isPuzzle puzzleNo: Int, isStep stepNo: Int) -> Bool {
        return puzzle + 1 == puzzleNo && step == stepNo
    }
    
    func multiplierProgress() -> Float {
        let lower = pointsMultiplier.range.lowerBound
        let upper = pointsMultiplier.range.upperBound
        if upper == Int.max {
            return 1.00
        } else {
            return Float(self.totalScore-lower)/Float(upper-lower)
        }
    }
    
    func currentPointsMultiplier() -> Int {
        return Int(pointsMultiplier.multiplier)
    }
    
    func nextPointsMultiplier() -> Int? {
        if pointsMultiplier.multiplier == 1.0 {
            return 2
        } else {
            return nil
        }
    }
    
    func increasePointsMultiplier() {
        pointsMultiplier.multiplier = 2.0
    }
}
