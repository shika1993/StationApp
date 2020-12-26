//
//  RegistViewController.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/15.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD


class RegistViewController: UIViewController{
   
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registButton: UIButton!
    @IBOutlet weak var keepLoginSwitch: UISwitch!
    @IBOutlet weak var eulaSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        self.title = K.title
        registButton.layer.cornerRadius = 10.0
        registButton.isEnabled = false
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "ユーザー名",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        mailTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func registButtonPressed(_ sender: UIButton) {
        
        HUD.show(.progress)
        guard let userName = usernameTextField.text else {
            return
        }
        guard let mail = mailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        
        var user = User(mail: mail, password: password)
        user.finishCreateUserdelegate = self
        user.createUser(userName: userName)
    }
    
    @IBAction func EULAButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: K.Segue.eula, sender: nil)
    }
    
    @IBAction func eulaSwitchPressed(_ sender: UISwitch) {
        
        if eulaSwitch.isOn {
            registButton.layer.cornerRadius = 10.0
            registButton.layer.shadowColor = UIColor.black.cgColor
            registButton.layer.shadowOpacity = 0.4
            registButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            registButton.isEnabled = true
        }else{
            registButton.layer.cornerRadius = 10.0
            registButton.layer.shadowColor = .none
            registButton.layer.shadowOpacity = 0
            registButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            registButton.isEnabled = false
        }
    }
    
    
    
}

//MARK:- finishCreatedUser
extension RegistViewController:finishCreateUser {
    
    func finishCreateUser() {
        
        UserDefaults.standard.setValue(true, forKey: "isLogin")
        if keepLoginSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "keepLogin")
        }else{
            UserDefaults.standard.setValue(false, forKey: "keepLogin")
        }
        performSegue(withIdentifier: K.Segue.tomap, sender: nil)
    }
}
