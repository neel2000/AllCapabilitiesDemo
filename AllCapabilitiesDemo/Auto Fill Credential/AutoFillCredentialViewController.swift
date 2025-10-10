//
//  AutoFillCredentialViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 12/12/24.
//

import UIKit
import AuthenticationServices

class AutoFillCredentialViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        saveAutofillCredential()
        usernameTextField.textContentType = .username
        usernameTextField.keyboardType = .emailAddress
        
         passwordTextField.textContentType = .password
        
//        usernameTextField.autocorrectionType = .no
//        usernameTextField.autocapitalizationType = .none
//        passwordTextField.isSecureTextEntry = true
    }

    @IBAction func saveCredential(_ sender: UIButton) {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
              !username.isEmpty, !password.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let success = KeychainManager.shared.saveCredential(service: "kardder.com", account: username, password: password)
        if success {
            print("Credential saved successfully")
            let alert = UIAlertController(title: "Success", message: "Credential saved", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            print("Failed to save credential. Check console for details.")
            let alert = UIAlertController(title: "Error", message: "Failed to save credential", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func saveAutofillCredential() {
        let serviceIdentifier = ASCredentialServiceIdentifier(identifier: "kardder.com", type: .domain)
        let credentialIdentity = ASPasswordCredentialIdentity(serviceIdentifier: serviceIdentifier, user: "demo@kardder.com", recordIdentifier: UUID().uuidString)
        
        
        ASCredentialIdentityStore.shared.getState({ state in
            if state.isEnabled {
                ASCredentialIdentityStore.shared.getState { state in
                  if state.isEnabled {
                    ASCredentialIdentityStore.shared.saveCredentialIdentities([credentialIdentity]) { success, error in
                      if success {
                        print("Saved for autofill")
                      } else {
                        print("Error: \(String(describing: error?.localizedDescription))")
                      }
                    }
                  } else {
                    print("Autofill is not enabled")
                  }
                }
            }
        })
    }
    
}
