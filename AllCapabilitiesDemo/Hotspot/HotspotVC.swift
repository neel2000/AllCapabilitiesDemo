//
//  HotspotVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 26/08/25.
//

import UIKit
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

class HotspotVC: UIViewController {
    
    private let ssidTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter SSID"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let connectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Connect WiFi", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(connectToWifi), for: .touchUpInside)
        return btn
    }()
    
    private let statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Not Connected"
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = .darkGray
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "WiFi Demo"
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(ssidTextField)
        view.addSubview(passwordTextField)
        view.addSubview(connectButton)
        view.addSubview(statusLabel)
        
        ssidTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ssidTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            ssidTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ssidTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ssidTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: ssidTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: ssidTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: ssidTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            connectButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.widthAnchor.constraint(equalToConstant: 180),
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            
            statusLabel.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 40),
            statusLabel.leadingAnchor.constraint(equalTo: ssidTextField.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: ssidTextField.trailingAnchor)
        ])
    }
    
    @objc private func connectToWifi() {
        guard let ssid = ssidTextField.text, !ssid.isEmpty else {
            statusLabel.text = "⚠️ Please enter SSID"
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            statusLabel.text = "⚠️ Please enter password"
            return
        }
        
        // Validate SSID and password format
        let trimmedSSID = ssid.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedSSID.isEmpty {
            statusLabel.text = "⚠️ Invalid SSID"
            return
        }
        
        // Remove any existing configuration for the SSID to avoid conflicts
        //NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: trimmedSSID)
        
        let configuration = NEHotspotConfiguration(ssid: trimmedSSID, passphrase: trimmedPassword, isWEP: false)
        configuration.joinOnce = false
        
        statusLabel.text = "⏳ Connecting to \(trimmedSSID)..."
        
        NEHotspotConfigurationManager.shared.apply(configuration) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    switch (error.domain, error.code) {
                    case (NEHotspotConfigurationErrorDomain, NEHotspotConfigurationError.alreadyAssociated.rawValue):
                        self?.statusLabel.text = "✅ Already connected to \(trimmedSSID)"
                    case (NEHotspotConfigurationErrorDomain, NEHotspotConfigurationError.invalidSSID.rawValue):
                        self?.statusLabel.text = "❌ Invalid SSID"
                    case (NEHotspotConfigurationErrorDomain, NEHotspotConfigurationError.invalidWPAPassphrase.rawValue):
                        self?.statusLabel.text = "❌ Invalid password"
                    case (NEHotspotConfigurationErrorDomain, NEHotspotConfigurationError.userDenied.rawValue):
                        self?.statusLabel.text = "❌ Connection denied by user"
                    default:
                        self?.statusLabel.text = "❌ Failed: \(error.localizedDescription)"
                    }
                } else {
                    // Verify actual connection status
                    self?.verifyWifiConnection(ssid: trimmedSSID)
                }
            }
        }
    }
    
    private func verifyWifiConnection(ssid: String) {
        // Use CaptiveNetwork to check the current Wi-Fi SSID
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    if let currentSSID = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String {
                        if currentSSID == ssid {
                            statusLabel.text = "🎉 Successfully connected to \(ssid)"
                        } else {
                            statusLabel.text = "❌ Connected to wrong network: \(currentSSID)"
                        }
                        return
                    }
                }
            }
        }
        statusLabel.text = "❌ Failed to verify connection to \(ssid)"
    }
}
