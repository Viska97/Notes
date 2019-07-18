//
//  ImageNoteViewController.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class ImageNoteViewController: UIViewController {
    
    var fileNotebook: FileNotebook? = nil
    var indexPath: Int = 0
    
    private var imageNotes = [ImageNote]()
    private var dragging = false
    private var imageViews = [UIImageView]()
    
    @IBOutlet weak var imageNoteSlider: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        tabBarController?.tabBar.isHidden = true
        imageNoteSlider.delegate = self
        setupImageViews()
        setupImages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImagesFrames()
        let contentWidth = imageNoteSlider.frame.width * CGFloat(imageViews.count)
        imageNoteSlider.contentSize = CGSize(width: contentWidth, height: imageNoteSlider.frame.height)
        imageNoteSlider.setContentOffset(CGPoint(x: imageNoteSlider.frame.width*CGFloat(currentPage), y: 0), animated: false)
    }
    
    private func updateImages() {
        for(index, imageView) in imageViews.enumerated() {
            imageView.image = UIImage(contentsOfFile: imageNotes[index].path)
        }
    }
    
    private func updateImagesFrames() {
        for(index, imageView) in imageViews.enumerated() {
            imageView.frame.size = imageNoteSlider.frame.size
            imageView.frame.origin.x = imageNoteSlider.frame.width * CGFloat(index)
            imageView.frame.origin.y = 0
        }
    }
    
    private func setupImageViews() {
        guard let fileNotebook = fileNotebook else {return}
        var count = 3
        if (fileNotebook.imageNotes.count < 3){
            count = fileNotebook.imageNotes.count
        }
        (0..<count).forEach {_ in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)
        }
    }
    
    private func setupImages() {
        guard let fileNotebook = fileNotebook else {return}
        var indexes = [Int]()
        if(indexPath == fileNotebook.imageNotes.count-1){
            let start = max(fileNotebook.imageNotes.count-1-indexPath, indexPath-2)
            for i in start...indexPath {
                indexes.append(i)
            }
        }
        else if(indexPath == 0){
            let end = min(fileNotebook.imageNotes.count-1, indexPath+2)
            for i in 0...end {
                indexes.append(i)
            }
        }
        else {
            for i in indexPath-1...indexPath+1 {
                indexes.append(i)
            }
        }
        for index in indexes {
            imageNotes.append(fileNotebook.imageNotes[index])
        }
        for imageView in imageViews {
            imageNoteSlider.addSubview(imageView)
        }
        updateImages()
    }
    
    private var currentPage: Int {
        let uid = fileNotebook?.imageNotes[indexPath].uid
        if let page = imageNotes.firstIndex(where: { $0.uid == uid }) {
            return page
        }
        else{
            return 0
        }
    }

}

extension ImageNoteViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        dragging = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dragging = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let fileNotebook = fileNotebook else {return}
        if !dragging {
            return
        }
        let offsetX = scrollView.contentOffset.x
        let previousPage = currentPage
        if (offsetX > scrollView.frame.size.width * 1.5) {
            guard (indexPath < fileNotebook.imageNotes.count-1) else {return}
            indexPath = indexPath + 1
            guard (previousPage == 1 && indexPath < fileNotebook.imageNotes.count-1) else {return}
            let newImageNote = fileNotebook.imageNotes[indexPath+1]
            imageNotes.remove(at: 0)
            imageNotes.append(newImageNote)
            updateImages()
            scrollView.contentOffset.x -= scrollView.frame.width
        }
        if (offsetX < scrollView.frame.size.width * 0.5) {
            guard (indexPath > 0) else {return}
            indexPath = indexPath - 1
            guard (previousPage == 1 && indexPath > 0) else {return}
            let newImageNote = fileNotebook.imageNotes[indexPath-1]
            imageNotes.removeLast()
            imageNotes.insert(newImageNote, at: 0)
            updateImages()
            scrollView.contentOffset.x += scrollView.frame.width
        }
    }
    
}
