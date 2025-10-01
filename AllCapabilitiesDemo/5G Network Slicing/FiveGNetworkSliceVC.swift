//
//  5GNetworkSliceVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 06/08/25.
//

import UIKit

class FiveGNetworkSliceVC: UIViewController {
        
    @IBOutlet weak var tv: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.text = """
        
        Imagine a 5G network like a big highway 🛣️ with lots of cars 🚗 (data) traveling on it.
        5G Network Slicing is like creating special lanes on this highway for different types of cars—each lane is designed to make certain cars go faster, smoother, or safer depending on what they need.

           🏎️ Emergency lane: Super fast and reliable (for critical apps)

           🚚 Delivery lane: Steady and high-capacity (for file transfers)

           🚗 Regular lane: Normal speed (for everyday apps)

        For iPhones and iPads, 5G Network Slicing lets apps use these special "lanes" to work better for tasks like video calls, gaming, or business apps. Each lane (called a slice) is configured by your phone company to give the right speed, reliability, or low latency.

        
        📱 How It Works on iOS

        On iPhone or iPad running iOS 17 or later (more features in iOS 18), Apple allows certain apps to use these network lanes—but only for apps managed by a company’s IT team using MDM (Mobile Device Management).

        1️⃣ Special Apps Get Special Lanes

            • A company app (like a video call app) can be assigned a network slice by the carrier.

            • Example: A slice for video calls might be super fast and lag-free, perfect for crystal-clear calls.

        2️⃣ Set Up by IT Team

            • IT teams use MDM software to tell the iPhone which app should use which slice.

            • Example: “This app uses the ‘low-lag video’ lane.”

        3️⃣ App Uses Slice Automatically

            • All internet traffic from the app goes through its special lane, making it faster and more reliable.

            • Users don’t need to do anything—the iPhone handles it automatically.

        4️⃣ User Notification

            • The first time you open the app, iPhone might show:
                ⚡ “This app is using an enhanced 5G connection.”

            • You can toggle it on/off in Settings → Cellular.

        5️⃣ Works With VPNs

            • Even if you use a VPN 🔒, the app can still use its special lane.

        
        🌟 Example in Everyday Life

        Imagine you use a company video call app for meetings.
        The IT team sets it up to use a dedicated 5G lane 🛣️ that’s super fast and lag-free.
        When you join a video call:

             • Video is crystal clear 🎥

             • Audio doesn’t freeze 🔊

             • Works smoothly even if others are streaming movies 🍿            
        
        All because your app’s data travels on its own dedicated lane.

        
        🛠️ How It’s Used in iOS Apps (Swift)

            • No Code Changes for Most Developers: The network slice is set up via MDM.

            • Special Permission Needed: Apps require an entitlement from Apple.

            • Example Code (Optional Hint for Network Type):
        
        
            var request = URLRequest(url: URL(string: "https://example.com/video")!)
        
            request.networkServiceType = .video // Hint: prioritize video traffic
        
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle response
            }.resume()
            
        
            Note: This doesn’t create a slice but informs the network about your traffic type.
           
        """
        
    }
    
    
}
