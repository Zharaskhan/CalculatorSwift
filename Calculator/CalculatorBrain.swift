//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Zharaskhan Aman on 13.06.17.
//  Copyright © 2017 Zharaskhan. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    
    private var resultNumber: Double = 0
    private var displayNumber: Double? = 0
    private var resultIsPending = false
    
    private var pendingFunction: ((Double, Double) -> Double)?
    // закачиваем операнд в модельку
    mutating func setOperand(_ operand: Double) {
        displayNumber = operand
    }
    
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.result
    ]
    
    
    // выполняем операцию
    mutating func performOperation(_ symbol: String) {
      
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                displayNumber = value
            case .unaryOperation(let function):
                if resultIsPending {
                    
                    if (displayNumber != nil) {
                        //10 + x
                        displayNumber = function(displayNumber!)
                    } else {
                        //10 + .. -> 10 + sqrt(10)
                        displayNumber = function(resultNumber)
                        
                    }
                } else {
                    //
                    if (displayNumber != nil) {
                        displayNumber = function(displayNumber!)
                    } else {
                        //100, ... -> sqrt(100)
                        resultNumber = function(resultNumber)
                        
                    }
                }
            case .binaryOperation(let function):
                if resultIsPending {
                    if (displayNumber != nil) {
                        //10 + x *
                        resultNumber = pendingFunction!(resultNumber, displayNumber!)
                        
                        displayNumber = nil
                        pendingFunction = function
                      
                        
                    } else {
                        //10 + .. -> 10 - ..
                        pendingFunction = function
                        
                    }
                    
                    //resultIsPending = true already
                } else {
                    //1000, 3434 *
                    if (displayNumber != nil) {
                        resultNumber = displayNumber!
                        
                        displayNumber = nil
                        pendingFunction = function
                        resultIsPending = true
                    } else {
                        //1000, ... *
                        //assert(false)
                        
                        pendingFunction = function
                        resultIsPending = true
                    }
                }
                
            case .result:
                if resultIsPending {
                    if (displayNumber != nil) {
                        //10 + x *
                        resultNumber = pendingFunction!(resultNumber, displayNumber!)
                        displayNumber = nil
                        
                    } else {
                        //10 + .. -> 10 + 10
                        resultNumber = pendingFunction!(resultNumber, resultNumber)
                        
                    }
                    
                    resultIsPending = false
                } else {
                    
                    if (displayNumber != nil) {
                        if pendingFunction != nil {
                            //10 + 213213 =
                            resultNumber = pendingFunction!(resultNumber, displayNumber!)
                        } else {
                            //1000, 123123213 =
                            resultNumber = displayNumber!
                        }
                        
                        displayNumber = nil
                        
                    } else {
                        //10 + .. = 10 + 10
                        if pendingFunction != nil {
                            resultNumber = pendingFunction!(resultNumber, resultNumber)
                        }
                        //else 10 .. = 10
                        
                        
                    }
                }
                
            }
        }
    }
    
    var result: Double? {
        
        print("\(resultNumber) and ")
        if (displayNumber != nil) {
            print("\(displayNumber!)");
        } else {
            print("nothing")
        }
        if (displayNumber != nil) {
            return displayNumber
        }
        return resultNumber
    }
    
}
