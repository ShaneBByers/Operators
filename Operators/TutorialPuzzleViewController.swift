//
//  TutorialPuzzleViewController.swift
//  Operators
//
//  Created by Shane Byers on 4/12/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class TutorialPuzzleViewController: PuzzleViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTutorial()
    }
    
    func initializeTutorial() {
        setupPuzzle(withEquation: tutorialModel.currentEquation())
        step1()
    }
    
    func step1() {
        for label in defaultOperatorLabels {
            for recognizer in label.gestureRecognizers! {
                if recognizer is UITapGestureRecognizer || label.text! != Symbols.Add {
                    label.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    override func operatorEndedPanning(label: UILabel, isDefaultOperator: Bool) {
        super.operatorEndedPanning(label: label, isDefaultOperator: isDefaultOperator)
        
        if isDefaultOperator {
            for label in defaultOperatorLabels {
                for recognizer in label.gestureRecognizers! {
                    if recognizer is UITapGestureRecognizer || label.text! != Symbols.Add {
                        label.removeGestureRecognizer(recognizer)
                    }
                }
            }
        }
        
        if puzzleLabels[1].label.text! == Symbols.Add {
            step2()
        }
    }
    
    func step2() {
        
    }
}
