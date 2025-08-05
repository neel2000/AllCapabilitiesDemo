//
//  DefaultCallingAppVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 04/08/25.
//

import UIKit

class DefaultCallingAppVC: UIViewController {
    
    private let callHandler = CallHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Default Dialer Demo"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Phone Number Label
        let phoneLabel = UILabel()
        phoneLabel.text = "Call: 9876543210"
        phoneLabel.font = .systemFont(ofSize: 18)
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(phoneLabel)
        
        // Call Button
        let callButton = UIButton(type: .system)
        callButton.setTitle("Simulate Call", for: .normal)
        callButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        callButton.backgroundColor = .systemBlue
        callButton.setTitleColor(.white, for: .normal)
        callButton.layer.cornerRadius = 10
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.addTarget(self, action: #selector(simulateCall), for: .touchUpInside)
        view.addSubview(callButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            
            phoneLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            
            callButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callButton.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 30),
            callButton.widthAnchor.constraint(equalToConstant: 200),
            callButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func simulateCall() {
        let uuid = UUID()
        let phoneNumber = "9876543210"
        callHandler.reportIncomingCall(uuid: uuid, handle: phoneNumber)
    }
    
}

