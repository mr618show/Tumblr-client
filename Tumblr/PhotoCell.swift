//
//  PhotoCell.swift
//  Tumblr
//
//  Created by Rui Mao on 4/8/18.
//  Copyright © 2018 Rui Mao. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
