//
//  BestScoreModel.swift
//  Operators
//
//  Created by Shane Byers on 12/9/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

class OriginalModel {
    static let sharedInstance = OriginalModel()
    
    let hintsModel = HintsModel.sharedInstance
    
    var difficulty : Difficulty?
    
    private var current : Int?
    
    private var total : Int = 0
    
    private var highScores : [String:Int] = [:]
    
    private var bestScoreURL : URL
    
    private var archive : BestScoreArchive
    
    private let scoreBooster = 10
    
    public var maxScore = 100.0
    
    private var pointsMultipliers = [(range: CountableRange<Int>, multiplier: Double)]()
    
    private var pointsMultiplier = (range: 0..<1000, multiplier: 1.0)
    
    init() {
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        bestScoreURL = documentURL.appendingPathComponent(Filenames.bestScore + ".archive")
        
        pointsMultipliers.append((range: 0..<1000, multiplier: 1.0))
        pointsMultipliers.append((range: 1000..<5000, multiplier: 2.0))
        pointsMultipliers.append((range: 5000..<20000, multiplier: 5.0))
        pointsMultipliers.append((range: 20000..<Int.max, multiplier: 10.0))
        
        let fileExists = fileManager.fileExists(atPath: bestScoreURL.path)
        
        if fileExists {
//            archive = NSKeyedUnarchiver.unarchiveObject(withFile: bestScoreURL.path)! as! BestScoreArchive
//            highScores = archive.scores
            let fileContents = fileManager.contents(atPath: bestScoreURL.path)
            if let contents = fileContents {
                do {
                    archive = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(contents) as! BestScoreArchive
                    highScores = archive.scores
                } catch {
                    fatalError("Cannot find Best Score Archive object")
                }
            } else {
                fatalError("Cannot find contents of Best Score Archive file")
            }
        } else {
            
            highScores[Difficulty.easy.rawValue] = 0
            highScores[Difficulty.medium.rawValue] = 0
            highScores[Difficulty.hard.rawValue] = 0
            highScores[Difficulty.random.rawValue] = 0
            
            archive = BestScoreArchive(highScores: highScores)
//            NSKeyedArchiver.archiveRootObject(archive, toFile: bestScoreURL.path)
            saveArchive()
        }
    }
    
    func configureMaxScore() {
        switch difficulty! {
        case .easy: maxScore = 100.0
        case .medium: maxScore = 200.0
        case .hard: maxScore = 300.0
        case .random: maxScore = 250.0
        }
    }
    
    func updateScores(withEquation equation: Equation, withSolution solution: Int) -> Int? {
        if let correctSolution = equation.solution.number {
            configureMaxScore()
            let hintsMultiplier = hintsModel.multiplier()
            let percentageError = (Double(abs(correctSolution - solution)))/Double(abs(correctSolution) + scoreBooster)
            let newScore = Int(round(maxScore*hintsMultiplier*pointsMultiplier.multiplier - ceil(percentageError*maxScore*hintsMultiplier*pointsMultiplier.multiplier)))
            if let currentScore = current {
                let addedScore = Int(round(Double(newScore - currentScore)))
                if addedScore > 0 {
                    self.current! += addedScore
                    self.total += addedScore
                }
            } else {
                let addedScore = Int(round(Double(newScore)))
                if addedScore >= 0 {
                    self.current = newScore
                } else {
                    self.current = 0
                }
                self.total += self.current!
            }
        }
        
        if self.total > highScores[difficulty!.rawValue]! {
            highScores[difficulty!.rawValue] = self.total
            archive.scores = highScores
            saveArchive()
        }
        
        for pointMult in pointsMultipliers {
            if pointMult.range ~= self.total {
                pointsMultiplier = pointMult
                break
            }
        }
        
        return current
    }
    
    func multiplierProgress() -> Float {
        let lower = pointsMultiplier.range.lowerBound
        let upper = pointsMultiplier.range.upperBound
        if upper == Int.max {
            return 1.00
        } else {
            return Float(self.total-lower)/Float(upper-lower)
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
//        archive = NSKeyedUnarchiver.unarchiveObject(withFile: bestScoreURL.path)! as! BestScoreArchive
        highScores = archive.scores
        return highScores[difficulty.rawValue]!
    }
    
    func saveArchive() {
//        NSKeyedArchiver.archiveRootObject(archive, toFile: bestScoreURL.path)
        do {
            let codedData = try NSKeyedArchiver.archivedData(withRootObject: archive, requiringSecureCoding: false)
            try codedData.write(to: bestScoreURL)
        } catch {
            fatalError("Save archive OriginalModel data failed.")
        }
    }
}
