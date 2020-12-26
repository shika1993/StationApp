//
//  GetStationInfo.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/16.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleMaps

struct RegistStationInfo {
    
    let apikey:String
    let db = Firestore.firestore()

    
    
    init(apikey: String) {
        
        self.apikey = apikey
    }
    
    func addStationInfo() {
        
        AF.request(self.apikey).response { (response) in
            
             let json:JSON = JSON(response.data as Any)
             
            for i in 0...json.count {
                
                let name = json[i]["dc:title"].string ?? ""
                let geolong = json[i]["geo:long"].double ?? 0
                let geolat = json[i]["geo:lat"].double ?? 0
            
                self.db.collection("Station").addDocument(data: [
                    
                    "name" : name,
                    "geolong": geolong,
                    "geolat": geolat
                    
                ])
            }
        }
    }
    
    
    
}
