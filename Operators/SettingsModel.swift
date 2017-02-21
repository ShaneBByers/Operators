//
//  SettingsModel.swift
//  Operators
//
//  Created by Shane Byers on 2/18/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import Foundation

class SettingsModel {
    static let sharedInstance = SettingsModel()
    
    let fileManager : FileManager
    let documentURL : URL
    
    let settingsURL : URL
    
    let settingsArchive : SettingsArchive
    
    init() {
        fileManager = FileManager.default
        documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        settingsURL = documentURL.appendingPathComponent(Filenames.settings + ".archive")
        
        let fileExists = fileManager.fileExists(atPath: settingsURL.path)
        
        if fileExists {
            settingsArchive = NSKeyedUnarchiver.unarchiveObject(withFile: settingsURL.path)! as! SettingsArchive
            
            Symbols.Divide = settingsArchive.divisionSymbol
        } else {
            Symbols.Divide = Symbols.HyphenDots
            
            settingsArchive = SettingsArchive(divisionSymbol: Symbols.Divide)
            NSKeyedArchiver.archiveRootObject(settingsArchive, toFile: settingsURL.path)
        }
    }
    
    func canDeleteChallengePuzzles(forDifficulty difficulty: Difficulty) -> Bool {
        let challengeURL : URL
        
        challengeURL = documentURL.appendingPathComponent(Filenames.challenge + ".archive")
        
        let fileExists = fileManager.fileExists(atPath: challengeURL.path)
        
        if fileExists {
            let archive = NSKeyedUnarchiver.unarchiveObject(withFile: challengeURL.path)! as! ChallengeArchive
            
            for i in 1..<archive.availablePuzzles[difficulty.rawValue]!.count {
                if archive.availablePuzzles[difficulty.rawValue]![i] {
                    return true
                }
            }
        }
        return false
    }
    
    func deleteOriginalHighScores() {
        let bestScoreURL : URL
        
        bestScoreURL = documentURL.appendingPathComponent(Filenames.bestScore + ".archive")
        
        let fileExists = fileManager.fileExists(atPath: bestScoreURL.path)
        
        if fileExists {
            let archive = NSKeyedUnarchiver.unarchiveObject(withFile: bestScoreURL.path)! as! BestScoreArchive
            for scoreKey in archive.scores.keys {
                archive.scores[scoreKey] = 0
            }
            NSKeyedArchiver.archiveRootObject(archive, toFile: bestScoreURL.path)
        }
    }
    
    func deleteTimedHighScores() {
        let timedURL : URL
        
        timedURL = documentURL.appendingPathComponent(Filenames.timed + ".archive")
        
        let fileExists = fileManager.fileExists(atPath: timedURL.path)
        
        if fileExists {
            let archive = NSKeyedUnarchiver.unarchiveObject(withFile: timedURL.path)! as! TimedArchive
            for difficultyKey in archive.scores.keys {
                for timeKey in archive.scores[difficultyKey]!.keys {
                    archive.scores[difficultyKey]![timeKey]! = 0
                }
            }
            NSKeyedArchiver.archiveRootObject(archive, toFile: timedURL.path)
        }
    }
    
    func deleteChallengePuzzles(difficulty: Difficulty) {
        let challengeURL : URL
        
        challengeURL = documentURL.appendingPathComponent(Filenames.challenge + ".archive")
        
        let fileExists = fileManager.fileExists(atPath: challengeURL.path)
        
        if fileExists {
            let archive = NSKeyedUnarchiver.unarchiveObject(withFile: challengeURL.path)! as! ChallengeArchive
            
            for i in 1..<archive.availablePuzzles[difficulty.rawValue]!.count {
                archive.availablePuzzles[difficulty.rawValue]![i] = false
            }
            NSKeyedArchiver.archiveRootObject(archive, toFile: challengeURL.path)
        }
    }
    
    func changeDivisionSymbol(fromSymbol symbol : String) {
        if symbol == Symbols.HyphenDots {
            Symbols.Divide = Symbols.Slash
        } else if symbol == Symbols.Slash {
            Symbols.Divide = Symbols.HyphenDots
        }
        settingsArchive.divisionSymbol = Symbols.Divide
        saveSettingsArchive()
    }
    
    func saveSettingsArchive() {
        NSKeyedArchiver.archiveRootObject(settingsArchive, toFile: settingsURL.path)
    }
}
