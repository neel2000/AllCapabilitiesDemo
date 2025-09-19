//
//  MultipathViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 20/08/25.
//

import UIKit

class MultipathViewController: UIViewController {

    @IBOutlet weak var tv: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.text = """
        
        The Multipath capability allows your app to maintain network connections across multiple interfaces (like Wi-Fi and cellular) at the same time, improving reliability and performance.

        🔑 Key Features

            • Use both Wi-Fi and cellular data seamlessly.

            • Automatically switch between networks without interrupting the connection.

            • Improves stability for long-lived connections like VoIP, video calls, or streaming.

            • Built on Apple’s Multipath TCP (MPTCP) technology.

        📌 Common Use Cases

            • VoIP apps: Maintain calls when switching from Wi-Fi to cellular.

            • Video conferencing: Prevent interruptions if Wi-Fi drops.

            • Streaming apps: Keep media playing smoothly during network changes.

            • Enterprise apps: Ensure persistent VPN sessions.

        ⚠️ Important Considerations

            • Requires the Multipath entitlement from Apple (not enabled for all apps).

            • Apple grants access mainly to apps where reliability is critical (e.g., VoIP, enterprise, conferencing).

            • Can slightly increase battery and data usage since multiple interfaces may be active.

            • Must use the Network framework or NSURLSessionConfiguration.multipathServiceType to enable.
        
        private var alamoFireManager: Session = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = APICALL_TIMEOUT
            configuration.timeoutIntervalForResource = APICALL_TIMEOUT
            configuration.multipathServiceType = .handover
            let alamoMgr = Alamofire.Session(configuration: configuration)
            return alamoMgr

        }()
        
        enum MultipathServiceType
        
        case none
            The default service type indicating that Multipath TCP should not be used.
        
        case handover
             A Multipath TCP service that provides seamless handover between Wi-Fi and cellular in order to preserve the connection.
        
        case interactive
             A service whereby Multipath TCP attempts to use the lowest-latency interface.
        
        case aggregate
              A service that aggregates the capacities of other Multipath options in an attempt to increase throughput and minimize latency.
        
        """
    }
  
}
