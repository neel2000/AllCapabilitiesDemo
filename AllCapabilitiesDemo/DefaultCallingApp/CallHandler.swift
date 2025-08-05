//
//  Untitled.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 04/08/25.
//

import CallKit

class CallHandler: NSObject { // ✅ Inherit from NSObject
    let provider: CXProvider

    override init() {
        let config = CXProviderConfiguration(localizedName: "DefaultDialerDemo")
        config.supportsVideo = true
        config.includesCallsInRecents = true
        config.supportedHandleTypes = [.phoneNumber]

        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    func reportIncomingCall(uuid: UUID, handle: String) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = false

        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("❌ Error reporting incoming call: \(error)")
            } else {
                print("✅ Incoming call reported")
            }
        }
    }
}

extension CallHandler: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("🔄 Provider reset")
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("📞 Call answered")
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("❌ Call ended")
        action.fulfill()
    }
}
