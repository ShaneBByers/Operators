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
    
    var current : TimeInterval?
    
    let timeOptions : [TimeInterval]
    
    var completed : Int
    
    var solution : Int?
    
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
        
        current = totalTime!
        
        difficulty = Difficulty(rawValue: diff)
    }
    
    func remainingTime(timeElapsed elapsed: TimeInterval) -> TimeInterval? {
        
        current = round((current! - elapsed)*10)/10
        
        if current! > 0.0 {
            return current
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
        completed = 0
        current = totalTime!
        solution = nil
    }
}
