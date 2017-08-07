//
//  LoginViewController.swift
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    var first: String?
    var last: String?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "createUser" {
//                dismissKeyboard()
                print("To Create User Screen!")
            }
            if identifier == "forgotPassword" {
//                dismissKeyboard()
                print("To Forget Password Screen!")
            }
        }
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
        print("Returned to login screen!")
    }
    
    // MARK: - Facebook Login
    @IBAction func facebookLoginButtonClicked(_ sender: Any) {
        
        // present Facebook login window in app
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil {
                print("Facebook login has failed.")
                return
            }
            
            print("Facebook login was successful.")
        }
        
        // sign in Facebook user to Firebase
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        AuthService.facebookSignIn(controller: self, credential: credentials) { (authUser) in
            guard let authUser = authUser else {
                print("error: FIRUser does not exist")
                return
            }
            
            UserService.show(forUID: authUser.uid) { (user) in
                if let user = user {
                    User.setCurrent(user, writeToUserDefaults: true)
                    let initialViewController = UIStoryboard.initialViewController(for: .main)
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                }
                else {
                    self.first = User.getFacebookFirstName()
                    self.last = User.getFacebookLastName()
                    if let firstName = self.first, let lastName = self.last {
                    UserService.create(authUser, firstName: firstName, lastName: lastName, completion: { (user) in
                        guard let user = user else {
                            return
                        }
                        
                        User.setCurrent(user, writeToUserDefaults: true)
                        let initialViewController = UIStoryboard.initialViewController(for: .main)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                    })
                    }
                }
            }
            
        }
    }
    
    // MARK: - Firebase Login
    @IBAction func loginClicked(_ sender: UIButton) {
        dismissKeyboard()
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
            return
        }
        AuthService.signIn(controller: self, email: email, password: password) { (user) in
            guard let user = user else {
                print("error: FIRUser does not exist!")
                return
            }
            
            UserService.show(forUID: user.uid) { (user) in
                if let user = user {
                    User.setCurrent(user, writeToUserDefaults: true)
                    let initialViewController = UIStoryboard.initialViewController(for: .main)
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                }
                else {
                    print("error: User does not exist!")
                    return
                }
            }
        }
    }
    
    @IBAction func createAccountClicked(_ sender: UIButton) {
        dismissKeyboard()
        performSegue(withIdentifier: "createUser", sender: self)
    }
    
    @IBAction func forgotPasswordClicked(_ sender: UIButton) {
        dismissKeyboard()
        performSegue(withIdentifier: "forgotPassword", sender: self)
    }
}

extension LoginViewController{
    func configureView(){
        applyKeyboardPush()
        applyKeyboardDismisser()
        logInButton.layer.cornerRadius = 20
    }
}
