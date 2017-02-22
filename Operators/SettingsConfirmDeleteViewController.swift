//
//  SettingsConfirmDeleteViewController.swift
//  Operators
//
//  Created by Shane Byers on 2/22/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class SettingsConfirmDeleteViewController: UIViewController {
    
    let settingsModel = SettingsModel.sharedInstance
    
    var deleteText : String?
    
    var deleteScoresFunction: ((Void) -> (Void))?
    
    var deletePuzzlesFunction: ((Difficulty) -> (Void))?
    
    var difficulty: Difficulty?
    
    @IBOutlet weak var deleteTextLabel: UILabel!
    
    func configureConfirmDeleteScores(deleteText: String, deleteScoresFunction: @escaping (Void) -> (Void)) {
        self.deleteText = deleteText
        self.deleteScoresFunction = deleteScoresFunction
    }
    
    func configureConfirmDeleteChallengePuzzles(deleteText: String, deletePuzzlesFunction: @escaping (Difficulty) -> (Void), difficulty: Difficulty) {
        self.deleteText = deleteText
        self.deletePuzzlesFunction = deletePuzzlesFunction
        self.difficulty = difficulty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        deleteTextLabel.text = deleteText!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        if let scoresFunction = self.deleteScoresFunction {
            scoresFunction()
        }
        if let puzzleFunction = self.deletePuzzlesFunction,
            let difficulty = self.difficulty {
            puzzleFunction(difficulty)
        }
        dismiss(animated: true)
    }
    
}
