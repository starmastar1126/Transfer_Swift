//
//  TripsViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 04/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit

class TripsViewController: UITableViewController, APIControllerDelegate {
    
    var trips: Array<Dictionary<String, AnyObject>> = [];
    var lastContentOffset: CGFloat = 0;
    var isLoading:Bool = false;
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "CellTrips", bundle: nil), forCellReuseIdentifier: "CellTrips");
        setTheme();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isLoading = true;
        if let mainVC = self.parent as? MainViewController {
            mainVC.spinner.isHidden = false;
        }
        APIController(delegate: self).trips() { (data, error) -> Void in }
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return trips.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellTrips", for: indexPath) as! CellTrips;
        
        setCellTheme(cell: cell);
        cell.populate(item: trips[indexPath.row]);
        
        return cell;
    }
    
    private func setCellTheme(cell: CellTrips) {
        cell.boxView.layer.cornerRadius = 8;
        cell.boxView.layer.shadowColor = UIColor.black.cgColor;
        cell.boxView.layer.shadowOpacity = 0.3;
        cell.boxView.layer.shadowOffset = CGSize.zero;
        cell.boxView.layer.shadowRadius = 5;
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
                APIController(delegate: self).trips() { (data, error) -> Void in }
            }
        }
    }
    
    // MARK: API delegate
    func didReceiveAPIResults(results: Dictionary<String, AnyObject>?, param: String) {
        DispatchQueue.main.sync {
            if(results!["error"] == nil) {
                let session: Array<Dictionary<String, AnyObject>> = results!["finishedRides"] as! Array<Dictionary<String, AnyObject>>;
                UserDefaults.standard.set(session, forKey: "trips");
                
                trips = results!["finishedRides"] as! Array<Dictionary<String, AnyObject>>;
                
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
