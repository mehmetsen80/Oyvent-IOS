//
//  GeoTableHeaderCell.swift
//  OyventApp
//
//  Created by Mehmet Sen on 5/23/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

protocol GeoTableHeaderViewCellDelegate {
    func didSelectGeoTableHeaderViewCell(Selected: Bool, GeoHeader: GeoTableHeaderCell)
}

class GeoTableHeaderCell: UITableViewCell {
    
    var delegate : GeoTableHeaderViewCellDelegate?
    @IBOutlet weak var btnGeoAlbum: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func doSelectHeader(sender: UIButton) {
        delegate?.didSelectGeoTableHeaderViewCell(true, GeoHeader: self)
    }
    
    @IBAction func selectedHeader(sender: AnyObject) {
        delegate?.didSelectGeoTableHeaderViewCell(true, GeoHeader: self)
        
    }
}