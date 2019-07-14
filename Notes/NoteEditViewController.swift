//
//  NoteEditViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class NoteEditViewController: UIViewController,UITextViewDelegate {
    
    //плейсхолдер содержимого заметки
    let contentPlaceholder = "Enter note content"
    //текущая высота клавиатуры
    var keyboardHeight: CGFloat = 0.0
    
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextView: UITextField!
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
        updateUI(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //подписка на события появления и убирания клавиатуры
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //отписываемся от событий появления и убирания клавиатуры
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
        var userInfo = notification.userInfo
        let keyboardFrame:CGRect? = (userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        if var keyboardFrame = keyboardFrame {
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            keyboardHeight = keyboardFrame.size.height
        }
        else {
            keyboardHeight = 0.0
        }
        updateUI()
    }
    
    @objc func keyboardWillHide (_ notification: Notification) {
        keyboardHeight = 0.0
        updateUI()
    }
    
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    internal func textViewDidEndEditing(_ textView: UITextView) {
        updateUI(true)
    }
    
    internal func textViewDidChange(_ textView: UITextView) {
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
    
    private func updateUI(_ updatePlaceholder: Bool = false) {
        datePicker.isHidden = !dateSwitch.isOn
        //изменяем приоритет констрейнта высоты, чтобы скрывать и показывать поле выбора даты
        if (dateSwitch.isOn) {
            datePickerHeight.priority = UILayoutPriority(1)
        }
        else{
            datePickerHeight.priority = UILayoutPriority(999)
        }
        //логика обновления плейсхолдера для содержимого заметки
        if(updatePlaceholder){
            if (contentTextView.text.isEmpty) {
                contentTextView.text = contentPlaceholder
                contentTextView.textColor = UIColor.lightGray
            }
            else {
                contentTextView.textColor = UIColor.black
            }
        }
        //через 0.01 т.к. высота поля выбора даты не обновляется моментально
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            self.updateScrollViewInset()
        })
    }
    
    //метод для обновления оступа снизу для scroll view (нужен, чтобы иметь возможность прокрутить scroll view полностью при наличии клавиатуры на экране
    private func updateScrollViewInset() {
        let contentHeight = titleTextView.bounds.height + contentTextView.bounds.height + dateSwitch.bounds.height + datePicker.bounds.height + colorSelector.bounds.height + CGFloat(40)
        if (contentHeight > (colorPicker.bounds.height - keyboardHeight)){
            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            if (contentHeight > colorPicker.bounds.height) {
                contentInset.bottom = keyboardHeight
            }
            else {
                contentInset.bottom = keyboardHeight - (colorPicker.bounds.height-contentHeight)
            }
            scrollView.contentInset = contentInset
        }
        else{
            let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInset
        }
    }
    
}
