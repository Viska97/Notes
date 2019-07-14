//
//  SelectedColorView.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class SelectedColorView: UIView {
    
    private let colorView = UIView()
    private let hexLabel = UILabel()
    
    var color : UIColor = .green {
        didSet{
            updateColor()
        }
    }
    
    private var hexColor : String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        self.color.getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X",
                      Int(round(r * 255)), Int(round(g * 255)),
                      Int(round(b * 255)))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.frame = CGRect(
            origin: CGPoint(x: bounds.minX, y: bounds.minY), size: CGSize(width: bounds.width, height: bounds.width))
        hexLabel.frame = CGRect(
            origin: CGPoint(x: bounds.minX, y: colorView.frame.maxY), size: CGSize(width: bounds.width, height: bounds.height - colorView.frame.height))
    }
    
    private func setupViews() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true;
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.black.cgColor
        hexLabel.adjustsFontSizeToFitWidth=true;
        hexLabel.numberOfLines = 0
        hexLabel.lineBreakMode = .byClipping
        hexLabel.textAlignment = .center
        hexLabel.font = UIFont.systemFont(ofSize: 30)
        addSubview(colorView)
        addSubview(hexLabel)
        updateColor()
    }
    
    private func updateColor() {
        colorView.backgroundColor = color
        hexLabel.text = hexColor
    }
    
}
