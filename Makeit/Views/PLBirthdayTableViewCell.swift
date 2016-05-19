//
//  PLBirthdayTableViewCell.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 19/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLBirthdayTableViewCell: UITableViewCell {
    
    @IBOutlet var memberImage: UIImageView!
    
    @IBOutlet var memberName: UILabel!
    
    @IBOutlet var memberDetail: UILabel!
    
    @IBOutlet var makeCall: UIButton!
    
    @IBOutlet var makeMessage: UIButton!
    
    @IBOutlet var sendBirthdayGreetings: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
