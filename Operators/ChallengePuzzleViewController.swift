//
//  ChallengePuzzleViewController.swift
//  Operators
//
//  Created by Shane Byers on 4/1/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class ChallengePuzzleViewController : PuzzleViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "challengePuzzleCompletedSegue":
            let destination = segue.destination as! ChallengePuzzleCompletedViewController
            
            if challengeModel.hasNextPuzzle() {
                destination.configureText(completedPuzzleDifficulty: challengeModel.difficulty, completedPuzzleNumber: challengeModel.currentIndex!, nextPuzzleDifficulty: challengeModel.difficulty, nextPuzzleNumber: challengeModel.currentIndex! + 1)
            } else {
                switch challengeModel.difficulty {
                case .easy:
                    challengeModel.changeDifficulty(toDifficulty: .medium)
                    destination.configureText(completedPuzzleDifficulty: challengeModel.difficulty, completedPuzzleNumber: challengeModel.currentIndex!, nextPuzzleDifficulty: .medium, nextPuzzleNumber: nil)
                case .medium:
                    challengeModel.changeDifficulty(toDifficulty: .hard)
                    destination.configureText(completedPuzzleDifficulty: challengeModel.difficulty, completedPuzzleNumber: challengeModel.currentIndex!, nextPuzzleDifficulty: .hard, nextPuzzleNumber: nil)
                case .hard:
                    destination.configureText(completedPuzzleDifficulty: challengeModel.difficulty, completedPuzzleNumber: challengeModel.currentIndex!, nextPuzzleDifficulty: nil, nextPuzzleNumber: nil)
                case .random: break
                }
            }
            
            destination.configurePuzzleViewController(viewController : self)
            
            resetOnDisappear()
        case "timerCompletedSegue": break
        case "hintsSegue": break
        case "unwindToOriginal": break
        case "unwindToChallenge": break
        case "unwindToTimed": break
        default: assert(false,"Unhandled Segue")
        }
        super.prepare(for: segue, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeChallenge()
        setupPuzzle(withEquation: challengeModel.equationAtCurrentIndex())
    }
    
    override func backButtonPressed(_ sender: UIButton) {
        super.backButtonPressed(sender)
        performSegue(withIdentifier: "unwindToChallenge", sender: self)
    }
    
    override func defaultOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        super.defaultOperatorDoubleTapped(recognizer)
        if correctChallengeSolution() {
            performSegue(withIdentifier: "challengePuzzleCompletedSegue", sender: self)
            challengeModel.completeCurrentPuzzle()
        }
    }
    
    override func operatorEndedPanning(label: UILabel, isDefaultOperator: Bool) {
        super.operatorEndedPanning(label: label, isDefaultOperator: isDefaultOperator)
        if correctChallengeSolution() {
            performSegue(withIdentifier: "challengePuzzleCompletedSegue", sender: self)
            challengeModel.completeCurrentPuzzle()
        }
    }
    
    func initializeChallenge() {
        primaryLabel.text = "\(challengeModel.difficulty.rawValue) Puzzle #\(challengeModel.currentPuzzleNumber())"
        secondaryLabel.alpha = 0.0
    }
    
    func nextChallengePuzzle() {
        primaryLabel.text = "\(challengeModel.difficulty.rawValue) Puzzle #\(challengeModel.currentPuzzleNumber())"
        setupPuzzle(withEquation: challengeModel.nextEquation())
        resetButtonAction(enable: false)
    }
    
    func correctChallengeSolution() -> Bool {
        var newExpression : [String] = []
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand || puzzleLabel.isOperator {
                newExpression.append(puzzleLabel.label.text!)
            }
        }
        
        let solution = puzzleModel.solutionFor(expression: newExpression)
        
        if let solution = solution {
            return solution == challengeModel.currentSolution()
        } else {
            return false
        }
    }
}
