//
//  DefaultCallingAppVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 04/08/25.
//

import UIKit
import CallKit
import AVFoundation

final class CallViewController: UIViewController {
    
    // MARK: - Public Properties (set before presenting)
    var displayName: String = "Unknown"
    var phoneNumber: String = ""
    var callManager: CallManager?
    var callUUID: UUID?
    
    // MARK: - Private UI Elements
    private let callerNameLabel = UILabel()
    private let callerNumberLabel = UILabel()
    private let callStatusLabel = UILabel()
    private let timerLabel = UILabel()
    
    private let muteButton = CircleButton(symbol: "mic.fill")
    private let speakerButton = CircleButton(symbol: "speaker.wave.2.fill")
    private let endCallButton = CircleButton(symbol: "phone.down.fill", background: .systemRed)
    
    private var isMuted = false
    private var isSpeakerOn = false
    private var callTimer: Timer?
    private var startDate: Date?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startConnecting()
        
        // Listen for call state changes
        NotificationCenter.default.addObserver(self, selector: #selector(onCallConnected(_:)), name: NSNotification.Name("CallConnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCallEnded(_:)), name: NSNotification.Name("CallEnded"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        callerNameLabel.text = displayName
        callerNameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        callerNameLabel.textColor = .white
        callerNameLabel.textAlignment = .center
        
        callerNumberLabel.text = phoneNumber
        callerNumberLabel.font = .systemFont(ofSize: 16)
        callerNumberLabel.textColor = .lightGray
        callerNumberLabel.textAlignment = .center
        
        callStatusLabel.text = "Calling…"
        callStatusLabel.font = .systemFont(ofSize: 16)
        callStatusLabel.textColor = .white
        callStatusLabel.textAlignment = .center
        
        timerLabel.text = "00:00"
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        timerLabel.textColor = .lightGray
        timerLabel.textAlignment = .center
        timerLabel.isHidden = true
        
        let infoStack = UIStackView(arrangedSubviews: [callerNameLabel, callerNumberLabel, callStatusLabel, timerLabel])
        infoStack.axis = .vertical
        infoStack.alignment = .center
        infoStack.spacing = 6
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Button actions
        muteButton.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
        speakerButton.addTarget(self, action: #selector(toggleSpeaker), for: .touchUpInside)
        endCallButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)
        
        let controlsStack = UIStackView(arrangedSubviews: [muteButton, speakerButton, endCallButton])
        controlsStack.axis = .horizontal
        controlsStack.distribution = .equalSpacing
        controlsStack.alignment = .center
        controlsStack.spacing = 24
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(infoStack)
        view.addSubview(controlsStack)
        
        NSLayoutConstraint.activate([
            infoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            controlsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Call State Handling
    
    func startConnecting() {
        callStatusLabel.text = "Calling…"
        timerLabel.isHidden = true
    }
    
    @objc private func onCallConnected(_ note: Notification) {
        if let uuid = note.userInfo?["uuid"] as? UUID,
           uuid == callUUID {
            callConnected()
        }
    }
    
    @objc private func onCallEnded(_ note: Notification) {
        if let uuid = note.userInfo?["uuid"] as? UUID,
           uuid == callUUID {
            callEnded()
        }
    }
    
    private func callConnected() {
        callStatusLabel.text = "Connected"
        startDate = Date()
        startTimer()
    }
    
    private func callEnded() {
        callStatusLabel.text = "Call Ended"
        stopTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc private func toggleMute() {
        isMuted.toggle()
        muteButton.tintColor = isMuted ? .systemYellow : .white
        // TODO: Integrate with audio mute control
    }
    
    @objc private func toggleSpeaker() {
        isSpeakerOn.toggle()
        speakerButton.tintColor = isSpeakerOn ? .systemYellow : .white
        // TODO: Integrate with AVAudioSession route
    }
    
    @objc private func endCall() {
        print("UI EndCall button tapped")
        if isFromCommunicationNotification {
            callManager?.endActiveCallForComminicationNotification(activeCallUUID: callUUID)
        } else {
            callManager?.endActiveCall()
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timerLabel.isHidden = false
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let start = self?.startDate else { return }
            let elapsed = Int(Date().timeIntervalSince(start))
            let min = elapsed / 60
            let sec = elapsed % 60
            self?.timerLabel.text = String(format: "%02d:%02d", min, sec)
        }
    }
    
    private func stopTimer() {
        callTimer?.invalidate()
        callTimer = nil
    }
}

// MARK: - Helper Classes

final class CircleButton: UIButton {
    init(symbol: String, background: UIColor = UIColor.white.withAlphaComponent(0.15)) {
        super.init(frame: .zero)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let img = UIImage(systemName: symbol, withConfiguration: config)
        setImage(img, for: .normal)
        tintColor = .white
        backgroundColor = background
        layer.cornerRadius = 35
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 70).isActive = true
        heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    required init?(coder: NSCoder) { fatalError() }
}
