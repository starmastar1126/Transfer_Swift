//
//  BidsViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 08/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit
import UICircularProgressRing

class ScheduledDetailViewController: UIViewController, APIControllerDelegate {
    
    public var scheduledObject: Dictionary<String, AnyObject> = [:];
    
    @IBOutlet var card: UIView!
    @IBOutlet var profileLoading: UIActivityIndicatorView!
    @IBOutlet var profile: UIStackView!
    @IBOutlet var dateIcon: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var startIcon: UIImageView!
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endIcon: UIImageView!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var iconType: UIImageView!
    @IBOutlet var type: UILabel!
    @IBOutlet var buttonReady: UIButton!
    @IBOutlet var buttonArrived: UIButton!
    @IBOutlet var buttonFinish: UIButton!
    @IBOutlet var buttonSupport: UIButton!
    
    private var number: String = "";
    private var support: String = "";
    private var nextStatus: Int64 = 0;
    private var orderId: String = "";
    
    // user info
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userNumber: UIButton!
    
    private let loading: LoadingViewController = LoadingViewController.init();
    
    override func viewDidLoad() {
        setTheme();
        
        loading.setView(view: view);
        
        self.title = NSLocalizedString("scheduled_detail", comment: "");
        
        buttonReady.setTitle(NSLocalizedString("button_ready", comment: ""), for: .normal);
        buttonArrived.setTitle(NSLocalizedString("button_arrived", comment: ""), for: .normal);
        buttonFinish.setTitle(NSLocalizedString("button_finish", comment: ""), for: .normal);
        
        buttonSupport.setImage(UIImage(named: "support")?.withRenderingMode(.alwaysTemplate), for: .normal);
        buttonSupport.setTitle("  ".appending(NSLocalizedString("call_support", comment: "")), for: .normal);
        buttonSupport.isHidden = true;

        // reset values
        dateLabel.text = "";
        startLabel.text = "";
        endLabel.text = "";
        
        buttonReady.isHidden = true;
        buttonArrived.isHidden = true;
        buttonFinish.isHidden = true;
        
        populate();
    }
    
    private func populate() -> Void {
        dateLabel.text = scheduledObject["date_service"] as? String;
        dateLabel.text = dateLabel.text?.appending(" ").appending(scheduledObject["time_service"] as! String);
        startLabel.text = scheduledObject["pick_up_location"] as? String;
        endLabel.text = scheduledObject["drop_off_location"] as? String;
        type.text = scheduledObject["meta_description"] as? String;
        
        profile.isHidden = true;
        profileLoading.isHidden = false;
        
        let rideId: String = (scheduledObject["ride_id"] as? String)!;
        APIController(delegate: self).scheduledDetail(rideId: rideId) { (data, error) -> Void in }
    }
    
    @IBAction func call(_ sender: Any) {
        if(number != "") {
            if let url = URL(string: "tel://\(number)") {
                DispatchQueue.main.async() {
                    UIApplication.shared.openURL(url);
                }
            }
        }
    }
    
    @IBAction func support(_ sender: Any) {
        if(support != "") {
            if let url = URL(string: "tel://\(support)") {
                DispatchQueue.main.async() {
                    UIApplication.shared.openURL(url);
                }
            }
        }
    }
    
    @IBAction func sendStatus(_ sender: UIButton) {
        loading.show();
        APIController(delegate: self).updateStatus(status: nextStatus, orderId: orderId) { (data, error) -> Void in }
        
        if(sender == buttonReady) {
            let alert = UIAlertController(title: nil,
                                          message: NSLocalizedString("ready_alert", comment: ""),
                                          preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil));
            self.present(alert, animated: true);
        }
    }
    
    
    // MARK: Api Delegate
    public func didReceiveAPIResults(results: [String : AnyObject]?, param: String) {
        DispatchQueue.main.sync {
            loading.hide();
            
            if(results!["error"] != nil) {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: (results!["error"] as? String), preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil));
                self.present(alert, animated: true);
            }
            else {
                profileLoading.isHidden = true;
                if(param == "scheduledDetail") {
                    if(results!["ride_detail"] != nil) {
                        
                        let rideDetail: NSDictionary = results!["ride_detail"] as! NSDictionary;
                        if(rideDetail["customer_name"] != nil) {
                            profile.isHidden = false;
                            userName.text = rideDetail["customer_name"] as? String;
                            userNumber.setTitle(rideDetail["customer_contact"] as? String, for: .normal);
                            
                            // Vars API
                            number = rideDetail["customer_contact"] as! String;
                            nextStatus = rideDetail["next_status"] as! Int64;
                            orderId = rideDetail["order_id"] as! String;
                            support = rideDetail["ride_support"] as! String;
                            support = support.components(separatedBy: .whitespaces).joined();
                            
                            buttonReady.isHidden = !(rideDetail["button_ready_enable"] as? Bool)!;
                            buttonArrived.isHidden = !(rideDetail["button_arrived_enable"] as? Bool)!;
                            buttonFinish.isHidden = !(rideDetail["button_finish_enable"] as? Bool)!;
                            buttonSupport.isHidden = false;
                        }
                    }
                }
                else {
                    loading.show();
                    let rideId: String = (scheduledObject["ride_id"] as? String)!;
                    APIController(delegate: self).scheduledDetail(rideId: rideId) { (data, error) -> Void in }
                }
            }
        }
    }
    
    
    // MARK: Set theme
    private func setTheme() -> Void {
        view.backgroundColor = AppColor.primary();
        buttonReady.backgroundColor = AppColor.accent();
        buttonFinish.backgroundColor = AppColor.accent();
        buttonArrived.backgroundColor = AppColor.accent();
        
        buttonReady.setTitleColor(AppColor.contrast(), for: .normal);
        buttonFinish.setTitleColor(AppColor.contrast(), for: .normal);
        buttonArrived.setTitleColor(AppColor.contrast(), for: .normal);
        buttonSupport.setTitleColor(AppColor.contrast(), for: .normal);
        buttonSupport.tintColor = AppColor.contrast();
        
        card.layer.cornerRadius = 8;
        card.layer.shadowColor = AppColor.primary().cgColor;
        card.layer.shadowOpacity = 0.3;
        card.layer.shadowOffset = CGSize.zero;
        card.layer.shadowRadius = 5;
        card.backgroundColor = AppColor.cellBackground();
        
        dateLabel.textColor = AppColor.primary();
        startLabel.textColor = AppColor.primary();
        endLabel.textColor = AppColor.primary();
        userName.textColor = AppColor.primary();
        type.textColor = AppColor.primary();
        userNumber.setTitleColor(AppColor.link(), for: .normal);
        
        // Images
        dateIcon.image = dateIcon.image!.withRenderingMode(.alwaysTemplate);
        dateIcon.tintColor = AppColor.primary();
        
        startIcon.image = startIcon.image!.withRenderingMode(.alwaysTemplate);
        startIcon.tintColor = AppColor.primary();
        
        endIcon.image = endIcon.image!.withRenderingMode(.alwaysTemplate);
        endIcon.tintColor = AppColor.primary();
        
        userIcon.image = userIcon.image!.withRenderingMode(.alwaysTemplate);
        userIcon.tintColor = AppColor.primary();
        
        iconType.image = iconType.image!.withRenderingMode(.alwaysTemplate);
        iconType.tintColor = AppColor.primary();
    }
}
