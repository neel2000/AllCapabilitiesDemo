//
//  CommunicationNotificationsVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 18/09/25.
//

import UIKit

class CommunicationNotificationsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    @IBAction func btnSendCallNotiicationAction(_ sender: Any) {
        NotificationManager.shared.configure()
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            
            The Communication Notifications capability in iOS helps apps deliver notifications for calls and messages that feel just like the iPhone’s built-in Phone or Messages app. This makes communication apps (like WhatsApp, Zoom, or custom call/messaging apps) feel seamless and natural to users.

            ✨ What Is the Communication Notifications Capability?

            Imagine you’re building an app that lets people make voice or video calls or send messages. When someone calls or messages a user, you want the notification to feel like a real phone call or text.

            With this capability, your app can:

                • Show notifications that look like incoming calls or messages, including caller name and preview text.

                • Add interactive buttons like “Accept”, “Decline”, or “Reply”.

                • Use Apple’s system to display a full-screen call interface (just like the Phone app).

                • Integrate with Siri, so users can use voice commands like “Answer the call.”

                • Deliver urgent, time-sensitive alerts, even if the phone is locked or in Do Not Disturb mode.

            🔑 What Does It Do?
            1. Show Call-Like Notifications

                • Incoming calls through your app appear like iPhone calls.

                • Example: “📞 Incoming Call: John Doe (Video Call)” with Accept/Decline options.

            2. Add Interactive Buttons

                • Notifications can include quick-action buttons.

                • Example:

                    • Accept → starts the call.

                    • Decline → dismisses the call.

                    • Reply → sends a quick message response.

            3. Work with the iPhone’s Call System

                    • Uses CallKit, so your app’s calls feel like normal phone calls.

                    • Supports the full-screen call UI instead of just a banner.

                    • Great for apps like Skype, WhatsApp, or FaceTime alternatives.

            4. Support Siri Integration

                • Users can interact with your app using Siri.

                • Example:

                    • “📱 Call John on MyApp.”

                    • “🗣 Answer the call.”

            5. Deliver High-Priority Notifications

                • Notifications show up even when the phone is locked.

                • Can override Do Not Disturb for urgent calls/messages.

                • May include a ringtone-like sound to grab attention.

            ✅ In short: Communication Notifications make third-party communication apps feel like native phone and messaging apps, providing users with a smooth, professional, and reliable experience.
            
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
