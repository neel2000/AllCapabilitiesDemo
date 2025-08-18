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
    
    @objc private func playAudioTapped() {
        // Replace with your Dolby Atmos / multichannel file in your app bundle
        guard let url = Bundle.main.url(forResource: "DolbyAtmosSample", withExtension: "mp4") else {
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
