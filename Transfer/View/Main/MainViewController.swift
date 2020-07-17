//
//  MainViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 01/03/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit
import OneSignal

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    
    public var selectedTab = 0;
    
    private var tabBarList: Array<UIViewController> = [];
    public let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white);
    private var defaults: UserDefaults =  UserDefaults.standard;
    private var session: Dictionary<String, AnyObject> = Dictionary();
    
    override func viewDidLoad() {
        delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        session = UserDefaults.standard.object(forKey: "session") as! Dictionary<String, AnyObject>;
        
        // Views
        let homeVC = HomeViewController();
        homeVC.title = NSLocalizedString("home_label", comment: "").capitalized;
        
        let offers = OffersViewController();
        offers.title = NSLocalizedString("offers_label", comment: "").capitalized;
        
        let scheduled = ScheduledViewController();
        scheduled.title = NSLocalizedString("scheduled_label", comment: "").capitalized;
        
        let trips = TripsViewController();
        trips.title = NSLocalizedString("trips_label", comment: "").capitalized;
        
        
        // Add view on tabBar
        self.tabBarList = [];
        self.tabBarList.append(homeVC);
        if(UserDefaults.standard.object(forKey: "allow_bids") as! Int == 1) {
            self.tabBarList.append(offers);
        }
        self.tabBarList.append(scheduled);
        self.tabBarList.append(trips);
        
        viewControllers = tabBarList;
        
        
        // Set icons tabBar
        for index in self.tabBarList.indices {
            let item: UIViewController = tabBarList[index];
            let tabItem: UITabBarItem = tabBar.items![index];
            
            if(item is HomeViewController) {
                tabItem.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate);
            }
            else if(item is OffersViewController) {
                tabItem.image = UIImage(named: "offers")?.withRenderingMode(.alwaysTemplate);
            }
            else if(item is ScheduledViewController) {
                tabItem.image = UIImage(named: "schedule")?.withRenderingMode(.alwaysTemplate);
            }
            else if(item is TripsViewController) {
                tabItem.image = UIImage(named: "rides")?.withRenderingMode(.alwaysTemplate);
            }
        }
        
        // Right Swipe Detect
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(MainViewController.swiped(_:)));
        swipeRight.direction = UISwipeGestureRecognizerDirection.right;
        self.view.addGestureRecognizer(swipeRight);
        
        // Left Swipe Detect
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(MainViewController.swiped(_:)));
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left;
        self.view.addGestureRecognizer(swipeLeft);
        
        tabBarController(self, didSelect: tabBarList[0]);
        
        // Right Button item
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        spinner.startAnimating();
        spinner.alpha = 1;
        let barButtonItem = UIBarButtonItem(customView: spinner);
        self.navigationItem.rightBarButtonItem = barButtonItem;
        
        // Left Button item (Logout)
        let button: UIButton = UIButton(type: .custom);
        let imageLogout: UIImage = UIImage(named: "sign-out")!.withRenderingMode(.alwaysTemplate);
        button.setImage(imageLogout, for: .normal);
        button.addTarget(self, action: #selector(logout), for: .touchUpInside);
        button.contentMode = .scaleAspectFit;
        button.tintColor = AppColor.contrast();
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let barButton = UIBarButtonItem(customView: button);
        self.navigationItem.leftBarButtonItem = barButton;
        
        spinner.isHidden = true;
        
        // Set default tabbar
        if(self.selectedTab > 0) {
            self.selectedIndex = selectedTab;
            tabBarController(self, didSelect: tabBarList[self.selectedIndex]);
            selectedTab = 0;
        }
    }
    
    
    // Logout
    @objc public func logout() -> Void {
        defaults.removeObject(forKey: "session");
        OneSignal.logoutEmail();
        OneSignal.setSubscription(false);
        let loginController = LoginViewController();
        present(loginController, animated: true, completion: nil);
    }
    
    
    // MARK: Tabbar delegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.title = viewController.title;
    }
    
    
    // MARK: swipe function
    @objc func swiped(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if (self.selectedIndex) < tabBarList.count {
                self.selectedIndex += 1;
                tabBarController(self, didSelect: tabBarList[self.selectedIndex]);
            }
        } else if gesture.direction == .right {
            if (self.selectedIndex) > 0 {
                self.selectedIndex -= 1;
                tabBarController(self, didSelect: tabBarList[self.selectedIndex]);
            }
        }
    }
}
