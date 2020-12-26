//
//  post.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/16.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Post {
    
    var id:String = ""
    var userName:String = ""
    var stationName:String = ""
    var postImageURL:String = ""
    var comment:String = ""
    var goodUser:[String] = []
    var badUser:[String] = []
    var createdAt:String
    var uid:String = ""
    
    init(id:String,userName:String, stationName:String, postImageURL:String, comment:String, goodUser: [String], badUser: [String] , createdAt:String, uid:String) {
        
        self.id = id
        self.userName = userName
        self.stationName = stationName
        self.postImageURL = postImageURL
        self.comment = comment
        self.goodUser = goodUser
        self.badUser = badUser
        self.createdAt = createdAt
        self.uid = uid
    }
  
}
