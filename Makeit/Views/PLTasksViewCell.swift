//
//  PLTasksViewCell.swift
//  Makeit
//
//  Created by Tharani P on 19/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTasksViewCell: UITableViewCell {

    @IBOutlet weak var commitmentDetailsIndicator: UIButton!
    @IBOutlet weak var taskEndTime: UILabel!
    @IBOutlet weak var taskStartTime: UILabel!
    @IBOutlet weak var projectNameField: UILabel!
    @IBOutlet weak var taskNameField: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func toEditCommitmentDetails(sender: AnyObject) {
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
