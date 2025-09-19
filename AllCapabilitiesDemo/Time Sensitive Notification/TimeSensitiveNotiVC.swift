//
//  TimeSensitiveNotiVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 16/09/25.
//

import UIKit

class TimeSensitiveNotiVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnTimeSensitiveNotifiationAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.scheduleNotification()
        }
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            This capability allows your app to deliver notifications that can break through Focus modes (like Do Not Disturb or Sleep) when the notification is considered important and time-critical.

            🔑 Key Features

                • Lets notifications bypass Focus filters so users don’t miss urgent alerts.

                • Designed for high-priority, time-critical events only.

                • Works alongside standard User Notifications framework.

            📌 Common Use Cases

                • Delivery apps: alerting when the driver is arriving.

                • Ride-hailing apps: notifying when the car is outside.

                • Health apps: sending medication reminders or emergency alerts.

                • Banking/security apps: warning about suspicious activity in real-time.

            ⚠️ Important Considerations

                • You must request the Time Sensitive entitlement from Apple.

                • Overusing this can result in App Store rejection or degraded trust.

                • Notifications should truly be urgent; otherwise, use normal notifications.

                • Still respects user preferences (users can turn off Time Sensitive access for your app).
            """
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


}
