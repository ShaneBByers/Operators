//
//  OriginalPuzzleViewController.swift
//  Operators
//
//  Created by Shane Byers on 4/1/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class OriginalPuzzleViewController : PuzzleViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBestScore()
        newPuzzleButtonPressed(UIButton())
    }
    
    override func backButtonPressed(_ sender: UIButton) {
        super.backButtonPressed(sender)
        performSegue(withIdentifier: "unwindToOriginal", sender: self)
    }
    
    override func resetOnDisappear() {
        super.resetOnDisappear()
        originalModel.resetTotalScore()
    }
    
    override func defaultOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        super.defaultOperatorDoubleTapped(recognizer)
        if !solvePuzzleButtonPressed {
            updateBestScore()
        }
    }
    
    override func operatorEndedPanning(label: UILabel, isDefaultOperator: Bool) {
        super.operatorEndedPanning(label: label, isDefaultOperator: isDefaultOperator)
        if !solvePuzzleButtonPressed {
            updateBestScore()
        }
    }
    
    override func newPuzzleButtonPressed(_ sender: UIButton) {
        let equation : Equation
        
        switch originalModel.difficulty! {
        case .easy: equation = puzzleModel.newEquation(operands: OperandCount.easy)
        case .medium: equation = puzzleModel.newEquation(operands: OperandCount.medium)
        case .hard: equation = puzzleModel.newEquation(operands: OperandCount.hard)
        case .random: equation = puzzleModel.newEquation(operands: OperandCount.random())
        }
        
        originalModel.resetCurrentScore()
        primaryLabel.text = "Score: " + String(originalModel.totalScore())
        secondaryLabel.text = "Current: N/A"
        
        setupPuzzle(withEquation: equation)
        
        super.newPuzzleButtonPressed(sender)
        
        solveButtonAction(enable: true)
    }
    
    func initializeBestScore() {
        
        primaryLabel.text = "Score: 0"
        
        secondaryLabel.text = "Current: N/A"
        
        newPuzzleButton.alpha = 1.0
        newPuzzleButton.isEnabled = true
        
        solveButton.alpha = 1.0
        solveButton.isEnabled = true
        
        progressBarView.isHidden = false
        currentMultiplierLabel.isHidden = false
        nextMultiplierLabel.isHidden = false
        
        hintsButtonAction(enable: true)
    }
    
    func updateBestScore() {
        
        var newExpression : [String] = []
        
        var currentScore : Int?
        
        let oldScore = originalModel.currentScore()
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand || puzzleLabel.isOperator {
                newExpression.append(puzzleLabel.label.text!)
            }
        }
        
        if let solution = puzzleModel.solutionFor(expression: newExpression) {
            currentScore = originalModel.updateScores(withEquation: puzzleModel.equation!, withSolution: solution)
        } else {
            currentScore = originalModel.currentScore()
        }
        
        if let best = currentScore {
            secondaryLabel.text = "Current: " + String(best)
            if let old = oldScore {
                if best > old {
                    primaryLabelUpdate(withText: "\(best-old)")
                }
            } else if best > 0 {
                primaryLabelUpdate(withText: "\(best)")
            }
            if best == Int(originalModel.maxScore*Double(originalModel.currentPointsMultiplier())) {
                hintsButtonAction(enable: false)
                solveButtonAction(enable: false)
                displayCompleted()
            }
            progressBarView.setProgress(originalModel.multiplierProgress(), animated: true)
            let currentMultiplier = originalModel.currentPointsMultiplier()
            if currentMultiplier != 1 {
                currentMultiplierLabel.text = "×\(currentMultiplier)"
            } else {
                currentMultiplierLabel.text = ""
            }
            if let nextMultiplier = originalModel.nextPointsMultiplier() {
                nextMultiplierLabel.text = "×\(nextMultiplier)"
            } else {
                nextMultiplierLabel.text = ""
            }
        } else {
            secondaryLabel.text = "Current: N/A"
        }
        
        primaryLabel.text = "Score: " + String(originalModel.totalScore())
    }
    
    func displayCompleted() {
        let completedLabel = UILabel()
        completedLabel.text = "Complete!"
        completedLabel.textAlignment = .center
        completedLabel.font = UIFont(name: Fonts.wRhC!.fontName, size: 60)
        completedLabel.frame.size.width = self.view.frame.size.width
        completedLabel.frame.size.height = kPuzzleLabelSize.height + 2*kLabelBuffer
        completedLabel.center.x = self.view.center.x
        completedLabel.center.y = kPuzzleLabelsYPosition + kPuzzleLabelSize.height
        completedLabel.alpha = 0.0
        
        self.view.addSubview(completedLabel)
        
        UIView.animate(withDuration: kLongAnimationDuration, animations: {
            completedLabel.alpha = 1.0
            completedLabel.center.y = self.kPuzzleLabelsYPosition
        }) { (value) in
            UIView.animate(withDuration: self.kLongAnimationDuration, delay: self.kShortAnimationDuration, options: .allowAnimatedContent, animations: {
                completedLabel.alpha = 0.0
                completedLabel.center.y = self.kPuzzleLabelsYPosition - self.kPuzzleLabelSize.height
            }, completion: { (value) in
                completedLabel.removeFromSuperview()
            })
        }
    }
}
