//
//  AppleLoginViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 30/07/25.
//

import UIKit
import AuthenticationServices

class AppleLoginViewController: UIViewController {
    
    @IBOutlet weak var sv: UIStackView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var btnAppleLogin: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAuthData()
    }
    
    func setAuthData() {
        let userDefaults = UserDefaults.standard
        tfName.text = userDefaults.string(forKey: "fullName") ?? ""
        tfEmail.text = userDefaults.string(forKey: "email") ?? ""
        
        if tfName.text!.isEmpty && tfEmail.text!.isEmpty {
            sv.isHidden = true
            btnAppleLogin.isHidden = false
            btnLogout.isHidden = true
        } else {
            sv.isHidden = false
            btnAppleLogin.isHidden = true
            btnLogout.isHidden = false
        }
    }

    @IBAction func appleLoginAction(_ sender: Any) {
        self.showActivityIndicator()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func btnLogoutAction(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "fullName")
        UserDefaults.standard.removeObject(forKey: "email")
        setAuthData()
    }
    
}

//MARK: - Apple Login Delegate Methods
extension AppleLoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Handle successful authorization
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Extract user details
            let userId = credential.user
            let firstName = credential.fullName?.givenName ?? ""
            let lastName = credential.fullName?.familyName ?? ""
            let email = credential.email ?? ""

            print("Name : \(firstName) \(lastName) and Email : \(email)")

            let userDefaults = UserDefaults.standard
            userDefaults.set(userId, forKey: "userId")
            userDefaults.set(firstName, forKey: "firstName")
            userDefaults.set(lastName, forKey: "lastName")
            userDefaults.set(email, forKey: "email")
            userDefaults.set(firstName + " " + lastName, forKey: "fullName")
            userDefaults.synchronize() //
            
            setAuthData()
            self.hideActivityIndicator()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.hideActivityIndicator()
        self.showAlert(title: "Error", message: error.localizedDescription)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func showAlert(title: String, message: String, buttonTitle: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alert.addAction(action)

        // Present the alert on the main thread
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    
    // Show Activity Indicator
    func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.tag = 999 // Any unique tag to identify the view later
        activityIndicator.center = self.view.center
        activityIndicator.color = .white
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        
        // Optionally add a semi-transparent background
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.tag = 998
        backgroundView.backgroundColor = .clear//UIColor(white: 0, alpha: 0.3)
        backgroundView.addSubview(activityIndicator)
        
        self.view.addSubview(backgroundView)
    }
    
    // Hide Activity Indicator
    func hideActivityIndicator() {
        if let backgroundView = self.view.viewWithTag(998) {
            backgroundView.removeFromSuperview()
        }
    }
}

