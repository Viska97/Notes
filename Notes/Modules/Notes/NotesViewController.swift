//
//  NotesViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack

class NotesViewController: UIViewController {
    
    private var backendQueue = OperationQueue()
    private var dbQueue = OperationQueue()
    private var commonQueue = OperationQueue()
    private var backgroundContext: NSManagedObjectContext? {
        didSet {
            updateNotes()
        }
    }
    
    private let fileNotebook = FileNotebook()
    
    private var authorized: Bool = false
    
    @IBOutlet weak var notesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //maxConcurrentOperationCount=1 гарантирует что операции будут выполняться последовательно (сначала нам нужно сохранить данные, а только потом обновлять их (если пользователь запросил обновление прямо во время сохранения). Иначе может вначале выполниться задача загрузки, которая вернет нам старые данные
        commonQueue.maxConcurrentOperationCount = 1
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(changeEditMode))
        navigationItem.leftBarButtonItem = editButton
        updateNavigationBar()
        notesTable.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "note")
        notesTable.rowHeight = UITableView.automaticDimension
        notesTable.estimatedRowHeight = 76.0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateNotes), for: .valueChanged)
        notesTable.refreshControl = refreshControl
        //в начале нужен индикатор загрузки, так как данных в списке еще нет и пользователь должен видеть что они загружаются
        createContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        // перед появлением экрана сразу покажем данные в памяти и запустим обновление данных с бекенда
        // в случае первого запуска данных сразу не будет, но будет индикатор загрузки, информирующий пользователя
        notesTable.reloadData()
        notesTable.refreshControl?.beginRefreshing()
        updateNotes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let noteEditViewController = segue.destination as? NoteEditViewController,
            let backgroundContext = backgroundContext,
            segue.identifier == "ShowNoteEditScreen" {
            noteEditViewController.fileNotebook = fileNotebook
            noteEditViewController.backgroundContext = backgroundContext
            noteEditViewController.backendQueue = backendQueue
            noteEditViewController.dbQueue = dbQueue
            noteEditViewController.commonQueue = commonQueue
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
    
    @objc func updateNotes() {
        guard let backgroundContext = backgroundContext else {return}
        checkToken()
        let loadNotesOperation = LoadNotesOperation(
            backgroundContext: backgroundContext,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        //после завершения операции добавляем новую операцию в главную очередь для обновления UI
        loadNotesOperation.completionBlock = {
            let updateUI = BlockOperation { [weak self] in
                guard let self = self else {return}
                guard let notes = loadNotesOperation.result else {return}
                self.fileNotebook.replaceNotes(notes)
                self.notesTable.refreshControl?.endRefreshing()
                self.notesTable.reloadData()
            }
            OperationQueue.main.addOperation(updateUI)
        }
        commonQueue.addOperation(loadNotesOperation)
    }
    
    func removeNote(with uid: String) {
        guard let backgroundContext = backgroundContext else {return}
        checkToken()
        let removeNoteOperation = RemoveNoteOperation(
            uid: uid,
            backgroundContext: backgroundContext,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        //после завершения операции выводим в лог результат и проводим синхронизацию
        removeNoteOperation.completionBlock = {
            let updateUI = BlockOperation { [weak self] in
                guard let result = removeNoteOperation.result else {return}
                DDLogInfo("Note removed with result \(result)", level: logLevel)
                guard let self = self else {return}
                self.updateNotes()
            }
            OperationQueue.main.addOperation(updateUI)
        }
        commonQueue.addOperation(removeNoteOperation)
    }
    
    //если токена нет или это оффлайн режим, показываем экран авторизации
    func checkToken() {
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            if(token == offlineToken) {
                authorized = false
            }
            else {
                authorized = true
            }
        }
        else {
            authorized = false
            requestToken()
        }
        updateNavigationBar()
    }
    
    @objc func requestToken() {
        performSegue(withIdentifier: "ShowAuthScreen", sender: nil)
    }
    
    func createContext() {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Failed to load store")
            }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    fatalError("Failed to setup context")
                }
                self.backgroundContext = container.newBackgroundContext()
            }
        }
    }
    
    func updateNavigationBar() {
        var rightBarButtonItems = [UIBarButtonItem]()
        rightBarButtonItems.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote)))
        if(!authorized){
            rightBarButtonItems.append(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(requestToken)))
        }
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
}

extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Список заметок"
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
            let uid = fileNotebook.notes[indexPath.row].uid
            //сразу показываем пользователю удаление заметки и запускаем операцию удаления
            fileNotebook.remove(with: uid)
            self.notesTable.deleteRows(at: [indexPath], with: .automatic)
            removeNote(with: uid)
        }
    }
    
}
