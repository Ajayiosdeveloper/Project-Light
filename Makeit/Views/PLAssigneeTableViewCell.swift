//
//  PLAssigneeTableViewCell.swift
//  Makeit
//
//  Created by Tharani P on 24/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLAssigneeTableViewCell: UITableViewCell {

    @IBOutlet var statusField: KAProgressLabel!
    
    @IBOutlet weak var mailIdField: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet weak var disclosureButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
