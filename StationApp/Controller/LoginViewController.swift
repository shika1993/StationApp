//
//  RoginViewController.swift
//  StationApp
//
//  Created by 鹿内翔平 on 2020/08/15.
//  Copyright © 2020 鹿内翔平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD

class LoginViewController: UIViewController{

    @IBOutlet weak var mailtextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var roginButton: UIButton!
    @IBOutlet weak var keepLoginSwitch: UISwitch!
    
    let auth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = false
        self.title = K.title
        roginButton.layer.cornerRadius = 10.0
        roginButton.layer.shadowColor = UIColor.black.cgColor
        roginButton.layer.shadowOpacity = 0.4
        roginButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        mailtextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func roginButtonPressed(_ sender: UIButton) {
        
        HUD.show(.progress)
        guard let mail = mailtextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        var user = User(mail: mail, password: password)
        user.finishLoginUserdelegate = self
        user.login()
    }
    
}

//MARK:-finishLoginUserdelegate
extension LoginViewController: finishLoginUser {
    
    func finishLogin() {
        
        UserDefaults.standard.setValue(true, forKey: "isLogin")
        if keepLoginSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "keepLogin")
        }else{
            UserDefaults.standard.setValue(false, forKey: "keepLogin")
        }
        performSegue(withIdentifier: K.Segue.tomap, sender: nil)
    }
}
