//
//  NoteTableViewCell.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        super.setSelected(selected, animated: animated)
        if selected {
            colorView.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            colorView.backgroundColor = color
        }
    }
    
}
