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
    
    var bestSolution : Int?
    
    func calculateBestSolution(withEquation equation: Equation, withSolution solution: Int) -> Int? {
        if let correctSolution = equation.solution.number {
            if let bestSolution = bestSolution {
                if abs(correctSolution - solution) <= bestSolution {
                    self.bestSolution = abs(correctSolution - solution)
                }
            } else {
                self.bestSolution = abs(correctSolution - solution)
            }
        }
        
        return bestSolution
    }
    
    func currentBestSolution() -> Int? {
        return bestSolution
    }
    
    func resetBestSolution() {
        bestSolution = nil
    }
}
