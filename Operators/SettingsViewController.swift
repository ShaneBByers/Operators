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
    
    @IBOutlet var challengePuzzleButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in challengePuzzleButtons {
            button.isEnabled = settingsModel.canDeleteChallengePuzzles(forDifficulty: Difficulty(rawValue: button.titleLabel!.text!)!)
            if button.isEnabled {
                button.alpha = 1.0
            } else {
                button.alpha = 0.25
            }
        }
        
        if Symbols.Divide == Symbols.HyphenDots {
            hyphenButton.titleLabel!.font = UIFont(descriptor: hyphenButton.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: hyphenButton.titleLabel!.font.pointSize)
        } else if Symbols.Divide == Symbols.Slash {
            slashButton.titleLabel!.font = UIFont(descriptor: slashButton.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: slashButton.titleLabel!.font.pointSize)
        }
        
        divisionSymbolLabel.text = Symbols.Divide
        
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
                button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits())!, size: button.titleLabel!.font.pointSize)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }
    
    @IBAction func divisionSymbolButtonPressed(_ sender: UIButton) {
        for button in divisionSymbolButtons {
            button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits())!, size: button.titleLabel!.font.pointSize)
        }
        
        sender.titleLabel!.font = UIFont(descriptor: sender.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: sender.titleLabel!.font.pointSize)
        
        settingsModel.changeDivisionSymbol(fromSymbol: divisionSymbolLabel.text!)
        
        divisionSymbolLabel.text = Symbols.Divide
    }
    
    @IBAction func colorSchemeButtonPressed(_ sender: UIButton) {
        for button in colorSchemeButtons {
            button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits())!, size: button.titleLabel!.font.pointSize)
        }
        
        sender.titleLabel!.font = UIFont(descriptor: sender.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: sender.titleLabel!.font.pointSize)
        
        settingsModel.changeColorScheme(toScheme: sender.titleLabel!.text!)
        
        ColorScheme.updateScheme(forView: self.view)
    }
    
    @IBAction func deleteOriginalScoresPressed(_ sender: UIButton) {
        settingsModel.deleteOriginalHighScores()
    }
    
    @IBAction func deleteTimedScoresPressed(_ sender: UIButton) {
        settingsModel.deleteTimedHighScores()
    }
    
    @IBAction func deleteChallengePuzzlesPressed(_ sender: UIButton) {
        settingsModel.deleteChallengePuzzles(difficulty: Difficulty(rawValue: sender.titleLabel!.text!)!)
        
        sender.isEnabled = false
        sender.alpha = 0.25
    }
}
