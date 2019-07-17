//
//  NotesViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    private let fileNotebook = (UIApplication.shared.delegate as! AppDelegate).fileNotebook
    
    @IBOutlet weak var notesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(changeEditMode))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        navigationItem.leftBarButtonItem = editButton
        navigationItem.rightBarButtonItem = addButton
        notesTable.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "note")
        notesTable.rowHeight = UITableView.automaticDimension
        notesTable.estimatedRowHeight = 76.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        notesTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let noteEditViewController = segue.destination as? NoteEditViewController,
            segue.identifier == "ShowNoteEditScreen" {
            noteEditViewController.fileNotebook = fileNotebook
            if let cell = sender as? NoteTableViewCell, let indexPath = notesTable.indexPath(for: cell) {
                noteEditViewController.note = fileNotebook.notes[indexPath.row]
            }
            else {
                noteEditViewController.note = Note(title: "", content: "", importance: .normal)
            }
        }
    }
    
    @objc func changeEditMode() {
        notesTable.setEditing(!notesTable.isEditing, animated: true)
    }
    
    @objc func addNote() {
        performSegue(withIdentifier: "ShowNoteEditScreen", sender: nil)
    }

}

extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Prototype Cells"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNotebook.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath) as! NoteTableViewCell
        let note = fileNotebook.notes[indexPath.row]
        if note.color == .white {
            cell.colorView.layer.borderWidth = 1
        }
        else {
            cell.colorView.layer.borderWidth = 0
        }
        cell.colorView.backgroundColor = note.color
        cell.titleLabel.text = note.title
        cell.contentLabel.text = note.content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowNoteEditScreen", sender: tableView.cellForRow(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            let uid = fileNotebook.notes[indexPath.row].uid
            fileNotebook.remove(with: uid)
            notesTable.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}
