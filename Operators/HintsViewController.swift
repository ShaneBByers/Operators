//
//  HintsViewController.swift
//  Operators
//
//  Created by Shane Byers on 2/13/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class HintsViewController: UIViewController {
    
    let hintsModel = HintsModel.sharedInstance
    
    @IBOutlet weak var randomCountLabel: UILabel!
    @IBOutlet weak var customCountLabel: UILabel!
    @IBOutlet weak var allUsesCountLabel: UILabel!
    
    @IBOutlet weak var randomMinusButton: UIButton!
    @IBOutlet weak var customMinusButton: UIButton!
    @IBOutlet weak var allUsesMinusButton: UIButton!
    
    @IBOutlet weak var randomPlusButton: UIButton!
    @IBOutlet weak var customPlusButton: UIButton!
    @IBOutlet weak var allUsesPlusButton: UIButton!
    
    var countLabels : [Hint:UILabel] = [:]
    var minusButtons : [Hint:UIButton] = [:]
    var plusButtons : [Hint:UIButton] = [:]
    
    var returnFunction : ((Void) -> Void)?
    
    func configureReturnFunction(returnFunction: @escaping ((Void) -> Void)) {
        self.returnFunction = returnFunction
    }
    
    override func viewDidLoad() {
        countLabels[Hint.random] = randomCountLabel
        countLabels[Hint.custom] = customCountLabel
        countLabels[Hint.allUses] = allUsesCountLabel
        
        minusButtons[Hint.random] = randomMinusButton
        minusButtons[Hint.custom] = customMinusButton
        minusButtons[Hint.allUses] = allUsesMinusButton
        
        plusButtons[Hint.random] = randomPlusButton
        plusButtons[Hint.custom] = customPlusButton
        plusButtons[Hint.allUses] = allUsesPlusButton
        
        updateEnableButtons()
        
        customCountLabel.text = "\(hintsModel.customCount())"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
        
    }
    
    @IBAction func changeCountButtonPressed(_ sender: UIButton) {
        for (key, value) in minusButtons {
            if value == sender {
                hintsModel.subtractHint(hint: key)
                countLabels[key]!.text = "\(hintsModel.proposedCount(forHint: key))"
            }
        }
        
        for (key, value) in plusButtons {
            if value == sender {
                hintsModel.addHint(hint: key)
                countLabels[key]!.text = "\(hintsModel.proposedCount(forHint: key))"
            }
        }
        
        updateEnableButtons()
    }
    
    func updateEnableButtons() {
        for (key, value) in minusButtons {
            value.isEnabled = hintsModel.canSubtract(hint: key)
        }
        
        for (key, value) in plusButtons {
            value.isEnabled = hintsModel.canAdd(hint: key)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hintsModel.resetProposedCounts()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.returnFunction!()
        }
    }
}
