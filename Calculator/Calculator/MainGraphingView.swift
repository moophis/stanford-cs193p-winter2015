//
//  MainGraphingView.swift
//  Calculator
//
//  Created by Liqiang Wang on 3/12/15.
//  Copyright (c) 2015 Liqiang Wang. All rights reserved.
//

import UIKit
import CoreGraphics

protocol MainGraphingViewDataSource: class {
    func functionValue(x: Double) -> Double? 
}

@IBDesignable
class MainGraphingView: UIView {
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var originOffset: OriginOffset = OriginOffset() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var axesDrawer = AxesDrawer()
    
    weak var dataSource: MainGraphingViewDataSource?
    
    // Drawing code
    override func drawRect(rect: CGRect) {
        println("width: \(rect.width), height: \(rect.height), originX: \(rect.minX), originY: \(rect.minY), endX: \(rect.maxX), endY: \(rect.maxY), center: (\(rect.midX), \(rect.midY)), pixels per point: \(contentScaleFactor)")
        
        // Check whether the origin has been changed by double tapping gesture
        if originReset {
            originOffset.x = tappingLocation.x - rect.midX
            originOffset.y = tappingLocation.y - rect.midY
            originReset = false
        }
        
        let originPoint = CGPoint(x: rect.midX + originOffset.x,
                                  y: rect.midY + originOffset.y)
        
        // Draw axes
        axesDrawer.drawAxesInRect(rect,
            origin: originPoint,
            pointsPerUnit: Scaling.POINTS_PER_UNIT * scale)
        
        // Draw function plot
        drawFunctionPlot(rect,
            origin: originPoint,
            pointsPerUnit: Scaling.POINTS_PER_UNIT * scale)
    }
    
    // Draw the function plot
    private func drawFunctionPlot(rect: CGRect, origin: CGPoint, pointsPerUnit: CGFloat) {
        for var xpt = rect.minX; xpt <= rect.maxX; xpt += 1.0 {
            if let xcoor = getXCoordinateFromPointValue(xpt, origin: origin, pointsPerUnit: pointsPerUnit) {
                if let ycoor = dataSource?.functionValue(xcoor) {
                    if let ypt = getYPointValueFromCoordinate(ycoor, origin: origin, pointsPerUnit: pointsPerUnit) {
                        drawDot(CGPoint(x: xpt, y: ypt), bound: rect)
                    }
                }
            }
        }
    }
    
    private func drawDot(point: CGPoint, bound: CGRect) {
        if point.x >= bound.minX && point.x <= bound.maxX
            && point.y >= bound.minY && point.y <= bound.maxY {
                CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(point.x, point.y, 1, 1))
        }
    }
    
    private func getXCoordinateFromPointValue(pointValue: CGFloat, origin: CGPoint, pointsPerUnit: CGFloat) -> Double? {
        if pointsPerUnit == CGFloat(0) {
            return nil
        }
        let dx = (pointValue - origin.x) / pointsPerUnit
        return Double(dx)
    }
    
    private func getYPointValueFromCoordinate(coordinate: Double, origin: CGPoint, pointsPerUnit: CGFloat) -> CGFloat? {
        if pointsPerUnit == CGFloat(0) {
            return nil
        }
        return origin.y - (CGFloat(coordinate) * pointsPerUnit)
    }
    
    // Scaling gesture handler
    func scale(gesture: UIPinchGestureRecognizer) {
        let location = gesture.locationInView(self)
        println("The location of the pinch: (\(location.x), \(location.y))")
        
        if gesture.state == .Changed {
            scale = max(min(scale * gesture.scale, Scaling.MAX_SCALE_FACTOR), Scaling.MIN_SCALE_FACTOR)
            gesture.scale = 1
        }
        println("Current scale: \(scale)")
    }
    
    // Double tapping gesture handler
    func doubleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.locationInView(self)
        tappingLocation = location
        println("Got a double tap: @(\(location.x), \(location.y))")
    }
    
    // To indicate if double tap occurred so that we need to adjust the origin
    // offset in a different way in drawRect()
    private var originReset: Bool = false
    private var tappingLocation: CGPoint = CGPointZero {
        didSet {
            originReset = true
            setNeedsDisplay()
        }
    }
    
    private struct Scaling {
        static let POINTS_PER_UNIT: CGFloat = 50
        static let MAX_SCALE_FACTOR: CGFloat = 3
        static let MIN_SCALE_FACTOR: CGFloat = 0.4
    }
    
    // The coordinate difference of the origin point
    struct OriginOffset {
        var x: CGFloat = CGFloat(0)
        var y: CGFloat = CGFloat(0)
    }

}
