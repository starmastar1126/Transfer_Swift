//
//  HomeViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 02/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, APIControllerDelegate {
    
    @IBOutlet var subtitleLabel: UILabel!;
    @IBOutlet var nameLabel: UILabel!;
    
    @IBOutlet var offersValueLabel: UILabel!
    @IBOutlet var plannedValueLabel: UILabel!
    @IBOutlet var tripsValueLabel: UILabel!
    
    @IBOutlet var offersLabel: UILabel!;
    @IBOutlet var plannedLabel: UILabel!;
    @IBOutlet var tripsLabel: UILabel!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setTheme();
        populate();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let mainVC = self.parent as? MainViewController {
            mainVC.spinner.isHidden = false;
        }
        APIController(delegate: self).customer() { (data, error) -> Void in }
    }
    
    private func populate() -> Void {
        let session: Dictionary<String, AnyObject> = UserDefaults.standard.object(forKey: "session") as! Dictionary<String, AnyObject>;
        
        subtitleLabel.text = NSLocalizedString("subtitle", comment: "");
        nameLabel.text = session["customer"]!["firstname"] as? String;
        
        offersValueLabel.text = session["customer"]!["availableOffers"] as? String;
        plannedValueLabel.text = session["customer"]!["scheduledOffers"] as? String;
        tripsValueLabel.text = session["customer"]!["finishedOffers"] as? String;
        
        offersLabel.text = NSLocalizedString("offers_label", comment: "");
        plannedLabel.text = NSLocalizedString("planned_label", comment: "");
        tripsLabel.text = NSLocalizedString("trips_label", comment: "");
    }
    
    // MARK: Api delegate
    public func didReceiveAPIResults(results: [String : AnyObject]?, param: String) {
        DispatchQueue.main.sync {
            if let mainVC = self.parent as? MainViewController {
                mainVC.spinner.isHidden = true;
            }
            if(results!["error"] == nil) {
                var session: Dictionary<String, AnyObject> = UserDefaults.standard.object(forKey: "session") as! Dictionary<String, AnyObject>;
                session["customer"] = results!["customer"] as AnyObject;
                UserDefaults.standard.set(session, forKey: "session");
                populate();
            }
            else {
                if let mainVC = self.parent as? MainViewController {
                    mainVC.logout();
                }
            }
        }
    }
    
    
    // MARK: Set Theme
    func setTheme() -> Void {
        self.view.backgroundColor = AppColor.primary();
        subtitleLabel.textColor = AppColor.contrast();
        nameLabel.textColor = AppColor.contrast();
        
        offersValueLabel.textColor = AppColor.contrast();
        plannedValueLabel.textColor = AppColor.contrast();
        tripsValueLabel.textColor = AppColor.contrast();
        offersLabel.textColor = AppColor.contrast();
        plannedLabel.textColor = AppColor.contrast();
        tripsLabel.textColor = AppColor.contrast();
    }
}
