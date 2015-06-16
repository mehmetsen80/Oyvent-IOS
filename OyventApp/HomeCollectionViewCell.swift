//
//  HomeCollectionViewCell.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/7/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    
    
    required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var btnGeoAlbum: UIButton!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var btnParentName: UIButton!
    @IBOutlet weak var lblPhotoSize: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.viewForBaselineLayout()?.layer.masksToBounds = false
//        self.viewForBaselineLayout()?.layer.cornerRadius = 12.0
//        //self.viewForBaselineLayout()?..layer.shadowColor = UIColor.blueColor().CGColor
//        self.viewForBaselineLayout()?.layer.shadowColor = UIColor.darkGrayColor().CGColor
//        self.viewForBaselineLayout()?.layer.shadowOffset = CGSizeMake(0, 2.0);
//        self.viewForBaselineLayout()?.layer.shadowRadius = 2.0
//        self.viewForBaselineLayout()?.layer.shadowOpacity = 1.0
    

        
    }

    
}
