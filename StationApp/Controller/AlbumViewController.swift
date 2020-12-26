//
//  AlbumViewController.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/15.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class AlbumViewController: UIViewController {

    
    @IBOutlet weak var albumTableView: UITableView!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    let postdb = Firestore.firestore().collection("post")
    let userdb = Firestore.firestore().collection("user")
    var userName:String = ""
    var myPosts:[[String:Any]] = []
    var uid:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "マイアルバム"
        albumTableView.delegate = self
        albumTableView.dataSource = self
        albumTableView.register(UINib(nibName: K.Cell.customCell, bundle: nil), forCellReuseIdentifier: K.Cell.cell)
        albumButton.layer.cornerRadius = 40
        albumButton.layer.shadowColor = UIColor.black.cgColor
        albumButton.layer.shadowOpacity = 0.4
        albumButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        favoriteButton.layer.cornerRadius = 40
        favoriteButton.layer.shadowColor = UIColor.black.cgColor
        favoriteButton.layer.shadowOpacity = 0.4
        favoriteButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getMyPosts()
    }
    
    @IBAction func albumButtonPressed(_ sender: UIButton) {
        
        HUD.show(.progress)
        getMyPosts()
    }
    
    @IBAction func bookMarkButtonPressed(_ sender: UIButton) {
        
        HUD.show(.progress)
        myBookMarkedPostID()
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        
        albumTableView.reloadData()
    }
    
    
}

//MARK:- TableViewdelegate & TableviewDatasource
extension AlbumViewController: UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return myPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = albumTableView.dequeueReusableCell(withIdentifier: K.Cell.cell, for: indexPath) as! CustomCell
        cell.selectionStyle = .none
        cell.userNameLabel.text = "投稿者：　\(myPosts[indexPath.row]["userName"] as! String)"
        cell.postImageView.sd_setImage(with: URL(string: myPosts[indexPath.row]["imageURL"] as! String), completed: nil)
        cell.commentLabel.text = myPosts[indexPath.row]["commet"] as? String ?? ""
        cell.createdAtLabel.text = myPosts[indexPath.row]["createdAt"] as? String ?? ""
        cell.goodButton.isHidden = true
        cell.badButton.isHidden = true
        cell.stationNameLabel.text = myPosts[indexPath.row]["stationName"] as? String ?? "" + "駅"
        cell.bookmarkButton.isHidden = true
        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    
    

}

//MARK:- Get post data
extension AlbumViewController {
    
    func getMyPosts() {
        
        self.myPosts.removeAll()
        postdb.whereField("userName", isEqualTo: userName).getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            }else{
                if snapshot?.count == 0{
                    let alertcontroller = UIAlertController(title: "マイアルバム", message: "まだ投稿した写真がありません\nお出かけした駅周辺でぜひ投稿してみてください", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertcontroller.addAction(alertAction)
                    self.present(alertcontroller, animated: true, completion: nil)
                }
                for snap in snapshot!.documents {
                    self.myPosts.append(snap.data())
                }
                HUD.hide()
            }
            self.title = "マイアルバム"
            self.albumTableView.reloadData()
        }
        
    }
    
    func  myBookMarkedPostID() {
        
        userdb.document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print(error)
            }else{
                
                if snapshot?.data()!["favorites"] as? [String] == []{
                    let alertcontroller = UIAlertController(title: "お気に入り", message: "お気に入り写真がありません！\n他のユーザーの投稿を気に入ったらブックマークボタンを押してみましょう", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertcontroller.addAction(alertAction)
                    self.present(alertcontroller, animated: true, completion: nil)
                }
                self.myBookMarkedPostData(ids:snapshot?.data()!["favorites"] as? [String] ?? [])
                HUD.hide()
            }
        }
    }
    
    func  myBookMarkedPostData(ids:[String]) {
        
        if ids.count >= 1 {
            self.myPosts.removeAll()
            var flag = 0
            for id in ids {
                
                postdb.document(id).getDocument { (snap, error) in
                    if let error = error {
                        print(error)
                    }else{
                        
                        if snap?.data() != nil {
                            self.title = "お気に入り"
                            self.myPosts.append((snap?.data())!)
                            self.albumTableView.reloadData()
                            flag = flag + 1
                        }
                    }
                }

            }
        }else{
            self.myPosts.removeAll()
            self.title = "お気に入り"
            self.albumTableView.reloadData()
        }
        
      
    }
    
    func noImageAlert() {
        let alertController = UIAlertController(title: "写真がありません", message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
