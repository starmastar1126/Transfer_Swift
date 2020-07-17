//
//  CellTrips.swift
//  Transfer
//
//  Created by Elian Medeiros on 04/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit
import SVGKit

class CellTrips: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var boxView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dividerView: UIView!
    @IBOutlet var driverIconImageView: UIImageView!
    @IBOutlet var footerLabel: UILabel!
    
    public func  populate(item: Dictionary<String, AnyObject>) -> Void {
        let object:Dictionary<String, AnyObject> = item;
        
        setCellTheme();
        
        titleLabel.text = object["date_service"] as? String;
        footerLabel.text = object["meta_description"] as? String;
        
        do {
            let imageStr:String = (object["driver_icon"] as? String)!;
            driverIconImageView.image = changeTintColor(with: base64ToImage(base64: imageStr), color: AppColor.primary());
        }
    }
    
    func base64ToImage(base64: String) -> UIImage {
        var img: UIImage = UIImage()
        if (!base64.isEmpty) {
            // remove header base64 (IOS not native for svg)
            let modString = base64.replacingOccurrences(of: "data:image/svg+xml;utf8;base64,", with: "");

            // decode base64
            let decodedData = Data(base64Encoded: modString, options: .ignoreUnknownCharacters);
            let receivedIcon: SVGKImage = SVGKImage(data: decodedData);
            img = receivedIcon.uiImage;
        }
        return img
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
        
        // Images
        iconImageView.image = iconImageView.image!.withRenderingMode(.alwaysTemplate);
        iconImageView.tintColor = AppColor.contrast();
        
        //driverIconImageView.image = driverIconImageView.image!.withRenderingMode(.alwaysTemplate);
        //driverIconImageView.tintColor = AppColor.darkPrimary();
    }
    
    //  Tint SVG
    func changeTintColor(with img: UIImage, color tintColor: UIColor) -> UIImage {
        let imageIn: UIImage? = img
        let rect = CGRect(x: 0, y: 0, width: (imageIn?.size.width)!, height: (imageIn?.size.height)!)
        let alphaInfo: CGImageAlphaInfo = (imageIn?.cgImage?.alphaInfo)!
        let opaque: Bool = alphaInfo == .noneSkipLast || alphaInfo == .noneSkipFirst || alphaInfo == .none
        UIGraphicsBeginImageContextWithOptions((imageIn?.size)!, opaque, (imageIn?.scale)!)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: (imageIn?.size.height)!)
        context?.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(.normal)
        context?.clip(to: rect, mask: (imageIn?.cgImage)!)
        context?.setFillColor(tintColor.cgColor)
        context?.fill(rect)
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut ?? UIImage()
    }

}
