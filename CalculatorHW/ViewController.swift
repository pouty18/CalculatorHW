//
//  ViewController.swift
//  CalculatorHW
//
//  Created by Richard Poutier on 11/17/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var userIsInMiddleOfTyping: Bool = false
    
    var containsDecimal : Bool {
        let val = display.text!
        if val.contains(".") {
            return true
        } else {
            return false
        }
    }
    
    var displayValue : Double {
        set {
            display.text! = String(newValue)
        }
        get {
            return Double(display.text!)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func digitPressed(_ sender: UIButton) {
        
        if containsDecimal && sender.currentTitle! == "." {
            if !userIsInMiddleOfTyping {
                display.text = sender.currentTitle!
                userIsInMiddleOfTyping = true
            }
        } else if userIsInMiddleOfTyping {
            display.text! += sender.currentTitle!
        } else {
            display.text! = sender.currentTitle!
            userIsInMiddleOfTyping = true
        }
    }
    
    var brain = CalculatorBrain()
    
    @IBAction func clear() {
        brain = CalculatorBrain()
        display.text = ""
        descriptionLabel.text = ""
    }
    
    @IBAction func operationPressed(_ sender: UIButton) {
        userIsInMiddleOfTyping = false
        
        if brain.accumulator == nil {
            brain.setOperand(displayValue)
        }
        
        brain.performOperation(sender.currentTitle!)
        
        if brain.result != nil {
            display.text = "\(brain.result!)"
        }
        
        if brain.description != nil {
            print(brain.description!)
        }
        
        
        if brain.resultIsPending && brain.description != nil {
            descriptionLabel.text = brain.description! + "..."
        } else if brain.description != nil {
            descriptionLabel.text = brain.description! + "="
        }
    }
    
}

