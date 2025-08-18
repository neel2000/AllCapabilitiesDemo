//
//  ViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 10/12/24.
//

//iCloud
//Enables the app to use iCloud storage and services, including key-value storage, CloudKit, and document storage.

import UIKit
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import SpriteKit
import UserNotifications

@available(iOS 16.0, *)
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var btnCapiCloud: UIButton!
    
    
    @IBOutlet weak var mview: UIView!
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example Usage
        if let ipAddress = getIPAddress() {
            print("Device IP Address: \(ipAddress)")
        } else {
            print("Unable to retrieve IP address")
        }
        
        // Usage Example
       fetchWiFiInfo()
        
    }
    
    func fetchWiFiInfo() {
         // Request location permissions (required since iOS 13)
         locationManager.delegate = self
         locationManager.requestWhenInUseAuthorization()
     }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
                print("No Wi-Fi interfaces found")
                return
            }
            
            for interface in interfaces {
                if let networkInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: AnyObject] {
                    if let ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String {
                        print("SSID: \(ssid)")
                    }
                    if let bssid = networkInfo[kCNNetworkInfoKeyBSSID as String] as? String {
                        print("BSSID (Router MAC Address): \(bssid)")
                    }
                } else {
                    print("No Wi-Fi network information available")
                }
            }
        } else {
            print("Location permission is not granted")
        }
    }
    
    func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil

        // Retrieve the current interfaces
        if getifaddrs(&ifaddr) == 0 {
            // Loop through interfaces
            var ptr = ifaddr
            while ptr != nil {
                guard let interface = ptr?.pointee else { break }
                let addrFamily = interface.ifa_addr.pointee.sa_family

                // Check for IPv4
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    // Convert interface name to String
                    let name = String(cString: interface.ifa_name)

                    // Look for Wi-Fi interface (en0)
                    if name == "en0" {
                        // Convert address to string
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(
                            interface.ifa_addr,
                            socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            socklen_t(0),
                            NI_NUMERICHOST
                        )
                        address = String(cString: hostname)
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return address
    }

    @IBAction func btnCapiCloudAction(_ sender: Any) {
        let vc = ICloudTypeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnAccessWiFiInfoAction(_ sender: Any) {
        let vc = AccessWiFiInfoViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnAutoFillCredentialProviderAction(_ sender: Any) {
        let vc = AutoFillCredentialViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnApplePayAction(_ sender: Any) {
        let vc = ApplePayVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnTimeSensitiveNotificationAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.scheduleNotification()
        }
    }
    
    @IBAction func btnWeatherKitAction(_ sender: Any) {
//        let vc = WeatherKitViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
        if #available(iOS 16.0, *) {
            let weatherView = WeatherView()
            let hostingVC = UIHostingController(rootView: weatherView)
            navigationController?.pushViewController(hostingVC, animated: true)
        } else {
            showAlert(message: "Weatherkit is available on iOS 16.0 and later")
        }
    }
    
    @IBAction func btnHealthKitAction(_ sender: Any) {
        if #available(iOS 16.0, *) {
            let healthView = HealthSummaryView()
            let vc = UIHostingController(rootView: healthView)
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            showAlert(message: "Healthkit is available on iOS 16.0 and later")
        }
    }
    
    @IBAction func btnSignApple(_ sender: Any) {
        let vc = AppleLoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnAppGroupsAction(_ sender: Any) {
        let vc = AppGroupsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnDataProtectionAction(_ sender: Any) {
        let vc = DataProtectionVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnDefaultCallingAppAction(_ sender: Any) {
        let vc = CallViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnDefaultMessagingAppAction(_ sender: Any) {
        let vc = DefaultMessagingAppVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHeadPoseAction(_ sender: Any) {
        let vc = HeadPoseVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSiriAction(_ sender: Any) {
        let vc = SiriVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn5GNetworkSliceAction(_ sender: Any) {
        let vc = FiveGNetworkSliceVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSensitiveContentAnalysisAction(_ sender: Any) {
        if #available(iOS 17.0, *) {
            let vc = SensitiveContentVC()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            // Fallback on earlier versions
            showAlert(message: "Sensitive Content Analysis is not supported on this device.")
        }
    }
    
    @IBAction func btnSpatialAudioAction(_ sender: Any) {
       // if #available(iOS 16.0, *) {
            let vc = SpatialAudioProfileVC()
            self.navigationController?.pushViewController(vc, animated: true)
//        } else {
//            // Fallback on earlier versions
//            showAlert(message: "Spatial Audio Profile is not supported on this device.")
//        }
    }
    
    @IBAction func btnNFCTagAction(_ sender: Any) {
        let vc = NFCReadWriteViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnDriverkitFamiliyMIDIAction(_ sender: Any) {
        let vc = DriverkitFamiliyMIDIVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSimInsertedForWirelessCarriersAction(_ sender: Any) {
        let vc = SIMInsertedforWirelessCarriersVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time Sensitive Alert"
        content.body = "This alert can break through Focus modes if enabled."
        content.sound = .default
        content.interruptionLevel = .timeSensitive
      
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TimeSensitiveDemo",
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error:", error.localizedDescription)
            } else {
                print("✅ Time Sensitive Notification scheduled.")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

@available(iOS 16.0, *)
struct MyViewControllerPreview: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
        return vc // Replace with your UIViewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // No updates needed for this example
    }
}

@available(iOS 16.0, *)
struct MyViewController_Previews: PreviewProvider {
    static var previews: some View {
        MyViewControllerPreview()
    }
}
