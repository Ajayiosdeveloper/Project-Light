//
//  PLProjectViewCell.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 14/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectViewCell: UITableViewCell {
    
    @IBOutlet var circularView: UIView!
    
    @IBOutlet var projectLetterLabel: UILabel!
    
    @IBOutlet var projectName: UILabel!
    
    @IBOutlet var projectDescription: UILabel!
    
    @IBOutlet var createdAt: UILabel!
    
    @IBOutlet var createdBy: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
