//
//  APIGeneral.swift
//  Transfer
//
//  Created by Elian Medeiros on 24/02/18.
//  Copyright © 2018 Transfer+. All rights reserved.
//

import Foundation

typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>
var dict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "API_Config", ofType: "plist")!)

protocol APIControllerDelegate {
    func didReceiveAPIResults(results: Dictionary<String, AnyObject>?, param: String);
}

class APIGeneral: NSObject {
    
    var delegate: APIControllerDelegate?
    
    init(delegate: APIControllerDelegate?) {
        self.delegate = delegate
    }
    typealias APICallback = ((Dictionary<String, AnyObject>?, String?) -> ())
    
    public func makeHTTPGetRequest(path: String, params: Dictionary<String, AnyObject>, routine: String, callback: @escaping APICallback) {
        requestSet(type: "GET", path: path, params: params, routine: routine, callback: callback);
    }
    
    public func makeHTTPPostRequest(path: String, params: Dictionary<String, AnyObject>, routine: String, callback: @escaping APICallback) {
        requestSet(type: "POST", path: path, params: params, routine: routine, callback: callback);
    }
    
    private  func requestSet(type: String, path: String, params: Dictionary<String, AnyObject>, routine: String, callback: @escaping APICallback) {
        let baseUrl = dict!["BASE_URL"] as! String;
        let pathComplete = baseUrl + path;
        
        //print("Url: \(pathComplete)  vars: \(params)");print("Url: \(path)  vars: \(params)");
        
        var request: URLRequest;
        if(type == "POST") {
            request = URLRequest(url: URL(string: pathComplete)!);
            let boundary = generateBoundaryString();
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type");
            request.httpBody = createBodyWithParameters(parameters: params, boundary: boundary);
        }
        else {
            request = URLRequest(url: URL(string: queryItems(url: pathComplete, dictionary: params))!);
        }
        request.httpMethod = type;
        
        httpRequest(request: request, routine: routine, callback: callback);
    }
    
    private func httpRequest(request: URLRequest, routine: String, callback: @escaping APICallback) {
        let session = URLSession.shared;
        let task = session.dataTask(with: request) { (data, response, error) in
            do {
                // Debug verify error
                //let responseString = String(data: data!, encoding: .utf8)
                //print("\(responseString!)");
                
                var json: Dictionary<String, AnyObject> = [:];
                if(routine != "updateStatus") {
                    json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                }
                let nsDictionaryObject = json;
                callback(nsDictionaryObject, nil);
            }
            catch {
                callback(nil, error.localizedDescription)
            }
        }
        task.resume();
    }
    
    private func queryItems(url: String, dictionary: [String:Any]) -> String {
        var components = URLComponents()
        components.queryItems = dictionary.map {
            URLQueryItem(name: $0, value: $1  as? String);
        }
        let urlPrev:String = url + (components.url?.absoluteString)!;
        let pathParams:Array = urlPrev.split(separator: "?");
        var urlFinal:String = "";
        for index in pathParams.indices {
            if index == 0 {
                urlFinal += pathParams[index] + "?";
            }
            else {
                urlFinal += pathParams[index] + "&";
            }
        }
        
        return urlFinal;
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    private func createBodyWithParameters(parameters: [String: AnyObject]?, boundary: String) -> Data {
        var body = Data();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
    }
}
