//
//  PuzzleViewController.swift
//  Operators
//
//  Created by Shane Byers on 11/12/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

class PuzzleViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    // MARK: - Variables
    //
    // MARK: Models
    //
    let puzzleModel = PuzzleModel.sharedInstance
    let hintsModel = HintsModel.sharedInstance
    let settingsModel = SettingsModel.sharedInstance
    let originalModel = OriginalModel.sharedInstance
    let challengeModel = ChallengeModel.sharedInstance
    let timedModel = TimedModel.sharedInstance
    let tutorialModel = TutorialModel.sharedInstance
    
    
    // MARK: Constants
    //
    let kInitDefaultOperatorCount = 4
    let kGrowthFactor : CGFloat = 1.1
    let kPuzzleLabelSize : CGSize = CGSize(width: 60, height: 60)
    let kSolutionLabelSize : CGSize = CGSize(width: 120, height: 60)
    let kLabelBuffer : CGFloat = 10
    let kPlaceholderLabel = PuzzleLabel(text: "", isOperand: false, isOperator: false, isSolution: false, isMovable: true, viewController: nil)
    let kShortAnimationDuration : TimeInterval = 0.2
    let kLongAnimationDuration : TimeInterval = 0.5
    var kWildcardOperatorPosition = 2
    let kOperatorUsesLabelAlpha : CGFloat = 0.5
    
    let wildcardOperator : UILabel
    
    var hasPlaceholder = false
    var placeholderIndex : Int?
    
    var initialPoint : CGPoint = CGPoint.zero
    var kPuzzleLabelsYPosition : CGFloat = 0.0
    
    
    // MARK: Labels
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
    
    
    // MARK: Buttons
    //

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var hintsButton: UIButton!
    @IBOutlet weak var newPuzzleButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    
    
    // MARK: Custom Variables
    //
    var resetAllowed : Bool = true
    var solvePuzzleButtonPressed : Bool = false
    var operatorBeingMoved : UILabel?
    let colorElements : ColorElements
    
    
    // MARK: - Configurations
    //
    override func awakeFromNib() {
        switch PuzzleModel.sharedInstance.gameType! {
        case .original:
            object_setClass(self, OriginalPuzzleViewController.self)
        case .challenge:
            object_setClass(self, ChallengePuzzleViewController.self)
        case .timed:
            object_setClass(self, TimedPuzzleViewController.self)
        case .tutorial:
            object_setClass(self, TutorialPuzzleViewController.self)
        }
    }
    
    
    // MARK: - Segues
    //
    @IBAction func backButtonPressed(_ sender: UIButton) {
        resetOnDisappear()
        
        hintsModel.reset()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "challengePuzzleCompletedSegue": break
        case "timerCompletedSegue": break
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
        case "unwindToGameType": break
        case "showGameModeSegue": break
        case "showTutorialStepSegue": break
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
        kPlaceholderLabel.label.alpha = 0.0
        
        kPuzzleLabelsYPosition = self.view.center.y - kPuzzleLabelSize.height - kLabelBuffer
        
        initializeGestureRecognizers()
        initializeDefaultOperators()
        initializeOperatorCountLabels()
        
        expressionLabel.text = ""
        
        hintsButton.alpha = 0.0
        hintsButton.isEnabled = false
        
        hintsMultiplierLabel.alpha = 0.0
        
        newPuzzleButton.alpha = 0.0
        newPuzzleButton.isEnabled = false
        
        solveButton.alpha = 0.0
        solveButton.isEnabled = false
        
        resetButton.alpha = 0.0
        resetButton.isEnabled = false
        
    }
    
    
    // MARK: - Appear/Disappear
    //
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
        progressBarView.progressTintColor = colorElements.buttonColor
    }
    
    func resetOnDisappear() {}
    
    
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
        let yPositionCenter = self.view.center.y
        
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
    
    
    // MARK: - Label Gestures
    //
    func initializeGestureRecognizers() {
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
    
    
    // MARK: Double Tap Gestures
    //
    @objc func defaultOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
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
                    
                    puzzleLabels.insert(newLabel, at: i+1)
                    
                    placePuzzle(isNewPuzzle: false)
                    
                    displayExpression()
                    
                    break
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
    
    @objc func puzzleOperatorDoubleTapped(_ recognizer: UITapGestureRecognizer) {
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
        var resetEnabled = false
        
        for puzzleLabel in puzzleLabels {
            if puzzleLabel.isOperator && puzzleLabel.isMovable {
                resetEnabled = true
            }
        }
        
        resetButtonAction(enable: resetEnabled)
    }
    
    
    // MARK: Long Press Gesture
    //
    @objc func puzzleOperatorHeld(_ recognizer: UILongPressGestureRecognizer) {
        if let view = recognizer.view {
            let label = view as! UILabel
            for i in puzzleLabels.indices {
                if puzzleLabels[i].label == label {
                    switch recognizer.state {
                    case .began:
                        if let lockLabel = puzzleLabels[i].lockLabel {
                            if puzzleLabels[i].lockLabel!.isHidden {
                                puzzleLabels[i].resetLockString()
                                lockLabel.alpha = 0.0
                                lockLabel.isHidden = false
                                self.view.bringSubviewToFront(lockLabel)
                                UIView.animate(withDuration: kShortAnimationDuration, animations: {
                                    lockLabel.alpha = self.puzzleLabels[i].kLockLabelAlpha
                                })
                            } else {
                                self.view.bringSubviewToFront(lockLabel)
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
                                    self.view.sendSubviewToBack(lockLabel)
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
    }
    
    
    // MARK: Panned Gestures
    //
    @objc func defaultOperatorPanned(_ recognizer : UIPanGestureRecognizer) {
        operatorPanned(recognizer, isDefaultOperator: true)
    }
    
    @objc func puzzleOperatorPanned(_ recognizer: UIPanGestureRecognizer) {
        operatorPanned(recognizer, isDefaultOperator: false)
    }
    
    func operatorPanned(_ recognizer: UIPanGestureRecognizer, isDefaultOperator: Bool) {
        if let view = recognizer.view {
            let label = view as! UILabel
            if operatorBeingMoved == nil || operatorBeingMoved! == label {
                operatorBeingMoved = label
                switch recognizer.state {
                case .began:
                    self.operatorBeganPanning(label: label, isDefaultOperator: isDefaultOperator)
                case .changed:
                    self.operatorChangedPanning(recognizer: recognizer, label: label)
                case .ended:
                    self.operatorEndedPanning(label: label, isDefaultOperator: isDefaultOperator)
                    operatorBeingMoved = nil
                default: break
                }
            }
        }
    }
    
    func operatorBeganPanning(label: UILabel, isDefaultOperator: Bool) {
        
        label.transform = CGAffineTransform(scaleX: kGrowthFactor, y: kGrowthFactor)
        
        initialPoint = label.center
        
        self.view.bringSubviewToFront(label)
        
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
                        
                        operatorCountLabels[wildcardOperator.text!]!.removeFromSuperview()
                        
                        operatorCountLabels.removeValue(forKey: wildcardOperator.text!)
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
                
                UIView.animate(withDuration: kLongAnimationDuration, animations: {
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
    
    
    // MARK: - Button Actions
    //
    func resetButtonAction(enable: Bool) {
        if resetAllowed {
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
    
    func newPuzzleButtonAction(enable: Bool) {
        if enable {
            newPuzzleButton.isEnabled = true
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
                self.newPuzzleButton.alpha = 1.0
            })
        } else {
            newPuzzleButton.isEnabled = false
            UIView.animate(withDuration: kShortAnimationDuration, animations: {
                self.newPuzzleButton.alpha = 0.0
            })
        }
    }
    
    // MARK: - Button Presses
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
                
                newLabel.label.isUserInteractionEnabled = false
                
                if let lockLabel = newLabel.lockLabel {
                    lockLabel.isUserInteractionEnabled = false
                }
                
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
    
    
    // MARK: - Hints
    //
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
            self.view.sendSubviewToBack(countLabel)
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
        self.view.sendSubviewToBack(operatorCountLabel)
        UIView.animate(withDuration: kShortAnimationDuration, animations: {
            operatorCountLabel.alpha = self.kOperatorUsesLabelAlpha
        })
    }
    
    
    // MARK: - Puzzle Display
    //
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
        
        let solutionWidth = puzzleLabels[puzzleLabels.count - 1].label.frame.size.width - self.view.safeAreaInsets.left
        
//        let solutionWidth = self.view.safeAreaLayoutGuide.layoutFrame.size.width
        
        let totalWidth = self.view.frame.size.width - kLabelBuffer*2.0*3.0 - solutionWidth - kPuzzleLabelSize.width
        
        let oneWidth = totalWidth/CGFloat(puzzleLabels.count - 2)
        
        let oneWidthCenter = oneWidth/2
        
        for (i, puzzleLabel) in puzzleLabels.enumerated() {
            
            let xPositionCenter : CGFloat
            
            if i == puzzleLabels.count - 1 {
                xPositionCenter = self.view.frame.size.width - kLabelBuffer*2.0 - solutionWidth/2 - self.view.safeAreaInsets.left/2
            } else if i == puzzleLabels.count - 2 {
                xPositionCenter = self.view.frame.size.width - kLabelBuffer*2.0*2.0 - solutionWidth - puzzleLabel.label.frame.size.width/2 - self.view.safeAreaInsets.left/2
            } else {
                xPositionCenter = self.view.safeAreaInsets.left/2 + oneWidth*CGFloat(i) + oneWidthCenter
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
