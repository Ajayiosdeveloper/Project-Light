//
//  PLAssignmentTableViewCell.swift
//  Makeit
//
//  Created by Tharani P on 30/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLAssignmentTableViewCell: UITableViewCell {

    @IBOutlet var asssignmentSubtitle: UILabel!
    @IBOutlet var assignmentTitle: UILabel!
   
    @IBOutlet var progressLabel: KAProgressLabel!
  
    
    override func awakeFromNib() {
       
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
