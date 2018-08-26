//
//  TutorialPuzzleViewController.swift
//  Operators
//
//  Created by Shane Byers on 4/12/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class TutorialPuzzleViewController: PuzzleViewController {
    
    var storedOperatorLabels : [UILabel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTutorial()
    }
    
    func initializeTutorial() {
        storedOperatorLabels = defaultOperatorLabels
        executeNextStep()
    }
    
    func executeNextStep() {
        tutorialModel.nextStep()
        switch tutorialModel.puzzleNumber() {
        case 1:
            switch tutorialModel.stepNumber() {
            case 1: // Initialize first puzzle
                setupPuzzle(withEquation: tutorialModel.getCurrentPuzzle())
                puzzleModel.equation = tutorialModel.getCurrentPuzzle() // TEMPORARY FIX!!!!!1
                expressionLabel.alpha = 0.0
                resetAllowed = false
                primaryLabel.alpha = 0.0
                secondaryLabel.alpha = 0.0
                
                keepDefaults(Symbols.Add)
                placeDefaultOperators(isInitial: true)
                
                for recognizer in defaultOperatorLabels[0].gestureRecognizers! {
                    if recognizer is UITapGestureRecognizer {
                        defaultOperatorLabels[0].removeGestureRecognizer(recognizer)
                    }
                }
            case 2: // Double tap + into puzzle
                for puzzleLabel in puzzleLabels {
                    if puzzleLabel.isOperator {
                        for recognizer in puzzleLabel.label.gestureRecognizers! {
                            puzzleLabel.label.removeGestureRecognizer(recognizer)
                        }
                    }
                }
                super.initializeGestureRecognizers()
                for recognizer in defaultOperatorLabels[0].gestureRecognizers! {
                    if recognizer is UIPanGestureRecognizer {
                        defaultOperatorLabels[0].removeGestureRecognizer(recognizer)
                    }
                }
            case 3: // Show score label with 0 score
                for puzzleLabel in puzzleLabels {
                    if puzzleLabel.isOperator {
                        for recognizer in puzzleLabel.label.gestureRecognizers! {
                            puzzleLabel.label.removeGestureRecognizer(recognizer)
                        }
                    }
                }
                var newExpression : [String] = []
                for puzzleLabel in puzzleLabels {
                    if puzzleLabel.isOperand || puzzleLabel.isOperator {
                        newExpression.append(puzzleLabel.label.text!)
                    }
                }
                if let solution = puzzleModel.solutionFor(expression: newExpression) {
                    tutorialModel.updateTotalScore(withSolution: solution)
                    
                    primaryLabel.text = "Score: 0"
                    UIView.animate(withDuration: kShortAnimationDuration, animations: {
                        self.primaryLabel.alpha = 1.0
                    }, completion: {(value) in
                        self.executeNextStep()
                    })
                }
            case 4: // Show score increasing
                primaryLabel.text = "Score: \(tutorialModel.getTotalScore())"
                primaryLabelUpdate(withText: "\(tutorialModel.getTotalScore())")
                progressBarView.isHidden = false
                currentMultiplierLabel.isHidden = false
                nextMultiplierLabel.isHidden = false
                progressBarView.setProgress(originalModel.multiplierProgress(), animated: true)
                let currentMultiplier = tutorialModel.currentPointsMultiplier()
                if currentMultiplier != 1 {
                    currentMultiplierLabel.text = "×\(currentMultiplier)"
                } else {
                    currentMultiplierLabel.text = ""
                }
                if let nextMultiplier = tutorialModel.nextPointsMultiplier() {
                    nextMultiplierLabel.text = "×\(nextMultiplier)"
                } else {
                    nextMultiplierLabel.text = ""
                }
                executeNextStep()
            case 5: // Show expression label
                displayExpression()
                UIView.animate(withDuration: kShortAnimationDuration, animations: {
                    self.expressionLabel.alpha = 1.0
                })
                executeNextStep()
            case 6: // Show - operator
                keepDefaults(Symbols.Add, Symbols.Subtract)
                super.initializeGestureRecognizers()
                placeDefaultOperators(isInitial: false)
                executeNextStep()
            case 7: // Show pan and double tap puzzle operators to remove
                for puzzleLabel in puzzleLabels {
                    if puzzleLabel.isOperator {
                        puzzleLabel.label.addGestureRecognizer(puzzleLabel.operatorPanGestureRecognizer)
                        puzzleLabel.label.addGestureRecognizer(puzzleLabel.operatorDoubleTapGestureRecognizer)
                    }
                }
                executeNextStep()
            case 8: // Allow user to complete the puzzle
                break
            default: // Next puzzle
                tutorialModel.puzzleComplete()
                executeNextStep()
            }
        case 2:
            switch tutorialModel.stepNumber() {
            case 1: // Prepare puzzle and show hints button
                setupPuzzle(withEquation: tutorialModel.getCurrentPuzzle())
                puzzleModel.equation = tutorialModel.getCurrentPuzzle() // TEMPORARY FIX!!!!!1
                self.hintsButtonAction(enable: true)
            case 2: // Place wildcard into place
                for label in defaultOperatorLabels {
                    if label != defaultOperatorLabels[1] {
                        label.isUserInteractionEnabled = false
                        label.alpha = 0.5
                    }
                }
            case 3: // Show lock and have them unlock
                for puzzleLabel in puzzleLabels {
                    if puzzleLabel.isOperator {
                        puzzleLabel.label.removeGestureRecognizer(puzzleLabel.operatorPanGestureRecognizer)
                        puzzleLabel.label.removeGestureRecognizer(puzzleLabel.operatorDoubleTapGestureRecognizer)
                    }
                }
            case 4: // Show how to lock again
                break
            case 5: // Allow user to place another operator
                resetAllowed = true
                for label in defaultOperatorLabels {
                    label.isUserInteractionEnabled = true
                    label.alpha = 1.0
                }
            case 6: // Show reset button and say how to use it
                keepDefaults(Symbols.Add, Symbols.Subtract, Symbols.Multiply, Symbols.Divide)
                super.initializeGestureRecognizers()
                placeDefaultOperators(isInitial: false)
                executeNextStep()
            case 7: // Allow user to complete the puzzle
                break
            default: // Next puzzle
                tutorialModel.puzzleComplete()
                executeNextStep()
            }
        case 3:
            switch tutorialModel.stepNumber() {
            case 1: // Prepare puzzle and show score multiplier
                setupPuzzle(withEquation: tutorialModel.getCurrentPuzzle())
                puzzleModel.equation = tutorialModel.getCurrentPuzzle() // TEMPORARY FIX!!!!!1
                self.hintsButtonAction(enable: true)
            case 2: // Show solve button as an option
                self.solveButtonAction(enable: true)
            default: // Finish tutorial
                tutorialModel.puzzleComplete()
                executeNextStep()
            }
        default: break // PERFORM SEGUE FROM PUZZLE VC TO "TUTORIAL COMPLETE" VC THEN BACK TO FIRST VC
            
        }
    }
    
    func keepDefaults(_ operatorStrings: String...) {
        for operatorLabel in defaultOperatorLabels {
            operatorLabel.removeFromSuperview()
        }
        defaultOperatorLabels = []
        for operatorString in operatorStrings {
            for storedOperatorLabel in storedOperatorLabels! {
                if storedOperatorLabel.text! == operatorString {
                    defaultOperatorLabels.append(storedOperatorLabel)
                }
            }
        }
        for operatorLabel in defaultOperatorLabels {
            super.view.addSubview(operatorLabel)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? HintsViewController {
            if tutorialModel.status(isPuzzle: 2, isStep: 1) {
                destination.configureTutorial(allowed: .custom)
            } else if tutorialModel.status(isPuzzle: 3, isStep: 1) {
                destination.configureTutorial(allowed: .random, .uses)
            }
        }
    }
    
    override func implementHints() {
        kWildcardOperatorPosition = 1
        
        super.implementHints()
        
        executeNextStep()
    }
    
    override func operatorEndedPanning(label: UILabel, isDefaultOperator: Bool) {
        super.operatorEndedPanning(label: label, isDefaultOperator: isDefaultOperator)
        
        if isDefaultOperator {
            if (correctTutorialSolution()) ||
                (tutorialModel.status(isPuzzle: 1, isStep: 1) && puzzleLabels[1].label.text! == Symbols.Add) ||
                (tutorialModel.status(isPuzzle: 2, isStep: 2) && puzzleLabels[1].label.text! == Symbols.Add){
                executeNextStep()
            } else if tutorialModel.status(isPuzzle: 1, isStep: 8) {
                for puzzleLabel in puzzleLabels {
                    if puzzleLabel.isOperator {
                        puzzleLabel.label.removeGestureRecognizer(puzzleLabel.operatorHoldGestureRecognizer)
                    }
                }
            } else if tutorialModel.status(isPuzzle: 2, isStep: 5) && resetButton.isEnabled {
                executeNextStep()
            }
        } else {
            if (tutorialModel.status(isPuzzle: 1, isStep: 5)) {
                var operandCount = 0
                var operatorCount = 0
                for puzzleLabel in puzzleLabels {
                    if puzzleLabel.isOperator {
                        operatorCount += 1
                    } else if puzzleLabel.isOperand {
                        operandCount += 1
                    }
                }
                if operatorCount <= operandCount - 2 {
                    executeNextStep()
                }
            }
        }
    }
    
    override func defaultOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        super.defaultOperatorDoubleTapped(recognizer)
        
        if (correctTutorialSolution()) ||
            (tutorialModel.status(isPuzzle: 1, isStep: 2)) ||
            (tutorialModel.status(isPuzzle: 2, isStep: 2)) {
            executeNextStep()
        } else if tutorialModel.status(isPuzzle: 1, isStep: 8) {
            for puzzleLabel in puzzleLabels {
                if puzzleLabel.isOperator {
                    puzzleLabel.label.removeGestureRecognizer(puzzleLabel.operatorHoldGestureRecognizer)
                }
            }
        } else if tutorialModel.status(isPuzzle: 2, isStep: 5) && resetButton.isEnabled {
            executeNextStep()
        }
    }
    
    override func puzzleOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        super.puzzleOperatorDoubleTapped(recognizer)
        
        var operandCount = 0
        var operatorCount = 0
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperator {
                operatorCount += 1
            } else if puzzleLabel.isOperand {
                operandCount += 1
            }
        }
        if operatorCount <= operandCount - 2 {
            executeNextStep()
        }
    }
    
    override func puzzleOperatorHeld(_ recognizer: UILongPressGestureRecognizer) {
        super.puzzleOperatorHeld(recognizer)
        
        if (tutorialModel.status(isPuzzle: 2, isStep: 3) && recognizer.state == .ended) ||
            (tutorialModel.status(isPuzzle: 2, isStep: 4) && recognizer.state == .ended) {
            executeNextStep()
        }
        
    }
    
    func correctTutorialSolution() -> Bool {
        var newExpression : [String] = []
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand || puzzleLabel.isOperator {
                newExpression.append(puzzleLabel.label.text!)
            }
        }
        
        let solution = puzzleModel.solutionFor(expression: newExpression)
        
        if let solution = solution {
            return solution == tutorialModel.currentSolution()
        } else {
            return false
        }
    }
}
