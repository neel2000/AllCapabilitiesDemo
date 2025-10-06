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
        let vc = TimeSensitiveNotiVC()
        self.navigationController?.pushViewController(vc, animated: true)
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
        if #available(iOS 18.2, *) {
            let vc = CallViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert(message: "Default Calling app is available on iOS 18.2 and later")
        }
    }
    
    @IBAction func btnDefaultMessagingAppAction(_ sender: Any) {
        let vc = DefaultMessagingAppVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHeadPoseAction(_ sender: Any) {
        let vc = HeadPoseVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCriticalMessagingAction(_ sender: Any) {
        let vc = CriticalMessagingVC()
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
            showAlert(message: "Sensitive Content Analysis is available on iOS 17.0 and later")
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
    
    @IBAction func btnIncreadedDebuggingMemoryLimitAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
        
        The “Increased Debugging Memory Limit” capability in iOS is a developer-focused feature that allows your app to use more memory than usual when running in a debugging session. This is mainly useful for apps that handle large data sets, high-resolution images, or intensive computations during development.

        Here’s a concise breakdown:

        🔑 What It Is

        Normally, iOS imposes memory limits on apps to prevent a single app from consuming too much system memory, which could affect stability. When you enable Increased Debugging Memory Limit:

            • The system raises the memory cap while debugging.

            • Your app can load larger resources (like big datasets or complex scenes) without crashing in the debugger.

            • It does not affect the memory limit for production builds on users’ devices.

        📌 Use Cases

            • Loading high-resolution images or videos for testing.

            • Processing large data arrays or JSON datasets.

            • Debugging memory-heavy algorithms like AI models, 3D graphics, or AR scenes.

        📱 How It Works

            • Only available when the app is run from Xcode in debug mode.

            • The system automatically adjusts the memory limit — no runtime code changes are required.

            • You don’t enable it in code, you enable it as an App Capability in Xcode (or via your scheme).

        ⚠️ Important Notes

            • This capability cannot be used in production; it’s strictly for development.

            • Memory limits in production remain strict to avoid affecting device stability.

            • Helps catch memory-related bugs early without crashing the debugger due to low memory.
        """
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction func btnFontsAction(_ sender: Any) {
        let vc = FontViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnGroupActivities(_ sender: Any) {
        let vc = GroupActivitiesVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMultipathAction(_ sender: Any) {
        let vc = MultipathViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnJournalingSuggestionsAction(_ sender: Any) {
        let vc = JournalingSuggestionsVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMultitaskingCameraAccess(_ sender: Any) {
        let vc = MultitaskingCameraAccessVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHotspotAction(_ sender: Any) {
        let vc = HotspotVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnClassKitAction(_ sender: Any) {
        let vc = ClassKitVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnWirelessAccessoryConfigurationAction(_ sender: Any) {
        let vc = WirelessAccessoryConfigurationVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCommunicationNotificationsAction(_ sender: Any) {
        let vc = CommunicationNotificationsVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnDefaultTransaltionAppAction(_ sender: Any) {
        if #available(iOS 18.4, *) {
            let vc = DefaultTranslationAppVC()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert(message: "Default translation app is available on iOS 18.4 and later")
        }
    }
    
    @IBAction func btnGameCenterAction(_ sender: Any) {
        let vc = GameCenterVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnExtendedVirtualAddressingAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            The Extended Virtual Addressing capability allows apps to use a much larger virtual memory space on supported Apple devices. This is especially useful for apps that handle very large datasets, complex files, or advanced workloads like video editing, 3D modeling, AI/ML, and scientific computing.

            🔹 What It Does

                • Expands the virtual memory address range available to your app.

                • Lets your app load, process, and manage bigger datasets without hitting memory mapping limits.

                • Improves stability and performance for pro-level apps that work with large assets.

            🔑 Why It’s Useful

                • Prevents memory-related crashes in apps that handle huge files or advanced workflows.

                • Enables high-performance apps (CAD, media editing, AI, simulations) to run more smoothly.

                • Future-proofs apps for devices with higher RAM capacity.

            📌 Requirements

                • Enable Extended Virtual Addressing in Xcode → Signing & Capabilities.

                • Works only on supported devices (e.g., newer iPad Pro and Apple silicon devices with large RAM).

                • No special Swift code is required — iOS automatically manages the extended memory once the capability is turned on.
            
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnDefaultNavigtionAppAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            The Default Navigation App capability allows third-party apps to register themselves as a user’s preferred navigation app, similar to how users can choose a default browser or mail app. With this capability, your app can replace Apple Maps as the system-wide navigation choice.

            🔹 What It Does

                    • System Integration – Lets your app act as the default navigation app across iOS.

                    • Deep Linking from Other Apps – When another app (like Safari, Mail, or Messages) tries to open a navigation route, iOS can launch your app instead of Apple Maps.

                    • Consistent User Experience – Ensures all directions and navigation requests go through the app the user prefers.

                    •  Custom Features – Third-party navigation apps (Google Maps, Waze, etc.) can offer traffic alerts, EV charging stops, or specialized routing.

            🔑 Why It’s Useful

                    • Provides users freedom to choose their favorite navigation app.

                    • Helps developers compete directly with Apple Maps.

                    • Supports apps that specialize in delivery, logistics, ride-hailing, or niche travel experiences.

            📌 Requirements

                    • Apple Developer Program membership.

                    • Enable Default Navigation App capability in Xcode → Signing & Capabilities.

                    • App must implement support for handling navigation intents (via Intents framework and URL schemes like maps://).

                    • Apple must approve the app’s entitlement — not all apps get it automatically.
                
            
            ⚡ Note:
            As of iOS 18, Apple has not fully exposed a Settings UI where users can easily pick a default navigation app (like they can for Mail or Browser). This capability exists for entitlements and is mainly used by big navigation apps (Google Maps, Waze) through Apple approval.
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHomeKitAction(_ sender: Any) {
        let vc = HomeKitVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFamilyControlAction(_ sender: Any) {
        let vc = UIHostingController(rootView: FamilyControlVC())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMessageCollaboration(_ sender: Any) {
        let vc  = MessageCollaborationVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSharedWithYouAction(_ sender: Any) {
        if #available(iOS 16.0, *) {
            let vc = SharedWithYouVC()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert(message: "Shared with you is available on iOS 16.0 and later")
        }
    }
    
    @IBAction func btnShallowDepthAction(_ sender: Any) {
        let vc = ShallowDepthPressureVC()
        self.navigationController?.pushViewController(vc, animated: true)
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
