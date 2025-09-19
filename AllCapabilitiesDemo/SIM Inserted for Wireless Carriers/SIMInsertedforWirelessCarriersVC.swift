//
//  SIMInsertedforWirelessCarriersVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 15/08/25.
//

import UIKit
import CoreTelephony

class SIMInsertedforWirelessCarriersVC: UIViewController {

    let infoLabel = UILabel()
    let checkButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.text = "Press the button to check SIM/eSIM status"

        checkButton.setTitle("Check SIM Status", for: .normal)
        checkButton.addTarget(self, action: #selector(checkSIMStatus), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [infoLabel, checkButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            This capability allows your app (typically carrier or telecom apps) to detect and work only when a valid SIM card from the associated wireless carrier is inserted in the device.

            🔑 Key Features

                • Restricts app usage to devices with a specific carrier’s SIM card.

                • Ensures only eligible subscribers can use the app.

                • Works in combination with carrier entitlements from Apple.

            📌 Common Use Cases

                • Carrier self-care apps: Managing mobile data, bills, and services.

                • Operator-specific apps: Features available only to that carrier’s customers.

                • SIM-based authentication: Allowing access to exclusive plans, offers, or features.

            ⚠️ Important Considerations

                • Requires a special entitlement from Apple, granted only to carriers or partners.

                • Not available for general third-party apps.

                • If no valid SIM is inserted (or it’s from a different carrier), the app may not launch or may restrict features.

                • Users with eSIM are also supported if linked to the carrier.
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @objc func checkSIMStatus() {
        let networkInfo = CTTelephonyNetworkInfo()

        if let carriers = networkInfo.serviceSubscriberCellularProviders {
            var resultText = ""
            var simDetected = false

            for (slotID, carrier) in carriers {
                let mcc = carrier.mobileCountryCode ?? ""
                let mnc = carrier.mobileNetworkCode ?? ""
                let carrierName = carrier.carrierName ?? ""

                // Active SIM/eSIM detection: MCC & MNC must be present
                if !mcc.isEmpty && !mnc.isEmpty {
                    simDetected = true
                    resultText += "📱 Slot: \(slotID)\n"
                    resultText += "Carrier: \(carrierName.isEmpty ? "Unknown" : carrierName)\n"
                    resultText += "Mobile County Code: \(mcc)\n"
                    resultText += "Mobile Network Code: \(mnc)\n"
                    resultText += "ISO Country: \(carrier.isoCountryCode ?? "N/A")\n\n"
                } else {
                    resultText += "📭 Slot: \(slotID) — No SIM/eSIM Detected\n\n"
                }
            }

            infoLabel.text = simDetected ? "✅ SIM/eSIM Detected\n\n\(resultText)" : "❌ No SIM/eSIM Detected"
        } else {
            infoLabel.text = "No Carrier Info Found"
        }
    }
}
