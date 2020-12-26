//
//  File.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/23.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol GetUserInfo {
    
    func getUserInfo(info:[String:Any])
    func removeUserInfo(info:[String:Any])
}

struct GetUserGoodInfo {
    
    var id:String?
    var getUserInfoDelegate: GetUserInfo?
    let postdb = Firestore.firestore().collection("post")
    
    init(id:String) {
        self.id = id
    }
    
    func getPostInfo() {
        
        postdb.document(self.id!).getDocument { (snapshot, error) in
            
            if let error = error {
                
                print(error)
            }else{
                
                if let data = snapshot?.data() {
                    
                    self.getUserInfoDelegate?.getUserInfo(info: data)
                }
            }
        }
    }
    
    func removePostInfo() {
        
        postdb.document(self.id!).getDocument { (snapshot, error) in
            
            if let error = error {
                
                print(error)
            }else{
                
                if let data = snapshot?.data() {

                    self.getUserInfoDelegate?.removeUserInfo(info: data)
                }
            }
        }
    }
    
    
}
