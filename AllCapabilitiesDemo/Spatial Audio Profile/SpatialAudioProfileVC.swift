//
//  SpatialProfileAudioVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 08/08/25.
//
import UIKit
import AVFoundation
import AVKit
import CoreTelephony

class SpatialAudioProfileVC: UIViewController {
    
    private var player: AVPlayer?
    private let statusLabel = UILabel()
    private let playButton = UIButton(type: .system)
    
    private let engine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private let player1 = AVAudioPlayerNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        observeRouteChanges()
        checkSpatialAudioSupport()
    }

    private func setupUI() {
        // Status Label
        statusLabel.text = "Checking spatial audio support..."
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Play Button
        playButton.setTitle("Play Dolby Atmos Audio", for: .normal)
        playButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        playButton.addTarget(self, action: #selector(playAudioTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func observeRouteChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioRouteChanged),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    @objc private func audioRouteChanged() {
        checkSpatialAudioSupport()
    }
    
    private func checkSpatialAudioSupport() {
        let session = AVAudioSession.sharedInstance()
        if let output = session.currentRoute.outputs.first {
            let portName = output.portName
            // Spatial audio is typically supported on AirPods Pro/Max, AirPods 3rd Gen, certain Beats
            if output.supportsSpatialAudio {
                statusLabel.text = "✅ Spatial Audio supported on: \(portName)"
            } else {
                statusLabel.text = "❌ Spatial Audio not supported on: \(portName)"
            }
        } else {
            statusLabel.text = "No audio output detected."
        }
    }
    
//    private func setupAudio() {
//        // Attach nodes
//        engine.attach(environment)
//        engine.attach(player1)
//        
//        // Connect environment → output (NOT just mainMixerNode)
//        engine.connect(environment, to: engine.outputNode, format: nil)
//        
//        // Load audio file
//        guard let fileURL = Bundle.main.url(forResource: "sound", withExtension: "mp3") else {
//            print("❌ Audio file not found")
//            return
//        }
//        let audioFile = try! AVAudioFile(forReading: fileURL)
//        
//        // Connect player → environment
//        engine.connect(player1, to: environment, format: audioFile.processingFormat)
//        
//        // Set listener position (your "ears")
//        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
//        
//        // Set player position (sound source 5m in front)
//        player1.position = AVAudio3DPoint(x: 0, y: 0, z: -5)
//        
//        do {
//            try engine.start()
//            print("✅ Engine started")
//            
//            // Schedule and play
//            player1.scheduleFile(audioFile, at: nil) {
//                print("▶️ Finished playing")
//            }
//            player1.play()
//            
//        } catch {
//            print("❌ Engine error: \(error)")
//        }
//    }
    
    @objc private func playAudioTapped() {
        // Replace with your Dolby Atmos / multichannel file in your app bundle
        guard let url = Bundle.main.url(forResource: "DolbyAtmosSample", withExtension: "mp3") else {
            statusLabel.text = "Audio file not found in bundle."
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        present(playerVC, animated: true) {
            self.player?.play()
        }
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            
            Spatial Audio provides an immersive 3D audio experience by simulating sound in a three-dimensional space.
            
            It’s primarily used with AirPods Pro, AirPods Max, and other supported headphones.

                •  Sounds can appear to come from a specific direction or move around the user.

                •  Supports dynamic head tracking, so audio stays fixed relative to the device or moves with the listener’s head.

                •  Works with movies, music, and games for a more realistic audio experience.

            Key Features

                1. 3D Audio Positioning: Audio can be placed virtually anywhere in 3D space around the listener.

                2  Dynamic Head Tracking: Tracks the user’s head movement and adjusts the sound perspective.

                3. Immersive Experience: Makes games, AR/VR apps, or media apps feel more lifelike.

                4. Works with AVAudioEngine: Developers can control spatial audio through AVAudioEngine and related classes.

            Requirements

                • iOS 14+ (for dynamic head tracking features, iOS 15+ recommended)

                • Compatible headphones (AirPods Pro, AirPods Max, Beats Fit Pro)

                • AVAudioEngine or AVPlayer for audio playback

                • App capability is handled in software, no special entitlement is required, but you should enable Audio, AirPlay, and Bluetooth capabilities.
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

private extension AVAudioSessionPortDescription {
    var supportsSpatialAudio: Bool {
        // Public API: only check known spatial audio devices by name
        let spatialDevices = [
            "AirPods Pro",
            "AirPods Pro (2nd generation)",
            "AirPods (3rd generation)",
            "AirPods Max",
            "Beats Fit Pro"
        ]
        return spatialDevices.contains { portName.contains($0) }
    }
}
