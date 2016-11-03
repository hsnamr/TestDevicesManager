//
//  DeviceCell.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/3/16.
//  Copyright © 2016 IM. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {

    @IBOutlet weak var device: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
