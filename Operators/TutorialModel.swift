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
    
    private let hintsModel = HintsModel.sharedInstance
    
    private var equations : [[String]] = []
    
    private var currentEquation : Equation?
    
    private var puzzle : Int = 0
    
    private var step : Int = 0
    
    private let scoreBooster : Int = 10
    
    private let maxScore : Double = 100
    
    private var currentScoreValue : Int? = 0
    
    private var totalScoreValue : Int = 0
    
    private var pointsMultipliers = [(range: CountableRange<Int>, multiplier: Double)]()
    
    private var pointsMultiplier = (range: 0..<180, multiplier: 1.0)
    
    init() {
        
        pointsMultipliers.append((range: 0..<180, multiplier: 1.0))
        pointsMultipliers.append((range: 0..<1000, multiplier: 2.0))
        pointsMultipliers.append((range: 0..<2000, multiplier: 5.0))
        
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
                self.currentScoreValue = newScore
            } else {
                self.currentScoreValue = 0
            }
            self.totalScoreValue += self.currentScoreValue!
        }
    }
    
    func getTotalScore() -> Int {
        return totalScoreValue
    }
    
    func puzzleComplete() {
        step = 0
        
        puzzle += 1
        
        resetCurrentScore()
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
    
    func updateScores(withEquation equation: Equation, withSolution solution: Int) -> Int? {
        if let correctSolution = equation.solution.number {
            let hintsMultiplier = hintsModel.multiplier()
            let percentageError = (Double(abs(correctSolution - solution)))/Double(abs(correctSolution) + scoreBooster)
            let newScore = Int(round(maxScore*hintsMultiplier*pointsMultiplier.multiplier - ceil(percentageError*maxScore*hintsMultiplier*pointsMultiplier.multiplier)))
            if let currentScore = currentScoreValue {
                let addedScore = Int(round(Double(newScore - currentScore)))
                if addedScore > 0 {
                    self.currentScoreValue! += addedScore
                    self.totalScoreValue += addedScore
                }
            } else {
                let addedScore = Int(round(Double(newScore)))
                if addedScore >= 0 {
                    self.currentScoreValue = newScore
                } else {
                    self.currentScoreValue = 0
                }
                self.totalScoreValue += self.currentScoreValue!
            }
        }
        
        for pointMult in pointsMultipliers {
            if pointMult.range ~= self.totalScoreValue {
                pointsMultiplier = pointMult
                break
            }
        }
        
        return currentScoreValue
    }
    
    func multiplierProgress() -> Float {
        let lower = pointsMultiplier.range.lowerBound
        let upper = pointsMultiplier.range.upperBound
        if upper == Int.max {
            return 1.00
        } else {
            return Float(self.totalScoreValue-lower)/Float(upper-lower)
        }
    }
    
    func currentPointsMultiplier() -> Int {
        return Int(pointsMultiplier.multiplier)
    }
    
    func nextPointsMultiplier() -> Int? {
        for (i,pointMult) in pointsMultipliers.enumerated() {
            if pointMult == pointsMultiplier {
                if i+1 < pointsMultipliers.count {
                    return Int(pointsMultipliers[i+1].multiplier)
                }
                break
            }
        }
        return nil
    }
    
    func currentScore() -> Int? {
        return currentScoreValue
    }
    
    func resetCurrentScore() {
        currentScoreValue = nil
    }
    
    func totalScore() -> Int {
        return totalScoreValue
    }
    
    func resetTotalScore() {
        totalScoreValue = 0
    }
}
