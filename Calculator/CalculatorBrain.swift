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
    private var historyArray:[String] = ["0"]
    
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
        case clear()
    }
    
    
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "%": Operation.unaryOperation({$0 / 100}),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.result,
        "C": Operation.clear()
    ]
    
    
    // выполняем операцию
    mutating func performOperation(_ symbol: String) {
      
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
            
                if (resultIsPending) {
                    //100 + ...
                    if (historyArray.last == "+" || historyArray.last == "-" || historyArray.last == "×" || historyArray.last == "÷") {
                        
                        historyArray.append(symbol)
                    }
                    
                    
                } else {
                    //100 or 100 + 232 -> pi
                    historyArray.removeAll()
                    historyArray.append(symbol)
                    
                    //100 + pi
                    resultIsPending = false
                }
                
                displayNumber = value
            case .unaryOperation(let function):
                if resultIsPending {
                    
                    if (displayNumber != nil) {
                        //10 + x
                        historyArray.append(symbol + "(" + String(displayNumber!) + ")")
                        displayNumber = function(displayNumber!)
                    } else {
                        //10 + .. -> 10 + sqrt(10)
                        
                        
                        historyArray.append(symbol + "(" + String(resultNumber) + ")")
                        displayNumber = function(resultNumber)
                        
                    }
                } else {
                    //
                    if (displayNumber != nil) {
                        //100, 23213 -> func(23213)
                        //clear
                        historyArray.removeAll()
                        
                        historyArray.append(symbol + "(" + String(displayNumber!) + ")")
                        displayNumber = function(displayNumber!)
                    } else {
                        //100, ... -> sqrt(100)
                        
                       // historyArray.removeAll()
                        
                       // historyArray.append(symbol + "(" + String(resultNumber) + ")")
                        
                        historyArray[0] = symbol + "(" + historyArray[0]
                        historyArray[historyArray.count - 1] += ")"
                        resultNumber = function(resultNumber)
                        
                    }
                }
            case .clear():
                print("sdfdsfs")
                resultNumber = 0
                displayNumber = 0
                resultIsPending = false
                historyArray = ["0"]
                pendingFunction = nil
            case .binaryOperation(let function):
                if resultIsPending {
                    if (displayNumber != nil) {
                        //10 + x *
                        
                        if (historyArray.last == "+" || historyArray.last == "-" || historyArray.last == "×" || historyArray.last == "÷") {
                            
                            historyArray.append(String(displayNumber!))
                        }
                        
                        historyArray.append(symbol)
                        
                        resultNumber = pendingFunction!(resultNumber, displayNumber!)
                        
                        displayNumber = nil
                        pendingFunction = function
                      
                        
                    } else {
                        //10 + .. -> 10 - ..
                        historyArray[historyArray.count - 1] = symbol
                        pendingFunction = function
                        
                    }
                    
                    //resultIsPending = true already
                } else {
                    //1000, 3434 *
                    if (displayNumber != nil) {
                        //restart
                        resultNumber = displayNumber!
                        
                        historyArray.removeAll()
                        historyArray.append(String(displayNumber!))
                        historyArray.append(symbol)
                        
                        displayNumber = nil
                        pendingFunction = function
                        resultIsPending = true
                    } else {
                        //1000, ... *
                        historyArray.append(symbol)
                        
                        pendingFunction = function
                        resultIsPending = true
                    }
                }
                
            case .result:
                if resultIsPending {
                    if (displayNumber != nil) {
                        //10 + x -> 10 + x =
                        if (historyArray.last == "+" || historyArray.last == "-" || historyArray.last == "×" || historyArray.last == "÷") {
                            
                            historyArray.append(String(displayNumber!))
                        }
                        //10 + sqrt(x)
                        
                        
                        resultNumber = pendingFunction!(resultNumber, displayNumber!)
                        displayNumber = nil
                        
                    } else {
                        //10 + .. -> 10 + 10
                       
                        historyArray.append(String(resultNumber))
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
                            //clean history
                            historyArray.removeAll()
                            historyArray.append(String(displayNumber!))
                            resultNumber = displayNumber!
                        }
                        
                        displayNumber = nil
                        
                    } else {
                        //10 .. = -> 10 + 10
                        if pendingFunction != nil {
                            
                            //some error, 100 + .. => 100 + 100 -> 200 + 200 not 200 + 100
                            //historyArray.append(historyArray[historyArray.count - 2])
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
    var history: String {
        var tmpstring = ""
        for i in historyArray {
            tmpstring += i + " ";
        }
        if (resultIsPending) {
            tmpstring += "..."
        } else {
            tmpstring += "="
        }
        return tmpstring
    }
}
