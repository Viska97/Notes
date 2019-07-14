//
//  NoteEditViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class NoteEditViewController: UIViewController,UITextViewDelegate {
    
    let contentPlaceholder = "Enter note content"
    
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var colorSelector: ColorSelectorView!
    @IBOutlet weak var colorPicker: ColorPickerView!
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.delegate = self
        colorSelector.requestColorHandler = { [weak self] in
            self?.onColorRequested()
        }
        colorPicker.selectColorHandler = { [weak self] in
            self?.onColorSelected()
        }
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterFromKeyboardNotifications()
    }
    
    private func registerForKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterFromKeyboardNotifications() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        center.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow (_ notification: Notification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide (_ notification: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    internal func textViewDidEndEditing(_ textView: UITextView) {
        updateUI()
    }
    
    private func onColorRequested() {
        if let color = colorSelector.fourthColor {
            colorPicker.updateColor(color)
        }
        colorPicker.isHidden = false
    }
    
    private func onColorSelected() {
        colorPicker.isHidden = true
        colorSelector.selectedColor = colorPicker.selectedColor
    }
    
    private func updateUI() {
        datePicker.isHidden = !dateSwitch.isOn
        if (dateSwitch.isOn) {
            datePickerHeight.priority = UILayoutPriority(1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                self.scrollToEnd()
            })
        }
        else{
            datePickerHeight.priority = UILayoutPriority(999)
        }
        if (contentTextView.text.isEmpty) {
            contentTextView.text = contentPlaceholder
            contentTextView.textColor = UIColor.lightGray
        }
        else {
            contentTextView.textColor = UIColor.black
        }
    }
    
    private func scrollToEnd() {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
}
