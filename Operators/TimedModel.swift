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
    
    public var difficulty : Difficulty?
    
    public var totalTime : TimeInterval?
    
    public var currentTime : TimeInterval?
    
    private let timeOptions : [TimeInterval]
    
    private var completed : Int
    
    private var solution : Int?
    
    private var current : Int?
    
    private var totalScore : Int = 0
    
    private var highScores : [String:[Int:Int]] = [:]
    
    private var timedURL : URL
    
    private var archive : TimedArchive
    
    init() {
        timeOptions = [30, 61, 121, 301]
        completed = 0
        
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        timedURL = documentURL.appendingPathComponent(Filenames.timed + ".archive")
        
        if fileManager.fileExists(atPath: timedURL.path) {
            archive = NSKeyedUnarchiver.unarchiveObject(withFile: timedURL.path)! as! TimedArchive
            highScores = archive.scores
        } else {
            
            var initTimeHighScores : [Int:Int] = [:]
            
            for time in timeOptions {
                initTimeHighScores[Int(time)] = 0
            }
            
            highScores[Difficulty.easy.rawValue] = initTimeHighScores
            highScores[Difficulty.medium.rawValue] = initTimeHighScores
            highScores[Difficulty.hard.rawValue] = initTimeHighScores
            highScores[Difficulty.random.rawValue] = initTimeHighScores
            
            archive = TimedArchive(highScores: highScores)
            saveArchive()
        }
    }
    
    func initialize(withDifficulty diff: Difficulty, withTime time: String) {
        changeTime(toTime: time)
        
        currentTime = totalTime!
        
        difficulty = diff
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
    
    func changeDifficulty(toDifficulty difficulty: Difficulty) {
        self.difficulty = difficulty
    }
    
    func changeTime(toTime time: String) {
        switch time {
        case "30 sec": totalTime = timeOptions[0]
        case "1 min": totalTime = timeOptions[1]
        case "2 min": totalTime = timeOptions[2]
        case "5 min": totalTime = timeOptions[3]
        default: totalTime = timeOptions[0]
        }
    }
    
    func addTime() -> Double {
        let timeAdded : TimeInterval
        switch difficulty! {
        case .easy: timeAdded = 5
        case .medium: timeAdded = 10
        case .hard: timeAdded = 15
        case .random: timeAdded = 10
        }
        
        currentTime! += timeAdded
        
        return timeAdded
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
        if totalScore > highScores[difficulty!.rawValue]![Int(totalTime!)]! {
            highScores[difficulty!.rawValue]![Int(totalTime!)]! = totalScore
            archive.scores = highScores
            saveArchive()
        }
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
    
    func highScore() -> Int {
        archive = NSKeyedUnarchiver.unarchiveObject(withFile: timedURL.path)! as! TimedArchive
        highScores = archive.scores
        return highScores[difficulty!.rawValue]![Int(totalTime!)]!
    }
    
    func saveArchive() {
        NSKeyedArchiver.archiveRootObject(archive, toFile: timedURL.path)
    }
}
