//
//  HomeCollectionViewCell.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/7/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    let colors = Colors()
    
    required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var btnGeoAlbum: UIButton!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var btnParentName: UIButton!
    @IBOutlet weak var lblCategoryName: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.viewForBaselineLayout()?.layer.masksToBounds = false
//        self.viewForBaselineLayout()?.layer.cornerRadius = 12.0
//        //self.viewForBaselineLayout()?..layer.shadowColor = UIColor.blueColor().CGColor
//        self.viewForBaselineLayout()?.layer.shadowColor = UIColor.darkGrayColor().CGColor
//        self.viewForBaselineLayout()?.layer.shadowOffset = CGSizeMake(0, 2.0);
//        self.viewForBaselineLayout()?.layer.shadowRadius = 2.0
//        self.viewForBaselineLayout()?.layer.shadowOpacity = 1.0
    

//        var backgroundLayer = colors.gl
//        backgroundLayer.frame = layer.bounds
//        let backgroundView = UIView(frame: layer.bounds)
//        self.viewForBaselineLayout()?.layer.insertSublayer(backgroundLayer, atIndex: 0)
//        self.backgroundView = backgroundView
//        self.viewForBaselineLayout()?.layer.cornerRadius = 12.0
//        self.viewForBaselineLayout()?.layer.masksToBounds = true
//        self.viewForBaselineLayout()?.layer.borderWidth = 1.0
//        self.viewForBaselineLayout()?.layer.borderColor = UIColor(red: 0xcc/255, green: 0xcc/255, blue: 0xcc/255, alpha: 1.0).CGColor

        
        
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        //gradientLayer.frame = bounds
//    }
  

    
}
