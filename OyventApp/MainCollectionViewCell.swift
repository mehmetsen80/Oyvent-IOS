//
//  CategoriesCollectionViewCell.swift
//  OyventApp
//
//  Created by Mehmet Sen on 6/7/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var btnParent: UIButton!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var lblPhotoSize: UILabel!
    @IBOutlet weak var imgPoster: UIImageView!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    
    
}
