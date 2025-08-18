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
