//
//  PLSideBarTableViewCell.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 16/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLSideBarTableViewCell: UITableViewCell {
    
    @IBOutlet var imageIcon: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var countLabel: UILabel!
    
    @IBOutlet var countHostView: UIView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
