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
    
    struct historyArray {
        //                  is binary operation
        private var array:[(String, Bool)] = [("0", false)]
        
        func islastBinary() -> Bool {
        
            if self.array.last == nil {
                return false
            }
            return self.array.last!.1
        }
        mutating func append(_ symbol: String) {
            if symbol == "+" || symbol == "-" || symbol == "×" || symbol == "÷" {
                if self.islastBinary() == false {
                    self.array.append((symbol, true))
                } else {
                    self.array[array.count - 1].0 = symbol
                }
                
            } else {
                self.array.append((symbol, false))
            }
        }
        
        mutating func append(_ symbol: String, _ num: String) {
            if self.array.last != nil && self.array.last!.0.characters.last == ")" {
                self.array[self.array.count - 1].0 = symbol + "(" + self.array[self.array.count - 1].0 + ")"
            } else {
                self.append(symbol + "(" + num + ")");
            }
        }
        
        func get() -> String {
            
            var result = ""
            for i in self.array {
                if let val = Double(i.0) {
                    let formatter = NumberFormatter()
                    formatter.maximumSignificantDigits = 5
                    result += formatter.string(from: val as NSNumber)!
                } else {
                    result += i.0 + " "
                }
            }
            return result
        }
        mutating func clear() {
            self.array.removeAll()
        }
        
    }
    var MyHistoryArray: historyArray = historyArray()
    
    
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
                    if MyHistoryArray.islastBinary() {
                        MyHistoryArray.append(symbol)
                    }
                    
                    
                } else {
                    //100 or 100 + 232 -> pi
                    
                    MyHistoryArray.clear();
                    MyHistoryArray.append(symbol)
                    
                    //100 + pi
                    resultIsPending = false
                }
                
                displayNumber = value
            case .unaryOperation(let function):
                if resultIsPending {
                    
                    if (displayNumber != nil) {
                        //10 + x
                        MyHistoryArray.append(symbol, String(displayNumber!))
                        displayNumber = function(displayNumber!)
                    } else {
                        //10 + .. -> 10 + sqrt(10)
                        
                        
                        MyHistoryArray.append(symbol, String(resultNumber))
                        displayNumber = function(resultNumber)
                        
                    }
                } else {
                    //
                    if (displayNumber != nil) {
                        //100, 23213 -> func(23213)
                        //clear
                        MyHistoryArray.clear()
                        MyHistoryArray.append(symbol, String(displayNumber!))
                        displayNumber = function(displayNumber!)
                    } else {
                        //100, ... -> sqrt(100)
                        
                       // historyArray.removeAll()
                        
                       // historyArray.append(symbol + "(" + String(resultNumber) + ")")
                        let tmpstring = MyHistoryArray.get()
                        MyHistoryArray.clear()
                        MyHistoryArray.append(symbol, tmpstring)
                        
                        resultNumber = function(resultNumber)
                        
                    }
                }
            case .clear():
                print("sdfdsfs")
                resultNumber = 0
                displayNumber = 0
                resultIsPending = false
                MyHistoryArray.clear()
                pendingFunction = nil
                
            case .binaryOperation(let function):
                if resultIsPending {
                    if (displayNumber != nil) {
                        //10 + x *
                        if MyHistoryArray.islastBinary() {
                            
                            MyHistoryArray.append(String(displayNumber!))
                        }
                        
                        
                        MyHistoryArray.append(symbol)
                        
                        resultNumber = pendingFunction!(resultNumber, displayNumber!)
                        
                        displayNumber = nil
                        pendingFunction = function
                      
                        
                    } else {
                        //10 + .. -> 10 - ..
                        
                        MyHistoryArray.append(symbol)
                        pendingFunction = function
                        
                    }
                    
                    //resultIsPending = true already
                } else {
                    //1000, 3434 *
                    if (displayNumber != nil) {
                        //restart
                        resultNumber = displayNumber!
                        
                        MyHistoryArray.clear()
                        
                        MyHistoryArray.append(String(displayNumber!))
                        MyHistoryArray.append(symbol)
                        
                        displayNumber = nil
                        pendingFunction = function
                        resultIsPending = true
                    } else {
                        //1000, ... *
                        MyHistoryArray.append(symbol)
                        
                        pendingFunction = function
                        resultIsPending = true
                    }
                }
                
            case .result:
                if resultIsPending {
                    if (displayNumber != nil) {
                        //10 + x -> 10 + x =
                        
                        if MyHistoryArray.islastBinary() {
                            
                            MyHistoryArray.append(String(displayNumber!))
                        }
                        // else             in display 3.14
                        //10 + pi
                        
                        
                        resultNumber = pendingFunction!(resultNumber, displayNumber!)
                        displayNumber = nil
                        
                    } else {
                        //10 + .. -> 10 + 10
                       
                        MyHistoryArray.append(String(resultNumber))
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
                            MyHistoryArray.clear()
                            MyHistoryArray.append(String(displayNumber!))
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
        var tmpstring = MyHistoryArray.get()
        if (resultIsPending) {
            tmpstring += "..."
        } else {
            tmpstring += "="
        }
        return tmpstring
    }
}
