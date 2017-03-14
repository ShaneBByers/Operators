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
    
    private let kDefaultLabelSize = 60
    private let kLockString = "🔒"
    private let kUnlockString = "🔓"
    let kLockLabelAlpha : CGFloat = 0.5
    
    init(text: String, isOperand: Bool, isOperator: Bool, isSolution: Bool, isMovable: Bool, viewController: PuzzleViewController?) {
        
        let _label : UILabel
        
        if isSolution {
            let width = 30*text.characters.count + 5
            _label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: kDefaultLabelSize))
        } else {
            _label = UILabel(frame: CGRect(x: 0, y: 0, width: kDefaultLabelSize, height: kDefaultLabelSize))
        }
        
        _label.font = Fonts.wRhC
        _label.textAlignment = .center
        _label.text = text
        
        let colorElements : ColorElements
        
        switch ColorScheme.scheme {
        case .monochrome: colorElements = SchemeElements.monochrome
        case .ocean: colorElements = SchemeElements.ocean
        case .daybreak: colorElements = SchemeElements.daybreak
        }
        
        if isOperator {
            _label.textColor = .black
        } else {
            _label.textColor = colorElements.buttonColor
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
            let _lockLabel = UILabel(frame: CGRect(x: 0, y: 0, width: kDefaultLabelSize, height: kDefaultLabelSize))
            
            _lockLabel.font = Fonts.wRhC
            _lockLabel.text = kUnlockString
            _lockLabel.textAlignment = .center
            _lockLabel.alpha = kLockLabelAlpha
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
    
    func changeLockString() {
        if lockLabel!.text! == kLockString {
            lockLabel!.text = kUnlockString
        } else {
            lockLabel!.text = kLockString
        }
    }
}


class PuzzleViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Models
    //
    let puzzleModel = PuzzleModel.sharedInstance
    let challengeModel = ChallengeModel.sharedInstance
    let bestScoreModel = BestScoreModel.sharedInstance
    let timedModel = TimedModel.sharedInstance
    let hintsModel = HintsModel.sharedInstance
    let settingsModel = SettingsModel.sharedInstance
    
    // MARK: - Constants
    //
    let kInitDefaultOperatorCount = 4
    let kGrowthFactor : CGFloat = 1.1
    let kPuzzleLabelSize : CGSize = CGSize(width: 60, height: 60)
    let kSolutionLabelSize : CGSize = CGSize(width: 120, height: 60)
    let kLabelBuffer : CGFloat = 10
    let kPlaceholderLabel = PuzzleLabel(text: "", isOperand: false, isOperator: false, isSolution: false, isMovable: true, viewController: nil)
    let kShortAnimationDuration : TimeInterval = 0.2
    let kLongAnimationDuration : TimeInterval = 0.5
    let kWildcardOperatorPosition = 2
    let kTimerInterval : TimeInterval = 0.1
    let kOperatorUsesLabelAlpha : CGFloat = 0.5
    
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
    @IBOutlet weak var hintsMultiplierLabel: UILabel!
    
    
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var currentMultiplierLabel: UILabel!
    @IBOutlet weak var nextMultiplierLabel: UILabel!
    
    
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
    let colorElements : ColorElements
    
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
        
        hintsModel.reset()
        
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
            
            var emptyCounter = 0
            
            for i in puzzleLabels.indices {
                if puzzleLabels[i].isOperand && puzzleLabels[i+1].isOperand {
                    emptyCounter += 1
                }
            }
            
            var defaultEnables : [Hint:Bool] = [:]
            
            defaultEnables[.random] = emptyCounter >= 2
            
            defaultEnables[.custom] = emptyCounter >= 1
            
            defaultEnables[.uses] = true
            
            var maxCounts : [Hint:Int] = [:]
            
            maxCounts[.random] = emptyCounter - 1
            
            maxCounts[.custom] = emptyCounter - 1
            
            maxCounts[.uses] = 4
            
            hintsModel.configureDefaults(defaultEnables, max: maxCounts)
            
            destination.configureReturnFunction(returnFunction: self.implementHints)
        case "unwindToOriginal": break
        case "unwindToChallenge": break
        case "unwindToTimed": break
        default: assert(false, "Unhandled Segue")
        }
    }
    
    
    // MARK: - Init/Load
    //
    required init?(coder aDecoder: NSCoder) {
        for _ in 0..<kInitDefaultOperatorCount {
            defaultOperatorLabels.append(UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize)))
        }
        wildcardOperator = UILabel(frame: CGRect(origin: CGPoint.zero, size: kPuzzleLabelSize))
        switch ColorScheme.scheme {
        case .monochrome: colorElements = SchemeElements.monochrome
        case .ocean: colorElements = SchemeElements.ocean
        case .daybreak: colorElements = SchemeElements.daybreak
        }
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
        
        hintsMultiplierLabel.alpha = 0.0
        
        newPuzzleButton.alpha = 0.0
        newPuzzleButton.isEnabled = false
        
        solveButton.alpha = 0.0
        solveButton.isEnabled = false
        
        switch gameType! {
        case .original:
            bestScoreModel.configureMaxScore(withDifficulty: difficulty!)
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
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
        for puzzleLabel in puzzleLabels {
            if !puzzleLabel.isOperator {
                puzzleLabel.label.textColor = colorElements.buttonColor
            }
        }
        for label in defaultOperatorLabels {
            label.textColor = .black
        }
        expressionLabel.textColor = .black
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
            countLabel.textAlignment = .center
            countLabel.center.x = operatorLabel.frame.origin.x + operatorLabel.frame.size.width
            countLabel.center.y = operatorLabel.frame.origin.y
            countLabel.alpha = 0.0
            
            countLabel.textColor = colorElements.labelColor
            
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
                    UIView.animate(withDuration: kShortAnimationDuration, animations: {
                        label.alpha = 1.0
                    })
                } else {
                    UIView.animate(withDuration: kShortAnimationDuration, animations: {
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
        
        primaryLabel.textColor = colorElements.labelColor
        primaryLabel.text = "\(timedModel.remainingMinutesSeconds(timeElapsed: 0.0)!)"
        
        timer = Timer.scheduledTimer(timeInterval: kTimerInterval, target: self, selector: #selector(PuzzleViewController.timerFired(timer:)), userInfo: nil, repeats: true)
        
        newPuzzleButton.alpha = 1.0
        newPuzzleButton.isEnabled = true
        
        progressBarView.isHidden = false
        progressBarView.progress = 1.0
        
        secondaryLabel.text = "Score: 0"
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
                        
                        hintsModel.useCustom()
                        
                        if hintsModel.customCount() == 0 {
                            defaultOperatorLabels.remove(at: kWildcardOperatorPosition)
                            
                            placeDefaultOperators(isInitial: false)
                            
                            wildcardOperator.removeFromSuperview()
                            
                            operatorCountLabels[wildcardOperator.text!]!.removeFromSuperview()
                            
                            operatorCountLabels.removeValue(forKey: wildcardOperator.text!)
                        } else {
                            operatorCountLabels[wildcardOperator.text!]!.text = "\(hintsModel.customCount())"
                        }
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
        
    }
    
    func puzzleOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            let label = view as! UILabel
            var hasOperator : Bool = false
            
            for i in puzzleLabels.indices {
                if puzzleLabels[i].label == label {
                    if !puzzleLabels[i].isMovable {
                        break
                    }
                    UIView.animate(withDuration: kShortAnimationDuration, animations: {
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
        if let view = recognizer.view {
            let label = view as! UILabel
            for i in puzzleLabels.indices {
                if puzzleLabels[i].label == label {
                    switch recognizer.state {
                    case .began:
                        if let lockLabel = puzzleLabels[i].lockLabel {
                            if puzzleLabels[i].lockLabel!.isHidden {
                                lockLabel.alpha = 0.0
                                lockLabel.isHidden = false
                                self.view.bringSubview(toFront: lockLabel)
                                UIView.animate(withDuration: kShortAnimationDuration, animations: {
                                    lockLabel.alpha = self.puzzleLabels[i].kLockLabelAlpha
                                })
                            } else {
                                self.view.bringSubview(toFront: lockLabel)
                                DispatchQueue.main.asyncAfter(deadline: .now() + kShortAnimationDuration, execute: {
                                    self.puzzleLabels[i].changeLockString()
                                })
                            }
                        }
                    case .ended:
                        puzzleLabels[i] = puzzleLabels[i].changeLock()
                        let puzzleLabel = puzzleLabels[i]
                        
                        if let lockLabel = puzzleLabel.lockLabel {
                            if puzzleLabel.isMovable {
                                UIView.animate(withDuration: kShortAnimationDuration, animations: {
                                    lockLabel.alpha = 0.0
                                }, completion: { (value) in
                                    lockLabel.isHidden = true
                                })
                            } else {
                                puzzleLabel.changeLockString()
                                DispatchQueue.main.asyncAfter(deadline: .now() + kShortAnimationDuration, execute: {
                                    self.view.sendSubview(toBack: lockLabel)
                                })
                            }
                        }
                        var resetEnabled = false
                        
                        for puzzleLabel in puzzleLabels {
                            if puzzleLabel.isOperator && puzzleLabel.isMovable {
                                resetEnabled = true
                            }
                        }
                        
                        resetButtonAction(enable: resetEnabled)
                    default: break
                    }
                    break
                }
            }
        }
        
        /*var totalOperands = 0
         var operatorCounter = 0
         
         for i in puzzleLabels.indices {
         if puzzleLabels[i].isOperator && !puzzleLabels[i].isMovable {
         operatorCounter += 1
         }
         if puzzleLabels[i].isOperand {
         totalOperands += 1
         }
         }
         
         if operatorCounter == Int(totalOperands) - 2 {
         hintsButtonAction(enable: false)
         } else {
         hintsButtonAction(enable: true)
         }*/
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
                    
                    hintsModel.useCustom()
                    
                    if hintsModel.customCount() == 0 {
                        defaultOperatorLabels.remove(at: kWildcardOperatorPosition)
                    
                        placeDefaultOperators(isInitial: false)
                    
                        wildcardOperator.removeFromSuperview()
                    } else {
                        operatorCountLabels[wildcardOperator.text!]!.text = "\(hintsModel.customCount())"
                    }
                    
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
                    
                    UIView.animate(withDuration: kLongAnimationDuration, animations: {
                        label.alpha = 1.0
                    })
                } else {
                    label.removeFromSuperview()
                }
                
                hasPlaceholder = false
            } else {
                if isDefaultOperator {
                    UIView.animate(withDuration: kLongAnimationDuration, animations: {
                        label.center = self.initialPoint
                    })
                } else {
                    displayExpression()
                    
                    switch gameType! {
                    case .original:
                        updateBestScore()
                    default: break
                    }
                    
                    UIView.animate(withDuration: kLongAnimationDuration, animations: {
                        label.alpha = 0.0
                    }, completion: { (value) in
                        label.removeFromSuperview()
                    })
                }
            }
        } else {
            if isDefaultOperator {
                UIView.animate(withDuration: kLongAnimationDuration, animations: {
                    label.center = self.initialPoint
                })
            } else {
                
                displayExpression()
                
                switch gameType! {
                case .original:
                    updateBestScore()
                default: break
                }
                
                UIView.animate(withDuration: kLongAnimationDuration, animations: {
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
            if best == Int(bestScoreModel.maxScore) {
                hintsButtonAction(enable: false)
                solveButtonAction(enable: false)
                displayCompleted()
            }
            progressBarView.setProgress(bestScoreModel.multiplierProgress(), animated: true)
            let currentMultiplier = bestScoreModel.currentPointsMultiplier()
            if currentMultiplier != 1 {
                currentMultiplierLabel.text = "×\(currentMultiplier)"
            } else {
                currentMultiplierLabel.text = ""
            }
            if let nextMultiplier = bestScoreModel.nextPointsMultiplier() {
                nextMultiplierLabel.text = "×\(nextMultiplier)"
            } else {
                nextMultiplierLabel.text = ""
            }
        } else {
            secondaryLabel.text = "Current: N/A"
        }
        
        primaryLabel.text = "Score: " + String(bestScoreModel.totalScore())
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
        self.timer = Timer.scheduledTimer(timeInterval: kTimerInterval, target: self, selector: #selector(PuzzleViewController.timerFired(timer:)), userInfo: nil, repeats: true)
        
        self.newPuzzleButtonPressed(UIButton())
    }
    
    func timerFired(timer : Timer) {
        
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
    
    func addTime(difficulty diff: Difficulty) {
        let timeAdded = timedModel.addTime(difficulty: diff)
        primaryLabelUpdate(withText: "\(Int(timeAdded))")
    }
    
    func primaryLabelUpdate(withText text: String) {
        
        let primaryUpdateLabelSize = CGSize(width: 150, height: 60)
        
        let primaryLabelBuffer = 4.0*kLabelBuffer
        
        let primaryUpdateLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: primaryUpdateLabelSize))
        primaryUpdateLabel.font = Fonts.wRhC
        primaryUpdateLabel.text = "+\(text)"
        primaryUpdateLabel.center.y = primaryLabel.center.y
        primaryUpdateLabel.center.x = primaryLabel.frame.origin.x + primaryLabel.frame.size.width + primaryLabelBuffer
        primaryUpdateLabel.alpha = 0.0
        primaryUpdateLabel.textColor = primaryLabel.textColor
        self.view.addSubview(primaryUpdateLabel)
        
        UIView.animate(withDuration: kLongAnimationDuration, animations: {
            primaryUpdateLabel.alpha = 1.0
            primaryUpdateLabel.center.y -= primaryLabelBuffer/2.0
        }) { (value) in
            UIView.animate(withDuration: self.kLongAnimationDuration, animations: {
                primaryUpdateLabel.alpha = 0.0
                primaryUpdateLabel.center.y -= primaryLabelBuffer/2.0
            }, completion: { (value) in
                primaryUpdateLabel.removeFromSuperview()
            })
        }
    }
    
    func resetHints() {
        for countLabel in operatorCountLabels.values {
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
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
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
                self.resetButton.alpha = 1.0
            })
        } else {
            resetButton.isEnabled = false
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
                self.resetButton.alpha = 0.0
            })
        }
    }
    
    func hintsButtonAction(enable: Bool) {
        if enable {
            hintsButton.isEnabled = true
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
                self.hintsButton.alpha = 1.0
            })
        } else {
            hintsButton.isEnabled = false
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
                self.hintsButton.alpha = 0.0
            })
        }
    }
    
    func solveButtonAction(enable: Bool) {
        if enable {
            solveButton.isEnabled = true
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
                self.solveButton.alpha = 1.0
            })
        } else {
            solveButton.isEnabled = false
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
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
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
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
        case .easy: equation = puzzleModel.newEquation(operands: OperandCount.easy)
        case .medium: equation = puzzleModel.newEquation(operands: OperandCount.medium)
        case .hard: equation = puzzleModel.newEquation(operands: OperandCount.hard)
        case .random: equation = puzzleModel.newEquation(operands: OperandCount.random())
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
        
        hintsModel.reset()
        
        UIView.animate(withDuration: kShortAnimationDuration) { 
            self.hintsMultiplierLabel.alpha = 0.0
        }
        
        resetHints()
        
        if defaultOperatorLabels[kWildcardOperatorPosition].text! == Symbols.Wildcard {
            defaultOperatorLabels[kWildcardOperatorPosition].removeFromSuperview()
            defaultOperatorLabels.remove(at: kWildcardOperatorPosition)
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
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
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
                    
                    UIView.animate(withDuration: self.kShortAnimationDuration, animations: { 
                        self.hintsMultiplierLabel.alpha = 0.0
                    })
                }
            })
        }
        
        solveButtonAction(enable: false)
    }
    
    func implementHints() {
        
        for _ in 0..<hintsModel.proposedCount(forHint: .random) {
            hintsRandomOperator()
        }
        
        let newCustomOperators = hintsModel.proposedCount(forHint: .custom) - hintsModel.customCount()
        
        if newCustomOperators > 0 {
            hintsCustomOperators(copies: newCustomOperators)
        }
        
        for _ in 0..<hintsModel.proposedCount(forHint: .uses) - hintsModel.usesCount() {
            hintsOperatorUses()
        }
        
        hintsModel.convertCounts()
        
        hintsModel.updateMultiplier()
        
        if let multiplier = hintsModel.subtractPercentage() {
            hintsMultiplierLabel.text = "-\(multiplier)%"
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
                self.hintsMultiplierLabel.alpha = 1.0
            })
        }
        
        hintsModel.resetProposedCounts()
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
                    UIView.animate(withDuration: kShortAnimationDuration, animations: {
                        self.puzzleLabels[i].label.alpha = 0.0
                    }, completion: { (value) in
                        UIView.animate(withDuration: self.kShortAnimationDuration, animations: {
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
    }
    
    func hintsCustomOperators(copies: Int) {
        if hintsModel.customCount() == 0 {
            defaultOperatorLabels.insert(wildcardOperator, at: kWildcardOperatorPosition)
            
            placeDefaultOperators(isInitial: false)
            
            let size = CGSize(width: kPuzzleLabelSize.width + kLabelBuffer, height: kPuzzleLabelSize.height + kLabelBuffer)
            
            let countLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: size))
            countLabel.text = "\(copies)"
            countLabel.font = Fonts.wRhC
            countLabel.textAlignment = .center
            countLabel.center.x = wildcardOperator.frame.origin.x + wildcardOperator.frame.size.width
            countLabel.center.y = wildcardOperator.frame.origin.y
            countLabel.alpha = 0.0
            countLabel.textColor = colorElements.labelColor
            self.view.addSubview(countLabel)
            self.view.sendSubview(toBack: countLabel)
            UIView.animate(withDuration: kShortAnimationDuration, animations: { 
                countLabel.alpha = self.kOperatorUsesLabelAlpha
            })
            
            operatorCountLabels[wildcardOperator.text!] = countLabel
        } else {
            operatorCountLabels[wildcardOperator.text!]!.text! = "\(hintsModel.customCount() + copies)"
        }
        
    }
    
    func hintsOperatorUses() {
        
        var availablePositions : [Int] = []
        
        for (i,label) in defaultOperatorLabels.enumerated() {
            if label != wildcardOperator {
                if operatorCountLabels[label.text!]!.alpha != kOperatorUsesLabelAlpha {
                    availablePositions.append(i)
                }
            }
        }
        
        let random = Int(arc4random_uniform(UInt32(availablePositions.count)))
        
        let defaultPosition = availablePositions[random]
        
        let operatorKey = defaultOperatorLabels[defaultPosition].text!
        
        let operatorCountLabel = operatorCountLabels[operatorKey]!
        
        var operatorCount = 0
        for element in puzzleModel.equation!.elements {
            if operatorKey == element.string {
                operatorCount += 1
            }
        }
        operatorCountLabel.text = "\(operatorCount)"
        self.view.addSubview(operatorCountLabel)
        self.view.sendSubview(toBack: operatorCountLabel)
        UIView.animate(withDuration: kShortAnimationDuration, animations: {
            operatorCountLabel.alpha = self.kOperatorUsesLabelAlpha
        })
    }
    
    func setupPuzzle(withEquation eq: Equation) {
        
        for puzzleLabel in puzzleLabels {
            
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
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
        
        let totalWidth = self.view.frame.size.width - kLabelBuffer*2.0*3.0 - solutionWidth - kPuzzleLabelSize.width
        
        let oneWidth = totalWidth/CGFloat(puzzleLabels.count - 2)
        
        let oneWidthCenter = oneWidth/2
        
        for (i, puzzleLabel) in puzzleLabels.enumerated() {
            
            let xPositionCenter: CGFloat
            
            if i == puzzleLabels.count - 1 {
                xPositionCenter = self.view.frame.size.width - kLabelBuffer*2.0 - solutionWidth/2
            } else if i == puzzleLabels.count - 2 {
                xPositionCenter = self.view.frame.size.width - kLabelBuffer*2.0*2.0 - solutionWidth - puzzleLabel.label.frame.size.width/2
            } else {
                xPositionCenter = oneWidth*CGFloat(i) + oneWidthCenter
            }
            
            if isNewPuzzle {
            
                puzzleLabel.label.center = CGPoint(x: xPositionCenter, y: kPuzzleLabelsYPosition)
                
                puzzleLabel.label.alpha = 0.0
            
                self.view.addSubview(puzzleLabel.label)
            
            } else {
                
                if self.view.subviews.contains(puzzleLabel.label) {
                    UIView.animate(withDuration: kShortAnimationDuration, animations: {
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
                UIView.animate(withDuration: kShortAnimationDuration, delay: kShortAnimationDuration, options: [], animations: {
                    puzzleLabel.label.alpha = 1.0
                }, completion: nil)
            }
        }
    }
}
