//
//  ChatCell.swift
//  SocketIODemoApp
//
//  Created by Pandey on 25/04/17.
//  Copyright © 2017 Pandey. All rights reserved.
//

import UIKit

class ChatCell: BaseCell {

    @IBOutlet weak var lblChatMessage: UILabel!
    @IBOutlet weak var lblMessageDetails: UILabel!
    @IBOutlet weak var bubbleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
