//
//  DataProtectionVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 01/08/25.
//

import UIKit

class DataProtectionVC: UIViewController {
    
    @IBOutlet weak var tv: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.text = """
        In iOS, the Data Protection capability is used to enhance the security of your app’s data stored on disk by controlling when your data is accessible based on the device's lock state and encryption.

        🔐 Key Uses of Data Protection:
           • Encrypts app data at rest using the device’s passcode and hardware encryption.

           • Ensures data is unreadable when the device is locked, depending on the protection level you choose.

           • Protects sensitive files like user documents, database records, and other app content.

        Common Protection Classes:
           • NSFileProtectionComplete: Data is only accessible when the device is unlocked.

           • NSFileProtectionCompleteUntilFirstUserAuthentication: Data becomes accessible after the  device is unlocked once after reboot.

           • NSFileProtectionNone: No additional protection; data is always accessible.

        Why Use It:
           • Complies with privacy requirements and app guidelines.

           • Prevents unauthorized access to user data if the device is lost or stolen.

        You enable it in the "Signing & Capabilities" tab by turning on Data Protection and optionally choosing a protection level in your code.
        
        
        import UIKit

        class ViewController: UIViewController {

            override func viewDidLoad() {
                super.viewDidLoad()
                saveProtectedFile()
            }

            func saveProtectedFile() {
                let fileName = "secure_note.txt"
                let content = "This is a secure file protected with NSFileProtectionComplete."
                
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentDirectory.appendingPathComponent(fileName)
                    let data = content.data(using: .utf8)

                    do {
                        // Save file with NSFileProtectionComplete
                        try data?.write(to: fileURL, options: .completeFileProtection)
                        print("✅ File saved securely at: fileURL")
                    } catch {
                        print("❌ Failed to write file: error.localizedDescription")
                    }
                }
            }
        }
        """
    }

}
