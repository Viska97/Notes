//
//  ColorItemView.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class ColorItemView: UIView {
    
    var lineWidth: CGFloat = 2  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var itemColor: UIColor? = .green {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isMutable: Bool = false
    
    private var checkMarkPosition: CGPoint {
        let x = bounds.width - checkMarkSize.width - (checkMarkSize.width/5)
        let y = checkMarkSize.height/5
        return CGPoint(x: x, y: y)
    }
    
    private var checkMarkSize: CGSize {
        return CGSize(width: bounds.width/3, height: bounds.width/3)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure() 
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func draw(_ rect: CGRect) {
        if let itemColor = itemColor {
            drawBackground(rect, color: itemColor)
        }
        else {
            drawPalette(rect)
        }
        if(isSelected) {
            drawCheckMark()
        }
    }
    
    func configure() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func drawCheckMark() {
        let rect = CGRect(origin: checkMarkPosition, size: checkMarkSize)
        let circlePath = UIBezierPath(ovalIn: rect)
        circlePath.lineWidth = CGFloat(lineWidth)
        UIColor.clear.setFill()
        UIColor.black.setStroke()
        circlePath.stroke()
        circlePath.fill()
        let markPath = UIBezierPath()
        markPath.lineWidth = CGFloat(lineWidth)
        var x = rect.midX + lineWidth*2 + checkMarkSize.width/2 * cos(.deg2rad(180))
        var y = rect.midY + checkMarkSize.width/2 * sin(.deg2rad(180))
        markPath.move(to: CGPoint(x: x, y: y))
        x = rect.midX + checkMarkSize.width/2 * cos(.deg2rad(90))
        y = rect.midY - lineWidth*2 + checkMarkSize.width/2 * sin(.deg2rad(90))
        markPath.addLine(to: CGPoint(x: x, y: y))
        x = rect.midX + checkMarkSize.width/2 * cos(.deg2rad(300))
        y = rect.midY + lineWidth + checkMarkSize.width/2 * sin(.deg2rad(300))
        markPath.addLine(to: CGPoint(x: x, y: y))
        markPath.stroke()
    }
    
    func drawBackground(_ rect: CGRect, color: UIColor) {
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
    }
    
    func drawPalette(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        for y in 0 ..< Int(rect.height) {
            let saturation = 1 - CGFloat(y) / rect.height
            for x in 0 ..< Int(rect.width) {
                let hue = CGFloat(x) / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }
    
}
