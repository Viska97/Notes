//
//  ColorSelectorView.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

@IBDesignable
class ColorSelectorView : UIView {
    
    private let width = 280
    private let height = 68
    private let itemSize = 68
    private let itemSpacing = 4
    
    @IBInspectable var selectedColor: UIColor = .white {
        didSet {
            updateSelectedColor()
        }
    }
    
    @IBInspectable var firstColor: UIColor = .white {
        didSet {
            updateViewColor(position: 0, color: firstColor)
        }
    }
    @IBInspectable var secondColor: UIColor = .red {
        didSet {
            updateViewColor(position: 1, color: secondColor)
        }
    }
    @IBInspectable var thirdColor: UIColor = .green {
        didSet {
            updateViewColor(position: 2, color: thirdColor)
        }
    }
    @IBInspectable var fourthColor: UIColor? = nil {
        didSet {
            updateViewColor(position: 3, color: fourthColor)
        }
    }
    
    var requestColorHandler: (() -> Void)?
    var selectedColorHandler: (() -> Void)?
    
    private var views = [ColorItemView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = CGSize(width: itemSize, height: itemSize)
        var x = itemSpacing
        for item in views {
            item.frame = CGRect(
                origin: CGPoint(x: x, y: 0),
                size: size)
            x = x + Int(size.width) + itemSpacing
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }
    
    @objc func onTap(_ sender: UIGestureRecognizer) {
        let location = sender.location(in: self)
        let view = self.hitTest(location, with: nil) as? ColorItemView
        if let view = view {
            if let color = view.itemColor {
                selectedColor = color
                selectedColorHandler?()
            } else {
                requestColorHandler?()
            }
        }
    }
    
    @objc func onLongTap(_ sender: UIGestureRecognizer) {
        guard (sender.state == .began) else {return}
        let location = sender.location(in: self)
        let view = self.hitTest(location, with: nil) as? ColorItemView
        if let view = view {
            if view.isMutable {
                requestColorHandler?()
            }
        }
    }
    
    private func initialize() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap(_:)))
        self.addGestureRecognizer(longGesture)
        setupViews()
    }
    
    private func setupViews() {
        let colors = [firstColor, secondColor, thirdColor, fourthColor]
        for (index, color) in colors.enumerated() {
            let view = ColorItemView()
            view.itemColor = color
            if(index == 3) {
                view.isMutable = true
            }
            views.append(view)
        }
        for view in views {
            addSubview(view)
        }
        updateSelectedColor()
    }
    
    private func updateViewColor(position: Int, color: UIColor?) {
        views[position].itemColor = color
        updateSelectedColor()
    }
    
    private func updateSelectedColor() {
        deSelect()
        if let view = views.first(where: { $0.itemColor == selectedColor }) {
           view.isSelected = true
        }
        else {
            views[3].itemColor = selectedColor
            views[3].isSelected = true
        }
    }
    
    private func deSelect() {
        views.first(where: { $0.isSelected == true })?.isSelected = false
    }
    
}
