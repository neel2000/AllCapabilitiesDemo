//
//  AppTransportSecurityExceptionVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 08/10/25.
//

import UIKit

class AppTransportSecurityExceptionVC: UIViewController { 

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText =
        """
        🧩 What Is App Transport Security (ATS)?

        App Transport Security (ATS) is a security feature introduced by Apple (iOS 9 and later) that forces all network connections (e.g. using URLSession, NSURLConnection, WKWebView, etc.) to use secure HTTPS (TLS 1.2+) connections instead of plain HTTP.

        It ensures:

            • Data privacy (encryption in transit)

            • Protection from man-in-the-middle attacks

            • Stronger TLS ciphers and certificates
        
        
        🛠️ The “App Transport Security Exception” Capability
        
        This “capability” allows you to bypass ATS restrictions for specific domains or globally (only when absolutely necessary).
        
        
        ⚙️ How to Enable ATS Exceptions in Xcode
        
        Option 1: Disable ATS Globally (not recommended for production)
        
        In Info.plist, add:

            <key>NSAppTransportSecurity</key>
            <dict>
                <key>NSAllowsArbitraryLoads</key>
                <true/>
            </dict>
        
            👉 This allows all HTTP (non-HTTPS) connections.
        
        Option 2: Allow Exceptions for Specific Domains (Recommended)

        You can selectively disable ATS for certain domains only:

            <key>NSAppTransportSecurity</key>
            <dict>
                <key>NSExceptionDomains</key>
                <dict>
                    <key>example.com</key>
                    <dict>
                        <key>NSExceptionAllowsInsecureHTTPLoads</key>
                        <true/>
                        <key>NSIncludesSubdomains</key>
                        <true/>
                    </dict>
                </dict>
            </dict>
        
            ✅ What this does
                • Allows HTTP for example.com and its subdomains.
                • Keeps ATS active for all other domains.
        
        
        Option 3: Allow Localhost or Intranet Access

        If your app connects to a local development server or IoT device, use this:

            <key>NSAppTransportSecurity</key>
            <dict>
                <key>NSAllowsLocalNetworking</key>
                <true/>
            </dict>
        
            ✅ This allows connections to:
                • 127.0.0.1
                • .local domains
                • Private IPs (like 192.168.x.x or 10.x.x.x)
        
        
        Option 4: Fine-Tune TLS Settings

        You can explicitly define minimum TLS versions or allow self-signed certs:

            <key>NSAppTransportSecurity</key>
            <dict>
                <key>NSExceptionDomains</key>
                <dict>
                    <key>example.com</key>
                    <dict>
                        <key>NSTemporaryExceptionMinimumTLSVersion</key>
                        <string>TLSv1.0</string>
                        <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                        <true/>
                    </dict>
                </dict>
            </dict>
        
            ⚠️ Apple treats these as “temporary exceptions” — not valid for long-term use.
        
        
        🔐 Info.plist Summary Table
        
        | Key                                     | Purpose                                |
        | --------------------------------------- | -------------------------------------- |
        | `NSAppTransportSecurity`                | Root ATS configuration dictionary      |
        | `NSAllowsArbitraryLoads`                | Disable ATS globally (not recommended) |
        | `NSExceptionDomains`                    | Define per-domain exceptions           |
        | `NSExceptionAllowsInsecureHTTPLoads`    | Allow HTTP for specific domain         |
        | `NSIncludesSubdomains`                  | Apply exception to subdomains          |
        | `NSAllowsLocalNetworking`               | Allow non-secure local network calls   |
        | `NSTemporaryExceptionMinimumTLSVersion` | Allow older TLS versions temporarily   |

                    
        🧠 When Should You Use ATS Exceptions?
        
        | Situation                      | Best Practice                                              |
        | ------------------------------ | ---------------------------------------------------------- |
        | Your server supports HTTPS     | ✅ Use HTTPS only (preferred)                               |
        | Third-party API is HTTP-only   | ⚠️ Add **per-domain** exception                            |
        | Local development / IoT device | ✅ Use `NSAllowsLocalNetworking`                            |
        | Debugging or testing only      | ✅ Temporarily use global exception (remove before release) |

        
        """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
