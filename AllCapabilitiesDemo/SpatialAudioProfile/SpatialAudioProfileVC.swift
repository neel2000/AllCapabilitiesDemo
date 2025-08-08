//
//  SpatialProfileAudioVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 08/08/25.
//

import UIKit
import AVFoundation

class SpatialAudioProfileVC: UIViewController {
    
    private let statusLabel = UILabel()
    private let playButton = UIButton(type: .system)
    private var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Spatial Audio Demo"
        
        setupUI()
        configureSpatialAudio()
    }
    
    private func setupUI() {
        // Status label
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Play button
        playButton.setTitle("Play Audio", for: .normal)
        playButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        
        // Layout
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30)
        ])
    }
    
    private func configureSpatialAudio() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playback, mode: .moviePlayback, options: [])
            try session.setSupportsSpatialAudio(true)
            try session.setActive(true)
            
            let supports = session.supportsSpatialAudio
            let profile = session.spatialAudioProfile
            
            var profileText = "Unknown"
            if profile == .personalized {
                profileText = "Personalized"
            } else if profile == .standard {
                profileText = "Standard"
            }
            
            statusLabel.text = """
            Supports Spatial Audio: \(supports ? "✅ Yes" : "❌ No")
            Spatial Audio Profile: \(profileText)
            """
            
        } catch {
            statusLabel.text = "Error configuring Spatial Audio: \(error.localizedDescription)"
        }
    }
    
    @objc private func playTapped() {
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "mp3") else {
            statusLabel.text = "Audio file not found."
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            statusLabel.text = "Error playing audio: \(error.localizedDescription)"
        }
    }
}
