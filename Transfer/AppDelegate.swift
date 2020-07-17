//
//  AppDelegate.swift
//  Transfer
//
//  Created by Elian Medeiros on 24/02/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import OneSignal

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true;
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        /*
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            let  userInfo = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as! NSDictionary;
            
            if(userInfo["custom"] != nil) {
                var object: NSDictionary = userInfo["custom"] as! NSDictionary;
                var auction_id:String = "";
                
                if((object["a"]) != nil) {
                    object = object["a"] as! NSDictionary;
                }
                
                if((object["auction_id"]) != nil) {
                    auction_id = object["auction_id"] as! String;
                }
                
                let bidsVC: BidsViewController = BidsViewController();
                bidsVC.auctionId = auction_id;
                window.rootViewController = UINavigationController(rootViewController: bidsVC);
            }
        }
        else {*/
            window.rootViewController = LoginViewController();
        //}
        window.makeKeyAndVisible()
        self.window = window
        
        setTheme();
        
        // MARK: OneSignal
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "9c605b21-4cc7-4b5e-b079-14f2da33f572",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings);
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)");
        })
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if(url.host == "offer") {
            if(url.path != "") {
                let savedObject = UserDefaults.standard.object(forKey: "session");
                if(savedObject != nil) {
                    let bidsVC: BidsViewController = BidsViewController();
                    bidsVC.auctionId = url.path.replacingOccurrences(of: "/", with: "");
                    topMostController().present(UINavigationController(rootViewController: bidsVC),
                                                animated: true,
                                                completion: nil);
                }
            }
        }
        
        return true;
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = window!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        //
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        //
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    // MARK: Set theme
    func setTheme() -> Void {
        
        // Status bar
        UIApplication.shared.statusBarStyle = .lightContent;
        
        // Transparent navigation
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default);
        UINavigationBar.appearance().shadowImage = UIImage();
        UINavigationBar.appearance().backgroundColor = AppColor.primary().withAlphaComponent(0.5);
        UIApplication.shared.statusBarView?.backgroundColor = AppColor.primary().withAlphaComponent(0.5);
        UINavigationBar.appearance().isTranslucent = true;
        
        // text colors
        let strokeTextAttributes = [
            NSAttributedStringKey.strokeColor : AppColor.primary(),
            NSAttributedStringKey.foregroundColor : AppColor.contrast(),
            NSAttributedStringKey.strokeWidth : -4.0,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22)
        ] as [NSAttributedStringKey : Any];
        
        UINavigationBar.appearance().tintColor = AppColor.contrast();
        UINavigationBar.appearance().barTintColor = AppColor.contrast();
        UINavigationBar.appearance().titleTextAttributes = strokeTextAttributes;
        
        // UIBar
        UITabBar.appearance().barTintColor = AppColor.darkPrimary();
        UITabBar.appearance().tintColor = AppColor.contrast();
        UITabBar.appearance().isTranslucent = false;
    }
}

