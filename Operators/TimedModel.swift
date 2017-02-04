//
//  TimedModel.swift
//  Operators
//
//  Created by Shane Byers on 12/10/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

class TimedModel {
    static let sharedInstance = TimedModel()
    
    var difficulty : Difficulty?
    
    var totalTime : TimeInterval?
    
    var currentTime : TimeInterval?
    
    let timeOptions : [TimeInterval]
    
    var completed : Int
    
    var solution : Int?
    
    var current : Int?
    
    var totalScore : Int = 0
    
    init() {
        timeOptions = [30, 61, 121, 301]
        completed = 0
    }
    
    func initialize(withDifficulty diff: String, withTime time: String) {
        switch time {
        case "30 sec": totalTime = timeOptions[0]
        case "1 min": totalTime = timeOptions[1]
        case "2 min": totalTime = timeOptions[2]
        case "5 min": totalTime = timeOptions[3]
        default: totalTime = timeOptions[0]
        }
        
        currentTime = totalTime!
        
        difficulty = Difficulty(rawValue: diff)
    }
    
    func remainingTime(timeElapsed elapsed: TimeInterval) -> TimeInterval? {
        
        currentTime = round((currentTime! - elapsed)*10)/10
        
        if currentTime! > 0.0 {
            return currentTime
        } else {
            return nil
        }
    }
    
    func remainingMinutesSeconds(timeElapsed elapsed: TimeInterval) -> String? {
        if let remaining = remainingTime(timeElapsed: elapsed) {
            let minutes = Int(remaining)/60
            if minutes > 0 {
                let seconds = Int(remaining - (Double(minutes)*60.0))
                if seconds < 10 {
                    return "\(minutes):0\(seconds)"
                } else {
                    return "\(minutes):\(seconds)"
                }
            } else {
                return String(remaining)
            }
        } else {
            return nil
        }
    }
    
    func completePuzzle() {
        completed += 1
        solution = nil
    }
    
    func completedPuzzles() -> Int {
        return completed
    }
    
    func updateSolution(solution sol: Int) {
        solution = sol
    }
    
    func currentSolution() -> Int {
        return solution!
    }
    
    func restart() {
        totalScore = 0
        completed = 0
        currentTime = totalTime!
        solution = nil
    }
    
    func updateScore(withEquation equation: Equation, withSolution solution: Int) {
        if let correctSolution = equation.solution.number {
            let percentageError = (Double(abs(correctSolution - solution)))/Double(abs(correctSolution) + 10)
            let newScore = Int(100 - ceil(percentageError*100))
            if let currentScore = current {
                if newScore >= 0 && newScore >= currentScore {
                    self.totalScore -= self.current!
                    self.current = newScore
                    self.totalScore += self.current!
                }
            } else {
                if newScore >= 0 {
                    self.current = newScore
                } else {
                    self.current = 0
                }
                self.totalScore += self.current!
            }
        }
    }
    
    func score() -> Int {
        return totalScore
    }
    
    func resetCurrentScore() {
        current = nil
    }
}
