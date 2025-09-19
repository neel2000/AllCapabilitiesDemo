//
//  WirelessAccessoryConfigurationVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 17/09/25.
//

import UIKit
import ExternalAccessory

class WirelessAccessoryConfigurationVC: UIViewController, EAWiFiUnconfiguredAccessoryBrowserDelegate {

    private var browser: EAWiFiUnconfiguredAccessoryBrowser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize browser
        
    }
    
    @IBAction func btnStartBrowsingAction(_ sender: Any) {
        self.startBrowsing()
    }
    
    func startBrowsing() {
        // Use NSPredicate for filtering accessories (optional)
        let predicate = NSPredicate { (accessory, _) -> Bool in
            guard let accessory = accessory as? EAWiFiUnconfiguredAccessory else { return false }
            // Filter by accessory properties, e.g., name
            return accessory.name.contains("MyAccessory")
        }
        browser = EAWiFiUnconfiguredAccessoryBrowser(delegate: self, queue: .main)
        browser?.startSearchingForUnconfiguredAccessories(matching: nil)
    }
    
    // MARK: - EAWiFiUnconfiguredAccessoryBrowserDelegate Methods
    func accessoryBrowser(_ browser: EAWiFiUnconfiguredAccessoryBrowser, didUpdate state: EAWiFiUnconfiguredAccessoryBrowserState) {
        switch state {
        case .wiFiUnavailable:
            print("Wi-Fi available, searching for accessories")
        case .stopped:
            print("Browser stopped")
        default:
            print("Other state: \(state)")
        }
    }
    
    func accessoryBrowser(_ browser: EAWiFiUnconfiguredAccessoryBrowser, didFindUnconfiguredAccessories accessories: Set<EAWiFiUnconfiguredAccessory>) {
        guard let accessory = accessories.first else { return }
        print("Found accessory: \(accessory.name)")
        // Configure the accessory (system presents UI automatically)
        browser.configureAccessory(accessory, withConfigurationUIOn: self)
    }
    
    func accessoryBrowser(_ browser: EAWiFiUnconfiguredAccessoryBrowser, didRemoveUnconfiguredAccessories accessories: Set<EAWiFiUnconfiguredAccessory>) {
        print("Removed accessories: \(accessories.map { $0.name })")
    }
    
    func accessoryBrowser(_ browser: EAWiFiUnconfiguredAccessoryBrowser, didFinishConfiguringAccessory accessory: EAWiFiUnconfiguredAccessory, with status: EAWiFiUnconfiguredAccessoryConfigurationStatus) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop browsing when view disappears
        browser?.stopSearchingForUnconfiguredAccessories()
    }
}
