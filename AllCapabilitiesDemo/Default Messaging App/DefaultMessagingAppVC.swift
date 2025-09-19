//
//  NewMessaginAppVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 04/08/25.
//

import UIKit

class DefaultMessagingAppVC: UIViewController {

    @IBOutlet weak var tv: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.text = """
        
        On iOS, Apple does not allow changing the default messaging app (unlike Android). iMessage (via the built-in Messages app) remains the system-default for SMS, MMS, and iMessage messages. There is no public API to override or replace the default messaging behavior.
        
        ❌ Limitations
        Here’s what you cannot do:

         • You cannot set a third-party app as the default SMS/MMS/iMessage handler.

         • You cannot intercept or modify outgoing/incoming SMS/iMessages.

         • You cannot auto-send messages in the background without user interaction.
        
        """
    }
    
}
