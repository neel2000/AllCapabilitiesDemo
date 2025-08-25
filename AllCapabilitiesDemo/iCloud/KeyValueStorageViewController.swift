//
//  KeyValueStorageViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 20/08/25.
//

import UIKit

class KeyValueStorageViewController: UIViewController {
    
    private let toggleSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDarkModeStatus()
        
        // Listen for iCloud changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudKeyValueStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(statusLabel)
        view.addSubview(toggleSwitch)
        
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            toggleSwitch.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            toggleSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
     
    private func loadDarkModeStatus() {
        DispatchQueue.main.async {
            let darkMode = NSUbiquitousKeyValueStore.default.bool(forKey: "darkMode")
            self.toggleSwitch.isOn = darkMode
            self.applyDarkMode(darkMode)
        }
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let isDarkMode = sender.isOn
        saveDarkModeStatus(isDarkMode)
        applyDarkMode(isDarkMode)
    }
    
    private func saveDarkModeStatus(_ isDark: Bool) {
        let store = NSUbiquitousKeyValueStore.default
        store.set(isDark, forKey: "darkMode")
        store.synchronize()
    }
    
    private func applyDarkMode(_ isDark: Bool) {
        overrideUserInterfaceStyle = isDark ? .dark : .light
        statusLabel.text = isDark ? "🌙 Dark Mode ON" : "☀️ Light Mode OFF"
    }
    
    @objc private func iCloudKeyValueStoreDidChange(_ notification: Notification) {
        loadDarkModeStatus()
    }
}
