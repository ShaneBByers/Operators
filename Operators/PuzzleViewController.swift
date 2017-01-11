//
//  PuzzleViewController.swift
//  Operators
//
//  Created by Shane Byers on 11/12/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

struct PuzzleLabel {
    var isOperand : Bool
    var isOperator : Bool
    let label : UILabel
    
    init(text: String, isOperand: Bool, isOperator: Bool, isSolution: Bool) {
        let _label : UILabel
        
        if isSolution {
            _label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 60))
        } else {
            _label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        }
        
        _label.font = Fonts.largeBold
        _label.textColor = .green
        _label.textAlignment = .center
        _label.text = text
        
        if isOperator {
            _label.isUserInteractionEnabled = true
        }
        
        self.label = _label
        self.isOperand = isOperand
        self.isOperator = isOperator
    }
}


class PuzzleViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Models
    //
    let puzzleModel = PuzzleModel.sharedInstance
    let challengeModel = ChallengeModel.sharedInstance
    let bestScoreModel = BestScoreModel.sharedInstance
    let timedModel = TimedModel.sharedInstance
    
    // MARK: - Constants
    //
    let kGrowthFactor : CGFloat = 1.1
    let kPuzzleLabelSize : CGSize = CGSize(width: 60, height: 60)
    let kSolutionLabelSize : CGSize = CGSize(width: 120, height: 60)
    let kLabelBuffer : CGFloat = 10
    let kPlaceholderLabel = PuzzleLabel(text: "", isOperand: false, isOperator: false, isSolution: false)
    
    var hasPlaceholder = false
    var placeholderIndex : Int?
    
    var initialPoint : CGPoint = CGPoint.zero
    var kTopLabelPosition = CGPoint.zero
    var kBottomLabelPosition = CGPoint.zero
    var kPuzzleLabelsYPosition : CGFloat = 0.0
    
    // MARK: - Labels
    //
    var expressionLabel : UILabel?
    var timedCompletedLabel : UILabel?
    
    var addLabel : UILabel!
    var subtractLabel : UILabel!
    var multiplyLabel : UILabel!
    var divideLabel : UILabel!
    
    var bestScoreLabel : UILabel?
    var timerLabel : UILabel?
    
    var defaultOperatorLabels : [UILabel]
    var puzzleLabels : [PuzzleLabel] = []
    
    // MARK: - Custom Variables
    //
    var gameType : GameType?
    var difficulty : Difficulty?
    var challengeEquation : Equation?
    var timer : Timer?
    
    // MARK: - Configurations
    //
    func configureBestScore(withDifficulty diff: String) {
        difficulty = Difficulty(rawValue: diff)
        
        gameType = GameType.original
    }
    
    func configureChallenge(withEquation eq: Equation) {
        challengeEquation = eq
        
        gameType = GameType.challenge
    }
    
    func configureTimed(withDifficulty diff: String, withTime: TimeInterval) {
        difficulty = Difficulty(rawValue: diff)
        
        gameType = GameType.timed
    }
    
    // MARK: - Init/Load
    //
    required init?(coder aDecoder: NSCoder) {
        addLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize))
        subtractLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize))
        multiplyLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize))
        divideLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize))
        
        defaultOperatorLabels = [addLabel, subtractLabel, multiplyLabel, divideLabel]
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kPlaceholderLabel.label.alpha = 0.0
        
        kTopLabelPosition = CGPoint(x: self.view.center.x, y: self.view.center.y - 2.0*(kPuzzleLabelSize.height + kLabelBuffer))
        
        kBottomLabelPosition = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - kPuzzleLabelSize.height - 2.0*kLabelBuffer)
        
        kPuzzleLabelsYPosition = self.view.center.y - kPuzzleLabelSize.height - kLabelBuffer
        
        self.initializeDefaultOperators()
        
        self.intializeGestureRecognizers()
        
        self.initializeExpressionLabel()
        
        switch gameType! {
        case .original:
            self.initializeBestScore()
            self.newPuzzleButtonPressed(UIButton())
        case .challenge:
            self.setupPuzzle(withEquation: self.challengeEquation!)
        case .timed:
            self.initializeTimer()
            self.newPuzzleButtonPressed(UIButton())
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    // MARK: - Initializations
    //
    func initializeTimer() {
        
        timedCompletedLabel = UILabel()
        
        timedCompletedLabel!.frame.size = CGSize(width: self.view.frame.size.width, height: kPuzzleLabelSize.height)
        
        timedCompletedLabel!.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - 2.0*kLabelBuffer)
        
        timedCompletedLabel!.font = Fonts.smallBold
        timedCompletedLabel!.textAlignment = .center
        timedCompletedLabel!.text = "Completed: \(timedModel.completedPuzzles())"
        
        self.view.addSubview(timedCompletedLabel!)
        
        timerLabel = UILabel()
        
        timerLabel!.frame.size = CGSize(width: self.view.frame.size.width, height: kPuzzleLabelSize.height)
        timerLabel!.center = kBottomLabelPosition
        
        timerLabel!.font = Fonts.largeBold
        timerLabel!.textColor = UIColor.green
        timerLabel!.textAlignment = .center
        timerLabel!.text = "\(timedModel.remainingMinutesSeconds(timeElapsed: 0.0)!)"
        
        self.view.addSubview(timerLabel!)
        
        let timerInterval : TimeInterval = 0.1
        
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(PuzzleViewController.timerFired(timer:)), userInfo: nil, repeats: true)
    }
    
    func initializeBestScore() {
        
        bestScoreLabel = UILabel()
        
        bestScoreLabel!.frame.size = CGSize(width: self.view.frame.size.width, height: kPuzzleLabelSize.height)
        bestScoreLabel!.center = kBottomLabelPosition
        
        bestScoreLabel!.font = Fonts.largeBold
        bestScoreLabel!.textAlignment = .center
        bestScoreLabel!.text = "Best: N/A"
        
        self.view.addSubview(bestScoreLabel!)
        
        let newPuzzleButton: UIButton = UIButton()
        newPuzzleButton.frame.size = CGSize(width: self.view.frame.size.width/2, height: kPuzzleLabelSize.height)
        newPuzzleButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - 2.0*kLabelBuffer)
        newPuzzleButton.setTitleColor(.green, for: .normal)
        newPuzzleButton.setTitle("New Puzzle", for: .normal)
        newPuzzleButton.titleLabel!.font = Fonts.smallBold
        newPuzzleButton.addTarget(self, action: #selector(newPuzzleButtonPressed(_:)), for: .touchUpInside)
        newPuzzleButton.tag = 1
        self.view.addSubview(newPuzzleButton)
    }
    
    func initializeExpressionLabel() {
        
        expressionLabel = UILabel()
        
        expressionLabel!.frame.size = CGSize(width: self.view.frame.size.width, height: kPuzzleLabelSize.height)
        expressionLabel!.center = kTopLabelPosition
        
        expressionLabel!.font = Fonts.smallBold
        expressionLabel!.textAlignment = .center
        expressionLabel!.text = ""
        
        self.view.addSubview(expressionLabel!)
    }
    
    func initializeDefaultOperators() {

        let yPositionCenter = self.view.center.y + kPuzzleLabelSize.height
        
        let totalWidth = self.view.frame.size.width
        
        let oneWidth = totalWidth/CGFloat(defaultOperatorLabels.count)
        
        let oneWidthCenter = oneWidth/2
        
        for (i, label) in defaultOperatorLabels.enumerated() {
            label.font = Fonts.largeBold
            label.textColor = .green
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            
            let xPositionCenter: CGFloat
            
            xPositionCenter = oneWidth*CGFloat(i) + oneWidthCenter
                
            label.center = CGPoint(x: xPositionCenter, y: yPositionCenter)
                
            self.view.addSubview(label)
        }
        
        addLabel.text = Symbols.Add
        subtractLabel.text = Symbols.Subtract
        multiplyLabel.text = Symbols.Multiply
        divideLabel.text = Symbols.Divide
    }
    
    // MARK: - Label Gestures
    //
    func intializeGestureRecognizers() {
        let addPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PuzzleViewController.defaultOperatorPanned(_:)))
        let subtractPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PuzzleViewController.defaultOperatorPanned(_:)))
        let multiplyPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PuzzleViewController.defaultOperatorPanned(_:)))
        let dividePanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PuzzleViewController.defaultOperatorPanned(_:)))
        addPanRecognizer.delegate = self
        subtractPanRecognizer.delegate = self
        multiplyPanRecognizer.delegate = self
        dividePanRecognizer.delegate = self
        addLabel.addGestureRecognizer(addPanRecognizer)
        subtractLabel.addGestureRecognizer(subtractPanRecognizer)
        multiplyLabel.addGestureRecognizer(multiplyPanRecognizer)
        divideLabel.addGestureRecognizer(dividePanRecognizer)
    }
    
    func defaultOperatorPanned(_ recognizer : UIPanGestureRecognizer) {
        operatorPanned(recognizer, isDefaultOperator: true)
    }
    
    func puzzleOperatorPanned(_ recognizer: UIPanGestureRecognizer) {
        operatorPanned(recognizer, isDefaultOperator: false)
    }
    
    func operatorPanned(_ recognizer: UIPanGestureRecognizer, isDefaultOperator: Bool) {
        if let view = recognizer.view {
            let label = view as! UILabel
            switch recognizer.state {
            case .began:
                self.operatorBeganPanning(label: label, isDefaultOperator: isDefaultOperator)
            case .changed:
                self.operatorChangedPanning(recognizer: recognizer, label: label)
            case .ended:
                self.operatorEndedPanning(label: label, isDefaultOperator: isDefaultOperator)
            default: break
            }
        }

    }
    
    // MARK: - Label Panned Cases
    //
    func operatorBeganPanning(label: UILabel, isDefaultOperator: Bool) {
        label.transform = CGAffineTransform(scaleX: kGrowthFactor, y: kGrowthFactor)
        
        self.view.bringSubview(toFront: label)
        
        initialPoint = label.center
        
        if !isDefaultOperator {
            
            var index : Int?
            
            for (i,puzzleLabel) in puzzleLabels.enumerated() {
                if label == puzzleLabel.label {
                    index = i
                }
            }
            
            if let index = index {
                puzzleLabels.remove(at: index)
                puzzleLabels.insert(kPlaceholderLabel, at: index)
                placeholderIndex = index
                hasPlaceholder = true
            }
            
        }
    }
    
    func operatorChangedPanning(recognizer: UIPanGestureRecognizer, label: UILabel) {
        let translation = recognizer.translation(in: self.view)
        
        let newCenter = CGPoint(x: label.center.x + translation.x, y: label.center.y + translation.y)
        label.center = newCenter
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        if (label.center.y >= kPuzzleLabelsYPosition - kPuzzleLabelSize.height/2.0 && label.center.y <= kPuzzleLabelsYPosition + kPuzzleLabelSize.height/2) {
            
            var leftPuzzleLabel : PuzzleLabel? = nil
            
            var leftPuzzleLabelIndex : Int?
            
            var rightPuzzleLabel : PuzzleLabel? = nil
            
            for (i,puzzleLabel) in puzzleLabels.enumerated() {
                if leftPuzzleLabelIndex == nil && label.center.x < puzzleLabel.label.center.x {
                    leftPuzzleLabelIndex = i - 1
                }
            }
            
            if let index = leftPuzzleLabelIndex {
                if index >= 0 {
                    leftPuzzleLabel = puzzleLabels[index]
                }
                if index + 1 < puzzleLabels.count {
                    rightPuzzleLabel = puzzleLabels[index+1]
                }
            }
            
            if let leftPuzzleLabel = leftPuzzleLabel,
                let rightPuzzleLabel = rightPuzzleLabel {
                
                
                if leftPuzzleLabel.isOperand && rightPuzzleLabel.isOperand {
                    
                    if hasPlaceholder && placeholderIndex != leftPuzzleLabelIndex! + 1 {
                        
                        removePlaceholder()
                        
                        insertPlaceholder(at: leftPuzzleLabelIndex! + 1)
                        
                    } else if !hasPlaceholder {
                        
                        insertPlaceholder(at: leftPuzzleLabelIndex! + 1)
                        
                    } else {
                        
                    }
                    
                    
                } else if hasPlaceholder && leftPuzzleLabel.label != kPlaceholderLabel.label && rightPuzzleLabel.label != kPlaceholderLabel.label && rightPuzzleLabel.label.text! != Symbols.Equals {
                    
                    removePlaceholder()
                }
            } else if hasPlaceholder {
                
                removePlaceholder()
            }
        } else if hasPlaceholder {
            
            removePlaceholder()
        }
    }
    
    func operatorEndedPanning(label: UILabel, isDefaultOperator: Bool) {
        label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        if (label.center.y >= kPuzzleLabelsYPosition - kPuzzleLabelSize.height/2 && label.center.y <= kPuzzleLabelsYPosition + kPuzzleLabelSize.height/2) {
            
            if hasPlaceholder {
                puzzleLabels.remove(at: placeholderIndex!)
                
                let operatorPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PuzzleViewController.puzzleOperatorPanned(_:)))
                
                let newLabel = PuzzleLabel(text: label.text!, isOperand: false, isOperator: true, isSolution: false)
                
                newLabel.label.addGestureRecognizer(operatorPanGestureRecognizer)
                
                puzzleLabels.insert(newLabel, at: placeholderIndex!)
                
                placePuzzle(isNewPuzzle: false)
                
                displayExpression()
                
                switch gameType! {
                case .original:
                    updateBestScore()
                case .challenge:
                    if correctChallengeSolution() {
                        challengePuzzleActionSheet()
                        challengeModel.completeCurrentPuzzle()
                    }
                case .timed:
                    if correctTimedSolution() {
                        timedModel.completePuzzle()
                        timedCompletedLabel!.text = "Completed: \(timedModel.completedPuzzles())"
                        self.newPuzzleButtonPressed(UIButton())
                    }
                }
                
                label.alpha = 0.0
                
                if isDefaultOperator {
                    label.center = self.initialPoint
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        label.alpha = 1.0
                    })
                } else {
                    label.removeFromSuperview()
                }
                
                hasPlaceholder = false
            } else {
                if isDefaultOperator {
                    UIView.animate(withDuration: 0.5, animations: {
                        label.center = self.initialPoint
                    })
                } else {
                    displayExpression()
                    
                    switch gameType! {
                    case .original:
                        updateBestScore()
                    default: break
                    }
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        label.alpha = 0.0
                    }, completion: { (value) in
                        label.removeFromSuperview()
                    })
                }
            }
        } else {
            if isDefaultOperator {
                UIView.animate(withDuration: 0.5, animations: {
                    label.center = self.initialPoint
                })
            } else {
                
                displayExpression()
                
                switch gameType! {
                case .original:
                    updateBestScore()
                default: break
                }
                
                UIView.animate(withDuration: 0.5, animations: {
                    label.alpha = 0.0
                }, completion: { (value) in
                    label.removeFromSuperview()
                })
            }
        }
    }
    
    // MARK: - Placeholder Manipulation
    //
    func insertPlaceholder(at index: Int) {
        placeholderIndex = index
        puzzleLabels.insert(kPlaceholderLabel, at: placeholderIndex!)
        placePuzzle(isNewPuzzle: false)
        hasPlaceholder = true
    }
    
    func removePlaceholder() {
        puzzleLabels.remove(at: placeholderIndex!)
        placePuzzle(isNewPuzzle: false)
        hasPlaceholder = false
        placeholderIndex = nil
    }
    
    // MARK: - Custom Configuration Updates
    //
    func displayExpression() {
        
        var newExpression : [String] = []
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand || puzzleLabel.isOperator {
                newExpression.append(puzzleLabel.label.text!)
            }
        }
        
        let expression = puzzleModel.expressionWithSolutionFor(expression: newExpression)
        
        if let expression = expression {
            expressionLabel!.text = expression
        } else {
            expressionLabel!.text = ""
        }
        
    }
    
    func updateBestScore() {
        
        var newExpression : [String] = []
        
        var bestScore : Int?
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand || puzzleLabel.isOperator {
                newExpression.append(puzzleLabel.label.text!)
            }
        }
        
        if let solution = puzzleModel.solutionFor(expression: newExpression) {
            bestScore = bestScoreModel.calculateBestSolution(withEquation: puzzleModel.equation!, withSolution: solution)
        } else {
            bestScore = bestScoreModel.currentBestSolution()
        }
        
        if let best = bestScore {
            bestScoreLabel!.text = "Best: " + String(best)
        } else {
            bestScoreLabel!.text = "Best: N/A"
        }
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
    
    func challengePuzzleActionSheet() {
        
        let alertController : UIAlertController
        
        if challengeModel.hasNextPuzzle() {
            
            alertController = UIAlertController(title: "Congrats!", message: "You have completed Puzzle #\(challengeModel.currentPuzzleNumber())", preferredStyle: .actionSheet)
            
            let nextPuzzleAction = UIAlertAction(title: "Next Puzzle", style: .default)
            { (action) in
                self.challengeEquation = self.challengeModel.nextEquation()
                self.setupPuzzle(withEquation: self.challengeEquation!)
            }
            alertController.addAction(nextPuzzleAction)
            
            
        } else {
            
            switch challengeModel.difficulty {
            case .easy:
                alertController = UIAlertController(title: "Congrats!", message: "You have completed all of the Easy Puzzles!", preferredStyle: .actionSheet)
                let nextDifficultyAction = UIAlertAction(title: "Continue to Medium Puzzles", style: .default)
                { (action) in
                    self.challengeModel.changeDifficulty(toDifficulty: .medium)
                    self.challengeEquation = self.challengeModel.nextEquation()
                    self.setupPuzzle(withEquation: self.challengeEquation!)
                }
                alertController.addAction(nextDifficultyAction)
            case .medium:
                alertController = UIAlertController(title: "Congrats!", message: "You have completed all of the Medium Puzzles!", preferredStyle: .actionSheet)
                let nextDifficultyAction = UIAlertAction(title: "Continue to Hard Puzzles", style: .default)
                { (action) in
                    self.challengeModel.changeDifficulty(toDifficulty: .hard)
                    self.challengeEquation = self.challengeModel.nextEquation()
                    self.setupPuzzle(withEquation: self.challengeEquation!)
                }
                alertController.addAction(nextDifficultyAction)
            case .hard:
                alertController = UIAlertController(title: "Congrats!", message: "You have completed ALL of the puzzles!", preferredStyle: .actionSheet)
            }
            
            
        }
        
        let returnToMenuAction = UIAlertAction(title: "Return to Challenge Menu", style: .destructive)
        { (action) in
            self.navigationController!.popViewController(animated: true)
        }
        alertController.addAction(returnToMenuAction)
        
        self.present(alertController, animated: true)
    }
    
    func timerFired(timer : Timer) {
        
        if let remaining = timedModel.remainingMinutesSeconds(timeElapsed: timer.timeInterval) {
            timerLabel!.text = remaining
        } else {
            timer.invalidate()
            
            let alertController = UIAlertController(title: "Congrats!", message: "You have completed \(timedModel.completedPuzzles()) puzzles!", preferredStyle: .actionSheet)
            
            let restartAction = UIAlertAction(title: "Restart", style: .default)
            { (action) in
                
                self.timedModel.restart()
                
                self.timedCompletedLabel!.text = "Completed: \(self.timedModel.completedPuzzles())"
                self.timerLabel!.text = "\(self.timedModel.remainingMinutesSeconds(timeElapsed: 0.0)!)"
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PuzzleViewController.timerFired(timer:)), userInfo: nil, repeats: true)
                
                self.newPuzzleButtonPressed(UIButton())
                
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(restartAction)
            
            let returnToMenuAction = UIAlertAction(title: "Return to Timed Options Menu", style: .destructive)
            { (action) in
                alertController.dismiss(animated: true, completion: nil)
                self.navigationController!.popViewController(animated: true)
            }
            alertController.addAction(returnToMenuAction)
            
            self.present(alertController, animated: true)
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
    
    // MARK: - Puzzle Updates
    //
    func newPuzzleButtonPressed(_ : UIButton) {
        
        let equation : Equation
        
        switch difficulty! {
        case .easy: equation = puzzleModel.newEquation(operands: 3)
        case .medium: equation = puzzleModel.newEquation(operands: 4)
        case .hard: equation = puzzleModel.newEquation(operands: 5)
        }
        
        switch gameType! {
        case .timed: timedModel.updateSolution(solution: equation.solution.number!)
        default: break
        }
        
        self.setupPuzzle(withEquation: equation)
        
        if gameType == .original {
            bestScoreModel.resetBestSolution()
            bestScoreLabel!.text = "Best: N/A"
        }
    }
    
    func setupPuzzle(withEquation eq: Equation) {
        
        for puzzleLabel in puzzleLabels {
            
            UIView.animate(withDuration: 0.2, animations: {
                puzzleLabel.label.alpha = 0.0
            }, completion: { (value) in
                puzzleLabel.label.removeFromSuperview()
            })
        }
        
        puzzleLabels = []
        
        for element in eq.elements {
            if let _ = element.number {
                let newLabel = PuzzleLabel(text: element.string, isOperand: true, isOperator: false, isSolution: false)
                puzzleLabels.append(newLabel)
            }
            
            if let _ = element.equals {
                puzzleLabels.append(PuzzleLabel(text: element.string, isOperand: false, isOperator: false, isSolution: false))
            }
        }
        
        
        puzzleLabels.append(PuzzleLabel(text: eq.solution.string, isOperand: false, isOperator: false, isSolution: true))
        
        hasPlaceholder = false
        
        placePuzzle(isNewPuzzle: true)
        
        expressionLabel!.text = ""
    }
    
    func placePuzzle(isNewPuzzle: Bool) {
        
        let totalWidth = self.view.frame.size.width - kLabelBuffer*2.0
        
        let oneWidth = totalWidth/CGFloat(puzzleLabels.count)
        
        let oneWidthCenter = oneWidth/2
        
        for (i, puzzleLabel) in puzzleLabels.enumerated() {
            
            let xPositionCenter: CGFloat
            
            xPositionCenter = oneWidth*CGFloat(i) + oneWidthCenter
            
            if isNewPuzzle {
            
                puzzleLabel.label.center = CGPoint(x: xPositionCenter, y: kPuzzleLabelsYPosition)
                
                puzzleLabel.label.alpha = 0.0
            
                self.view.addSubview(puzzleLabel.label)
            
            } else {
                
                if self.view.subviews.contains(puzzleLabel.label) {
                    UIView.animate(withDuration: 0.2, animations: {
                        puzzleLabel.label.center = CGPoint(x: xPositionCenter, y: self.kPuzzleLabelsYPosition)
                    })
                } else {
                    self.view.addSubview(puzzleLabel.label)
                    puzzleLabel.label.center = CGPoint(x: xPositionCenter, y: kPuzzleLabelsYPosition)
                }
            }
        }
        
        if isNewPuzzle {
            for puzzleLabel in puzzleLabels {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
                    puzzleLabel.label.alpha = 1.0
                }, completion: nil)
            }
        }
    }
}
