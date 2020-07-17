//
//  LoginViewController.swift
//  Transfer
//
//  Created by Elian Medeiros on 24/02/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import UIKit
import OneSignal

class LoginViewController: UIViewController, APIControllerDelegate {
    
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var loginInput: InsetTextFieldLogin!
    @IBOutlet var passwordInput: InsetTextFieldLogin!
    @IBOutlet var buttonLogin: UIButton!
    
    private let loading: LoadingViewController = LoadingViewController.init();
    lazy var api: APIController = APIController(delegate: self);
    
    let defaults = UserDefaults.standard;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading.setView(view: view);
        loading.show();
        
        // Set texts
        loginInput.placeholder = NSLocalizedString("email", comment: "");
        passwordInput.placeholder = NSLocalizedString("password", comment: "");
        buttonLogin.setTitle(NSLocalizedString("button_login", comment: ""), for: .normal);
        alertLabel.text = "";
        
        // Set theme colors
        setTheme();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        // Check isLogged
        let savedObject = defaults.object(forKey: "session");
        if(savedObject != nil) {
            pushMainView();
        }
        else {
            loading.hide();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func pushMainView() {
        OneSignal.setEmail(defaults.object(forKey: "user") as! String);
        let session: Dictionary<String, AnyObject> = defaults.object(forKey: "session") as! Dictionary<String, AnyObject>;
        let allow_bids: Int = defaults.object(forKey: "allow_bids") as! Int;
        
        OneSignal.setSubscription(false);
        if((session["epicenters"] != nil) && allow_bids == 1){
            if(session["epicenters"] != nil) {
                let epicenters: Array<String> = session["epicenters"] as! Array<String>;
                for epicenter in epicenters {
                    OneSignal.sendTag(epicenter, value: "1");
                }
                OneSignal.setSubscription(true);
            }
        }

        let viewController = MainViewController();
        let navigationController = UINavigationController(rootViewController: viewController);
        present(navigationController, animated: true, completion: nil);
    }
    
    // MARK: Button click
    @IBAction func onLoginClick(_ sender: Any) {
        loading.show();
        alertLabel.text = "";
        
        api.login(email: loginInput.text!, password: passwordInput.text!) { (data, error) -> Void in }
    }
    
    // MARK: API Delegate
    public func didReceiveAPIResults(results: [String : AnyObject]?, param: String) {
        DispatchQueue.main.sync {
            if(results!["error"] == nil) {
                let resultDict = results!
                
                let customer: Dictionary<String, Any> = resultDict["customer"] as! Dictionary<String, Any>;
                if(customer["allow_bids"] != nil) {
                    let allow_bids:Int = customer["allow_bids"] as! Int;
                    defaults.set(allow_bids, forKey: "allow_bids");
                }
                else {
                    defaults.set(0, forKey: "allow_bids");
                }
                
                defaults.set(resultDict, forKey: "session");
                defaults.set(loginInput.text, forKey: "user");
                defaults.set(passwordInput.text, forKey: "pass");
                
                pushMainView();
            }
            else {
                alertLabel.text = NSLocalizedString("alert_login_user", comment: "");
            }
            loading.hide();
        }
    }
    
    // MARK: Set theme
    private func setTheme() {
        setIconLabel(textField: loginInput, named: "email");
        setIconLabel(textField: passwordInput, named: "password");
        
        loginInput.textColor = AppColor.contrast();
        loginInput.placeHolderColor = AppColor.contrast().withAlphaComponent(0.5);
        passwordInput.textColor = AppColor.contrast();
        passwordInput.placeHolderColor = AppColor.contrast().withAlphaComponent(0.5);
        buttonLogin.backgroundColor = AppColor.accent();
        buttonLogin.setTitleColor(AppColor.contrast(), for: .normal);
        view.backgroundColor = AppColor.primary();
        loginInput.addBorder();
        passwordInput.addBorder();
    }
    
    private func setIconLabel(textField: UITextField, named: String) {
        textField.leftViewMode = UITextFieldViewMode.always;
        let image = UIImage(named: named);
        let tintableImage = image?.withRenderingMode(.alwaysTemplate);
        let imageView = UIImageView();
        imageView.frame = CGRect(x: 0, y: 0, width: textField.frame.height, height: textField.frame.height);
        imageView.image = tintableImage;
        imageView.tintColor = AppColor.contrast().withAlphaComponent(0.8);
        textField.leftView = imageView;
    }
}
