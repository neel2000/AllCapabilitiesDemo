//
//  ShallowDepthPressureVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 06/10/25.
//

import UIKit
import CoreMotion

@available(iOS 16.0, *)
class ShallowDepthPressureVC: UIViewController {
    
    // The submersion manager
    private let submersionManager = CMWaterSubmersionManager()
    
    // UI labels
    private let stateLabel = UILabel()
    private let depthLabel = UILabel()
    private let pressureLabel = UILabel()
    private let surfacePressureLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLabels()
        
        // Set delegate to receive events
        submersionManager.delegate = self
        
        // Optionally: Check if submersion / water sensing is “available”
        // There's a class property `waterSubmersionAvailable` in Apple docs.
        if !CMWaterSubmersionManager.waterSubmersionAvailable {
            stateLabel.text = "Submersion unavailable on this device"
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setupLabels() {
        // Basic layout and adding to view
        let stack = UIStackView(arrangedSubviews: [stateLabel, depthLabel, pressureLabel, surfacePressureLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        stateLabel.text = "State: —"
        depthLabel.text = "Depth: —"
        pressureLabel.text = "Pressure: —"
        surfacePressureLabel.text = "Surface Pressure: —"
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText =
            """
            The Shallow Depth & Pressure capability allows apps to detect when a device is submerged in water and measure water depth and pressure. It leverages the device’s barometric and water‑resistant sensors to provide real‑time data about the surrounding water environment.

            Key Features:

                • Submersion Detection: Detect whether the device is currently underwater or not.

                • Depth Measurement: Provides accurate water depth measurements up to a certain limit (~6 meters).

                • Water Pressure Measurement: Measures pressure in kilopascals while submerged.

                • Surface Pressure: Measures atmospheric or surface water pressure.

                • Event Updates: Delivers real-time updates via a delegate for use in apps.

            Use Cases:

                • Dive logging and underwater activity tracking.

                • Swimming performance or water sports apps.

                • Water safety or alert applications.

                • Environmental monitoring in water-related apps.

            Requirements:

                • Supported Devices: Apple Watch Ultra and newer devices with depth and pressure sensors.

                • OS Version: watchOS 9.0+ (primarily) and iOS 17+ where supported.

                • Entitlement: The app must request the Shallow Depth & Pressure capability from Apple.

                • Limitations: Depth measurement is reliable only up to approximately 6 meters; values beyond this may be inaccurate.

            Technical Details:

                • Provided via the Core Motion framework: CMWaterSubmersionManager and CMWaterSubmersionEvent.

                • Apps receive updates through a delegate conforming to CMWaterSubmersionManagerDelegate.

                • Values include depth (Double?), pressure (Measurement<UnitPressure>), surfacePressure (Measurement<UnitPressure>), and state (.submerged / .notSubmerged).
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - Delegate

@available(iOS 16.0, *)
extension ShallowDepthPressureVC: CMWaterSubmersionManagerDelegate {
    func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterSubmersionMeasurement) {
        
        switch measurement.submersionState {
        case .notSubmerged:
            self.stateLabel.text = "State: Not submerged"
        case .submergedShallow:
            self.stateLabel.text = "State: The device is submerged, but less than 1 meter under water"
        case .submergedDeep:
            self.stateLabel.text = "State: The device is submerged at least 1 meter under water"
        case .approachingMaxDepth:
            self.stateLabel.text = "State: The device is approaching the maximum safe diving depth"
        case .unknown:
            break
        case .pastMaxDepth:
            self.stateLabel.text = "State: The device has exceeded the maximum safe diving depth"
        case .sensorDepthError:
            self.stateLabel.text = "State: An error with the depth sensor occurred"
        @unknown default:
            self.stateLabel.text = "State: Unknown"
        }
        
        // Depth (optional Double)
        if let depth = measurement.depth {
            self.depthLabel.text = String(format: "Depth: %.2f m", depth as CVarArg)
        } else {
            self.depthLabel.text = "Depth: unavailable"
        }
        
        // Pressure (Measurement<UnitPressure>)
        let pressure = measurement.pressure
        self.pressureLabel.text = String(format: "Pressure: %.2f kPa", pressure?.converted(to: .kilopascals).value ?? 0.0)
        
        // Surface Pressure (Measurement<UnitPressure>)
        let surface = measurement.surfacePressure
        self.surfacePressureLabel.text = String(format: "Surface Pressure: %.2f kPa", surface.converted(to: .kilopascals).value)
    }
    
    func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterTemperature) {
        
    }
    
    func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {

        
    }
    
    func manager(_ manager: CMWaterSubmersionManager, errorOccurred error: Error) {
        DispatchQueue.main.async {
            self.stateLabel.text = "Error: \(error.localizedDescription)"
        }
    }
}
