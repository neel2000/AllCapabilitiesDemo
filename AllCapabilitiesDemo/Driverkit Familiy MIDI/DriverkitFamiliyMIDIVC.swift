//
//  DriverkitFamiliyMIDIVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 12/08/25.
//

import UIKit

class DriverkitFamiliyMIDIVC: UIViewController {
    
    @IBOutlet weak var tv: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.text = """
        
        "DriverKit Family MIDI" is not an iOS capability at all — it’s a macOS capability that you might see in Xcode’s Signing & Capabilities tab if you have the wrong platform or entitlements context selected.

        Here’s the breakdown:

        What it is
        DriverKit is Apple’s framework for building user-space device drivers on macOS (introduced in macOS Catalina).

        The "DriverKit Family MIDI" capability specifically lets you build a MIDI driver (Musical Instrument Digital Interface) using DriverKit.

        It is only for macOS system extensions that handle MIDI devices (like keyboards, audio controllers, synths).

        It’s part of the com.apple.developer.driverkit.family.midi entitlement.

        Why you see it in Xcode for an iOS project
            • Xcode lists all capabilities it supports, but many are platform-specific.

            • If your project target is iOS, enabling this does nothing — iOS doesn’t allow third-party device drivers.

            • It might appear if:

                • You’re viewing capabilities for a macOS app target in a multi-platform project.

                •  Or you accidentally clicked “+ Capability” in the wrong target.

        Where it’s used
            • macOS only

            • Apps or extensions that need to:

                • Communicate with custom MIDI hardware

                • Provide a MIDI driver to CoreMIDI

            • Requires System Extension + DriverKit entitlement.

        💡 For iOS development — you can ignore it.
        If you want MIDI access in iOS, you use CoreMIDI (no DriverKit needed), because drivers are built into iOS and cannot be extended by apps.

        """

    }

}
