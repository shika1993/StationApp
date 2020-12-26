//
//  MapViewController.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/15.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SDWebImage
import PKHUD

class MapViewController: UIViewController {
    
    let stationdb = Firestore.firestore().collection(K.station)
    let userdb = Firestore.firestore().collection("user")
    let postdb = Firestore.firestore().collection("post")
    let image = UIImage(named: "album")
    var mapView = GMSMapView()
    var stationName:String?
    var locationManager = CLLocationManager()
    var userGeoLat = 35.6812226
    var userGeoLong = 139.7670594
    var stationLat:Double = 0.0
    var stationLong:Double = 0.0
    var width:CGFloat = 0
    var height:CGFloat = 0
    var userName = ""
    var userPostedStation:[String] = []
    var userPostedImage:[String] = []
    var myPostsCount:Int = 0
    let postedStationLabel = UILabel()
    let postedimageLabel = UILabel()
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isMyLocationEnabled = true
        navigationController?.isNavigationBarHidden = false
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        width = self.view.frame.width
        height = self.view.frame.height
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool{
            navigationItem.rightBarButtonItem?.title = "トップ"
            navigationItem.leftBarButtonItem?.isEnabled = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserName()
        requestLoacion()
        setupMap()
        self.title = K.title
        navigationItem.hidesBackButton = true

    }
    
    @objc func albumButtonPressed(_ sender: UIButton) {
        

        if let _ = Auth.auth().currentUser?.uid{
            performSegue(withIdentifier: K.Segue.album, sender: nil)
        }else{
            let alertController = UIAlertController(title: "ログイン、会員登録を\nしていないのでアルバムを見ることができません。", message: "トップに戻りログイン、または会員登録を行ますか？", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "いいえ", style: .default)
            let action2 = UIAlertAction(title: "はい", style: .default) { (alert) in
                UserDefaults.standard.set(false, forKey: "noLogin")
                self.navigationController?.popToRootViewController(animated: true)
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool{
            UserDefaults.standard.set(false, forKey: "noLogin")
            navigationController?.popToRootViewController(animated: true)
        }else{
            let alertController = UIAlertController(title: "ログアウト", message: "ログアウトしますか？", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "いいえ", style: .default)
            let action2 = UIAlertAction(title: "はい", style: .destructive) { (alert) in
                
                do {
                    try Auth.auth().signOut()
                    UserDefaults.standard.setValue(false, forKey: "isLogin")
                    UserDefaults.standard.setValue(false, forKey: "keepLogin")
                    self.navigationController?.popToRootViewController(animated: true)
                } catch let error {
                    print("ログアウトに失敗しました",error)
                }
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func editButonpressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "edit", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.Segue.timeline{
            let timeLineVC = segue.destination as? TimeLineViewController
            timeLineVC?.stationLat = self.stationLat
            timeLineVC?.stationLong = self.stationLong
            timeLineVC?.userLat = self.userGeoLat
            timeLineVC?.userLong = self.userGeoLong
            if let name = stationName{
                timeLineVC?.stationName = name
            }
        }else if segue.identifier == "edit"{
            
            let editVC = segue.destination as? EditUserInfoViewController
            editVC?.userName = self.userName
            editVC?.uid = uid
            
        }else{
            self.navigationItem.title = "Album"
            let albumVC = segue.destination as? AlbumViewController
            albumVC?.userName = userName
        }
    }
    
}

//MARK:- Make a MAP & delegate Methods

extension MapViewController: GMSMapViewDelegate {
    
    private func setupMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: userGeoLat, longitude: userGeoLong, zoom: 12.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        view = mapView
        makeButton()
        makeLabel()
    }
    
    func makeMapMaker() {
        
        stationdb.getDocuments { (snapshot, error) in
            if let error = error {
                print("\(error)")
            }else{
                
                for snap in snapshot!.documents {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: snap.data()["geolat"] as! CLLocationDegrees, longitude: snap.data()["geolong"] as! CLLocationDegrees)
                    marker.title = snap.data()["name"] as? String
                    marker.map = self.mapView
                    marker.isTappable = true
                    if self.userPostedStation.firstIndex(of: snap.data()["name"] as! String) == nil {
                        marker.icon = UIImage(named: "nopost")
                    }else{
                        marker.icon = UIImage(named: "posted")
                    }
                    
                }
            }
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        stationName = marker.title
        stationLat = marker.position.latitude
        stationLong = marker.position.longitude
        performSegue(withIdentifier: K.Segue.timeline, sender: nil)
    }
    
}

//MARK:- use Location
extension MapViewController {
    
    private func requestLoacion() {
        
        // ユーザにアプリ使用中のみ位置情報取得の許可を求めるダイアログを表示
        locationManager.requestWhenInUseAuthorization()
        if let lat = locationManager.location?.coordinate.latitude, let long = locationManager.location?.coordinate.longitude {
            userGeoLat = lat
            userGeoLong = long
        }
    }
    
}

//MARK:- Make Button
extension MapViewController {
    
    func makeButton() {
        
        let btn: UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        btn.frame = CGRect(x: width * 0.75, y: height * 0.75, width: 60, height: 60)
        btn.layer.cornerRadius = 30.0
        btn.backgroundColor = UIColor(named: "Green")
        btn.setImage(image, for: .normal)
        btn.tintColor = .darkGray
        btn.addTarget(self, action: #selector(albumButtonPressed(_:)), for: .touchUpInside)
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.view.addSubview(btn)
    }
    
    func makeLabel() {
        // ラベルの生成
        postedStationLabel.frame = CGRect(x: 10, y: height * 0.15, width: 180, height: 40) // 位置とサイズの指定
        postedStationLabel.textAlignment = NSTextAlignment.center // 横揃えの設定
        postedStationLabel.textColor = UIColor.black // テキストカラーの設定
        postedStationLabel.font = UIFont(name: "HiraKakuProN-W6", size: 17) // フォントの設定
        postedStationLabel.backgroundColor = UIColor(named: K.BrandColors.WhiteGreen)
        postedStationLabel.numberOfLines = 0
        postedStationLabel.layer.cornerRadius = 20.0
        postedStationLabel.clipsToBounds = true
        self.view.addSubview(postedStationLabel)
        
        postedimageLabel.frame = CGRect(x: 10, y: height * 0.2 + 20, width: 150, height: 40) // 位置とサイズの指定
        postedimageLabel.textAlignment = NSTextAlignment.center // 横揃えの設定
        postedimageLabel.textColor = UIColor.black // テキストカラーの設定
        postedimageLabel.font = UIFont(name: "HiraKakuProN-W6", size: 17) // フォントの設定
        postedimageLabel.backgroundColor = UIColor(named: K.BrandColors.WhiteGreen)
        postedimageLabel.numberOfLines = 0
        postedimageLabel.layer.cornerRadius = 20.0
        postedimageLabel.clipsToBounds = true
        self.view.addSubview(postedimageLabel)
    }
    
}

//MARK:- getUserdata
extension MapViewController {
    
    func getUserName() {
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid
            userdb.whereField("uid", isEqualTo: uid).getDocuments{ (snapshot, error) in
                
                if let error = error {
                    fatalError("failed1:\(error)")
                }else{

                    for snap in snapshot!.documents {
                        self.userName = snap.data()["userName"] as! String
                    }
                    self.getUserPostedStation()
                }
            }
            
        }
        
        if UserDefaults.standard.object(forKey: "noLogin") as! Bool{
            self.postedimageLabel.text = "写真 : 0枚"
            self.postedStationLabel.text = "お出かけ : 0駅"
            makeMapMaker()
        }
    }
    
    func getUserPostedStation() {
        if let uid = Auth.auth().currentUser?.uid {
            userdb.document(uid).getDocument { (snap, error) in
                if let error = error {
                    print(error)
                }else{

                    self.userPostedStation = snap?.data()!["posts"] as? [String] ?? []
                    self.getUserPostedImage()
                }
            }
        }
    }
    
    func getUserPostedImage() {
        
        postdb.whereField("userName", isEqualTo: userName).getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            }else{
                
                
                DispatchQueue.main.async {
                    self.postedimageLabel.text = "写真 : \(snapshot!.documents.count)枚"
                    self.postedStationLabel.text = "お出かけ : \(self.userPostedStation.count)駅"
                }
                self.makeMapMaker()
            }
        }
        
    }
    
}
