//
//  PuzzleLabel.swift
//  Operators
//
//  Created by Shane Byers on 3/31/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import Foundation
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
            _lockLabel.text = kLockString
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
    
    func resetLockString() {
        lockLabel!.text = kUnlockString
    }
}
