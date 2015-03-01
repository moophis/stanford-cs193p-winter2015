//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Liqiang Wang on 2/27/15.
//  Copyright (c) 2015 Liqiang Wang. All rights reserved.
//

import Foundation

class CalculateBrain: Printable
{
    // Enum for operands and operators
    private enum Op: Printable {
        case Operand(Double?, String?) // (value, constant/variable name)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand, let name):
                    if name != nil {
                        return "\(name!)"
                    }
                    return "\(operand!)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    // The description of the class showing the complete math expression
    var description: String {
        get {
            if let desc = restoreExpression(opStack).expr {
                return "CurrentExpression: \(desc)"
            } else {
                return "(No description for CalculateBrain to show)"
            }
        }
    }
    
    // The stack storing the input Ops
    private var opStack = [Op]()
    
    // Supported Ops
    private var knownOps = [String : Op]()
    
    // Supported constants
    private var knownConstants = [String : Double]()
    
    // Variable map
    var variableValues = [String : Double]()
    
    init() {
        knownOps["×"] = Op.BinaryOperation("×") { $0 * $1 }
        knownOps["÷"] = Op.BinaryOperation("÷") { (op0, op1) in
            if op0 == 0 {
                println("Error: divide by zero!")
                return 0
            } else {
                return op1 / op0
            }
        }
        knownOps["+"] = Op.BinaryOperation("+") { $0 + $1 }  // ("+", +)
        knownOps["-"] = Op.BinaryOperation("-") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√") { sqrt($0) }  // ("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin") { sin($0) }
        knownOps["cos"] = Op.UnaryOperation("cos") { cos($0) }
        
        knownConstants["π"] = M_PI
    }
    
    // Restore the math expression from the reverse-polish style input
    private func restoreExpression(ops: [Op]) -> (expr: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand, let symbol):
                if symbol != nil {
                    return (symbol, remainingOps)
                } else {
                    return (operand?.toString(), remainingOps)
                }
            case .UnaryOperation(let symbol, _):
                let opEvaluation = restoreExpression(remainingOps)
                if let unaryExpr = opEvaluation.expr {
                    let ret = "\(symbol)(\(unaryExpr))"
                    return (ret, opEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let rightEvaluation = restoreExpression(remainingOps)
                if let rightExpr = rightEvaluation.expr {
                    let leftEvaluation = restoreExpression(rightEvaluation.remainingOps)
                    if let leftExpr = leftEvaluation.expr {
                        let ret = "(\(leftExpr)\(symbol)\(rightExpr))"
                        return (ret, leftEvaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    // Evaluate the math expression and calculate the result
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand, _):
                if operand == nil {
                    return (nil, ops)
                }
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evalution = evaluate(remainingOps)
                if let operand1 = op1Evalution.result {
                    let op2Evaluation = evaluate(op1Evalution.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    // Evaluate the expression stored in the op stack
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) with \(remainder)")
        println(self)
        return result
    }
    
    // Push operand literal
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand, nil))
        return evaluate()
    }
    
    // Operand can have a name (e.g. constants)
    // When you push an empty variable as a placeholder, operand can be nil
    func pushOperand(operand: Double?, symbol: String) -> Double? {
        opStack.append(Op.Operand(operand, symbol))
        return evaluate()
    }
    
    // Push a labeled operand (constants or registered variables)
    func pushOperand(symbol: String) -> Double? {
        // Check constants
        if let value = knownConstants[symbol] {
            return pushOperand(value, symbol: symbol)
        }
        // Check variables
        if let value = variableValues[symbol] {
            return pushOperand(value, symbol: symbol)
        }
        // Then it mush be an unregistered variable
        return pushOperand(nil, symbol: symbol)
    }
    
    // Push operator and then evaluate
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    // update variables (if exist) in the op stack
    func updateVariableInOpStack(symbol: String, value: Double) {
        for (index, val) in enumerate(opStack) {
            switch val {
            case .Operand(nil, let name):
                if name == symbol {
                    opStack[index] = Op.Operand(value, symbol)
                }
            default: break
            }
        }
    }
    
    func clearOpStack() {
        opStack.removeAll(keepCapacity: true)
        assert(opStack.isEmpty)
    }
    
    func clearVariables() {
        variableValues.removeAll(keepCapacity: true)
        assert(variableValues.isEmpty)
    }
}

// Utility Extensions
extension Double {
    func toString() -> String {
        return String(format: "%.1f", self)
    }
}