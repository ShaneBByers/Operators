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
    
    var maxCounts : [Hint:Int] = [:]
    
    var defaultAllowed : [Hint:Bool] = [:]
    
    var allowed : [Hint:Bool] = [:]
    
    func configureDefaults(_ defaults : [Hint:Bool], max : [Hint:Int]) {
        defaultAllowed = defaults
        maxCounts = max
        proposedCounts[.custom] = customCountValue
    }
    
    init() {
        proposedCounts[.random] = 0
        proposedCounts[.custom] = 0
        proposedCounts[.allUses] = 0
        
        allowed[.random] = true
        allowed[.custom] = true
        allowed[.allUses] = true
    }
    
    func addHint(hint: Hint) {
        proposedCounts[hint]! += 1
        proposedMultiplierValue -= hint.rawValue
        updateAllowed()
    }
    
    func subtractHint(hint: Hint) {
        proposedCounts[hint]! -= 1
        proposedMultiplierValue += hint.rawValue
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
        if hint == .custom {
            return proposedCounts[hint]! > customCountValue
        } else {
            return proposedCounts[hint]! > 0
        }
    }
    
    func proposedCount(forHint hint: Hint) -> Int {
        return proposedCounts[hint]!
    }
    
    func updateMultiplier(hint: Hint, copies: Int) {
        multiplierValue -= hint.rawValue*Double(copies)
        proposedMultiplierValue = multiplierValue
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
    
    func convertCustomCount() {
        customCountValue = proposedCounts[.custom]!
    }
    
    func useCustom() {
        customCountValue -= 1
    }
    
    func customCount() -> Int {
        return customCountValue
    }
    
    func reset() {
        multiplierValue = 1.00
        proposedMultiplierValue = 1.00
        customCountValue = 0
        for key in proposedCounts.keys {
            proposedCounts[key] = 0
            allowed[key] = true
        }
    }
}
