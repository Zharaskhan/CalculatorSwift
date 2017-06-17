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
        
        print("before \(digit) \(currentTextInDisplay)")
        if !userInTheMiddleOfTyping || currentTextInDisplay == "0" {
            displayLabel.text = digit
        } else {
            
            displayLabel.text = currentTextInDisplay + digit
        }
        
        userInTheMiddleOfTyping = true
        print("after \(digit) \(currentTextInDisplay)")
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
            
            if let result = brain.result {
            
                displayValue = result
                historyLabel.text = brain.history
            } 
        }
    }
    
}