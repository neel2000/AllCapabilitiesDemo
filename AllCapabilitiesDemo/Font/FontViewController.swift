//
//  FontViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 18/08/25.
//

import UIKit

enum registerFont {
    case register
    case unregister
}

class FontViewController: UIViewController {

    override func viewDidLoad() {
         super.viewDidLoad()
         setupButtons()
     }
     
     private func setupButtons() {
         let registerFonts = ["GreycliffCF", "Poppins", "Roboto", "SegoeUI"]
         let unregisterFonts = ["GreycliffCF", "Poppins", "Roboto", "SegoeUI"]
             
             // Stack for Register Buttons
             let registerStack = UIStackView()
             registerStack.axis = .vertical
             registerStack.alignment = .center
             registerStack.spacing = 13
             
             for (index, fontName) in registerFonts.enumerated() {
                 let button = UIButton(type: .system)
                 button.setTitle("Register \(fontName)", for: .normal)
                 button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
                 button.backgroundColor = .systemBlue
                 button.setTitleColor(.white, for: .normal)
                 button.layer.cornerRadius = 10
                 button.tag = index
                 button.addTarget(self, action: #selector(registerFont(_:)), for: .touchUpInside)
                 
                 button.translatesAutoresizingMaskIntoConstraints = false
                 NSLayoutConstraint.activate([
                     button.widthAnchor.constraint(equalToConstant: 250),
                     button.heightAnchor.constraint(equalToConstant: 50)
                 ])
                 
                 registerStack.addArrangedSubview(button)
             }
             
             // Stack for Unregister Buttons
             let unregisterStack = UIStackView()
             unregisterStack.axis = .vertical
             unregisterStack.alignment = .center
             unregisterStack.spacing = 13
             
             for (index, fontName) in unregisterFonts.enumerated() {
                 let button = UIButton(type: .system)
                 button.setTitle("Unregister \(fontName)", for: .normal)
                 button.titleLabel?.font = . systemFont(ofSize: 18, weight: .medium)
                 button.backgroundColor = .systemRed
                 button.setTitleColor(.white, for: .normal)
                 button.layer.cornerRadius = 10
                 button.tag = index
                 button.addTarget(self, action: #selector(unregisterFont(_:)), for: .touchUpInside)
                 
                 button.translatesAutoresizingMaskIntoConstraints = false
                 NSLayoutConstraint.activate([
                     button.widthAnchor.constraint(equalToConstant: 250),
                     button.heightAnchor.constraint(equalToConstant: 50)
                 ])
                 
                 unregisterStack.addArrangedSubview(button)
             }
             
             // Parent stack to hold both stacks
             let mainStack = UIStackView(arrangedSubviews: [registerStack, unregisterStack])
             mainStack.axis = .vertical
             mainStack.alignment = .center
             mainStack.spacing = 25 // space between register & unregister groups
             mainStack.translatesAutoresizingMaskIntoConstraints = false
             
             view.addSubview(mainStack)
             
             NSLayoutConstraint.activate([
                 mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
             ])
     }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            The Fonts capability allows your app to include and use custom fonts beyond the system-provided ones. With this, you can create a unique look and feel for your app’s text elements.

            🔑 Key Features

                • Embed custom font files (e.g., .ttf, .otf) into your app.

                • Use custom fonts in UILabel, UITextView, UIButton, SwiftUI Text, and more.

                • Provide users with branded typography for a consistent design.

                • Fonts are packaged inside your app bundle, so they work offline.

            📌 Common Use Cases

                • Branding: Match your app’s UI with a company’s official fonts.

                • Design/Creativity apps: Give users more font choices for editing text.

                • Games: Use themed fonts to match the game’s style.

                • Accessibility: Provide fonts optimized for readability.

            ⚠️ Important Considerations

                • Add fonts to your app’s Info.plist under UIAppFonts.

                • Ensure you have the legal right/license to use and distribute the font.

                • Large font files may increase your app size.

                • Dynamic Type compatibility is recommended for accessibility.
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
     @objc private func registerFont(_ sender: UIButton) {
         switch sender.tag {
         case 0:
             registerGreycliffFonts(fontRegister: .register)
         case 1:
             registerPoppinsFontFamily(fontRegister: .register)
         case 2:
             registerRobotoFontFamily(fontRegister: .register)
         case 3:
             registerSegoeUIFontFamily(fontRegister: .register)
         default:
             break
         }
     }
    
    @objc private func unregisterFont(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            registerGreycliffFonts(fontRegister: .unregister)
        case 1:
            registerPoppinsFontFamily(fontRegister: .unregister)
        case 2:
            registerRobotoFontFamily(fontRegister: .unregister)
        case 3:
            registerSegoeUIFontFamily(fontRegister: .unregister)
        default:
            break
        }
    }
    
    private func registerGreycliffFonts(fontRegister: registerFont) {
        let fontFiles = [
            "GreycliffCF-ThinOblique", "GreycliffCF-Heavy", "GreycliffCF-ExtraBold",
            "GreycliffCF-ExtraLightOblique", "GreycliffCF-Light", "GreycliffCF-BoldOblique",
            "GreycliffCF-DemiBoldOblique", "GreycliffCF-ExtraLight", "GreycliffCF-RegularOblique",
            "GreycliffCF-Thin", "GreycliffCF-Bold", "GreycliffCF-LightOblique",
            "GreycliffCF-DemiBold", "GreycliffCF-HeavyOblique", "GreycliffCF-Medium",
            "GreycliffCF-ExtraBoldOblique", "GreycliffCF-Regular", "GreycliffCF-MediumOblique"
        ]
        
        fontRegister == .register ? registerFonts(fontFiles, withExtension: "otf") : unRegisterFonts(fontFiles, withExtension: "otf")
    }
    
    private func registerPoppinsFontFamily(fontRegister: registerFont) {
        let fontFiles = [
            "Poppins-Black", "Poppins-Bold", "Poppins-LightItalic", "Poppins-Medium", "Poppins-MediumItalic", "Poppins-Regular", "Poppins-SemiBold"
        ]
        
        fontRegister == .register ? registerFonts(fontFiles, withExtension: "ttf") : unRegisterFonts(fontFiles, withExtension: "ttf")
    }
 
    private func registerRobotoFontFamily(fontRegister: registerFont) {
        let fontFiles = [
            "Roboto-Thin", "Roboto-Regular", "Roboto-Medium", "Roboto-Light", "Roboto-Bold", "Roboto-Black"
        ]
        
        fontRegister == .register ? registerFonts(fontFiles, withExtension: "ttf") : unRegisterFonts(fontFiles, withExtension: "ttf")
    }

    private func registerSegoeUIFontFamily(fontRegister: registerFont) {
        let fontFiles = [
            "Segoe UI Semibold", "Segoe UI", "Segoe UI Italic", "Segoe UI Bold", "Segoe UI Bold Italic"
        ]
        
        fontRegister == .register ? registerFonts(fontFiles, withExtension: "ttf") : unRegisterFonts(fontFiles, withExtension: "ttf")
    }
    
    private func registerFonts(_ fontFiles: [String], withExtension ext: String) {
        var urls: [CFURL] = []
        
        for fontFile in fontFiles {
            if let url = Bundle.main.url(forResource: fontFile, withExtension: ext) {
                urls.append(url as CFURL)
            } else {
                print("❌ Font \(fontFile).\(ext) not found in bundle")
            }
        }
        
        if !urls.isEmpty {
            CTFontManagerRegisterFontURLs(urls as CFArray, .persistent, true) { (errors, success) -> Bool in
                if success {
                    print("✅ Fonts registered successfully: \(urls)")
                    self.showAlert(message: "Font registered successfully")
                }
                if let errors = errors as? [NSError], !errors.isEmpty {
                    print("⚠️ Errors: \(errors)")
                }
                return true
            }
        }
        
     
    }
    
    private func unRegisterFonts(_ fontFiles: [String], withExtension ext: String) {
        var urls: [CFURL] = []
        
        for fontFile in fontFiles {
            if let url = Bundle.main.url(forResource: fontFile, withExtension: ext) {
                urls.append(url as CFURL)
            } else {
                print("❌ Font \(fontFile).\(ext) not found in bundle")
            }
        }
        
        if !urls.isEmpty {
            CTFontManagerUnregisterFontURLs(urls as CFArray, .persistent) { (errors, success) -> Bool in
                if success {
                    print("✅ Fonts unregistered successfully: \(urls)")
                    self.showAlert(message: "Font unregistered successfully")
                }
                if let errors = errors as? [NSError], !errors.isEmpty {
                    print("⚠️ Errors: \(errors)")
                }
                return true
            }
        }
   }
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
