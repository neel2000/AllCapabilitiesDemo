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
