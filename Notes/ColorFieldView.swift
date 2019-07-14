//
//  ColorFieldView.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class ColorFieldView: UIView {
    
    private let backgroundScale: CGFloat = 4
    private var backgroundImage: UIImage? = nil
    
    public private(set) var selectedColor: UIColor = .white {
        didSet{
            setNeedsDisplay()
            colorChangeHandler?()
        }
    }
    
    public private(set) var brightness: CGFloat = 1.0
    
    public var colorChangeHandler: (() -> Void)?
    
    private var markSize: CGFloat {
        if(bounds.width<bounds.height){
            return bounds.width/10
        }
        return bounds.height/10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if(backgroundImage == nil) {
            createBackgroundImage()
        }
        backgroundImage?.draw(in: rect)
        drawFilter(rect)
        drawMark()
    }
    
    private func initialize() {
        self.isOpaque = true
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onDrag(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func onTap(_ sender: UIGestureRecognizer) {
        onColorChanged(sender)
    }
    
    @objc func onDrag(_ sender: UILongPressGestureRecognizer) {
        guard (sender.state == .began || sender.state == .changed) else {return}
        onColorChanged(sender)
    }
    
    private func onColorChanged(_ sender: UIGestureRecognizer) {
        let point = sender.location(in: self)
        guard(self == self.hitTest(point, with: nil)) else {return}
        selectedColor = getColorAtPoint(point: point)
    }
    
    private func drawFilter(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1 - brightness)
        context.setFillColor(color.cgColor)
        context.fill(rect)
    }
    
    private func drawMark() {
        let point = getPointForColor(selectedColor)
        let position = CGPoint(x: point.x-markSize/2+markSize/6,y: point.y-markSize/2+markSize/6)
        let markRadius = CGSize(width: markSize/1.5, height: markSize/1.5)
        let rect = CGRect(origin: position, size: markRadius)
        let circlePath = UIBezierPath(ovalIn: rect)
        circlePath.lineWidth = CGFloat(1)
        UIColor.clear.setFill()
        UIColor.black.setStroke()
        circlePath.stroke()
        circlePath.fill()
        let markPath = UIBezierPath()
        var x = rect.midX + markSize/1.5 * cos(.deg2rad(270))
        var y = rect.midY + markSize/2 * sin(.deg2rad(270))
        markPath.move(to: CGPoint(x: x, y: y))
        y = y + markSize/6
        markPath.addLine(to: CGPoint(x: x, y: y))
        x = rect.midX + markSize/3 * cos(.deg2rad(0))
        y = rect.midY + markSize/2 * sin(.deg2rad(0))
        markPath.move(to: CGPoint(x: x, y: y))
        x = x + markSize/6
        markPath.addLine(to: CGPoint(x: x, y: y))
        x = rect.midX + markSize/1.5 * cos(.deg2rad(90))
        y = rect.midY + markSize/2 * sin(.deg2rad(90))
        markPath.move(to: CGPoint(x: x, y: y))
        y = y - markSize/6
        markPath.addLine(to: CGPoint(x: x, y: y))
        x = rect.midX + markSize/3 * cos(.deg2rad(180))
        y = rect.midY + markSize/3 * sin(.deg2rad(180))
        markPath.move(to: CGPoint(x: x, y: y))
        x = x - markSize/6
        markPath.addLine(to: CGPoint(x: x, y: y))
        markPath.stroke()
    }
    
    private func getPointForColor(_ color:UIColor) -> CGPoint {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        let yPos = self.bounds.height - saturation * self.bounds.height
        let xPos = hue * self.bounds.width
        return CGPoint(x: xPos, y: yPos)
    }
    
    private func getColorAtPoint(point:CGPoint) -> UIColor {
        let saturation = 1 - point.y / self.bounds.height
        let hue = point.x / self.bounds.width
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    func updateBrightness(_ newBrightness: CGFloat) {
        self.brightness = newBrightness
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        selectedColor.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        selectedColor = UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: 1.0)
    }
    
    func updateSelectedColor(_ newColor: UIColor) {
        var newBrightness: CGFloat = 0.0
        selectedColor = newColor
        selectedColor.getHue(nil, saturation: nil, brightness: &newBrightness, alpha: nil)
        brightness = newBrightness
    }
    
    private func createBackgroundImage() {
        let width = Int(self.frame.width/backgroundScale)
        let height = Int(self.frame.height/backgroundScale)
        guard let bitmapData = CFDataCreateMutable(nil, 0) else {
            return
        }
        CFDataSetLength(bitmapData, CFIndex(width * height * 4))
        fillBackgroundImage(bitmap: CFDataGetMutableBytePtr(bitmapData), size: CGSize(width: width, height: height))
        guard let dataProvider = CGDataProvider(data: bitmapData) else {
            return
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let image = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: CGColorRenderingIntent.defaultIntent
        )
        if let image = image {
            backgroundImage = UIImage(cgImage: image)
        }
    }
    
    private func fillBackgroundImage(bitmap: UnsafeMutablePointer<UInt8>, size: CGSize) {
        for y in 0 ..< Int(size.height) {
            let saturation = 1 - CGFloat(y) / CGFloat(size.height)
            for x in 0 ..< Int(size.width) {
                let hue = CGFloat(x) / CGFloat(size.width)
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                let i: Int = 4 * (x + y * Int(size.width))
                bitmap[i] = UInt8(red * 255)
                bitmap[i + 1] = UInt8(green * 255)
                bitmap[i + 2] = UInt8(blue * 255)
                bitmap[i + 3] = UInt8(alpha * 255)
            }
        }
    }

}
