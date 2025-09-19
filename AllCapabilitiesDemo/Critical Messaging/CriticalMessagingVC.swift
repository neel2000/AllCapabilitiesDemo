//
//  CriticalMessagingVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 16/09/25.
//

import UIKit

class CriticalMessagingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            
            The Critical Messaging capability allows your app to send critical alerts that bypass the device’s Do Not Disturb and Silent Mode settings. These alerts are meant only for situations where immediate user attention is essential.

            🔑 Key Features

                • Deliver notifications with sound and vibration even if the device is muted.

                • Bypass Do Not Disturb and Focus modes.

                • Ensures urgent messages reach the user instantly.

            📌 Common Use Cases

                • Health & safety apps: Emergency alerts, medical monitoring, fall detection.

                • Security apps: Intrusion alerts, fire alarms, or safety threats.

                • Government/emergency services apps: Natural disaster warnings or urgent safety info.

                • Enterprise apps: Critical system failures or urgent incident notifications.

            ⚠️ Important Considerations

                • Requires a special entitlement from Apple (granted only for approved apps).

                • Overuse or misuse can result in App Store rejection.

                • Must clearly explain to users why your app needs critical alerts.

                • Users can still disable critical alerts in Settings → Notifications.
            
            
            Example:
            
                let content = UNMutableNotificationContent()
                content.title = "Emergency Alert!"
                content.body = "This is a critical message demo. Evacuate if needed."
                content.sound = .defaultCritical // Critical sound (requires entitlement)
                content.badge = 1
                content.interruptionLevel = .critical // Key for critical behavior
            
                • There are four types of interruption level thatdetermine how notifications are presented to users, balancing urgency and user experience. These levels—introduced in iOS 15 and refined in later versions—control whether notifications bypass Do Not Disturb, Focus modes, or play sounds despite device settings. They are part of the UNNotificationContent property interruptionLevel in the UserNotifications framework.
            
                1. Active Interruption Level
                    
                    Definition: The default level for standard notifications. Active notifications are meant to grab immediate attention but respect Do Not Disturb and Focus settings.
                 
                    Behavior:

                        • Delivered immediately unless suppressed by Do Not Disturb or Focus.
                        • Plays sound and vibrates (if configured) when the device is not in silent mode.
                        • Appears on the lock screen and in Notification Center with banners (if enabled).
                        • Does not override silent mode or Focus filters.

            
                    Use Case: General app updates, like a new message in a chat or a friend posting in app's community timeline. For example, "Someone nearby commented on your event post!"
            
            
                2. Passive Interruption Level

                    Definition: Low-priority notifications that don’t demand immediate attention and are less intrusive.
                
                    Behavior:

                        • Delivered quietly without sound or vibration, even if the device is not in silent mode.
                        • Appears in Notification Center but not as banners unless explicitly enabled.
                        • Suppressed by Do Not Disturb and Focus modes.
                        • Ideal for background updates that don’t need user interaction.
                        

                    Use Case: Background syncs or non-urgent updates, like "Your club’s weekly summary is ready" or "New photos added to a local event you follow" in app.
            
            
                3. Time-Sensitive Interruption Level

                    Definition: Notifications that are important and time-critical but don’t require special entitlements. They can break through Focus modes but not Do Not Disturb’s full suppression.
                    
                    Behavior:

                        • Delivered immediately, bypassing most Focus mode restrictions (if user allows).
                        • Plays sound and vibrates (if configured) unless the device is fully muted.
                        • Appears on lock screen, Notification Center, and as banners.
                        • Requires the .timeSensitive authorization option when requesting permission.
                        

                    Use Case: Urgent but non-emergency alerts, like "The concert you’re attending starts in 10 minutes!" or "A nearby user just posted a live event update".
            
            
                4. Critical Interruption Level

                    Definition: High-priority notifications for emergencies, requiring a special Apple entitlement (com.apple.developer.usernotifications.critical-alerts). They override all restrictions, including Do Not Disturb and silent mode.
                    
                    Behavior:

                        • Delivered immediately, bypassing Do Not Disturb, Focus, and silent mode.
                        • Plays a distinct critical sound (.defaultCritical or custom) and vibrates, even on muted devices.
                        • Appears on lock screen, Notification Center, and as banners.
                        • Requires Apple’s approval for the entitlement, reserved for life-critical apps (e.g., medical or safety).


                    Use Case: Rare in social apps for extreme scenarios, like “Emergency alert: Evacuate the event area due to severe weather.” Likely not applicable unless app expands into safety-critical features.
                
            """
        self.navigationController?.pushViewController(vc, animated:true)
        
    }
    
}
