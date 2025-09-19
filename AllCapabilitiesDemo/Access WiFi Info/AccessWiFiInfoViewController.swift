//
//  AccessWiFiInfoViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 11/12/24.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import SpriteKit

class AccessWiFiInfoViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var lblWiFiName: UILabel!
    @IBOutlet weak var lblWiFiMacAdd: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocationUpdates()
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            This capability allows your app to read limited details about the Wi-Fi network the device is currently connected to.

            🔑 Key Features

                • Retrieve the SSID (network name) and BSSID (access point identifier).

                • Identify whether the connection is through a personal hotspot.

                • Useful for apps that need to confirm a trusted or specific Wi-Fi connection.

            📌 Common Use Cases

                • Enterprise apps verifying connection to a secure corporate Wi-Fi.

                • Apps that provide network diagnostics or troubleshooting.

                • IoT/Smart-home apps ensuring the device is on the same network as the accessory.

            ⚠️ Important Considerations

                • Requires user permission and proper entitlement from Apple.

                • Doesn’t provide signal strength or browsing data (for privacy reasons).

                • If permission isn’t granted, your app may only get limited or no Wi-Fi info.
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func startLocationUpdates() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled(){
                self.locationManager.delegate = self
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
                self.locationManager.startMonitoringSignificantLocationChanges()
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.pausesLocationUpdatesAutomatically = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if let wifiInfo = getWiFiInformation() {
                self.lblWiFiName.text = "Wi-Fi name: \(wifiInfo.ssid ?? "")"
                self.lblWiFiMacAdd.text = "Wi-Fi Mac Address: \(wifiInfo.bssid ?? "")"
                print("SSID: \(wifiInfo.ssid ?? "Unknown")")
                print("BSSID: \(wifiInfo.bssid ?? "Unknown")")
            } else {
                self.lblWiFiName.text = "Not connected to Wi-Fi or insufficient permissions."
                self.lblWiFiMacAdd.isHidden = true
                print("Not connected to Wi-Fi or insufficient permissions.")
            }
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location Permission Denied")
            locationManager.stopUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func getWiFiInformation() -> (ssid: String?, bssid: String?)? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        
        for interface in interfaces {
            if let networkInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                let ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String
                let bssid = networkInfo[kCNNetworkInfoKeyBSSID as String] as? String
                return (ssid: ssid, bssid: bssid)
            }
        }
        return nil
    }

}
