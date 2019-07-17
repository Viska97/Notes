//
//  ColorPickerView.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

@IBDesignable
class ColorPickerView: UIView {
    
    private let largeMargin: CGFloat = 16
    private let smallMargin: CGFloat = 8
    
    private var selectedColorView = SelectedColorView()
    private var brightnessSlider = UISlider()
    private var brightnessLabel = UILabel()
    private var colorField = ColorFieldView()
    
    public private(set) var selectedColor: UIColor = UIColor(hue: 0.5, saturation: 0.5, brightness: 1.0, alpha: 1.0) {
        didSet{
            updateUI()
        }
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
        let brightnessLabelSize = brightnessLabel.intrinsicContentSize
        let selectedColorWidth = brightnessLabel.intrinsicContentSize.height + brightnessSlider.intrinsicContentSize.height + largeMargin
        let selectedColorHeight = selectedColorWidth + selectedColorWidth/4
        let selectedColorSize = CGSize(width: selectedColorWidth, height: selectedColorHeight)
        selectedColorView.frame = CGRect(
            origin: CGPoint(x: bounds.minX + largeMargin, y: bounds.minY + largeMargin),
            size: selectedColorSize)
        brightnessSlider.frame = CGRect(
            origin: CGPoint(x: selectedColorView.frame.maxX + largeMargin, y: selectedColorView.frame.maxY - brightnessSlider.intrinsicContentSize.height),
            size: CGSize(width: bounds.maxX - selectedColorView.frame.maxX - largeMargin*2, height: brightnessSlider.intrinsicContentSize.height))
        brightnessLabel.frame = CGRect(
            origin: CGPoint(x: selectedColorView.frame.maxX + largeMargin, y: brightnessSlider.frame.minY - brightnessLabelSize.height - smallMargin), size: brightnessLabelSize)
        colorField.frame = CGRect(
            origin: CGPoint(x: bounds.minX + largeMargin, y: selectedColorView.frame.maxY + smallMargin),
            size: CGSize(width: bounds.width - largeMargin*2, height: bounds.maxY-selectedColorView.frame.maxY-smallMargin*2))
        
    }
    
    @objc private func brightnessValueChanged() {
        colorField.updateBrightness(CGFloat(brightnessSlider.value))
    }
    
    @objc private func colorChanged() {
        selectedColor = colorField.selectedColor
    }
    
    private func setupViews() {
        addSubview(selectedColorView)
        addSubview(brightnessSlider)
        addSubview(brightnessLabel)
        addSubview(colorField)
        brightnessSlider.value = 1.0
        brightnessSlider.addTarget(self, action: #selector(brightnessValueChanged), for:.valueChanged)
        brightnessLabel.text = "Brightness:"
        colorField.colorChangeHandler = { [weak self] in
            self?.colorChanged()
        }
        colorField.updateSelectedColor(selectedColor)
    }
    
    private func updateUI() {
        selectedColorView.color = selectedColor
    }
    
    func updateColor(_ newColor: UIColor) {
        selectedColor = newColor
        colorField.updateSelectedColor(selectedColor)
    }
    
}
