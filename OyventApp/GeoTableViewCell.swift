//
//  GeoViewCell.swift
//  OyventApp
//
//  Created by Mehmet Sen on 4/8/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class GeoTableViewCell: UITableViewCell {

    @IBOutlet weak var btnGeoAlbum: UIButton!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lblMilesGeo: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var btnSocial: UIButton!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var btnVoteUp: UIButton!
    @IBOutlet weak var btnVoteDown: UIButton!
    @IBOutlet weak var lblOys: UILabel!
   
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
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
