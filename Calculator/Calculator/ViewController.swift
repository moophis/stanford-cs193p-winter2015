//
//  ViewController.swift
//  Calculator
//
//  Created by Liqiang Wang on 2/10/15.
//  Copyright (c) 2015 Liqiang Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    
    // User is in the middle of typing expressions.
    // Note: all properties have to be initialized.
    var expectMore: Bool = false
    
    var brain = CalculateBrain()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        println("digit = \(digit)")
        
        if expectMore {
            display.text = display.text! + digit
        } else {
            display.text = digit
            expectMore = true
        }
    }

    func pushDefinedConstant(symbol: String) {
        if let value = brain.pushOperand(symbol) {
            display.text = String(format: "%f", value)
        } else {
            println("Operand \(symbol) has no value being set!")
            display.text = "N/A"
        }
    }
    
    @IBAction func constant(sender: UIButton) {
        let cons = sender.currentTitle!
        if expectMore {
            enter()
        }
        println("Constant \(cons)")
        
        pushDefinedConstant(cons)
    }
    
    @IBAction func useVariable(sender: UIButton) {
        let label = sender.currentTitle!
        if expectMore {
            enter()
        }
        println("Variable \(label)")
        
        pushDefinedConstant(label)
    }
    
    @IBAction func defineVariable(sender: UIButton) {
        if let val = displayValue {
            brain.variableValues["M"] = val
        } else {
            brain.variableValues["M"] = 0
        }
        expectMore = false
        brain.updateVariableInOpStack("M", value: brain.variableValues["M"]!)
        displayValue = brain.evaluate()
        
        let t = brain.variableValues["M"]!
        println("Variable M = \(t)")
    }
    
    @IBAction func clearAll(sender: AnyObject) {
        display.text = "0"
        brain.clearOpStack()
        brain.clearVariables()
    }
    
    @IBAction func operate(sender: UIButton) {
        if expectMore {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        expectMore = false
        println("After enter(): \(display.text)")
        if !validateNumber(display.text!) {
            println("\(display.text!) is not a valid number!");
            display.text! = "0"
        } else {
            if displayValue != nil {
                if let result = brain.pushOperand(displayValue!) {
                    displayValue = result
                } else {
                    displayValue = 0
                }
            }
        }
    }
    
    var displayValue: Double? {
        get {
//            if let doubleString = NSNumberFormatter().numberFromString(display.text!) {
////                println("doubleString: \(doubleString)")
//                return doubleString.doubleValue
//            } else {
//                return nil
//            }
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            // newValue is a reserved value by Swift
            display.text! = (newValue == nil) ? "0" : "\(newValue!)"
            expectMore = false
        }
    }
    
    // TODO: currently scientific input is not supported
    func validateNumber(str: String) -> Bool {
        println("String to be validated: \(str)")
        var firstChecked: Bool = false
        var hasDot: Bool = false
        var hasDigit: Bool = false
        
        for ch in str {
            if ch == "." {
                if hasDot {
                    return false
                } else {
                    hasDot = true
                }
            } else if ch == "-" && !firstChecked {
                continue
            } else if "0"..."9" ~= ch {
                hasDigit = true
            } else {
                return false
            }
            
            if !firstChecked {
                firstChecked = true
            }
        }
        return hasDigit
    }
}

