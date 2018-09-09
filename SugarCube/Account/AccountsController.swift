//
//  AccountsController.swift
//  SugarCube
//
//  Created by Carol Chen on 2018-09-08.
//  Copyright © 2018 Jesse Friedman. All rights reserved.
//

import UIKit
import StitchCore

class AccountsController: UIViewController {
    var isLoggedIn = false // TEMP

    var stitchClient: StitchAppClient!
    static var provider: StitchProviderType?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Stitch.defaultAppClient!.auth.isLoggedIn) {
            EMAIL_INPUT.isHidden = true
            PASSWORD_INPUT.isHidden = true
            PASSWORD_CONFIRM_INPUT.isHidden = true
            LOGIN_BUTTON.isHidden = true
            REGISTER_OPEN_BUTTON.isHidden = true
            REGISTER_BUTTON.isHidden = true
            LOGIN_OPEN_BUTTON.isHidden = true
            LOGOUT_BUTTON.isHidden = false
        } else {
            EMAIL_INPUT.isHidden = false
            PASSWORD_INPUT.isHidden = false
            PASSWORD_CONFIRM_INPUT.isHidden = true
            LOGIN_BUTTON.isHidden = false
            REGISTER_OPEN_BUTTON.isHidden = false
            REGISTER_BUTTON.isHidden = true
            LOGIN_OPEN_BUTTON.isHidden = true
            LOGOUT_BUTTON.isHidden = true
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var EMAIL_INPUT: UIStackView!
    @IBOutlet weak var PASSWORD_INPUT: UIStackView!
    @IBOutlet weak var PASSWORD_CONFIRM_INPUT: UIStackView!
    
    @IBOutlet weak var EMAIL_FIELD: UITextField!
    @IBOutlet weak var PASSWORD_FIELD: UITextField!
    @IBOutlet weak var PASSWORD_CONFIRM_FIELD: UITextField!

    @IBOutlet weak var LOGIN_BUTTON: UIButton!
    @IBAction func LOGIN_BUTTON(_ sender: Any) {
        let email = EMAIL_FIELD.text!
        let password = PASSWORD_FIELD.text!
        let credential = UserPasswordCredential.init(withUsername:email,
                                                     withPassword:password)
        Stitch.defaultAppClient!.auth.login(withCredential: credential) { result in
            switch result {
            case .success:
                print("Yeeeetus")
            case .failure(let error):
                print(error)
            }
        }
        if (Stitch.defaultAppClient!.auth.isLoggedIn) {
            EMAIL_INPUT.isHidden = true
            PASSWORD_INPUT.isHidden = true
            PASSWORD_CONFIRM_INPUT.isHidden = true
            LOGIN_BUTTON.isHidden = true
            REGISTER_OPEN_BUTTON.isHidden = true
            REGISTER_BUTTON.isHidden = true
            LOGIN_OPEN_BUTTON.isHidden = true
            LOGOUT_BUTTON.isHidden = false
        }
    }
    @IBOutlet weak var LOGIN_OPEN_BUTTON: UIButton!
    @IBAction func LOGIN_OPEN_BUTTON(_ sender: Any) {
        PASSWORD_CONFIRM_INPUT.isHidden = true
        LOGIN_BUTTON.isHidden = false
        REGISTER_OPEN_BUTTON.isHidden = false
        REGISTER_BUTTON.isHidden = true
        LOGIN_OPEN_BUTTON.isHidden = true
    }
    @IBOutlet weak var LOGOUT_BUTTON: UIButton!
    @IBAction func LOGOUT_BUTTON(_ sender: Any) {
        isLoggedIn = false // TEMP
        EMAIL_INPUT.isHidden = false
        PASSWORD_INPUT.isHidden = false
        PASSWORD_CONFIRM_INPUT.isHidden = true
        LOGIN_BUTTON.isHidden = false
        REGISTER_OPEN_BUTTON.isHidden = false
        REGISTER_BUTTON.isHidden = true
        LOGIN_OPEN_BUTTON.isHidden = true
        LOGOUT_BUTTON.isHidden = true
    }
    
    
    @IBOutlet weak var REGISTER_OPEN_BUTTON: UIButton!
    @IBAction func REGISTER_OPEN_BUTTON(_ sender: Any) {
        PASSWORD_CONFIRM_INPUT.isHidden = false
        LOGIN_BUTTON.isHidden = true
        REGISTER_OPEN_BUTTON.isHidden = true
        REGISTER_BUTTON.isHidden = false
        LOGIN_OPEN_BUTTON.isHidden = false
    }
    @IBOutlet weak var REGISTER_BUTTON: UIButton!
    @IBAction func REGISTER_BUTTON(_ sender: Any) {
        let email = EMAIL_FIELD.text!
        let password = PASSWORD_FIELD.text!
        let password_confirm = PASSWORD_CONFIRM_FIELD.text!
        if (password == password_confirm) {
            Stitch.defaultAppClient!.auth.providerClient(
                fromFactory: userPasswordClientFactory).register(withEmail:email, withPassword:password) { result in
                    switch result {
                    case .success:
                        self.EMAIL_INPUT.isHidden = false
                        self.PASSWORD_INPUT.isHidden = false
                        self.PASSWORD_CONFIRM_INPUT.isHidden = true
                        self.LOGIN_BUTTON.isHidden = false
                        self.REGISTER_OPEN_BUTTON.isHidden = false
                        self.REGISTER_BUTTON.isHidden = true
                        self.LOGIN_OPEN_BUTTON.isHidden = true
                        self.LOGOUT_BUTTON.isHidden = true
                    case .failure(let error):
                        print(error)
                    }
            }
            
        } else {
            PASSWORD_FIELD.text = ""
            PASSWORD_CONFIRM_FIELD.text = ""
        }
        
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
