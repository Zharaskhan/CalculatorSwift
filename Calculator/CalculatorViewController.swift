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

    var brain = CalculatorBrain()
    var userInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        
        let currentTextInDisplay = displayLabel.text!
        
        if !userInTheMiddleOfTyping || currentTextInDisplay == "0" {
            displayLabel.text = digit
            if digit != "0" {
                
                userInTheMiddleOfTyping = true
            }
        } else {
            
            displayLabel.text = currentTextInDisplay + digit
        }
    }
    
    var displayValue: Double {
        get { return Double(displayLabel.text!)! }
        set { displayLabel.text = String(newValue) }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userInTheMiddleOfTyping = false
        }
        
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
            
            if let result = brain.result {
                displayValue = result
            } 
        }
    }
    
}
