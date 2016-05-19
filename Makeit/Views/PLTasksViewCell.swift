//
//  PLTasksViewCell.swift
//  Makeit
//
//  Created by Tharani P on 19/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTasksViewCell: UITableViewCell
{

    @IBOutlet weak var detailsField: UILabel!
    @IBOutlet weak var taskEndTime: UILabel!
    @IBOutlet weak var taskStartTime: UILabel!
    @IBOutlet weak var projectNameField: UILabel!
    @IBOutlet weak var taskNameField: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
