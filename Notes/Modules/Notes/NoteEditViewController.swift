//
//  NoteEditViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class NoteEditViewController: UIViewController,UITextViewDelegate {
    
    private let backendQueue = OperationQueue()
    private let dbQueue = OperationQueue()
    private let commonQueue = OperationQueue()
    
    var fileNotebook: FileNotebook? = nil
    var note: Note? = nil
    
    //плейсхолдер содержимого заметки
    private let contentPlaceholder = "Enter note content"
    //текущая высота клавиатуры
    private var keyboardHeight: CGFloat = 0.0
    
    private var doneButton: UIBarButtonItem?
    
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var colorSelector: ColorSelectorView!
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        updateUI()
    }
    @IBAction func dateChanged() {
        updateUI()
    }
    @IBAction func titleChanged() {
        updateUI()
    }
    
    @IBAction func unwindToEditNote(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(save))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        tabBarController?.tabBar.isHidden = true
        contentTextView.delegate = self
        colorSelector.requestColorHandler = { [weak self] in
            self?.onColorRequested()
        }
        colorSelector.selectedColorHandler = { [weak self] in
            self?.updateUI()
        }
        titleTextView.text = note?.title ?? ""
        contentTextView.text = note?.content ?? ""
        colorSelector.selectedColor = note?.color ?? .white
        if let date = note?.selfDestructDate {
            dateSwitch.isOn = true
            datePicker.date = date
        }
        if (note?.title != "" && note?.content != "") {
            title = "Редактирование заметки"
        }
        updateUI(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) 
        //подписка на события появления и убирания клавиатуры
        self.registerForKeyboardNotifications()
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //отписываемся от событий появления и убирания клавиатуры
        self.unregisterFromKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let colorPickerViewController = segue.destination as? ColorPickerViewController,
            segue.identifier == "ShowColorPickerScreen",
            let color = colorSelector.fourthColor {
            colorPickerViewController.selectedColor = color
        }
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
        performSegue(withIdentifier: "ShowColorPickerScreen", sender: nil)
    }
    
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func save() {
        if let uid = note?.uid, let title = titleTextView.text, let content = contentTextView.text,
            let notebook = fileNotebook {
            let updatedNote = Note(uid: uid,
                                   title: title,
                                   content: content,
                                   color: colorSelector.selectedColor,
                                   importance: .normal,
                                   selfDestructDate: date)
            //fileNotebook?.add(updatedNote)
            let saveNoteOperation = SaveNoteOperation(
                note: updatedNote,
                notebook: notebook,
                backendQueue: backendQueue,
                dbQueue: dbQueue
            )
            commonQueue.addOperation(saveNoteOperation)
        }
        navigationController?.popViewController(animated: true)
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
        doneButton?.isEnabled = saveAvailable
        //через 0.01 т.к. высота поля выбора даты не обновляется моментально
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            self.updateScrollViewInset()
        })
    }
    
    //метод для обновления оступа снизу для scroll view (нужен, чтобы иметь возможность прокрутить scroll view полностью при наличии клавиатуры на экране
    private func updateScrollViewInset() {
        let contentHeight = colorSelector.frame.maxY
        if (contentHeight > (scrollView.frame.height - keyboardHeight)){
            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            if (contentHeight > scrollView.frame.height) {
                contentInset.bottom = keyboardHeight
            }
            else {
                contentInset.bottom = keyboardHeight - (scrollView.frame.height-contentHeight)
            }
            scrollView.contentInset = contentInset
        }
        else{
            let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInset
        }
    }
    
}

extension NoteEditViewController {
    
    var date: Date? {
        guard( dateSwitch.isOn) else {return nil}
        return datePicker.date
    }
    
    var contentIsEmpty: Bool {
        guard (contentTextView.textColor != UIColor.lightGray) else {return true}
        return contentTextView.text == ""
    }
    
    var saveAvailable: Bool {
        guard (titleTextView.text != "" && !contentIsEmpty) else {return false}
        if (titleTextView.text == note?.title &&
            contentTextView.text == note?.content &&
            colorSelector.selectedColor == note?.color &&
            date?.timeIntervalSinceReferenceDate == note?.selfDestructDate?.timeIntervalSinceReferenceDate) {
            return false
        }
        else {return true}
    }
    
}
