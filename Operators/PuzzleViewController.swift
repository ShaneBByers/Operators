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
    var isMovable : Bool
    let label : UILabel
    var lockLabel : UILabel?
    var operatorPanGestureRecognizer : UIPanGestureRecognizer
    var operatorDoubleTapGestureRecognizer : UITapGestureRecognizer
    var operatorHoldGestureRecognizer : UILongPressGestureRecognizer
    
    init(text: String, isOperand: Bool, isOperator: Bool, isSolution: Bool, isMovable: Bool, viewController: PuzzleViewController?) {
        let _label : UILabel
        
        if isSolution {
            let width = 30*text.characters.count + 5
            _label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 60))
        } else {
            _label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        }
        
        _label.font = Fonts.wRhC
        _label.textAlignment = .center
        _label.text = text
        
        if !isOperator {
            _label.textColor = .green
        }
        
        operatorPanGestureRecognizer = UIPanGestureRecognizer(target: viewController, action: #selector(PuzzleViewController.puzzleOperatorPanned(_:)))
        
        operatorDoubleTapGestureRecognizer = UITapGestureRecognizer(target: viewController, action: #selector(PuzzleViewController.puzzleOperatorDoubleTapped(_:)))
        operatorDoubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        operatorHoldGestureRecognizer = UILongPressGestureRecognizer(target: viewController, action: #selector(PuzzleViewController.puzzleOperatorHeld(_:)))
        
        if viewController != nil {
            _label.addGestureRecognizer(operatorPanGestureRecognizer)
            _label.addGestureRecognizer(operatorDoubleTapGestureRecognizer)
            _label.addGestureRecognizer(operatorHoldGestureRecognizer)
        }
        
        if isOperator {
            _label.isUserInteractionEnabled = true
            let _lockLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            
            _lockLabel.font = Fonts.wRhC
            _lockLabel.text = "🔒"
            _lockLabel.textAlignment = .center
            _lockLabel.alpha = 0.5
            _lockLabel.isHidden = isMovable
            self.lockLabel = _lockLabel
        }
        
        self.label = _label
        self.isOperand = isOperand
        self.isOperator = isOperator
        self.isMovable = isMovable
        
    }
    
    private init(label: UILabel, lockLabel: UILabel, isMovable: Bool, operatorPanGestureRecognizer: UIPanGestureRecognizer, operatorDoubleTapGestureRecognizer: UITapGestureRecognizer, operatorHoldGestureRecognizer: UILongPressGestureRecognizer) {
        self.isOperand = false
        self.isOperator = true
        self.isMovable = isMovable
        self.label = label
        self.lockLabel = lockLabel
        self.operatorPanGestureRecognizer = operatorPanGestureRecognizer
        self.operatorDoubleTapGestureRecognizer = operatorDoubleTapGestureRecognizer
        self.operatorHoldGestureRecognizer = operatorHoldGestureRecognizer
        
        if isMovable {
            self.label.addGestureRecognizer(operatorPanGestureRecognizer)
            self.label.addGestureRecognizer(operatorDoubleTapGestureRecognizer)
            self.label.addGestureRecognizer(operatorHoldGestureRecognizer)
        } else {
            self.label.removeGestureRecognizer(operatorPanGestureRecognizer)
            self.label.removeGestureRecognizer(operatorDoubleTapGestureRecognizer)
        }
    }
    
    func changeLock() -> PuzzleLabel {
        return PuzzleLabel(label: self.label, lockLabel: self.lockLabel!, isMovable: !self.isMovable, operatorPanGestureRecognizer: self.operatorPanGestureRecognizer, operatorDoubleTapGestureRecognizer: self.operatorDoubleTapGestureRecognizer, operatorHoldGestureRecognizer: self.operatorHoldGestureRecognizer)
    }
}


class PuzzleViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Models
    //
    let puzzleModel = PuzzleModel.sharedInstance
    let challengeModel = ChallengeModel.sharedInstance
    let bestScoreModel = BestScoreModel.sharedInstance
    let timedModel = TimedModel.sharedInstance
    let settingsModel = SettingsModel.sharedInstance
    
    // MARK: - Constants
    //
    let kGrowthFactor : CGFloat = 1.1
    let kPuzzleLabelSize : CGSize = CGSize(width: 60, height: 60)
    let kSolutionLabelSize : CGSize = CGSize(width: 120, height: 60)
    let kLabelBuffer : CGFloat = 10
    let kPlaceholderLabel = PuzzleLabel(text: "", isOperand: false, isOperator: false, isSolution: false, isMovable: true, viewController: nil)
    
    let wildcardOperator : UILabel
    
    var hasPlaceholder = false
    var placeholderIndex : Int?
    
    var initialPoint : CGPoint = CGPoint.zero
    var kPuzzleLabelsYPosition : CGFloat = 0.0
    
    // MARK: - Labels
    //
    var defaultOperatorLabels : [UILabel] = []
    var operatorCountLabels : [String:UILabel] = [:]
    
    var puzzleLabels : [PuzzleLabel] = []

    @IBOutlet weak var expressionLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    
    // MARK: - Buttons
    //
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var hintsButton: UIButton!
    @IBOutlet weak var newPuzzleButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    
    // MARK: - Custom Variables
    //
    var gameType : GameType?
    var difficulty : Difficulty?
    var challengeEquation : Equation?
    var timer : Timer?
    var solvePuzzleButtonPressed : Bool = false
    
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
    
    // MARK: - Segues
    //
    @IBAction func backButtonPressed(_ sender: UIButton) {
        resetOnDisappear()
        
        switch gameType! {
        case .challenge:
            performSegue(withIdentifier: "unwindToChallenge", sender: self)
        case .original:
            performSegue(withIdentifier: "unwindToOriginal", sender: self)
        case .timed:
            performSegue(withIdentifier: "unwindToTimed", sender: self)
        }
    }
    
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
        case "timerCompletedSegue":
            let destination = segue.destination as! TimedCompletedViewController
            
            destination.configureText(completedPuzzles: timedModel.completedPuzzles(), score: timedModel.score(), highScore: timedModel.highScore())
            destination.configurePuzzleViewController(viewController: self)
            
            resetOnDisappear()
        case "hintsSegue":
            let destination = segue.destination as! HintsViewController
            
            destination.configureViewController(viewController: self)
        case "unwindToOriginal": break
        case "unwindToChallenge": break
        case "unwindToTimed": break
        default: assert(false, "Unhandled Segue")
        }
    }
    
    
    // MARK: - Init/Load
    //
    required init?(coder aDecoder: NSCoder) {
        for _ in 0..<4 {
            defaultOperatorLabels.append(UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize)))
        }
        wildcardOperator = UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize))
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kPlaceholderLabel.label.alpha = 0.0
        
        kPuzzleLabelsYPosition = self.view.center.y - kPuzzleLabelSize.height - kLabelBuffer
        
        self.intializeGestureRecognizers()
        self.initializeDefaultOperators()
        self.initializeOperatorCountLabels()
        
        expressionLabel.text = ""
        
        hintsButton.alpha = 0.0
        hintsButton.isEnabled = false
        
        newPuzzleButton.alpha = 0.0
        newPuzzleButton.isEnabled = false
        
        solveButton.alpha = 0.0
        solveButton.isEnabled = false
        
        switch gameType! {
        case .original:
            self.initializeBestScore()
            self.newPuzzleButtonPressed(UIButton())
        case .challenge:
            self.initializeChallenge()
            self.setupPuzzle(withEquation: self.challengeEquation!)
        case .timed:
            self.initializeTimer()
            self.newPuzzleButtonPressed(UIButton())
        }
        
        resetButton.alpha = 0.0
        resetButton.isEnabled = false
        
    }
    
    func resetOnDisappear() {
        if let timer = timer {
            timer.invalidate()
        }
        
        switch gameType! {
        case .original: bestScoreModel.resetTotalScore()
        case .timed: timedModel.restart()
        default: break
        }
    }
    
    // MARK: - Initializations
    //
    func initializeDefaultOperators() {
        for label in defaultOperatorLabels {
            label.font = Fonts.wRhC
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            
            self.view.addSubview(label)
        }
        
        defaultOperatorLabels[0].text = Symbols.Add
        defaultOperatorLabels[1].text = Symbols.Subtract
        defaultOperatorLabels[2].text = Symbols.Multiply
        defaultOperatorLabels[3].text = Symbols.Divide
        
        wildcardOperator.font = Fonts.wRhC
        wildcardOperator.textAlignment = .center
        wildcardOperator.isUserInteractionEnabled = true
        wildcardOperator.text = Symbols.Wildcard
        wildcardOperator.alpha = 0.0
        
        placeDefaultOperators(isInitial: true)
    }
    
    func initializeOperatorCountLabels() {
        for operatorLabel in defaultOperatorLabels {
            let countLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize))
            countLabel.text = ""
            countLabel.font = Fonts.wRhC
            countLabel.textColor = .green
            countLabel.textAlignment = .center
            countLabel.center.x = operatorLabel.frame.origin.x + operatorLabel.frame.size.width
            countLabel.center.y = operatorLabel.frame.origin.y
            countLabel.alpha = 0.0
            operatorCountLabels[operatorLabel.text!] = countLabel
        }
    }
    
    func placeDefaultOperators(isInitial: Bool) {
        let yPositionCenter = primaryLabel.frame.origin.y - kPuzzleLabelSize.height/2.0
        
        let totalWidth = self.view.frame.size.width
        
        let oneWidth = totalWidth/CGFloat(defaultOperatorLabels.count)
        
        let oneWidthCenter = oneWidth/2
        
        for (i, label) in defaultOperatorLabels.enumerated() {
            let xPositionCenter: CGFloat
            
            xPositionCenter = oneWidth*CGFloat(i) + oneWidthCenter
            
            if isInitial {
                label.center = CGPoint(x: xPositionCenter, y: yPositionCenter)
            } else {
                if label.text == Symbols.Wildcard {
                    label.center = CGPoint(x: xPositionCenter, y: yPositionCenter)
                    self.view.addSubview(label)
                    UIView.animate(withDuration: 0.2, animations: { 
                        label.alpha = 1.0
                    })
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        label.center = CGPoint(x: xPositionCenter, y: yPositionCenter)
                        
                        if let countLabel = self.operatorCountLabels[label.text!] {
                            countLabel.center.x = label.frame.origin.x + label.frame.size.width
                        }
                    })
                }
            }
        }
    }
    
    func initializeTimer() {
        
        primaryLabel.textColor = UIColor.green
        primaryLabel.text = "\(timedModel.remainingMinutesSeconds(timeElapsed: 0.0)!)"
        
        let timerInterval : TimeInterval = 0.1
        
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(PuzzleViewController.timerFired(timer:)), userInfo: nil, repeats: true)
        
        newPuzzleButton.alpha = 1.0
        newPuzzleButton.isEnabled = true
        
        secondaryLabel.text = "Score: 0"
    }
    
    func initializeBestScore() {
        
        primaryLabel.text = "Score: 0"
        
        secondaryLabel.text = "Current: N/A"
        
        newPuzzleButton.alpha = 1.0
        newPuzzleButton.isEnabled = true
        
        solveButton.alpha = 1.0
        solveButton.isEnabled = true
        
        hintsButtonAction(enable: true)
    }
    
    func initializeChallenge() {
        primaryLabel.text = "\(challengeModel.difficulty.rawValue) Puzzle #\(challengeModel.currentPuzzleNumber())"
        secondaryLabel.alpha = 0.0
    }
    
    // MARK: - Label Gestures
    //
    func intializeGestureRecognizers() {
        for label in defaultOperatorLabels {
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PuzzleViewController.defaultOperatorPanned(_:)))
            panRecognizer.delegate = self
            label.addGestureRecognizer(panRecognizer)
        
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PuzzleViewController.defaultOperatorDoubleTapped(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            doubleTapRecognizer.delegate = self
            label.addGestureRecognizer(doubleTapRecognizer)
        }
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PuzzleViewController.defaultOperatorPanned(_:)))
        panRecognizer.delegate = self
        wildcardOperator.addGestureRecognizer(panRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PuzzleViewController.defaultOperatorDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delegate = self
        wildcardOperator.addGestureRecognizer(doubleTapRecognizer)
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
    
    func defaultOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        
        var resetEnabled = false
        
        if let view = recognizer.view {
            let label = view as! UILabel
            var operatorCounter = 0
            for i in self.puzzleLabels.indices {
                if self.puzzleLabels[i].isOperator  {
                    operatorCounter += 1
                }
                if self.puzzleLabels[i].isOperand && self.puzzleLabels[i+1].isOperand && !(label.text! == Symbols.Divide && puzzleLabels[i+1].label.text! == "0") {
                    
                    operatorCounter += 1
                    
                    let newLabel : PuzzleLabel
                    
                    if label.text! == Symbols.Wildcard {
                        var elementOperatorCounter = 0
                        var operatorText : String?
                        for element in puzzleModel.equation!.elements {
                            if Int(element.string) == nil {
                                elementOperatorCounter += 1
                            }
                            if operatorCounter == elementOperatorCounter {
                                operatorText = element.string
                                break
                            }
                        }
                        
                        newLabel = PuzzleLabel(text: operatorText!, isOperand: false, isOperator: true, isSolution: false, isMovable: false, viewController: self)
                        
                        defaultOperatorLabels.remove(at: 2)
                        
                        placeDefaultOperators(isInitial: false)
                        
                        wildcardOperator.removeFromSuperview()
                    } else {
                        newLabel = PuzzleLabel(text: label.text!, isOperand: false, isOperator: true, isSolution: false, isMovable: true, viewController: self)
                    }
                    
                    self.puzzleLabels.insert(newLabel, at: i+1)
                    
                    self.placePuzzle(isNewPuzzle: false)
                    
                    self.displayExpression()
                    
                    switch gameType! {
                    case .original:
                        if !solvePuzzleButtonPressed {
                            updateBestScore()
                        }
                    case .challenge:
                        if correctChallengeSolution() {
                            performSegue(withIdentifier: "challengePuzzleCompletedSegue", sender: self)
                            challengeModel.completeCurrentPuzzle()
                        }
                    case .timed:
                        updateTimedScore()
                        if correctTimedSolution() {
                            timedModel.completePuzzle()
                            self.newPuzzleButtonPressed(UIButton())
                            resetButtonAction(enable: false)
                            addTime(difficulty: difficulty!)
                        }
                    }
                    
                    break
                }
            }
        }
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperator && puzzleLabel.isMovable {
                resetEnabled = true
            }
        }
        
        switch gameType! {
        case .original:
            if let score = bestScoreModel.currentScore() {
                if score == 100 {
                    resetEnabled = false
                }
            }
        default: break
        }
        
        resetButtonAction(enable: resetEnabled)
        
    }
    
    func puzzleOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            let label = view as! UILabel
            var hasOperator : Bool = false
            
            for i in puzzleLabels.indices {
                if puzzleLabels[i].label == label {
                    UIView.animate(withDuration: 0.2, animations: { 
                        self.puzzleLabels[i].label.alpha = 0.0
                    }, completion: { (value) in
                        self.puzzleLabels[i].label.removeFromSuperview()
                        self.puzzleLabels.remove(at: i)
                        
                        for puzzleLabel in self.puzzleLabels {
                            if puzzleLabel.isOperator {
                                hasOperator = true
                                break
                            }
                        }
                        
                        self.placePuzzle(isNewPuzzle: false)
                        
                        self.displayExpression()
                        
                        if !hasOperator {
                            self.resetButtonAction(enable: false)
                        }
                    })
                    break
                }
            }
        }
    }
    
    func puzzleOperatorHeld(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let view = recognizer.view {
                let label = view as! UILabel
                for i in puzzleLabels.indices {
                    if puzzleLabels[i].label == label {
                        puzzleLabels[i] = puzzleLabels[i].changeLock()
                        let puzzleLabel = puzzleLabels[i]
                        
                        if let lockLabel = puzzleLabel.lockLabel {
                            if puzzleLabel.isMovable {
                                UIView.animate(withDuration: 0.2, animations: {
                                    lockLabel.alpha = 0.0
                                }, completion: { (value) in
                                    lockLabel.isHidden = true
                                })
                            } else {
                                lockLabel.alpha = 0.0
                                lockLabel.isHidden = false
                                UIView.animate(withDuration: 0.2, animations: {
                                    lockLabel.alpha = 0.5
                                })
                            }
                        }
                        break
                    }
                }
            }
        }
        var resetEnabled = false
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperator && puzzleLabel.isMovable {
                resetEnabled = true
            }
        }
        
        resetButtonAction(enable: resetEnabled)
    }
    
    // MARK: - Label Panned Cases
    //
    func operatorBeganPanning(label: UILabel, isDefaultOperator: Bool) {
        
        label.transform = CGAffineTransform(scaleX: kGrowthFactor, y: kGrowthFactor)
        
        initialPoint = label.center
        
        self.view.bringSubview(toFront: label)
        
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
        
        if (label.center.y >= kPuzzleLabelsYPosition - kPuzzleLabelSize.height/2.0 && label.center.y <= kPuzzleLabelsYPosition + kPuzzleLabelSize.height/2.0) {
            
            var leftPuzzleLabel : PuzzleLabel? = nil
            
            var leftPuzzleLabelIndex : Int?
            
            var rightPuzzleLabel : PuzzleLabel? = nil
            
            for (i,puzzleLabel) in puzzleLabels.enumerated() {
                if i == 0 && label.center.x < puzzleLabel.label.center.x {
                    break
                }
                if i > 0 && leftPuzzleLabelIndex == nil && label.center.x < puzzleLabel.label.center.x && puzzleLabel.isOperand {
                    leftPuzzleLabelIndex = i - 1
                }
            }
            
            if let index = leftPuzzleLabelIndex {
                if index >= 0 {
                    leftPuzzleLabel = puzzleLabels[index]
                }
                if index + 3 < puzzleLabels.count {
                    rightPuzzleLabel = puzzleLabels[index+1]
                }
            }
            
            if let leftPuzzleLabel = leftPuzzleLabel,
                let rightPuzzleLabel = rightPuzzleLabel {
                
                if leftPuzzleLabel.isOperand && rightPuzzleLabel.isOperand && !(label.text! == Symbols.Divide && rightPuzzleLabel.label.text! == "0") {
                    
                    if hasPlaceholder && placeholderIndex != leftPuzzleLabelIndex! + 1 {
                        
                        if placeholderIndex! < leftPuzzleLabelIndex! {
                        
                            removePlaceholder()
                        
                            insertPlaceholder(at: leftPuzzleLabelIndex!)
                            
                        } else {
                            
                            removePlaceholder()
                            
                            insertPlaceholder(at: leftPuzzleLabelIndex! + 1)
                            
                        }
                        
                    } else if !hasPlaceholder {
                        insertPlaceholder(at: leftPuzzleLabelIndex! + 1)
                    }
                } else if hasPlaceholder && leftPuzzleLabel.label != kPlaceholderLabel.label && rightPuzzleLabel.label != kPlaceholderLabel.label && rightPuzzleLabel.label.text! == Symbols.Equals {
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
                
                
                
                let newLabel : PuzzleLabel
                
                if label.text! == Symbols.Wildcard {
                    var operatorCounter = 0
                    for i in puzzleLabels.indices {
                        if (puzzleLabels[i].isOperator || (puzzleLabels[i].isOperand && puzzleLabels[i+1].isOperand) || i == placeholderIndex!) {
                            operatorCounter += 1
                        }
                        if i == placeholderIndex! {
                            break
                        }
                    }
                    
                    var elementOperatorCounter = 0
                    var operatorText : String?
                    for element in puzzleModel.equation!.elements {
                        if Int(element.string) == nil {
                            elementOperatorCounter += 1
                        }
                        if operatorCounter == elementOperatorCounter {
                            operatorText = element.string
                            break
                        }
                    }
                    
                    newLabel = PuzzleLabel(text: operatorText!, isOperand: false, isOperator: true, isSolution: false, isMovable: false, viewController: self)
                    
                    defaultOperatorLabels.remove(at: 2)
                    
                    placeDefaultOperators(isInitial: false)
                    
                    wildcardOperator.removeFromSuperview()
                } else {
                    newLabel = PuzzleLabel(text: label.text!, isOperand: false, isOperator: true, isSolution: false, isMovable: true, viewController: self)
                }
                
                puzzleLabels.remove(at: placeholderIndex!)
                
                puzzleLabels.insert(newLabel, at: placeholderIndex!)
                
                placePuzzle(isNewPuzzle: false)
                
                displayExpression()
                
                switch gameType! {
                case .original:
                    if !solvePuzzleButtonPressed {
                        updateBestScore()
                    }
                case .challenge:
                    if correctChallengeSolution() {
                        performSegue(withIdentifier: "challengePuzzleCompletedSegue", sender: self)
                        challengeModel.completeCurrentPuzzle()
                    }
                case .timed:
                    updateTimedScore()
                    if correctTimedSolution() {
                        timedModel.completePuzzle()
                        self.newPuzzleButtonPressed(UIButton())
                        resetButtonAction(enable: false)
                        addTime(difficulty: difficulty!)
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
        
        var resetEnabled = false
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperator && puzzleLabel.isMovable {
                resetEnabled = true
            }
        }
        
        if gameType! == .original {
            if let score = bestScoreModel.currentScore() {
                if score == 100 {
                    resetEnabled = false
                }
            }
        }
        
        resetButtonAction(enable: resetEnabled)
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
        
        var currentScore : Int?
        
        let oldScore = bestScoreModel.currentScore()
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand || puzzleLabel.isOperator {
                newExpression.append(puzzleLabel.label.text!)
            }
        }
        
        if let solution = puzzleModel.solutionFor(expression: newExpression) {
            currentScore = bestScoreModel.updateScores(withEquation: puzzleModel.equation!, withSolution: solution, forDifficulty: difficulty!)
        } else {
            currentScore = bestScoreModel.currentScore()
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
            if best == 100 {
                hintsButtonAction(enable: false)
                solveButtonAction(enable: false)
            }
        } else {
            secondaryLabel.text = "Current: N/A"
        }
        
        primaryLabel.text = "Score: " + String(bestScoreModel.totalScore())
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
    
    func nextChallengePuzzle() {
        self.challengeEquation = self.challengeModel.nextEquation()
        primaryLabel.text = "\(challengeModel.difficulty.rawValue) Puzzle #\(challengeModel.currentPuzzleNumber())"
        self.setupPuzzle(withEquation: self.challengeEquation!)
        resetButtonAction(enable: false)
    }
    
    func restartTimedPuzzle() {
        self.timedModel.restart()
        
        self.primaryLabel.text = "\(self.timedModel.remainingMinutesSeconds(timeElapsed: 0.0)!)"
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PuzzleViewController.timerFired(timer:)), userInfo: nil, repeats: true)
        
        self.newPuzzleButtonPressed(UIButton())
    }
    
    func timerFired(timer : Timer) {
        
        if let remaining = timedModel.remainingMinutesSeconds(timeElapsed: timer.timeInterval) {
            primaryLabel.text = remaining
            let doubleRemaining = Double(timedModel.currentTime!)
            let intRemaining = Int(doubleRemaining)
            if doubleRemaining <= 10.1 && abs(doubleRemaining - Double(intRemaining)) <= 0.1 {
                primaryLabel.textColor = .red
            } else {
                primaryLabel.textColor = .green
            }
        } else {
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
    
    func addTime(difficulty diff: Difficulty) {
        let timeAdded = timedModel.addTime(difficulty: diff)
        primaryLabelUpdate(withText: "\(Int(timeAdded))")
    }
    
    func primaryLabelUpdate(withText text: String) {
        let primaryUpdateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 60))
        primaryUpdateLabel.font = Fonts.wRhC
        primaryUpdateLabel.text = "+\(text)"
        primaryUpdateLabel.center.y = primaryLabel.center.y
        primaryUpdateLabel.center.x = primaryLabel.frame.origin.x + primaryLabel.frame.size.width + 4.0*kLabelBuffer
        primaryUpdateLabel.alpha = 0.0
        self.view.addSubview(primaryUpdateLabel)
        
        UIView.animate(withDuration: 0.5, animations: {
            primaryUpdateLabel.alpha = 1.0
            primaryUpdateLabel.center.y -= 2.0*self.kLabelBuffer
        }) { (value) in
            UIView.animate(withDuration: 0.5, animations: {
                primaryUpdateLabel.alpha = 0.0
                primaryUpdateLabel.center.y -= 2.0*self.kLabelBuffer
            }, completion: { (value) in
                primaryUpdateLabel.removeFromSuperview()
            })
        }
    }
    
    func resetHints() {
        for countLabel in operatorCountLabels.values {
            UIView.animate(withDuration: 0.2, animations: { 
                countLabel.alpha = 0.0
            }, completion: { (value) in
                countLabel.text = ""
                countLabel.removeFromSuperview()
            })
        }
    }
    
    func resetButtonAction(enable: Bool) {
        if enable {
            resetButton.isEnabled = true
            UIView.animate(withDuration: 0.2, animations: { 
                self.resetButton.alpha = 1.0
            })
        } else {
            resetButton.isEnabled = false
            UIView.animate(withDuration: 0.2, animations: { 
                self.resetButton.alpha = 0.0
            })
        }
    }
    
    func hintsButtonAction(enable: Bool) {
        if enable {
            hintsButton.isEnabled = true
            UIView.animate(withDuration: 0.2, animations: {
                self.hintsButton.alpha = 1.0
            })
        } else {
            hintsButton.isEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                self.hintsButton.alpha = 0.0
            })
        }
    }
    
    func solveButtonAction(enable: Bool) {
        if enable {
            solveButton.isEnabled = true
            UIView.animate(withDuration: 0.2, animations: {
                self.solveButton.alpha = 1.0
            })
        } else {
            solveButton.isEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                self.solveButton.alpha = 0.0
            })
        }
    }
    
    // MARK: - Puzzle Updates
    //
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        var count = 0
        
        let max = puzzleLabels.count
        
        var operators : [Int] = []
        
        expressionLabel!.text = ""
        
        resetButton.alpha = 0.0
        
        resetButton.isEnabled = false
        
        for (i,puzzleLabel) in puzzleLabels.enumerated() {
            UIView.animate(withDuration: 0.2, animations: {
                if puzzleLabel.isOperator && puzzleLabel.isMovable {
                    puzzleLabel.label.alpha = 0.0
                }
            }, completion: { (value) in
                if puzzleLabel.isOperator && puzzleLabel.isMovable {
                    operators.append(i)
                }
                count += 1
                if count == max {
                    operators.sort(by: >)
                    for index in operators {
                        self.puzzleLabels.remove(at: index)
                    }
                    self.placePuzzle(isNewPuzzle: false)
                }
            })
        }
    }
    
    @IBAction func newPuzzleButtonPressed(_ sender: UIButton) {
        let equation : Equation
        
        switch difficulty! {
        case .easy: equation = puzzleModel.newEquation(operands: 3)
        case .medium: equation = puzzleModel.newEquation(operands: 4)
        case .hard: equation = puzzleModel.newEquation(operands: 5)
        case .random:
            let operands = Int(arc4random_uniform(3) + 3)
            equation = puzzleModel.newEquation(operands: operands)
        }
        
        switch gameType! {
        case .original:
            bestScoreModel.resetCurrentScore()
            primaryLabel.text = "Score: " + String(bestScoreModel.totalScore())
            secondaryLabel.text = "Current: N/A"
        case .timed:
            timedModel.resetCurrentScore()
            secondaryLabel.text = "Score: " + String(timedModel.score())
            timedModel.updateSolution(solution: equation.solution.number!)
        default: break
        }
        
        self.setupPuzzle(withEquation: equation)
        
        resetButtonAction(enable: false)
        
        hintsButtonAction(enable: true)
        
        resetHints()
        
        if defaultOperatorLabels[2].text! == Symbols.Wildcard {
            defaultOperatorLabels[2].removeFromSuperview()
            defaultOperatorLabels.remove(at: 2)
            placeDefaultOperators(isInitial: false)
        }
        
        if gameType! == .original {
            solveButtonAction(enable: true)
        }
    }

    @IBAction func solveButtonPressed(_ sender: UIButton) {
        solvePuzzleButtonPressed = true
        
        let equation = puzzleModel.equation!
        
        var count = 0
        
        let max = puzzleLabels.count
        
        var operators : [Int] = []
        
        var insertOperators : [PuzzleLabel] = []
        
        for element in equation.elements {
            if Int(element.string) == nil {
                let newLabel = PuzzleLabel(text: element.string, isOperand: false, isOperator: true, isSolution: false, isMovable: false, viewController: self)
                
                insertOperators.append(newLabel)
            }
        }
        
        for (i,puzzleLabel) in puzzleLabels.enumerated() {
            UIView.animate(withDuration: 0.2, animations: {
                if puzzleLabel.isOperator {
                    puzzleLabel.label.alpha = 0.0
                }
            }, completion: { (value) in
                puzzleLabel.label.removeFromSuperview()
                if let lockLabel = puzzleLabel.lockLabel {
                    lockLabel.removeFromSuperview()
                }
                if puzzleLabel.isOperator {
                    operators.append(i)
                }
                count += 1
                if count == max {
                    operators.sort(by: >)
                    for index in operators {
                        self.puzzleLabels.remove(at: index)
                    }
                    for i in self.puzzleLabels.indices {
                        if self.puzzleLabels[i].isOperand && self.puzzleLabels[i+1].isOperand {
                            self.puzzleLabels.insert(insertOperators.removeFirst(), at: i+1)
                        }
                    }
                    
                    self.placePuzzle(isNewPuzzle: false)
                    
                    self.displayExpression()
                    
                    self.resetButtonAction(enable: false)
                    
                    self.hintsButtonAction(enable: false)
                }
            })
        }
        
        solveButtonAction(enable: false)
    }
    
    
    func hintsRandomOperator() {
        var totalOperands : UInt32 = 0
        var totalOperators : UInt32 = 0
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperand {
                totalOperands += 1
            } else if puzzleLabel.isOperator {
                totalOperators += 1
            }
        }
        
        var hintedPositions : [Int] = []
        
        var operatorCounter : Int = 0
        
        for i in puzzleLabels.indices {
            if puzzleLabels[i].isOperator && !puzzleLabels[i].isMovable {
                hintedPositions.append(operatorCounter)
            }
            if puzzleLabels[i].isOperator || (puzzleLabels[i].isOperand && puzzleLabels[i+1].isOperand) {
                operatorCounter += 1
            }
        }
        
        var randomOperatorPosition : Int = Int(arc4random_uniform(totalOperands - 1))
        
        while hintedPositions.contains(randomOperatorPosition) {
            randomOperatorPosition = Int(arc4random_uniform(totalOperands - 1))
        }
        
        var operatorText : String = ""
        
        operatorCounter = 0
        
        for element in puzzleModel.equation!.elements {
            if Int(element.string) == nil {
                if operatorCounter == randomOperatorPosition {
                    operatorText = element.string
                    break
                }
                operatorCounter += 1
            }
        }
        
        operatorCounter = 0
        
        for i in puzzleLabels.indices {
            if operatorCounter == randomOperatorPosition {
                
                if puzzleLabels[i].isOperand && puzzleLabels[i+1].isOperand {
                    
                    let newLabel = PuzzleLabel(text: operatorText, isOperand: false, isOperator: true, isSolution: false, isMovable: false, viewController: self)
                    
                    puzzleLabels.insert(newLabel, at: i+1)
                    
                    placePuzzle(isNewPuzzle: false)
                    
                    displayExpression()
                    
                } else if puzzleLabels[i].isOperator {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.puzzleLabels[i].label.alpha = 0.0
                    }, completion: { (value) in
                        UIView.animate(withDuration: 0.2, animations: {
                            self.puzzleLabels[i].label.text = operatorText
                            self.puzzleLabels[i].label.alpha = 1.0
                        })
                    })
                }
                
                break
                
            }
            if puzzleLabels[i].isOperator || (puzzleLabels[i].isOperand && puzzleLabels[i+1].isOperand) {
                operatorCounter += 1
            }
        }
        
        operatorCounter = 0
        
        for i in puzzleLabels.indices {
            if puzzleLabels[i].isOperator && !puzzleLabels[i].isMovable {
                operatorCounter += 1
            }
        }
        
        if operatorCounter == Int(totalOperands) - 2 {
            hintsButtonAction(enable: false)
        }
    }
    
    func hintsCustomOperator() {
        defaultOperatorLabels.insert(wildcardOperator, at: 2)
        
        placeDefaultOperators(isInitial: false)
    }
    
    func hintsOperatorUses() {
        for operatorLabel in defaultOperatorLabels {
            var operatorCount = 0
            if operatorLabel.text! != Symbols.Wildcard {
                for element in puzzleModel.equation!.elements {
                    if operatorLabel.text! == element.string {
                        operatorCount += 1
                    }
                }
                if let label = operatorCountLabels[operatorLabel.text!] {
                    label.text = "\(operatorCount)"
                    self.view.addSubview(label)
                    label.sendSubview(toBack: self.view)
                    UIView.animate(withDuration: 0.2, animations: {
                        label.alpha = 0.5
                    })
                }
            }
        }
    }
    
    func setupPuzzle(withEquation eq: Equation) {
        
        for puzzleLabel in puzzleLabels {
            
            UIView.animate(withDuration: 0.2, animations: {
                puzzleLabel.label.alpha = 0.0
                if let lockLabel = puzzleLabel.lockLabel {
                    lockLabel.alpha = 0.0
                }
            }, completion: { (value) in
                puzzleLabel.label.removeFromSuperview()
                if let lockLabel = puzzleLabel.lockLabel {
                    lockLabel.removeFromSuperview()
                }
            })
        }
        
        puzzleLabels = []
        
        for element in eq.elements {
            if let _ = element.number {
                let newLabel = PuzzleLabel(text: element.string, isOperand: true, isOperator: false, isSolution: false, isMovable: false, viewController: nil)
                puzzleLabels.append(newLabel)
            }
            
            if let _ = element.equals {
                puzzleLabels.append(PuzzleLabel(text: element.string, isOperand: false, isOperator: false, isSolution: false, isMovable: false, viewController: nil))
            }
        }
        
        
        puzzleLabels.append(PuzzleLabel(text: eq.solution.string, isOperand: false, isOperator: false, isSolution: true, isMovable: false, viewController: nil))
        
        hasPlaceholder = false
        
        placePuzzle(isNewPuzzle: true)
        
        expressionLabel!.text = ""
        
        solvePuzzleButtonPressed = false
    }
    
    func placePuzzle(isNewPuzzle: Bool) {
        
        let solutionWidth = puzzleLabels[puzzleLabels.count - 1].label.frame.size.width
        
        let totalWidth = self.view.frame.size.width - kLabelBuffer*6.0 - solutionWidth - kPuzzleLabelSize.width
        
        let oneWidth = totalWidth/CGFloat(puzzleLabels.count - 2)
        
        let oneWidthCenter = oneWidth/2
        
        for (i, puzzleLabel) in puzzleLabels.enumerated() {
            
            let xPositionCenter: CGFloat
            
            if i == puzzleLabels.count - 1 {
                xPositionCenter = self.view.frame.size.width - kLabelBuffer*2.0 - solutionWidth/2
            } else if i == puzzleLabels.count - 2 {
                xPositionCenter = self.view.frame.size.width - kLabelBuffer*4.0 - solutionWidth - puzzleLabel.label.frame.size.width/2
            } else {
                xPositionCenter = oneWidth*CGFloat(i) + oneWidthCenter
            }
            
            if isNewPuzzle {
            
                puzzleLabel.label.center = CGPoint(x: xPositionCenter, y: kPuzzleLabelsYPosition)
                
                puzzleLabel.label.alpha = 0.0
            
                self.view.addSubview(puzzleLabel.label)
            
            } else {
                
                if self.view.subviews.contains(puzzleLabel.label) {
                    UIView.animate(withDuration: 0.2, animations: {
                        if let lockLabel = puzzleLabel.lockLabel {
                            lockLabel.center = CGPoint(x: xPositionCenter, y: self.kPuzzleLabelsYPosition)
                        }
                        puzzleLabel.label.center = CGPoint(x: xPositionCenter, y: self.kPuzzleLabelsYPosition)
                    })
                } else {
                    if let lockLabel = puzzleLabel.lockLabel {
                        self.view.addSubview(lockLabel)
                        lockLabel.center = CGPoint(x: xPositionCenter, y: self.kPuzzleLabelsYPosition)
                    }
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
