//
//  HintsViewController.swift
//  Operators
//
//  Created by Shane Byers on 2/13/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class HintsViewController: UIViewController {
    
    var puzzleViewController : PuzzleViewController?
    
    func configureViewController(viewController: PuzzleViewController) {
        puzzleViewController = viewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }
    
    @IBAction func randomOperatorButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) { 
            self.puzzleViewController!.hintsRandomOperator()
        }
    }
    
    @IBAction func customOperatorButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) { 
            self.puzzleViewController!.hintsCustomOperator()
        }
    }
    
    @IBAction func numberOperatorUsesButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) { 
            self.puzzleViewController!.hintsOperatorUses()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
