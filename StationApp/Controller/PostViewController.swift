//
//  PostViewController.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/15.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class PostViewController: UIViewController {

    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var comentTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    var postImage:UIImage?
    var stationName:String = ""
    let postdb = Firestore.firestore().collection("post")
    let userdb = Firestore.firestore().collection("user")
    let storage = Storage.storage().reference(forURL: "gs://secondstationaapp.appspot.com").child("post")
    var uploadImage = Data()
    var uid:String = ""
    var userName:String = ""
    var userPostedStationArray:[String] = []
    
    var stationNameArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid
        }
        postButton.layer.cornerRadius = 10.0
        postButton.layer.shadowColor = UIColor.black.cgColor
        postButton.layer.shadowOpacity = 0.4
        postButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        comentTextField.attributedPlaceholder = NSAttributedString(string: "コメント",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        getUserName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let postImage = postImage else {return}
        postImageView.image = postImage
        stationNameArray.append(stationName)
    }

    @IBAction func postButtonPressed(_ sender: UIButton) {
        
        HUD.show(.progress)
        uploadImage(userName: userName, stationName: stationName)
        
    }
    
    func getUserName() {
        if let uid = Auth.auth().currentUser?.uid {
            userdb.whereField("uid", isEqualTo: uid).getDocuments{ (snapshot, error) in
                
                if let error = error {
                    fatalError("failed1:\(error)")
                }else{
                    
                    for snap in snapshot!.documents {
                        self.userName = snap.data()["userName"] as! String
                    }
                }
            }
            
        }
    }
    
    
//MARK:- uploadTask
    
    func uploadImage(userName:String, stationName:String) {
        
        if let image = postImageView.image {
            
            uploadImage = image.jpegData(compressionQuality: 0.01)!
        }
    
        storage.putData(uploadImage, metadata: nil) { (data, error) in
            if let error = error {
                print(error)
            }else{
                self.storage.downloadURL { (url, error) in
                    if let error = error {
                        print(error)
                    }else{
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd HH:mm:ss", options: 0, locale: Locale(identifier: "ja_JP"))
                        
                        self.postdb.addDocument(data: [
                            
                            "userName" : userName,
                            "stationName":stationName,
                            "imageURL":url!.absoluteString,
                            "comment": self.comentTextField.text ?? "No comment.",
                            "goodUser": [],
                            "badUser": [],
                            "createdAt":formatter.string(from: Date()),
                            "uid":self.uid
                            
                        ])
                        self.userdb.document(self.uid).getDocument { (snap, error) in
                            if let error = error {
                                print(error)
                            }else{
                                if let postedStationName = snap?.data()!["posts"] as? [String] {
                                    self.userPostedStationArray = postedStationName
                                    if postedStationName.firstIndex(of: self.stationName) == nil {
                                        self.userPostedStationArray.append(self.stationName)
                                        self.userdb.document(self.uid).updateData(["posts" : self.userPostedStationArray])
                                    }
                                }
                            }
                        }
                        HUD.hide()
                       self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
}

