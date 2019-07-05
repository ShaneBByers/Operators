//
//  TutorialStepViewController.swift
//  Operators
//
//  Created by Shane Byers on 9/16/18.
//  Copyright © 2018 Shane Byers. All rights reserved.
//

import UIKit

class TutorialStepViewController: UIViewController {
    
    var puzzleViewController: TutorialPuzzleViewController?
    
    var stepDescription: String?
    
    var exitingClosure: (()->Void)?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        if let description = stepDescription {
            descriptionLabel.text = description
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }
    
    func configureTutorialPuzzleViewController(with viewController: TutorialPuzzleViewController) {
        puzzleViewController = viewController
    }
    
    func configureTutorialStepDescription(with initStepDescription: String) {
        stepDescription = initStepDescription
    }
    
    @IBAction func skipTutorialButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.puzzleViewController!.skipTutorial()
        }
    }
    
    @IBAction func OKButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
        if let closure = exitingClosure {
            closure()
        }
    }
}
