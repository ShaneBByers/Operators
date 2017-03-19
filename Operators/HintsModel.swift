//
//  HintsModel.swift
//  Operators
//
//  Created by Shane Byers on 3/6/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import Foundation

class HintsModel {
    static let sharedInstance = HintsModel()
    
    var multiplierValue = 1.00
    
    var proposedMultiplierValue = 1.00
    
    var proposedCounts : [Hint:Int] = [:]
    
    var customCountValue = 0
    
    var usesCountValue = 0
    
    var maxCounts : [Hint:Int] = [:]
    
    var defaultAllowed : [Hint:Bool] = [:]
    
    var allowed : [Hint:Bool] = [:]
    
    var additional : [Hint:Double] = [:]
    
    func configureDefaults(_ defaults : [Hint:Bool], max : [Hint:Int]) {
        defaultAllowed = defaults
        maxCounts = max
        proposedCounts[.custom] = customCountValue
        proposedCounts[.uses] = usesCountValue
        updateAllowed()
    }
    
    init() {
        proposedCounts[.random] = 0
        proposedCounts[.custom] = 0
        proposedCounts[.uses] = 0
        
        allowed[.random] = true
        allowed[.custom] = true
        allowed[.uses] = true
        
        additional[.random] = 0.0
        additional[.custom] = 0.0
        additional[.uses] = 0.0
    }
    
    func changeHintCount(hint: Hint, isAdd: Bool) {
        proposedMultiplierValue = multiplierValue
        if isAdd {
            if hint == .uses && proposedCounts[hint]! == 2 {
                proposedCounts[hint]! += 2
            } else {
                proposedCounts[hint]! += 1
            }
        } else {
            if hint == .uses && proposedCounts[hint]! == 4 {
                proposedCounts[hint]! -= 2
            } else {
                proposedCounts[hint]! -= 1
            }
        }
        
        for (key,count) in proposedCounts {
            additional[key] = 0.0
            var countTo : Int
            switch key {
            case .custom: countTo = count - customCountValue
            case .uses:
                if count == 4 {
                    countTo = count - usesCountValue - 1
                } else {
                    countTo = count - usesCountValue
                }
            default: countTo = count
            }
            if count > 1 {
                for i in 1...countTo {
                    additional[key]! += key.rawValue/pow(1.5, Double(i-1))
                }
            } else if countTo == 1 {
                additional[key] = key.rawValue
            }
            proposedMultiplierValue -= additional[key]!
        }
        updateAllowed()
    }
    
    func updateAllowed() {
        for key in proposedCounts.keys {
            allowed[key] = round(100*key.rawValue) < round(100*proposedMultiplierValue)
            if key == .random || key == .custom {
                allowed[key] = allowed[key]! && proposedCounts[.random]! + proposedCounts[.custom]! < maxCounts[key]!
            } else {
                allowed[key] = allowed[key]! && proposedCounts[key]! < maxCounts[key]!
            }
            
        }
    }
    
    func canAdd(hint: Hint) -> Bool {
        return defaultAllowed[hint]! && allowed[hint]!
    }
    
    func canSubtract(hint: Hint) -> Bool {
        switch hint {
        case .random:
            return proposedCounts[hint]! > 0
        case .custom:
            return proposedCounts[hint]! > customCountValue
        case .uses:
            return proposedCounts[hint]! > usesCountValue
        }
    }
    
    func proposedCount(forHint hint: Hint) -> Int {
        return proposedCounts[hint]!
    }
    
    func updateMultiplier() {
        multiplierValue = proposedMultiplierValue
    }
    
    func multiplier() -> Double {
        return multiplierValue
    }
    
    func resetProposedCounts() {
        for key in proposedCounts.keys {
            proposedCounts[key] = 0
        }
        updateAllowed()
        proposedMultiplierValue = multiplierValue
    }
    
    func subtractPercentage() -> Int? {
        if Int(round(100*multiplierValue)) == 100 {
            return nil
        } else {
            return Int(round(100-100*multiplierValue))
        }
    }
    
    func subtractProposedPercentage() -> Int? {
        if Int(round(100*proposedMultiplierValue)) == 100 {
            return nil
        } else {
            return Int(round(100-100*proposedMultiplierValue))
        }
    }
    
    func subtractProposedPercentage(forHint hint: Hint) -> Int? {
        if additional[hint]! > 0.0 {
            return Int(round(100.0*additional[hint]!))
        } else {
            return nil
        }
    }
    
    func convertCounts() {
        customCountValue = proposedCounts[.custom]!
        usesCountValue = proposedCounts[.uses]!
    }
    
    func useCustom() {
        customCountValue -= 1
    }
    
    func customCount() -> Int {
        return customCountValue
    }
    
    func usesCount() -> Int {
        return usesCountValue
    }
    
    func reset() {
        multiplierValue = 1.00
        proposedMultiplierValue = 1.00
        customCountValue = 0
        usesCountValue = 0
        for key in proposedCounts.keys {
            proposedCounts[key] = 0
            allowed[key] = true
        }
    }
}
