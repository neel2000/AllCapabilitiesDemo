//
//  DefaultTranslationAppVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 18/09/25.
//

import UIKit

class DefaultTranslationAppVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            The Default Translation App capability allows third-party translation apps to register themselves with the system so they can become the user’s preferred app for handling translations. This makes it possible for users to choose your app instead of Apple’s built-in Translate app when they translate text across iOS.

            🔹 What It Does

                • System Integration – Lets your app act as the default translation app for text, similar to how users can pick a default browser or mail app.

                • Quick Access – When a user highlights text and selects Translate from the menu, iOS can open your app instead of Apple Translate.

                • Consistency – Ensures all translation requests across the system go through the app the user prefers.

                • Developer Control – Your app can offer additional features (offline models, custom dictionaries, domain-specific translations) while still feeling native.

            🔑 Why It’s Useful

                • Creates a seamless experience for users who rely on translation.

                • Helps third-party apps compete with Apple’s Translate app by becoming the default choice.

                • Supports specialized translation apps (e.g., medical, legal, or business-focused apps).

            📌 Requirements

                • Apple Developer Program membership.

                • Enable Default Translation App capability in Xcode.

                • Implement translation services in your app (using Apple’s Translation framework or a custom translation engine).

                • The feature depends on Apple exposing UI in Settings to let users choose the default translation app (currently limited and not widely available).
                        
                • Required iOS 18.4 or later
            
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
