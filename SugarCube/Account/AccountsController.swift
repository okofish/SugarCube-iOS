//
//  AccountsController.swift
//  SugarCube
//
//  Created by Carol Chen on 2018-09-08.
//  Copyright © 2018 Jesse Friedman. All rights reserved.
//

import UIKit

class AccountsController: UIViewController {
    var isLoggedIn = false // TEMP

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (isLoggedIn) {
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
        isLoggedIn = true // TEMP
        EMAIL_INPUT.isHidden = true
        PASSWORD_INPUT.isHidden = true
        PASSWORD_CONFIRM_INPUT.isHidden = true
        LOGIN_BUTTON.isHidden = true
        REGISTER_OPEN_BUTTON.isHidden = true
        REGISTER_BUTTON.isHidden = true
        LOGIN_OPEN_BUTTON.isHidden = true
        LOGOUT_BUTTON.isHidden = false
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
        EMAIL_INPUT.isHidden = false
        PASSWORD_INPUT.isHidden = false
        PASSWORD_CONFIRM_INPUT.isHidden = true
        LOGIN_BUTTON.isHidden = false
        REGISTER_OPEN_BUTTON.isHidden = false
        REGISTER_BUTTON.isHidden = true
        LOGIN_OPEN_BUTTON.isHidden = true
        LOGOUT_BUTTON.isHidden = true
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
