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
