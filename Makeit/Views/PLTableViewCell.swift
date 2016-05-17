//
//  PLTableViewCell.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 28/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLTableViewCell: UITableViewCell {
    
    @IBOutlet var teamMemberProfile: UIImageView!
    @IBOutlet var memberName: UILabel!
    @IBOutlet var memberDetail: UILabel!
    @IBOutlet var countHostingView: UIView!
    @IBOutlet var messageCountLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

 
        
        // Configure the view for the selected state
    }
    
}
