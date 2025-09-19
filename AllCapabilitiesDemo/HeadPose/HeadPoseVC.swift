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
    }
    
    
    @IBAction func btnHeadPoseAction(_ sender: Any) {
        let vc = HeadPoseVC1()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            
            The Head Pose capability lets your app access the position and orientation of the user’s head in 3D space. It uses the ARKit framework and TrueDepth camera (on supported devices) to provide real-time tracking.
            
            🔑 Key Features
            
                • Tracks the rotation and movement of the user’s head.
            
                • Provides pitch, yaw, and roll values in real time.
            
                • Works with ARKit face tracking for precise motion capture.
            
                • Can be combined with gaze tracking or facial expressions for richer interactions.
            
            📌 Common Use Cases
            
                • Accessibility: Control the interface with head movements.
            
                • Gaming/AR apps: Move the camera or trigger actions based on head direction.
            
                • Health & fitness apps: Measure posture, alignment, or neck movements.
            
                • Entertainment: Enable immersive experiences like nodding to confirm actions.
            
            ⚠️ Important Considerations
            
                • Requires a device with a TrueDepth camera (e.g., Face ID-enabled iPhones/iPads).
            
                • Needs the Head Pose entitlement in Xcode.
            
                • Must request camera access permission from the user.
            
                • Respect user privacy — only use tracking for the stated purpose.
            
            
            🎯 Pitch, Yaw, and Roll

            1. Pitch – Up and down movement of the head.

                • Like nodding “yes”.

                • Example: Looking up at the ceiling or down at the floor.

            2. Yaw – Left and right movement of the head.

                • Like shaking your head “no”.

                • Example: Turning to look over your left or right shoulder.

            3. Roll – Tilting your head sideways.

                • Like leaning your ear toward your shoulder.

                • Example: Tilting your head to the left/right while thinking.

            📌 In ARKit, these values are provided in radians (or degrees if you convert them).
            They let developers know exactly where the user’s head is pointing in 3D space in real time.
            
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
