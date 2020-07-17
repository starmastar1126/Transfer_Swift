//
//  CellTrips.swift
//  Transfer
//
//  Created by Elian Medeiros on 04/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit
import SVGKit

class CellScheduled: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var boxView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dividerView: UIView!
    @IBOutlet var footerLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    public func  populate(item: Dictionary<String, AnyObject>) -> Void {
        let object:Dictionary<String, AnyObject> = item;
        
        setCellTheme();
        
        titleLabel.text = object["date_service"] as? String;
        timeLabel.text = object["time_service"] as? String;
        footerLabel.text = object["meta_description"] as? String;
    }
    
    // MARK: Set theme
    public func setCellTheme() -> Void {
        // Cell
        boxView.layer.cornerRadius = 8;
        boxView.layer.shadowColor = AppColor.primary().cgColor;
        boxView.layer.shadowOpacity = 0.3;
        boxView.layer.shadowOffset = CGSize.zero;
        boxView.layer.shadowRadius = 5;
        boxView.backgroundColor = AppColor.cellBackground();
        
        // Texts
        titleLabel.textColor = AppColor.darkPrimary();
        dividerView.backgroundColor = AppColor.darkPrimary();
        footerLabel.textColor = AppColor.darkPrimary();
        timeLabel.textColor = AppColor.darkPrimary();
        
        // Images
        iconImageView.image = iconImageView.image!.withRenderingMode(.alwaysTemplate);
        iconImageView.tintColor = AppColor.contrast();
    }
    
}
