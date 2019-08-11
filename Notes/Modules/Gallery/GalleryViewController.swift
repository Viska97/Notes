//
//  GalleryViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit
import Photos

class GalleryViewController: UIViewController {
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 12.0,
                                             left: 12.0,
                                             bottom: 12.0,
                                             right: 12.0)
    
    private let imageNotebook = ImageNotebook()
    
    private let imagePickerController = UIImagePickerController()

    @IBOutlet weak var imageNotesCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImageNote))
        navigationItem.rightBarButtonItem = addButton
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imageNotesCollection.register(UINib(nibName: "NoteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageNote")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        imageNotebook.loadFromFile()
        imageNotesCollection.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageNoteViewController = segue.destination as? ImageNoteViewController,
            segue.identifier == "ShowImageNoteScreen",
            let indexPath = sender as? IndexPath {
            imageNoteViewController.imageNotebook = imageNotebook
            imageNoteViewController.indexPath = indexPath.row
        }
    }
    
    @objc private func addImageNote() {
        present(imagePickerController, animated: true, completion: nil)
    }

}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            let imageNote = ImageNote(name: url.lastPathComponent)
            imageNotebook.add(imageNote)
            imageNotebook.saveToFile()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNotebook.imageNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageNotesCollection.dequeueReusableCell(withReuseIdentifier: "imageNote", for: indexPath) as! NoteCollectionViewCell
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        let note = imageNotebook.imageNotes[indexPath.row]
        DispatchQueue.global(qos: .background).async {
            let image = UIImage(contentsOfFile: note.path)
            DispatchQueue.main.async {
                cell.noteImage.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = imageNotesCollection.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: imageNotesCollection)
        let indexPath = imageNotesCollection.indexPathForItem(at: location)
        if let index = indexPath {
            performSegue(withIdentifier: "ShowImageNoteScreen", sender: index)
        }
    }
    
}
