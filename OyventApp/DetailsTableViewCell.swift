//
//  DetailsTableViewCell.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/2/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var lblMilesUser: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
