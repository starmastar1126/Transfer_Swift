//
//  InsetTextFieldLogin.swift
//  Transfer
//
//  Created by Elian Medeiros on 24/02/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit

class InsetTextFieldLogin: UITextField {
    
    var padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8);
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        start();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        start();
    }
    
    func start() -> Void {
        padding = UIEdgeInsets(top: 8, left: frame.height + 8, bottom: 8, right: 8);
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
    
    func addBorder() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = AppColor.contrast().withAlphaComponent(0.7).cgColor
        border.frame = CGRect(x: 0,
                              y: (frame.size.height + padding.bottom + padding.top) - width,
                              width: (frame.size.width + padding.left + padding.right),
                              height: (frame.size.height + padding.bottom + padding.top))
        border.borderWidth = width
        
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}
