//
//  ColorPickerViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    var selectedColor: UIColor? = nil
    
    @IBOutlet weak var colorPicker: ColorPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        tabBarController?.tabBar.isHidden = true
        if let color = selectedColor {
            colorPicker.updateColor(color)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let noteEditViewController = segue.destination as? NoteEditViewController,
            segue.identifier == "UnwindToEditNote" {
            noteEditViewController.colorSelector.selectedColor = colorPicker.selectedColor
        }
    }
    
    @objc private func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func done() {
        performSegue(withIdentifier: "UnwindToEditNote", sender: nil)
    }
    
    //@IBAction func unwindToNoteEdit(segue: UIStoryboardSegue) {}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
