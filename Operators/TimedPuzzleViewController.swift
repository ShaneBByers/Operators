//
//  TimedPuzzleViewController.swift
//  Operators
//
//  Created by Shane Byers on 4/1/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class TimedPuzzleViewController : PuzzleViewController {
    
    var timer : Timer?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "timerCompletedSegue":
            let destination = segue.destination as! TimedCompletedViewController
            
            destination.configureText(completedPuzzles: timedModel.completedPuzzles(), score: timedModel.score(), highScore: timedModel.highScore())
            destination.configurePuzzleViewController(viewController: self)
            
            resetOnDisappear()
        case "challengePuzzleCompletedSegue": break
        case "hintsSegue": break
        case "unwindToOriginal": break
        case "unwindToChallenge": break
        case "unwindToTimed": break
        default: assert(false, "Unhandled Segue")
        }
        super.prepare(for: segue, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTimer()
        newPuzzleButtonPressed(UIButton())
    }
    
    override func backButtonPressed(_ sender: UIButton) {
        super.backButtonPressed(sender)
        performSegue(withIdentifier: "unwindToTimed", sender: self)
    }
    
    override func resetOnDisappear() {
        super.resetOnDisappear()
        timedModel.restart()
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    override func defaultOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        super.defaultOperatorDoubleTapped(recognizer)
        updateTimedScore()
        if correctTimedSolution() {
            timedModel.completePuzzle()
            self.newPuzzleButtonPressed(UIButton())
            resetButtonAction(enable: false)
            addTime()
        }
    }
    
    override func operatorEndedPanning(label: UILabel, isDefaultOperator: Bool) {
        super.operatorEndedPanning(label: label, isDefaultOperator: isDefaultOperator)
        updateTimedScore()
        if correctTimedSolution() {
            timedModel.completePuzzle()
            self.newPuzzleButtonPressed(UIButton())
            resetButtonAction(enable: false)
            addTime()
        }
    }
    
    override func newPuzzleButtonPressed(_ sender: UIButton) {
        let equation : Equation
        
        switch timedModel.difficulty! {
        case .easy: equation = puzzleModel.newEquation(operands: OperandCount.easy)
        case .medium: equation = puzzleModel.newEquation(operands: OperandCount.medium)
        case .hard: equation = puzzleModel.newEquation(operands: OperandCount.hard)
        case .random: equation = puzzleModel.newEquation(operands: OperandCount.random())
        }
        
        timedModel.resetCurrentScore()
        secondaryLabel.text = "Score: " + String(timedModel.score())
        timedModel.updateSolution(solution: equation.solution.number!)
        
        setupPuzzle(withEquation: equation)
        
        super.newPuzzleButtonPressed(sender)
    }
    
    func initializeTimer() {
        
        let kTimerInterval : TimeInterval = 0.1
        
        primaryLabel.textColor = colorElements.labelColor
        primaryLabel.text = "\(timedModel.remainingMinutesSeconds(timeElapsed: 0.0)!)"
        
        timer = Timer.scheduledTimer(timeInterval: kTimerInterval, target: self, selector: #selector(TimedPuzzleViewController.timerFired(timer:)), userInfo: nil, repeats: true)
        
        newPuzzleButton.alpha = 1.0
        newPuzzleButton.isEnabled = true
        
        progressBarView.isHidden = false
        progressBarView.progress = 1.0
        
        secondaryLabel.text = "Score: 0"
    }
    
    func updateTimedScore() {
        
        var newExpression : [String] = []
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand || puzzleLabel.isOperator {
                newExpression.append(puzzleLabel.label.text!)
            }
        }
        
        if let solution = puzzleModel.solutionFor(expression: newExpression) {
            timedModel.updateScore(withEquation: puzzleModel.equation!, withSolution: solution)
        }
        
        secondaryLabel.text = "Score: " + String(timedModel.score())
    }
    
    func restartTimedPuzzle() {
        
        let kTimerInterval : TimeInterval = 0.1
        
        self.timedModel.restart()
        
        self.primaryLabel.text = "\(self.timedModel.remainingMinutesSeconds(timeElapsed: 0.0)!)"
        self.timer = Timer.scheduledTimer(timeInterval: kTimerInterval, target: self, selector: #selector(TimedPuzzleViewController.timerFired(timer:)), userInfo: nil, repeats: true)
        
        self.newPuzzleButtonPressed(UIButton())
    }
    
    @objc func timerFired(timer : Timer) {
        
        let kTimerInterval : TimeInterval = 0.1
        
        let countdownTimerAmount : TimeInterval = 10.1
        
        if let remaining = timedModel.remainingMinutesSeconds(timeElapsed: timer.timeInterval) {
            primaryLabel.text = remaining
            let doubleRemaining = Double(timedModel.currentTime!)
            let intRemaining = Int(doubleRemaining)
            if doubleRemaining <= countdownTimerAmount && abs(doubleRemaining - Double(intRemaining)) <= kTimerInterval {
                primaryLabel.textColor = .red
            } else {
                primaryLabel.textColor = colorElements.buttonColor
            }
            progressBarView.progress = Float(doubleRemaining)/Float(timedModel.totalTime!)
        } else {
            primaryLabel.text = "0.0"
            timer.invalidate()
            self.performSegue(withIdentifier: "timerCompletedSegue", sender: self)
        }
    }
    
    func correctTimedSolution() -> Bool {
        var newExpression : [String] = []
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand || puzzleLabel.isOperator {
                newExpression.append(puzzleLabel.label.text!)
            }
        }
        
        let solution = puzzleModel.solutionFor(expression: newExpression)
        
        if let solution = solution {
            return solution == timedModel.currentSolution()
        } else {
            return false
        }
    }
    
    func addTime() {
        let timeAdded = timedModel.addTime()
        primaryLabelUpdate(withText: "\(Int(timeAdded))")
    }
}
