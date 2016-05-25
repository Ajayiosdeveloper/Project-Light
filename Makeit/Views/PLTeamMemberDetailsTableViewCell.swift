//
//  PLTeamMemberDetailsTableViewCell.swift
//  Makeit
//
//  Created by Tharani P on 24/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTeamMemberDetailsTableViewCell: UITableViewCell {

    @IBOutlet var statusField: UILabel!
    @IBOutlet var assignmentDetail: UILabel!
    @IBOutlet var startTime: UILabel!
    @IBOutlet var endTime: UILabel!
    @IBOutlet var assignmentTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
