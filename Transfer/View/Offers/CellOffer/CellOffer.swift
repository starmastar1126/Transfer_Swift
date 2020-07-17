//
//  CellOffer.swift
//  Transfer
//
//  Created by Elian Medeiros on 03/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit
import UICircularProgressRing

class CellOffer: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var boxView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dividerView: UIView!
    @IBOutlet var iconStartPointImageView: UIImageView!
    @IBOutlet var iconEndPointImageView: UIImageView!
    @IBOutlet var startPointLabel: UILabel!
    @IBOutlet var endPointLabel: UILabel!
    @IBOutlet var valueProgress: UILabel!
    @IBOutlet var progressView: UICircularProgressRingView!
    @IBOutlet var footerLabel: UILabel!
    
    private var object:Dictionary<String, AnyObject>? = [:];
    private var valueStart:Int64 = Int64(0);
    private var valueAtual:Int64 = Int64(0);
    private var atualTime:Int = Int(0);
    private var timeEnd:Int = 0;
    private var loopStart:Bool = false;
    private var totalTime:Int = 0;
    private var delegate: OffersViewController = OffersViewController();
    private var isRemove: Bool = false;
    
    public func getItem() -> Dictionary<String, AnyObject> {
        return object!;
    }
    
    public func populate(item: Dictionary<String, AnyObject>, delegate: OffersViewController) -> Void {
        isRemove = false;
        object = item;
        
        setCellTheme();
        
        self.delegate = delegate;

        titleLabel.text = object!["date_service"] as? String;
        titleLabel.text = titleLabel.text?.appending(" ").appending(object!["time_service"] as! String);
        startPointLabel.text = object!["pick_up_location"] as? String;
        endPointLabel.text = object!["drop_off_location"] as? String;
        footerLabel.text = object!["meta_description"] as? String;
        
        let strValueStart:String = (object!["start_time"] as? String)!;
        let strValueEnd:String = (object!["end_time"] as? String)!;
        valueStart = (strValueStart as NSString).longLongValue;
        let valueEnd:Int64 = (strValueEnd as NSString).longLongValue;
        totalTime = Int((valueEnd - valueStart as Int64) / 1000);
        
        progressView.maxValue = CGFloat(totalTime);
        if(!loopStart) {
            updateTime();
        }
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
                                self.valueProgress.text = "0";
                                self.removeCell();
                            }
                            else {
                                self.valueProgress.text = "\((self.timeEnd))";
                            }
        }, completion: { (finished: Bool) in
            if(self.timeEnd <= 0) {
                self.loopStart = false;
                self.valueProgress.text = "0";
                self.removeCell();
            }
            else {
                self.updateTime();
            }
        });
    }
    
    private func removeCell() -> Void {
        if(!isRemove) {
            isRemove = true;
            for index in delegate.offers.indices {
                let item:Dictionary<String, AnyObject> = delegate.offers[index];
                if(item["auction_id"] as! String == self.object!["auction_id"] as! String) {
                    delegate.offers.remove(at: index);
                    delegate.tableView.reloadData();
                    break;
                }
            }
        }
    }
    
    // MARK: Set theme
    private func setCellTheme() -> Void {
        // Cell
        boxView.layer.cornerRadius = 8;
        boxView.layer.shadowColor = AppColor.primary().cgColor;
        boxView.layer.shadowOpacity = 0.3;
        boxView.layer.shadowOffset = CGSize.zero;
        boxView.layer.shadowRadius = 5;
        boxView.backgroundColor = AppColor.cellBackground();
        
        // Progress
        progressView.innerRingColor = AppColor.accent();
        
        // Texts
        titleLabel.textColor = AppColor.darkPrimary();
        dividerView.backgroundColor = AppColor.darkPrimary();
        startPointLabel.textColor = AppColor.darkPrimary();
        endPointLabel.textColor = AppColor.darkPrimary();
        footerLabel.textColor = AppColor.darkPrimary();
        valueProgress.textColor = AppColor.darkPrimary();
        
        // Images
        iconImageView.image = iconImageView.image!.withRenderingMode(.alwaysTemplate);
        iconImageView.tintColor = AppColor.contrast();
        
        iconStartPointImageView.image = iconStartPointImageView.image!.withRenderingMode(.alwaysTemplate);
        iconStartPointImageView.tintColor = AppColor.darkPrimary();
        
        iconEndPointImageView.image = iconEndPointImageView.image!.withRenderingMode(.alwaysTemplate);
        iconEndPointImageView.tintColor = AppColor.darkPrimary();
    }
}
