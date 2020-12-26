//
//  User.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/15.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD

protocol finishCreateUser {
    
    func finishCreateUser()
}

protocol finishLoginUser {
    
    func finishLogin()
}

struct User{
    
    let mail:String
    let password:String
    let userName:String = ""
    var posts:[String] = []
    var favorites:[String] = []
    var goods:[String] = []
    var bads:[String] = []
    let db = Firestore.firestore()
    let auth = Auth.auth()
    var finishCreateUserdelegate: finishCreateUser?
    var finishLoginUserdelegate: finishLoginUser?
    
    init(mail:String, password:String) {
        self.mail = mail
        self.password = password
    }
    
    func createUser(userName:String) {
        
        auth.createUser(withEmail: mail, password: password) { (reslut, error) in
            if let error = error {
                
                HUD.flash(.error)
                print("ユーザー登録に失敗しました。：\(error)")
            }else if let uid = reslut?.user.uid{
                
                self.db.collection("user").document(uid).setData([
                    "uid": uid,
                    "mail": self.mail,
                    "userName": userName,
                    "posts": self.posts,
                    "favorites":self.favorites,
                    "goods":self.goods,
                    "bads":self.bads,
                    "blockContents": [],
                    "blockUsers": []
                ]) { (error) in
                    
                    if let error = error{
                        print("ユーザーの登録に失敗しました。：\(error)")
                    }
                }
                
                UserDefaults.standard.setValue(mail, forKey: "mail")
                UserDefaults.standard.setValue(password, forKey: "password")
                HUD.flash(.success)
                self.finishCreateUserdelegate?.finishCreateUser()
            }
            
        }
    }
    
    func login() {
        
        auth.signIn(withEmail: mail, password: password) { (result, error) in
            if let error = error {
                
                HUD.flash(.error)
                print("ログインに失敗しました。：\(error)")
            }else {
                
                UserDefaults.standard.setValue(mail, forKey: "mail")
                UserDefaults.standard.setValue(password, forKey: "password")
                HUD.flash(.success)
                self.finishLoginUserdelegate?.finishLogin()
            }
        }

    }

}
