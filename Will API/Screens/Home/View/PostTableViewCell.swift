//
//  PostTableViewCell.swift
//  Will API
//
//  Created by Shishir_Mac on 10/2/24.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var cellBGView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBGView.layer.cornerRadius = 6
        cellBGView.layer.borderWidth = 1
        cellBGView.layer.borderColor = UIColor.brown.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Function
    func configuratePostTheCell(_ posts: Posts) {
        titleLabel.text = posts.title
        bodyLabel.text = posts.body
    }
}
