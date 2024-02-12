//
//  CommentsTableViewCell.swift
//  Will API
//
//  Created by Shishir_Mac on 10/2/24.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var commentsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentsView.layer.cornerRadius = 6
        commentsView.backgroundColor = .systemGray6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // configurate Comments The Cell
    func configurateCommentsTheCell(_ comments: Comments) {
        nameLabel.text = comments.name
        emailLabel.text = comments.email
        bodyLabel.text = comments.body
    }
    
}
