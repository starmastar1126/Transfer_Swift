//
//  OffersViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 03/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit

class OffersViewController: UITableViewController, APIControllerDelegate {
    
    public var offers: Array<Dictionary<String, AnyObject>> = [];
    var lastContentOffset: CGFloat = 0;
    var isLoading:Bool = false;
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "CellOffer", bundle: nil), forCellReuseIdentifier: "CellOffer");
        setTheme();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = NSLocalizedString("offers_label", comment: "").capitalized;
        isLoading = true;
        if let mainVC = self.parent as? MainViewController {
            mainVC.title = self.title;
            mainVC.spinner.isHidden = false;
        }
        APIController(delegate: self).offers() { (data, error) -> Void in }
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return offers.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellOffer", for: indexPath) as! CellOffer;
        cell.populate(item: offers[indexPath.row], delegate: self);
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer: Dictionary<String, AnyObject> = offers[indexPath.row];
        
        let bidsVC: BidsViewController = BidsViewController();
        bidsVC.offerObject = offer;
        
        self.navigationController?.pushViewController(bidsVC, animated: true);
    }
    
    // MARK Scroll delegate
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            if (scrollView.contentOffset.y < -180 && !isLoading) {
                isLoading = true;
                if let mainVC = self.parent as? MainViewController {
                    mainVC.spinner.isHidden = false;
                }
                APIController(delegate: self).offers() { (data, error) -> Void in }
            }
        }
    }
    
    // MARK: API delegate
    func didReceiveAPIResults(results: Dictionary<String, AnyObject>?, param: String) {
        DispatchQueue.main.sync {
            if(results!["error"] == nil) {
                let session: Array<Dictionary<String, AnyObject>> = results!["offers"] as! Array<Dictionary<String, AnyObject>>;
                UserDefaults.standard.set(session, forKey: "offers");
                
                offers = results!["offers"] as! Array<Dictionary<String, AnyObject>>;
                
                tableView.reloadData();
            }
            else {
                if let mainVC = self.parent as? MainViewController {
                    mainVC.logout();
                }
            }
            isLoading = false;
            if let mainVC = self.parent as? MainViewController {
                mainVC.spinner.isHidden = true;
            }
        }
    }
    
    
    // MARK: Set theme
    func setTheme() -> Void {
        self.view.backgroundColor = AppColor.primary();
        self.tableView.backgroundColor = AppColor.primary();
    }
}
