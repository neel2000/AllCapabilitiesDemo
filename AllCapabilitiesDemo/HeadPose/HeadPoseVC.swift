//
//  HeadPoseVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 04/08/25.
//

import UIKit
import ARKit
import SceneKit

class HeadPoseVC: UIViewController, ARSessionDelegate {

    private var arView: ARSCNView!
    private var resultLabel: UILabel!

    private var lastPitchValues: [Float] = []
    private var lastYawValues: [Float] = []
    private let maxStoredFrames = 20
    private let yesThreshold: Float = 0.4 // nod up/down range
    private let noThreshold: Float = 0.5  // shake left/right range

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupARView()
        setupResultLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startFaceTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    private func setupARView() {
        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        arView.automaticallyUpdatesLighting = true
        view.addSubview(arView)
    }

    private func setupResultLabel() {
        resultLabel = UILabel()
        resultLabel.text = "Waiting..."
        resultLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        resultLabel.textColor = .white
        resultLabel.textAlignment = .center
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            resultLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func startFaceTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return
        }

        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
            let eulerAngles = getEulerAngles(from: faceAnchor.transform)
            trackHeadGesture(pitch: eulerAngles.x, yaw: eulerAngles.y)
        }
    }

    private func trackHeadGesture(pitch: Float, yaw: Float) {
        lastPitchValues.append(pitch)
        lastYawValues.append(yaw)

        if lastPitchValues.count > maxStoredFrames { lastPitchValues.removeFirst() }
        if lastYawValues.count > maxStoredFrames { lastYawValues.removeFirst() }

        if let minPitch = lastPitchValues.min(), let maxPitch = lastPitchValues.max() {
            if (maxPitch - minPitch) > yesThreshold {
                print("Detected YES nod")
                updateResultLabel(text: "YES 👍")
                lastPitchValues.removeAll()
            }
        }

        if let minYaw = lastYawValues.min(), let maxYaw = lastYawValues.max() {
            if (maxYaw - minYaw) > noThreshold {
                print("Detected NO shake")
                updateResultLabel(text: "NO 👎")
                lastYawValues.removeAll()
            }
        }
    }

    private func updateResultLabel(text: String) {
        DispatchQueue.main.async {
            self.resultLabel.text = text
        }
    }

    private func getEulerAngles(from transform: simd_float4x4) -> SIMD3<Float> {
        let rotationMatrix = transform.upperLeft3x3
        let pitch = asin(-rotationMatrix.columns.2.y)
        let yaw = atan2(rotationMatrix.columns.2.x, rotationMatrix.columns.2.z)
        let roll = atan2(rotationMatrix.columns.0.y, rotationMatrix.columns.1.y)
        return SIMD3<Float>(pitch, yaw, roll)
    }
}

extension simd_float4x4 {
    var upperLeft3x3: simd_float3x3 {
        return simd_float3x3(columns: (columns.0.xyz, columns.1.xyz, columns.2.xyz))
    }
}

extension simd_float4 {
    var xyz: simd_float3 {
        return simd_float3(x, y, z)
    }
}
