//
//  Untitled.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 04/08/25.
//

import Foundation
import CallKit
import AVFoundation
import UIKit

final class CallManager: NSObject, CXProviderDelegate {

    // MARK: Singleton
    static let shared = CallManager()

    // MARK: CallKit objects
    let callController = CXCallController()   // Single controller instance
    private let provider: CXProvider

    // Current active call UUID
    private(set) var activeCallUUID: UUID?

    // MARK: - Init
    override init() {
        let config = CXProviderConfiguration(localizedName: "AppCapabilitiesDemo")
        config.supportsVideo = false
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.phoneNumber, .generic]
        config.iconTemplateImageData = UIImage(named: "appIcon")?.pngData()
        config.ringtoneSound = "ringtone.wav"

        self.provider = CXProvider(configuration: config)
        super.init()

        provider.setDelegate(self, queue: .main)
        configureAudioSession()
    }

    // MARK: - Start Call
    func startCall(to phoneNumber: String, from caller: String) {
        let cleaned = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard !cleaned.isEmpty else {
            print("❌ Invalid phone number: \(phoneNumber)")
            return
        }

        let uuid = UUID()
        activeCallUUID = uuid
        print("📞 StartCall — uuid:", uuid)

        let handle = CXHandle(type: .phoneNumber, value: cleaned)
        let start = CXStartCallAction(call: uuid, handle: handle)
        start.contactIdentifier = caller

        let tx = CXTransaction(action: start)
        callController.request(tx) { error in
            if let error = error {
                print("❌ Start call error:", error.localizedDescription)
                return
            }
            print("✅ Start call transaction sent")

            // Present UI
            DispatchQueue.main.async {
                guard let root = UIApplication.shared.windows.first?.rootViewController else { return }
                let callVC = CallViewController()
                callVC.modalPresentationStyle = .fullScreen
                callVC.displayName = caller.isEmpty ? cleaned : caller
                callVC.phoneNumber = cleaned
                callVC.callUUID = uuid
                callVC.callManager = CallManager.shared
                root.present(callVC, animated: true)
            }
        }
    }

    // MARK: - End Call
    func endActiveCall() {
        guard let uuid = activeCallUUID else {
            print("ℹ️ No active call to end")
            logCurrentCalls()
            return
        }

        // Check if CallKit knows about this call
        let activeCalls = callController.callObserver.calls
        if !activeCalls.contains(where: { $0.uuid == uuid }) {
            print("⚠️ Call with UUID \(uuid) not found in callObserver")
            logCurrentCalls()
            return
        }

        print("🔴 Ending call — uuid:", uuid)
        let end = CXEndCallAction(call: uuid)
        let tx = CXTransaction(action: end)

        callController.request(tx) { error in
            if let error = error {
                print("❌ End call error:", error.localizedDescription)
            } else {
                print("✅ End call transaction sent")
            }
        }
    }

    // Helper: log calls from CallKit
    private func logCurrentCalls() {
        let calls = callController.callObserver.calls
        if calls.isEmpty {
            print("📭 No calls currently in CallKit")
        } else {
            print("📋 Active calls in CallKit:")
            for c in calls {
                print("- UUID:", c.uuid, "Outgoing:", c.isOutgoing, "OnHold:", c.isOnHold, "Connected:", c.hasConnected)
            }
        }
    }

    // MARK: - CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {
        print("⚠️ Provider reset")
        activeCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("▶️ Provider perform start — uuid:", action.callUUID)

        let update = CXCallUpdate()
        update.remoteHandle = action.handle
        update.localizedCallerName = action.contactIdentifier ?? "Unknown Caller"

        provider.reportCall(with: action.callUUID, updated: update)
        provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())

        NotificationCenter.default.post(name: .init("CallConnected"),
                                        object: nil,
                                        userInfo: ["uuid": action.callUUID])

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("⏹ Provider perform end — uuid:", action.callUUID)

        NotificationCenter.default.post(name: .init("CallEnded"),
                                        object: nil,
                                        userInfo: ["uuid": action.callUUID])

        if activeCallUUID == action.callUUID {
            activeCallUUID = nil
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("🎙 Audio session activated")
    }

    // MARK: - Audio Setup
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                    mode: .voiceChat,
                                    options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("❌ Audio session error:", error.localizedDescription)
        }
    }
    
    // Report an incoming call (typically from a push notification)
    func reportIncomingCall(from caller: String, handle: String) {
        let uuid = UUID()
        activeCallUUID = uuid
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.localizedCallerName = caller
        update.hasVideo = false
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("Failed to report incoming call: \(error)")
            }
        }
    }
    
    // Handle when user answers
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // User answered - now show your custom UI
        DispatchQueue.main.async {
            // Present CallViewController here
        }
        action.fulfill()
    }
}
