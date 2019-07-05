//
//  SettingsViewController.swift
//  Operators
//
//  Created by Shane Byers on 2/17/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let settingsModel = SettingsModel.sharedInstance
    
    @IBOutlet var divisionSymbolButtons: [UIButton]!
    
    @IBOutlet weak var hyphenButton: UIButton!
    
    @IBOutlet weak var slashButton: UIButton!
    
    @IBOutlet weak var divisionSymbolLabel: UILabel!
    
    @IBOutlet var colorSchemeButtons: [UIButton]!
    
    @IBOutlet weak var originalHighScoreButton: UIButton!
    
    @IBOutlet weak var timedHighScoreButton: UIButton!
    
    @IBOutlet var challengePuzzleButtons: [UIButton]!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let button = sender! as! UIButton
        
        switch segue.identifier! {
        case "deleteOriginalHighScores":
            
            let destination = segue.destination as! SettingsConfirmDeleteViewController
            
            destination.configureConfirmDeleteScores(deleteText: "All High Scores on \"Original\" Game Mode", deleteScoresFunction: settingsModel.deleteOriginalHighScores)
        case "deleteTimedHighScores":
            
            let destination = segue.destination as! SettingsConfirmDeleteViewController
            
            destination.configureConfirmDeleteScores(deleteText: "All High Scores on \"Timed\" Game Mode", deleteScoresFunction: settingsModel.deleteTimedHighScores)
        case "deleteChallengePuzzles":
            
            let destination = segue.destination as! SettingsConfirmDeleteViewController
            
            let difficulty = Difficulty(rawValue: button.titleLabel!.text!)!
            
            destination.configureConfirmDeleteChallengePuzzles(deleteText: "All \(difficulty.rawValue) Challenge Puzzles", deletePuzzlesFunction: settingsModel.deleteChallengePuzzles, difficulty: difficulty)
        case "unwindToGameType": break
        default: assert(false,"Unhandled Segue")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Symbols.Divide == Symbols.HyphenDots {
            hyphenButton.titleLabel!.font = UIFont(descriptor: hyphenButton.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: hyphenButton.titleLabel!.font.pointSize)
        } else if Symbols.Divide == Symbols.Slash {
            slashButton.titleLabel!.font = UIFont(descriptor: slashButton.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: slashButton.titleLabel!.font.pointSize)
        }
        
        divisionSymbolLabel.text = Symbols.Divide
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        updateColorScheme()
        
        for button in challengePuzzleButtons {
            button.isEnabled = settingsModel.canDeleteChallengePuzzles(forDifficulty: Difficulty(rawValue: button.titleLabel!.text!)!)
        }
        
        originalHighScoreButton.isEnabled = settingsModel.canDeleteOriginalHighScores()
        
        timedHighScoreButton.isEnabled = settingsModel.canDeleteTimedHighScores()
    }
    
    override func viewDidLayoutSubviews() {
        if Symbols.Divide == Symbols.HyphenDots {
            hyphenButton.titleLabel!.font = UIFont(descriptor: hyphenButton.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: hyphenButton.titleLabel!.font.pointSize)
        } else if Symbols.Divide == Symbols.Slash {
            slashButton.titleLabel!.font = UIFont(descriptor: slashButton.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: slashButton.titleLabel!.font.pointSize)
        }
        
        for button in colorSchemeButtons {
            if button.titleLabel!.text! == ColorScheme.scheme.rawValue {
                button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: button.titleLabel!.font.pointSize)
            } else {
                button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits())!, size: button.titleLabel!.font.pointSize)
            }
        }
    }
    
    @IBAction func divisionSymbolButtonPressed(_ sender: UIButton) {
        for button in divisionSymbolButtons {
            button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits())!, size: button.titleLabel!.font.pointSize)
        }
        
        sender.titleLabel!.font = UIFont(descriptor: sender.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: sender.titleLabel!.font.pointSize)
        
        settingsModel.changeDivisionSymbol(fromSymbol: divisionSymbolLabel.text!)
        
        divisionSymbolLabel.text = Symbols.Divide
    }
    
    @IBAction func colorSchemeButtonPressed(_ sender: UIButton) {
        for button in colorSchemeButtons {
            button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits())!, size: button.titleLabel!.font.pointSize)
        }
        
        sender.titleLabel!.font = UIFont(descriptor: sender.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: sender.titleLabel!.font.pointSize)
        
        settingsModel.changeColorScheme(toScheme: sender.titleLabel!.text!)
        
        updateColorScheme()
    }
    
    func updateColorScheme() {
        ColorScheme.updateScheme(forView: self.view)
        
        divisionSymbolLabel.textColor = .black
        
        challengePuzzleButtons[0].tintColor = .green
        challengePuzzleButtons[1].tintColor = .yellow
        challengePuzzleButtons[2].tintColor = .red
    }
}
