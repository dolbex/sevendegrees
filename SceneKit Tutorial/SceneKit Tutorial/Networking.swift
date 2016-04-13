//
//  Networking.swift
//  SceneKit Tutorial
//
//  Created by Gary Williams on 4/12/16.
//  Copyright © 2016 Gary Williams. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Networking {
    
    func makeRequest(
        endpoint:String,
        method: Alamofire.Method = .GET,
        data: Dictionary<String, String>? = [:],
        success: ((JSON) -> Void?)?,
        error: ((Int, String) -> Void?)?
    ){
        
        let globals: Globals = Globals()
        
        let url: String = "\(globals.baseApiUrl)\(endpoint)"
        let headers = [
            "Ocp-Apim-Subscription-Key": globals.apiKey
        ]
        
        //        print(url, data)
        
        Alamofire.request(method, url, parameters: data, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                
                let parsedJson = JSON(json)
                
                if parsedJson["error"] == nil {
                    if success != nil {
                        success!(parsedJson)
                    }
                } else {
                    
                    if error != nil {
                        error!(parsedJson["error"]["http_code"].intValue, parsedJson["error"]["message"].stringValue)
                    }
                }
            }
        }
    }
    
}
