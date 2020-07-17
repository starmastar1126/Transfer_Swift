//
//  TripsViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 04/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit

class ScheduledViewController: UITableViewController, APIControllerDelegate {
    
    var scheduledList: Array<Dictionary<String, AnyObject>> = [];
    var lastContentOffset: CGFloat = 0;
    var isLoading:Bool = false;
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "CellScheduled", bundle: nil), forCellReuseIdentifier: "CellScheduled");
        setTheme();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isLoading = true;
        if let mainVC = self.parent as? MainViewController {
            mainVC.title = self.title;
            mainVC.spinner.isHidden = false;
        }
        APIController(delegate: self).scheduled() { (data, error) -> Void in }
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return scheduledList.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellScheduled", for: indexPath) as! CellScheduled;
        
        setCellTheme(cell: cell);
        cell.populate(item: scheduledList[indexPath.row]);
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scheduled: Dictionary<String, AnyObject> = scheduledList[indexPath.row];
        
        let scheduledVC: ScheduledDetailViewController = ScheduledDetailViewController();
        scheduledVC.scheduledObject = scheduled;
        
        self.navigationController?.pushViewController(scheduledVC, animated: true);
    }
    
    private func setCellTheme(cell: CellScheduled) {
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
                APIController(delegate: self).scheduled() { (data, error) -> Void in }
            }
        }
    }
    
    // MARK: API delegate
    func didReceiveAPIResults(results: Dictionary<String, AnyObject>?, param: String) {
        DispatchQueue.main.sync {
            if(results!["error"] == nil) {
                
                scheduledList = results!["scheduledRides"] as! Array<Dictionary<String, AnyObject>>;
                
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
