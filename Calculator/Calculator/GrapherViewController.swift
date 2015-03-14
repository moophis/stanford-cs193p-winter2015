//
//  GrapherViewController.swift
//  Calculator
//
//  Created by Liqiang Wang on 3/11/15.
//  Copyright (c) 2015 Liqiang Wang. All rights reserved.
//

import UIKit

class GrapherViewController: UIViewController, MainGraphingViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("Grapher viewDidLoad()")
        functionExperssion.text = titleContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        mainGraphingView?.setNeedsDisplay()
    }
    
    @IBOutlet weak var functionExperssion: UILabel!
    
    @IBOutlet weak var mainGraphingView: MainGraphingView! {
        didSet {
            println("didSet mainGraphingView")
            mainGraphingView.dataSource = self
            mainGraphingView.addGestureRecognizer(UIPinchGestureRecognizer(target: mainGraphingView, action: "scale:"))
            var uiTapGestureRecognizer = UITapGestureRecognizer(target: mainGraphingView, action: "doubleTap:")
            uiTapGestureRecognizer.numberOfTapsRequired = 2
            mainGraphingView.addGestureRecognizer(uiTapGestureRecognizer)
        }
    }

    @IBAction func moveGraph(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(mainGraphingView)
        let offset = sender.translationInView(mainGraphingView)
        println("Caught a move! @(\(location.x), \(location.y)) " +
            "-> @(\(offset.x), \(offset.y))")
        mainGraphingView.originOffset.x += offset.x / Constants.DUMPING_FACTOR
        mainGraphingView.originOffset.y += offset.y / Constants.DUMPING_FACTOR
        sender.setTranslation(CGPointZero, inView: mainGraphingView)
    }
    
    // Implmentation of the protocol MainGraphingViewDataSource
    func functionValue(x: Double) -> Double? {
//        return pow(x, x)
        brain.variableValues["M"] = x
        brain.updateVariableInOpStack("M", value: brain.variableValues["M"]!)
        let y = brain.evaluate()
        println("f(\(x)) = \(y)")
        return y
    }
    
    // Calculate brain
    var brain: CalculateBrain = CalculateBrain() {
        didSet {
            println("CalculateBrain passed by ViewController")
        }
    }
    
    // Content shown on the label functionExperssion
    var titleContent: String = "(N/A)" {
        didSet {
            println("titleContent has been set")
        }
    }
    
    private struct Constants {
        // To prevent the view to be moved too fast
        static let DUMPING_FACTOR: CGFloat = CGFloat(1)
    }
}