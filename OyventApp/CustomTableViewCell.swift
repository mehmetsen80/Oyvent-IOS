//
//  CustomTableViewCell.swift
//  OyventApp
//
//  Created by Mehmet Sen on 3/22/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPkPhotoID: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var btnPoster: UIButton!
    @IBOutlet weak var lblAlbumName: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var btnVoteUp: UIButton!
    @IBOutlet weak var btnVoteDown: UIButton!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var btnSocial: UIButton!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var lblVoteResult: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var btnComments: UIButton!
    
   
   
    
    let kLabelHorizontalInsets: CGFloat = 15.0
    let kLabelVerticalInsets: CGFloat = 10.0
    
    var didSetupConstraints = false
    
    //var titleLabel: UILabel = UILabel. newAutoLayoutView()
    //var bodyLabel: UILabel =  UILabel. newAutoLayoutView()

   
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setupViews()
        
    }

    required init(coder aDecoder: NSCoder) {
        
         super.init(coder: aDecoder)
        //setupViews()
    }
    
    
//    func setupViews()
//    {
//      
//        lblPkPhotoID?.lineBreakMode = .ByTruncatingTail
//        lblPkPhotoID?.numberOfLines = 1
//        lblPkPhotoID?.textAlignment = .Left
//        lblPkPhotoID?.textColor = UIColor.blackColor()
//        lblPkPhotoID?.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.1) // light blue
//        
//        lblPostDate?.lineBreakMode = .ByTruncatingTail
//        lblPostDate?.numberOfLines = 0
//        lblPostDate?.textAlignment = .Left
//        lblPostDate?.textColor = UIColor.darkGrayColor()
//        lblPostDate?.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1) // light red
//        //lblPostDate?.frame.size = CGSizeMake(100, 40)
//        
//        //contentView.addSubview(lblPkPhotoID)
//        //contentView.addSubview(lblPostDate)
//        
//        contentView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.1) // light green
//        
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
