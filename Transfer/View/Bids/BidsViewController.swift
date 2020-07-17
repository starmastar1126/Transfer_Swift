//
//  BidsViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 08/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit
import UICircularProgressRing

class BidsViewController: UIViewController, APIControllerDelegate {
    
    public var offerObject: Dictionary<String, AnyObject> = [:];
    public var auctionId: String = "";
    
    @IBOutlet var progressValueLabel: UILabel!
    @IBOutlet var progressView: UICircularProgressRingView!
    @IBOutlet var dateIcon: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var startIcon: UIImageView!
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endIcon: UIImageView!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var valueBox: UIView!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var typeValueLabel: UILabel!
    @IBOutlet var scrollValue: UISlider!
    @IBOutlet var bidButton: UIButton!
    
    // vars calc progress
    private var valueStart:Int64 = Int64(0);
    private var valueAtual:Int64 = Int64(0);
    private var atualTime:Int = Int(0);
    private var timeEnd:Int = 0;
    private var loopStart:Bool = false;
    private var totalTime:Int = 0;
    private var auctionID:String = "";
    
    private let loading: LoadingViewController = LoadingViewController.init();
    
    override func viewDidLoad() {
        setTheme();
        
        loading.setView(view: view);
        
        self.title = NSLocalizedString("place_bid", comment: "").capitalized;
        bidButton.setTitle(NSLocalizedString("place_bid", comment: ""), for: .normal);
        
        // reset values
        progressValueLabel.text = "";
        dateLabel.text = "";
        startLabel.text = "";
        endLabel.text = "";
        valueLabel.text = "";
        typeValueLabel.text = "";
        
        let customBackButton = UIBarButtonItem(image: UIImage(named: "back"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(backAction(sender:)));
        customBackButton.imageInsets = UIEdgeInsets(top: 2, left: -8, bottom: 0, right: 0);
        navigationItem.leftBarButtonItem = customBackButton;
        
        if(offerObject.keys.count > 0) {
            populate();
        }
        else {
            loading.show();
            if(auctionId != "") {
                APIController(delegate: self).offerDetail(auctionId: auctionId) { (data, error) -> Void in }
            }
        }
    }
    
    @objc private func backAction(sender: UIBarButtonItem) {
        let main = MainViewController();
        main.selectedTab = 1;
        let navigationController = UINavigationController(rootViewController: main);
        present(navigationController, animated: true, completion: nil);
    }
    
    private func populate() -> Void {
        auctionID = (offerObject["auction_id"] as? String)!;
        print("ID: \(auctionID)\n\n");
        dateLabel.text = offerObject["date_service"] as? String;
        dateLabel.text = dateLabel.text?.appending(" ").appending(offerObject["time_service"] as! String);
        startLabel.text = offerObject["pick_up_location"] as? String;
        endLabel.text = offerObject["drop_off_location"] as? String;
        typeValueLabel.text = offerObject["currency_code"] as? String;
        
        setMaxValue();
        
        let strValueStart:String = (offerObject["start_time"] as? String)!;
        let strValueEnd:String = (offerObject["end_time"] as? String)!;
        valueStart = (strValueStart as NSString).longLongValue;
        let valueEnd:Int64 = (strValueEnd as NSString).longLongValue;
        totalTime = Int((valueEnd - valueStart as Int64) / 1000);
        
        progressView.maxValue = CGFloat(totalTime);
        if(!loopStart) {
            updateTime();
        }
    }
    
    private func setMaxValue() -> Void {
        let maxValueStr: String = (offerObject["max_price"] as? String)!;
        let number: Float = Float(maxValueStr)!;
        scrollValue.maximumValue = number / 10;
        scrollValue.value = scrollValue.maximumValue;
        valueLabel.text = String(format: "%.1f", scrollValue.maximumValue * 10).appending("0");
    }
    
    private func updateTime() -> Void {
        loopStart = false;
        UIView.transition(with: self.progressView,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.valueAtual = Int64(NSDate().timeIntervalSince1970 * 1000);
                            self.atualTime = Int((self.valueAtual - self.valueStart) / 1000);
                            self.timeEnd = self.totalTime - self.atualTime;
                            
                            self.progressView.value = CGFloat(self.atualTime);
                            if(self.timeEnd <= 0) {
                                self.loopStart = false;
                                self.progressValueLabel.text = "0";
                                self.closeOffer();
                            }
                            else {
                                self.progressValueLabel.text = "\((self.timeEnd))";
                            }                            
        }, completion: { (finished: Bool) in
            if(self.timeEnd <= 0) {
                self.loopStart = false;
                self.progressValueLabel.text = "0";
                self.closeOffer();
            }
            else {
                self.updateTime();
            }
        });
    }
    
    private func closeOffer() {
        self.backAction(sender: UIBarButtonItem());
    }
    
    @IBAction func onSlideChange(_ sender: UISlider) {
        let currentValue:Double = Double(sender.value);
        valueLabel.text = String(format: "%.1f", currentValue * 10).appending("0");
    }
    
    @IBAction func placeBid(_ sender: Any) {
        loading.show();
        APIController(delegate: self).placeBid(price: valueLabel.text!, id: auctionID) { (data, error) -> Void in }
    }
    
    // MARK: Api Delegate
    public func didReceiveAPIResults(results: [String : AnyObject]?, param: String) {
        DispatchQueue.main.sync {
            loading.hide();
            if(results!["no_results"] != nil) {
                let alert = UIAlertController(title: nil,
                                              message: NSLocalizedString("offer_closed", comment: ""),
                                              preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                    self.backAction(sender: UIBarButtonItem());
                });
                self.present(alert, animated: true);
            }
            if(results!["error"] != nil) {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                              message: (results!["error"] as? String),
                                              preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil));
                self.present(alert, animated: true);
            }
            else if(results!["success"] != nil) {
                if(param == "offerDetail") {
                    if(results!["auction_info"] != nil) {
                        offerObject = results!["auction_info"] as! Dictionary<String, AnyObject>;
                        populate();
                    }
                }
                else {
                    let alert = UIAlertController(title: nil,
                                                  message: NSLocalizedString("bid_success", comment: ""),
                                                  preferredStyle: .alert);
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil));
                    self.present(alert, animated: true);
                    
                    if(results!["max_price"] != nil) {
                        offerObject["max_price"] = results!["max_price"] as AnyObject;
                        setMaxValue();
                    }
                }
            }
        }
    }
    
    
    // MARK: Set theme
    private func setTheme() -> Void {
        typeValueLabel.transform = CGAffineTransform(rotationAngle: CGFloat(( 90 * Double.pi ) / -180));
        valueBox.layer.cornerRadius = 8;
        
        view.backgroundColor = AppColor.primary();
        progressView.innerRingColor = AppColor.accent();
        scrollValue.tintColor = AppColor.accent();
        scrollValue.maximumTrackTintColor = AppColor.cellBackground();
        bidButton.backgroundColor = AppColor.accent();
        
        progressValueLabel.textColor = AppColor.contrast();
        dateLabel.textColor = AppColor.contrast();
        startLabel.textColor = AppColor.contrast();
        endLabel.textColor = AppColor.contrast();
        valueLabel.textColor = AppColor.contrast();
        typeValueLabel.textColor = AppColor.contrast();
        
        // Images
        dateIcon.image = dateIcon.image!.withRenderingMode(.alwaysTemplate);
        dateIcon.tintColor = AppColor.contrast();
        
        startIcon.image = startIcon.image!.withRenderingMode(.alwaysTemplate);
        startIcon.tintColor = AppColor.contrast();
        
        endIcon.image = endIcon.image!.withRenderingMode(.alwaysTemplate);
        endIcon.tintColor = AppColor.contrast();
    }
}
