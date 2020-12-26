//
//  ViewController.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/14.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import UIKit
import FirebaseAuth
import PKHUD

class FirstViewController: UIViewController, finishLoginUser {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registButton: UIButton!
    @IBOutlet weak var nonLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = K.title
        subtitleLabel.text = K.subtitle
        loginButton.layer.cornerRadius = 10.0
        registButton.layer.cornerRadius = 10.0
        nonLoginButton.layer.cornerRadius = 10.0
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = UIColor(named: K.BrandColors.green)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.4
        loginButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        registButton.layer.shadowColor = UIColor.black.cgColor
        registButton.layer.shadowOpacity = 0.4
        registButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        nonLoginButton.layer.shadowColor = UIColor.black.cgColor
        nonLoginButton.layer.shadowOpacity = 0.4
        nonLoginButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        UserDefaults.standard.setValue(false, forKey: "isLogin")
        UserDefaults.standard.setValue(false, forKey: "noLogin")
        
        if UserDefaults.standard.object(forKey: "keepLogin") as? Bool == true {
            HUD.show(.progress)
            var user = User(mail: UserDefaults.standard.object(forKey: "mail") as! String, password: UserDefaults.standard.object(forKey: "password") as! String)
            user.finishLoginUserdelegate = self
            user.login()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserDefaults.standard.setValue(false, forKey: "noLogin")
        navigationController?.isNavigationBarHidden = true

    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: K.Segue.login, sender: nil)
    }
    
    @IBAction func registButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: K.Segue.regist, sender: nil)
    }
    
    
    @IBAction func noLoginButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.setValue(true, forKey: "noLogin")
        performSegue(withIdentifier: K.Segue.noLogin, sender: nil)
    }
    
    func finishLogin() {
        HUD.flash(.success)
        performSegue(withIdentifier: K.Segue.keepLogin, sender: nil)
    }
    
    
    @IBAction func eulaButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segue.eula, sender: nil)
    }
}

