//
//  TimeLineViewController.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/15.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SDWebImage

class TimeLineViewController: UIViewController {
    
    @IBOutlet weak var timeLineTableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    var stationName = String()
    let camera = UIImagePickerController()
    var image:UIImage?
    var posts:[Post] = []
    var myFavoritePostId:[String] = []
    var postId:[String] = []
    var goodUsers:[String] = []
    var badUsers:[String] = []
    var blockContents:[String] = []
    var blockUser:[String] = []
    let db = Firestore.firestore()
    var uid:String = ""
    var userName:String = ""
    var stationLat:Double = 0.0
    var stationLong:Double = 0.0
    var userLat:Double = 0.0
    var userLong:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uid = Auth.auth().currentUser?.uid {
  
            self.uid = uid
            db.collection("user").document(uid).getDocument { (snap, error) in
                if let error = error {
                    print(error)
                }else{
                    self.userName = snap?.data()!["userName"] as! String
                }
            }
        }
        
        self.navigationItem.title = stationName
        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self
        timeLineTableView.register(UINib(nibName: K.Cell.customCell, bundle: nil), forCellReuseIdentifier: K.Cell.cell)
        postButton.layer.cornerRadius = 40.0
        postButton.layer.shadowColor = UIColor.black.cgColor
        postButton.layer.shadowOpacity = 0.4
        postButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        camera.sourceType = .camera
        camera.delegate = self
        db.collection("post").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error)
            }else{
                self.fetchPostData()
            }
        }

        getMyFavoritePostId()
        getblockContentsData()
        getblockUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPostData()
    }

    @IBAction func postButtonPressed(_ sender: UIButton) {
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            if sqrt(pow((userLong-stationLong), 2.0) + pow((userLat-stationLat), 2.0)) >= 0.00901 {
                let alertController = UIAlertController(title: "駅周辺にいないので投稿できません", message: nil, preferredStyle: .alert)
                let action1 = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(action1)
                self.present(alertController, animated: true, completion: nil)
            }else{
                let alertController = UIAlertController(title: "駅周辺にいます、写真を投稿しますか？", message: nil, preferredStyle: .alert)
                let action1 = UIAlertAction(title: "投稿", style: .default) { (UIAlertAction) in
                    self.presentCamera()
                }
                let action2 = UIAlertAction(title: "キャンセル", style: .cancel)
                alertController.addAction(action1)
                alertController.addAction(action2)
                self.present(alertController, animated: true, completion: nil)
               
            }
        }else{
            let alertController = UIAlertController(title: "ログイン、会員登録を\nしていないので写真を投稿することができません。", message: "トップに戻りログイン、または会員登録を行ますか？", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "いいえ", style: .default)
            let action2 = UIAlertAction(title: "はい", style: .default) { (alert) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
   
}


//MARK:- TableViewdelegate & TableviewDatasource
extension TimeLineViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = timeLineTableView.dequeueReusableCell(withIdentifier: K.Cell.cell, for: indexPath) as! CustomCell

            cell.selectionStyle = .none
            cell.userNameLabel.text = "投稿者：　\(posts[indexPath.row].userName)"
            cell.postImageView.sd_setImage(with: URL(string: posts[indexPath.row].postImageURL), completed: nil)
            cell.commentLabel.text = posts[indexPath.row].comment
            cell.goodNumberLabel.text = String(posts[indexPath.row].goodUser.count)
            cell.badNumberLabel.text = String(posts[indexPath.row].badUser.count)
            cell.createdAtLabel.text = posts[indexPath.row].createdAt
            cell.id = posts[indexPath.row].id
            postId.append(cell.id)
            cell.bookmarkButton.tag = indexPath.row
            cell.goodButton.tag = indexPath.row
            cell.badButton.tag = indexPath.row
            cell.bookmarkButton.addTarget(self, action: #selector(bookmarkButtonPressed(_:)), for: .touchUpInside)
            cell.goodButton.addTarget(self, action: #selector(goodButtonPressed(_:)), for: .touchUpInside)
            cell.badButton.addTarget(self, action: #selector(badButtonPressed(_:)), for: .touchUpInside)
            cell.stationNameLabel.text = posts[indexPath.row].stationName + "駅"
            
            if myFavoritePostId.firstIndex(of: posts[indexPath.row].id) != nil {
                cell.bookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal)
            }else{
                cell.bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
            }
            
            if posts[indexPath.row].goodUser.firstIndex(of: uid) == nil {
                cell.goodButton.setImage(UIImage(named: "good1"), for: .normal)
            }else{
                cell.goodButton.setImage(UIImage(named: "good2"), for: .normal)
            }
            
            if posts[indexPath.row].badUser.firstIndex(of: uid) == nil {
                cell.badButton.setImage(UIImage(named: "bad1"), for: .normal)
            }else{
                cell.badButton.setImage(UIImage(named: "bad2"), for: .normal)
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if blockContents.firstIndex(of: posts[indexPath.row].id) != nil {
            return 0
        }else if blockUser.firstIndex(of: posts[indexPath.row].uid) != nil{
            return 0
        }else{
            return 600
        }
    }
    
}

//MARK:- UIImagePickerControllerDelegate
extension TimeLineViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func presentCamera() {
        present(camera, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.image = info[.originalImage] as? UIImage
        performSegue(withIdentifier: K.Segue.post, sender: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let postVC = segue.destination as? PostViewController
        postVC?.postImage = self.image
        postVC?.stationName = stationName
    }
}

//MARK:- getPostData

extension TimeLineViewController {
    
    func fetchPostData() {
        db.collection("post").whereField("stationName", isEqualTo: stationName).order(by: "createdAt").getDocuments { (snapshot, error) in
            self.posts.removeAll()
            
            if let error = error {
                print(error)
            }else{
                for snap in snapshot!.documents {
                    let post = Post(
                        id: snap.documentID,
                        userName: snap.data()["userName"] as! String,
                        stationName: snap.data()["stationName"] as! String,
                        postImageURL: snap.data()["imageURL"] as! String,
                        comment: snap.data()["comment"] as! String,
                        goodUser: snap.data()["goodUser"] as? [String] ?? [],
                        badUser: snap.data()["badUser"] as? [String] ?? [],
                        createdAt: snap.data()["createdAt"] as! String,
                        uid: snap.data()["uid"] as! String
                    )
                    self.posts.append(post)
                }
                self.timeLineTableView.reloadData()
            }
            
        }
    }
}

//MARK:- Favorite Method
extension TimeLineViewController {
    
    @objc func bookmarkButtonPressed(_ sender:UIButton) {
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            if myFavoritePostId.firstIndex(of: posts[sender.tag].id) == nil {
                myFavoritePostId.append(posts[sender.tag].id)
                db.collection("user").document(uid).updateData(["favorites" : myFavoritePostId])
            }else{
                
                let i = myFavoritePostId.firstIndex(of: posts[sender.tag].id)
                myFavoritePostId.remove(at: i!)
                db.collection("user").document(uid).updateData(["favorites" : myFavoritePostId])
            }
        }
        timeLineTableView.reloadData()
    }
    
    func getMyFavoritePostId() {
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            db.collection("user").document(uid).getDocument { (snapshot, error) in
                if let error = error {
                    print(error)
                }else if let snap = snapshot{
                    self.myFavoritePostId = snap.get("favorites") as? [String] ?? []
                    self.timeLineTableView.reloadData()
                }
            }
        }
    }
    
    
}

//MARK:- good and bad method
extension TimeLineViewController {

    @objc func goodButtonPressed(_ sender:UIButton) {
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            db.collection("post").document(posts[sender.tag].id).getDocument { (snapshot, error) in
                if let error = error {
                    print(error)
                }else{
                    if let goodUsers = snapshot?.data()!["goodUser"] as? [String]{
                        self.goodUsers = goodUsers
                        if self.goodUsers.firstIndex(of: self.uid) == nil{
                            self.goodUsers.append(self.uid)
                            self.db.collection("post").document(self.posts[sender.tag].id).updateData(["goodUser" : self.goodUsers])
                        }else{
                            let i = self.goodUsers.firstIndex(of: self.uid)
                            self.goodUsers.remove(at: i!)
                            self.db.collection("post").document(self.posts[sender.tag].id).updateData(["goodUser" : self.goodUsers])
                        }
                    }
                }
            }
        }
    }
    
    @objc func badButtonPressed(_ sender:UIButton) {
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            db.collection("post").document(posts[sender.tag].id).getDocument { (snapshot, error) in
                if let error = error {
                    print(error)
                }else{
                    if let badUsers = snapshot?.data()!["badUser"] as? [String]{
                        self.badUsers = badUsers
                        if self.badUsers.firstIndex(of: self.uid) == nil{
                            self.badUsers.append(self.uid)
                            self.db.collection("post").document(self.posts[sender.tag].id).updateData(["badUser" : self.badUsers])
                        }else{
                            let i = self.badUsers.firstIndex(of: self.uid)
                            self.badUsers.remove(at: i!)
                            self.db.collection("post").document(self.posts[sender.tag].id).updateData(["badUser" : self.badUsers])
                        }
                    }
                }
            }
        }
    }
    
    
}

//MARK:- swipe Action
extension TimeLineViewController {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        if posts[indexPath.row].userName == self.userName {
            return "削除"
        }else{
            return "非表示"
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            
            if posts[indexPath.row].userName == self.userName {
                //自分自身の投稿の場合、削除アラートを表示
                let alertController = UIAlertController(title: "削除", message: "この投稿を削除しますか？", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "キャンセル", style: .default)
                let action2 = UIAlertAction(title: "削除", style: .destructive) { (alert) in
                    let deleteID = self.posts[indexPath.row].id
                    self.db.collection("post").document(deleteID).delete()
                    self.timeLineTableView.reloadData()
                }
                alertController.addAction(action1)
                alertController.addAction(action2)
                self.present(alertController, animated: true, completion: nil)
            }else{
                //他のユーザーの投稿の場合、非表示→通報の順番でアラートを表示
                let alertController = UIAlertController(title: "投稿の非表示", message: "この投稿を不適切な投稿として非表示にしますか？", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "キャンセル", style: .default)
                let action2 = UIAlertAction(title: "はい", style: .destructive) { (alert) in
                    
                    let alertController = UIAlertController(title: "通報", message: "この投稿を不適切なコンテンツとして管理者に報告しますか？", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "いいえ", style: .default) { (alert) in
                        
                        self.blockContents.append(self.posts[indexPath.row].id)
                        self.db.collection("user").document(self.uid).updateData(["blockContents":self.blockContents])
                        self.blockContents.removeAll()
                        self.getblockContentsData()
                    }
                    let action2 = UIAlertAction(title: "はい", style: .destructive) { (alert) in
                        
                        self.blockContents.append(self.posts[indexPath.row].id)
                        self.db.collection("user").document(self.uid).updateData(["blockContents":self.blockContents])
                        self.db.collection("block").addDocument(data: [
                            
                            "blockContentsID":self.posts[indexPath.row].id,
                            "blockUserID":self.posts[indexPath.row].uid,
                            "userID":self.uid
                        ])
                        self.blockContents.removeAll()
                        self.getblockContentsData()
                        
                    }
                    alertController.addAction(action1)
                    alertController.addAction(action2)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                alertController.addAction(action1)
                alertController.addAction(action2)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            
            if posts[indexPath.row].userName != self.userName {
                let action = UIContextualAction(style: .destructive, title: "ブロック") { (ctxAction, view, completionHandler) in
                    
                    let alertController = UIAlertController(title: "不適切なユーザー", message: "このユーザーの投稿を今後表示しない。", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "キャンセル", style: .default)
                    let action2 = UIAlertAction(title: "はい", style: .destructive) { (alert) in
                        
                        
                        let alertController = UIAlertController(title: "通報", message: "このユーザーを不適切なユーザーとして管理者に通報しますか？", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "いいえ", style: .default) { (alert) in
                            self.blockUser.append(self.posts[indexPath.row].uid)
                            self.db.collection("user").document(self.uid).updateData(["blockUsers":self.blockUser])
                            self.blockUser.removeAll()
                            self.getblockUserData()
                        }
                        let action2 = UIAlertAction(title: "はい", style: .destructive) { (alert) in
                            
                            self.blockUser.append(self.posts[indexPath.row].uid)
                            self.db.collection("user").document(self.uid).updateData(["blockUsers":self.blockUser])
                            self.db.collection("block").addDocument(data: [
                                
                                "blockContentsID":self.posts[indexPath.row].id,
                                "blockUserID":self.posts[indexPath.row].uid,
                                "userID":self.uid
                            ])
                            self.blockUser.removeAll()
                            self.getblockUserData()
                        }
                        alertController.addAction(action1)
                        alertController.addAction(action2)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    alertController.addAction(action1)
                    alertController.addAction(action2)
                    self.present(alertController, animated: true, completion: nil)
                }
                return UISwipeActionsConfiguration(actions: [action])
            }
        }
        
        
        
       
        
        
        
        
        return UISwipeActionsConfiguration(actions: [])
    }
    
    func getblockContentsData() {
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            db.collection("user").document(uid).getDocument { (snap, error) in
                if let error = error{
                    print(error)
                }else{
                    self.blockContents.append(contentsOf: snap?.data()!["blockContents"] as? [String] ?? [])
                    self.timeLineTableView.reloadData()
                }
            }
        }
        
    }
    
    func getblockUserData(){
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool == false{
            db.collection("user").document(uid).getDocument { (snap, error) in
                if let error = error{
                    print(error)
                }else{
                    self.blockUser.append(contentsOf: snap?.data()!["blockUsers"] as? [String] ?? [])
                    self.timeLineTableView.reloadData()
                }
            }
        }
        
    }
    
}
