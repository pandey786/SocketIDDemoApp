//
//  BaseCell.swift
//  SocketIODemoApp
//
//  Created by Pandey on 25/04/17.
//  Copyright © 2017 Pandey. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
        layoutIfNeeded()
        
        // Set the selection style to None.
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
