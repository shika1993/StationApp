//
//  EditUserInfoViewController.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/12/08.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class EditUserInfoViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    let userdb = Firestore.firestore().collection("user")
    let postdb = Firestore.firestore().collection("post")
    var userName = ""
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        userNameTextField.text = userName
        userNameTextField.attributedPlaceholder = NSAttributedString(string: "ユーザー名",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeButtonPressed(_ sender: UIButton) {

        if userNameTextField.text! != ""{
            userdb.document(uid).updateData(["userName":"\(userNameTextField.text!)"])
            postdb.whereField("uid", isEqualTo: self.uid).getDocuments { (snaps, error) in
                if let error = error {
                    print(error)
                }else{
                    if let documents = snaps?.documents {
                        for document in documents {
                            self.postdb.document(document.documentID).updateData(["userName":self.userNameTextField.text!])
                        }
                    }
                }
            }
        }
        let alertController = UIAlertController(title: "ユーザー名変更", message: "ユーザー名を変更しました。", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "退会", message: "すべての情報を削除し退会しますか？", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "はい", style: .default) { (alert) in
            let firebaseAuth = Auth.auth().currentUser
            firebaseAuth?.delete(completion: { (err) in
                if err != nil{
                    print("退会に失敗しました",err as Any)
                    return
                }else{
                    self.userdb.document(self.uid).delete()
                    self.postdb.whereField("userName", isEqualTo: self.userName).getDocuments { (snaps, error) in
                        if let error = error {
                            print(error)
                        }else{
                            
                            for snap in snaps!.documents{
                                self.postdb.document(snap.documentID).delete()
                            }
                        }
                    }
                    UserDefaults.standard.set(false, forKey: "isLopgin")
                    UserDefaults.standard.set(false, forKey: "keepLopgin")
                    UserDefaults.standard.set(false, forKey: "noLopgin")
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
        let action2 = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
        alertController.addAction(action1)
        alertController.addAction(action2)
        present(alertController, animated: true, completion: nil)
    }
    
}
