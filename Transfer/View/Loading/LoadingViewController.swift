//
//  LoadingViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 28/02/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit

class LoadingViewController: NSObject {
    
    var target: UIView;
    var spinner: UIActivityIndicatorView;
    
    override init() {
        target = UIView.init();
        spinner = UIActivityIndicatorView.init()
    }
    
    public func setView(view: UIView) {
        target = view;
        
        let screenRect: CGRect = UIScreen.main.bounds;
        spinner = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 10000, height: 10000));
        spinner.activityIndicatorViewStyle = .whiteLarge;
        spinner.center = CGPoint(x: screenRect.width / 2, y: screenRect.height / 2);
        spinner.backgroundColor = UIColor.black.withAlphaComponent(0.5);
        spinner.startAnimating();
    }
    
    public func show() {
        UIView.transition(with: target, duration: 0.325, options: .transitionCrossDissolve, animations: {
            self.target.addSubview(self.spinner);
        });
    }
    
    public func hide() {
        UIView.transition(with: target, duration: 0.325, options: .transitionCrossDissolve, animations: {
            self.spinner.removeFromSuperview();
        });
    }
}
