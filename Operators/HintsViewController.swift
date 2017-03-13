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
    @IBOutlet weak var usesCountLabel: UILabel!
    
    @IBOutlet weak var randomMinusButton: UIButton!
    @IBOutlet weak var customMinusButton: UIButton!
    @IBOutlet weak var usesMinusButton: UIButton!
    
    @IBOutlet weak var randomPlusButton: UIButton!
    @IBOutlet weak var customPlusButton: UIButton!
    @IBOutlet weak var usesPlusButton: UIButton!
    
    @IBOutlet weak var randomPercentageLabel: UILabel!
    @IBOutlet weak var customPercentageLabel: UILabel!
    @IBOutlet weak var usesPercentageLabel: UILabel!
    
    @IBOutlet weak var previousPenaltyLabel: UILabel!
    @IBOutlet weak var addedPenaltyLabel: UILabel!
    @IBOutlet weak var totalPenaltyLabel: UILabel!
    
    
    var countLabels : [Hint:UILabel] = [:]
    var minusButtons : [Hint:UIButton] = [:]
    var plusButtons : [Hint:UIButton] = [:]
    var percentageLabels : [Hint:UILabel] = [:]
    
    var returnFunction : ((Void) -> Void)?
    
    func configureReturnFunction(returnFunction: @escaping ((Void) -> Void)) {
        self.returnFunction = returnFunction
    }
    
    override func viewDidLoad() {
        
        if let subtract = hintsModel.subtractPercentage() {
            previousPenaltyLabel.text = "-\(subtract)%"
        } else {
            previousPenaltyLabel.text = "N/A"
        }
        
        
        countLabels[.random] = randomCountLabel
        countLabels[.custom] = customCountLabel
        countLabels[.uses] = usesCountLabel
        
        minusButtons[.random] = randomMinusButton
        minusButtons[.custom] = customMinusButton
        minusButtons[.uses] = usesMinusButton
        
        plusButtons[.random] = randomPlusButton
        plusButtons[.custom] = customPlusButton
        plusButtons[.uses] = usesPlusButton
        
        percentageLabels[.random] = randomPercentageLabel
        percentageLabels[.custom] = customPercentageLabel
        percentageLabels[.uses] = usesPercentageLabel
        
        updateEnableButtons()
        
        customCountLabel.text = "\(hintsModel.customCount())"
        
        usesCountLabel.text = "\(hintsModel.usesCount())"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
        
    }
    
    @IBAction func changeCountButtonPressed(_ sender: UIButton) {
        for (key, value) in minusButtons {
            if value == sender {
                hintsModel.changeHintCount(hint: key, isAdd: false)
                countLabels[key]!.text = "\(hintsModel.proposedCount(forHint: key))"
                if let subtractPercentage = hintsModel.subtractProposedPercentage(forHint: key) {
                    percentageLabels[key]!.text = "-\(subtractPercentage)%"
                } else {
                    percentageLabels[key]!.text = "N/A"
                }
            }
        }
        
        for (key, value) in plusButtons {
            if value == sender {
                hintsModel.changeHintCount(hint: key, isAdd: true)
                countLabels[key]!.text = "\(hintsModel.proposedCount(forHint: key))"
                if let subtractPercentage = hintsModel.subtractProposedPercentage(forHint: key) {
                    percentageLabels[key]!.text = "-\(subtractPercentage)%"
                } else {
                    percentageLabels[key]!.text = "N/A"
                }
            }
        }
        
        if let subtractProposed = hintsModel.subtractProposedPercentage() {
            if let subtract = hintsModel.subtractPercentage() {
                if subtractProposed == subtract {
                    addedPenaltyLabel.text = "N/A"
                } else {
                    addedPenaltyLabel.text = "-\(subtractProposed - subtract)%"
                }
            } else {
                addedPenaltyLabel.text = "-\(subtractProposed)%"
            }
            totalPenaltyLabel.text = "-\(subtractProposed)%"
        } else {
            addedPenaltyLabel.text = "N/A"
            totalPenaltyLabel.text = "N/A"
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
