//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Zharaskhan Aman on 12.06.17.
//  Copyright © 2017 Zharaskhan. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!

    @IBOutlet weak var historyLabel: UILabel!
    
    var brain = CalculatorBrain()
    var userInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        let currentTextInDisplay = displayLabel.text!
        
        
        if !userInTheMiddleOfTyping || currentTextInDisplay == "0" {
            displayLabel.text = digit
        } else {
            
            displayLabel.text = currentTextInDisplay + digit
        }
        userInTheMiddleOfTyping = true
    }
    @IBAction func touchDot(_ sender: UIButton) {
       
        
        let currentTextInDisplay = displayLabel.text!
        
            if !userInTheMiddleOfTyping {
                displayLabel.text = "0."
            } else if currentTextInDisplay.contains(".") == false {
                displayLabel.text = currentTextInDisplay + "."
            }
            userInTheMiddleOfTyping = true
        
    }
    
    var displayValue: Double {
        get { return Double(displayLabel.text!)! }
        set {
            
            let formatter = NumberFormatter()
            formatter.maximumSignificantDigits = 5
            displayLabel.text = formatter.string(from: newValue as NSNumber)
           
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userInTheMiddleOfTyping = false
        }
        
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
            displayValue = brain.result!
            historyLabel.text = brain.history
        }
    }
    
}
