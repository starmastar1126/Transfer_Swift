//
//  AppColor.swift
//  Transfer
//
//  Created by Elian Medeiros on 25/02/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit

class AppColor: NSObject {
    
    static func primary() -> UIColor {return hexStringToUIColor(hex: "#003548")}
    static func darkPrimary() -> UIColor {return hexStringToUIColor(hex: "#002A3A")}
    static func lightPrimary() -> UIColor {return hexStringToUIColor(hex: "#1A4A5B")}
    static func contrast() -> UIColor {return hexStringToUIColor(hex: "#F6F6F6")}
    static func accent() -> UIColor {return hexStringToUIColor(hex: "#16A086")}
    static func link() -> UIColor {return hexStringToUIColor(hex: "#00C0C2")}
    static func cellBackground() -> UIColor {return contrast().withAlphaComponent(0.9)} // Example extends color
    
    //static func primary() -> UIColor {return hexStringToUIColor(hex: "#F6F6F6")}
    //static func contrast() -> UIColor {return hexStringToUIColor(hex: "#003548")}
    //static func accent() -> UIColor {return hexStringToUIColor(hex: "#16A086")}
    
    // Get color with Hex
    
    private static func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
