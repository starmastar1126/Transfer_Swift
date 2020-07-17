//
//  APIController.swift
//  Transfer
//
//  Created by Elian Medeiros on 25/02/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import Foundation

class APIController: APIGeneral {
    
    public func login(email: String, password: String, callback: APICallback) {
        let path = dict!["login"] as! String
        
        let params: [String: String] = [
            "key": dict!["API_KEY"] as! String,
            "email": email,
            "password": password];
        
        self.makeHTTPPostRequest(path: path, params: params as Dictionary<String, AnyObject>, routine: "login", callback: {
            (data, error) -> Void in
            if (error == nil){
                self.delegate?.didReceiveAPIResults(results: data, param: "login");
            }
        })
    }
    
    public func placeBid(price: String, id: String, callback: APICallback) {
        let path = dict!["bid"] as! String
        
        let params: [String: String] = [
            "token": APIController.getToken(),
            "price": price,
            "auction_id": id];
        
        self.makeHTTPPostRequest(path: path, params: params as Dictionary<String, AnyObject>, routine: "placeBid", callback: {
            (data, error) -> Void in
            if (error == nil){
                self.delegate?.didReceiveAPIResults(results: data, param: "placeBid");
            }
        })
    }
    
    public func updateStatus(status: Int64, orderId: String, callback: APICallback) {
        let path = dict!["rideStatus"] as! String
        
        let params: [String: String] = [
            "token": APIController.getToken(),
            "order_id": orderId,
            "order_status_id": String(status)];
        
        self.makeHTTPPostRequest(path: path, params: params as Dictionary<String, AnyObject>, routine: "updateStatus", callback: {
            (data, error) -> Void in
            if (error == nil){
                self.delegate?.didReceiveAPIResults(results: data, param: "updateStatus");
            }
        })
    }
    
    public func customer(callback: APICallback){
        let path = dict!["customer"] as! String
        getWithToken(path: path);
    }
    
    public func offers(callback: APICallback){
        let path = dict!["offers"] as! String
        getWithToken(path: path);
    }
    
    public func trips(callback: APICallback){
        let path = dict!["trips"] as! String
        getWithToken(path: path);
    }
    
    public func scheduled(callback: APICallback){
        let path = dict!["scheduled"] as! String
        getWithToken(path: path);
    }
    
    public func offerDetail(auctionId:String, callback: APICallback){
        let path = dict!["offerDetail"] as! String
        
        let params: [String: String] = [
            "token": APIController.getToken(),
            "auction_id": auctionId
        ];
        
        self.makeHTTPGetRequest(path: path, params: params as Dictionary<String, AnyObject>, routine: "offerDetail", callback: {
            (data, error) -> Void in
            if (error == nil){
                self.delegate?.didReceiveAPIResults(results: data, param: "offerDetail");
            }
        })
    }
    
    public func scheduledDetail(rideId:String, callback: APICallback){
        let path = dict!["rideDetail"] as! String
        
        let params: [String: String] = [
            "token": APIController.getToken(),
            "ride_id": rideId
        ];
        
        self.makeHTTPGetRequest(path: path, params: params as Dictionary<String, AnyObject>, routine: "scheduledDetail", callback: {
            (data, error) -> Void in
            if (error == nil){
                self.delegate?.didReceiveAPIResults(results: data, param: "scheduledDetail");
            }
        })
    }
    
    private func getWithToken(path: String) {
        let params: [String: String] = ["token": APIController.getToken()];
        
        self.makeHTTPGetRequest(path: path, params: params as Dictionary<String, AnyObject>, routine: "", callback: {
            (data, error) -> Void in
            if (error == nil){
                self.delegate?.didReceiveAPIResults(results: data, param: "");
            }
        })
    }
    
    private static func getToken() -> String {
        let session: Dictionary<String, AnyObject> = UserDefaults.standard.object(forKey: "session") as! Dictionary<String, AnyObject>;
        return session["token"] as! String;
    }
}
