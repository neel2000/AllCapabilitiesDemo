//
//  SensitiveContentVc.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 08/08/25.
//

//import UIKit
//import PhotosUI
//import SensitiveContentAnalysis
//
//@available(iOS 17.0, *)
//class SensitiveContentVC: UIViewController, PHPickerViewControllerDelegate {
//    private let imageView = UIImageView()
//    private let selectButton = UIButton(type: .system)
//    private let analyzer = SCSensitivityAnalyzer()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        checkFeatureAvailability()
//    }
//
//    private func setupUI() {
//        view.backgroundColor = .white
//
//        // Configure Image View
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(imageView)
//
//        // Configure Select Button
//        selectButton.setTitle("Select Photo", for: .normal)
//        selectButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
//        selectButton.addTarget(self, action: #selector(selectPhotoTapped), for: .touchUpInside)
//        selectButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(selectButton)
//
//        // Layout Constraints
//        NSLayoutConstraint.activate([
//            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
//            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
//            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
//
//            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            selectButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
//        ])
//    }
//
//    private func checkFeatureAvailability() {
//        // Check if Sensitive Content Analysis is supported (iOS 17.0+)
//        if #available(iOS 17.0, *) {
//            // Feature is supported; proceed with analysis when needed
//        } else {
//            showAlert(message: "Sensitive Content Analysis is not supported on this device. Please update to iOS 17 or later.")
//            selectButton.isEnabled = false
//        }
//    }
//
//    @objc private func selectPhotoTapped() {
//        var config = PHPickerConfiguration()
//        config.filter = .images
//        config.selectionLimit = 1
//
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self
//        present(picker, animated: true, completion: nil)
//    }
//
//    // PHPickerViewControllerDelegate
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        dismiss(animated: true, completion: nil)
//
//        guard let itemProvider = results.first?.itemProvider,
//              itemProvider.canLoadObject(ofClass: UIImage.self) else {
//            showAlert(message: "No image selected or unsupported format.")
//            return
//        }
//
//        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//            DispatchQueue.main.async {
//                guard let self = self, let image = image as? UIImage else {
//                    self?.showAlert(message: "Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//
//                self.analyzeImage(image)
//            }
//        }
//    }
//
//    private func analyzeImage(_ image: UIImage) {
//        guard #available(iOS 17.0, *) else {
//            showAlert(message: "Sensitive Content Analysis is not supported on this device.")
//            return
//        }
//
//        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
//            showAlert(message: "Failed to convert image to data.")
//            return
//        }
//        
//        // Convert Data to CGImage
//        guard let cgImage =  UIImage(data: imageData)?.cgImage else {
//            showAlert(message: "Failed to convert image data to CGImage.")
//            return
//        }
//        
//        // Validate CGImage properties
//        guard cgImage.width > 0, cgImage.height > 0, cgImage.bitmapInfo.rawValue != 0 else {
//            showAlert(message: "Invalid CGImage format.")
//            return
//        }
//        
//        let analyzer = SCSensitivityAnalyzer()
//        let policy = analyzer.analysisPolicy
//        if policy == .disabled {
//            showAlert(message: "Please enable sensitive content analysis in Settings > Privacy & Security > Sensitive Content")
//            return
//        }
//
//        Task {
//            do {
//                let analysis = try await analyzer.analyzeImage(cgImage)
//    
//
//                DispatchQueue.main.async { [weak self] in
//                    if analysis.isSensitive {
//                        self?.showAlert(message: "This image contains sensitive content and cannot be displayed.")
//                    } else {
//                        self?.imageView.image = image
//                        self?.showAlert(message: "Image is safe to display.")
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async { [weak self] in
//                    let errorMessage = error.localizedDescription.contains("disabled")
//                        ? "Sensitive Content Analysis is disabled. Please enable it in Settings > Privacy & Security > Sensitive Content Warning."
//                        : "Analysis failed: \(error.localizedDescription)"
//                    self?.showAlert(message: errorMessage)
//                }
//            }
//        }
//    }
//
//    private func showAlert(message: String) {
//        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
//}

import UIKit
import PhotosUI
import SensitiveContentAnalysis
import CoreGraphics
import AVFoundation
import UniformTypeIdentifiers

@available(iOS 17.0, *)
class SensitiveContentVC: UIViewController, PHPickerViewControllerDelegate {
    
    private let imageView = UIImageView()
    private let selectButton = UIButton(type: .system)
    private let analyzer = SCSensitivityAnalyzer()
    private var isVideo = false
    private var thumbnail: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkFeatureAvailability()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        selectButton.setTitle("Select Image or Video", for: .normal)
        selectButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        selectButton.addTarget(self, action: #selector(selectMediaTapped), for: .touchUpInside)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectButton)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        ])
    }
    
    private func checkFeatureAvailability() {
        let policy = analyzer.analysisPolicy
        print("Sensitive Content Analysis policy: \(policy)")
        if policy == .disabled {
            showAlert(message: "Sensitive Content Analysis is disabled. Enable it in Settings > Privacy & Security > Sensitive Content Warning.")
            selectButton.isEnabled = false
        }
    }
    
    @objc private func selectMediaTapped() {
        isVideo = false
        thumbnail = nil
        imageView.image = nil
        
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider else {
            showAlert(message: "No media selected.")
            return
        }
        
        let videoTypeIdentifiers = [
            UTType.movie.identifier,
            UTType.video.identifier,
            UTType.quickTimeMovie.identifier,
            UTType.mpeg4Movie.identifier
        ]
        
        let isImage = itemProvider.canLoadObject(ofClass: UIImage.self)
        let isVideoFile = videoTypeIdentifiers.contains { itemProvider.hasItemConformingToTypeIdentifier($0) }
        
        guard isImage || isVideoFile else {
            showAlert(message: "Unsupported media format.")
            return
        }
        
        isVideo = isVideoFile
        
        if isImage && !isVideo {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                DispatchQueue.main.async {
                    guard let self, let image = object as? UIImage, error == nil else {
                        self?.showAlert(message: "Failed to load image.")
                        return
                    }
                    self.imageView.image = image
                    self.analyzeImage(image)
                }
            }
        } else if isVideo {
            for type in videoTypeIdentifiers {
                if itemProvider.hasItemConformingToTypeIdentifier(type) {
                    itemProvider.loadFileRepresentation(forTypeIdentifier: type) { [weak self] url, error in
                        guard let self, let url, error == nil else {
                            DispatchQueue.main.async {
                                self?.showAlert(message: "Failed to load video.")
                            }
                            return
                        }
                        
                        if let thumb = self.generateThumbnail(from: url) {
                            self.thumbnail = thumb
                            DispatchQueue.main.async {
                                self.imageView.image = thumb
                                self.analyzeVideo(from: url)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(message: "Failed to generate thumbnail.")
                            }
                        }
                    }
                    break
                }
            }
        }
    }
    
    private func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let times = [CMTime(seconds: 0, preferredTimescale: 600),
                     CMTime(seconds: 1, preferredTimescale: 600)]
        
        for time in times {
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    private func analyzeImage(_ image: UIImage) {
        
        if analyzer.analysisPolicy == .disabled {
            showAlert(message: "Please enable sensitive content analysis in Settings > Privacy & Security > Sensitive Content")
            return
        }
        
        guard let cgImage = image.cgImage else {
            showAlert(message: "Invalid image data.")
            return
        }
        
        Task {
            do {
                let result = try await analyzer.analyzeImage(cgImage)
                DispatchQueue.main.async {
                    if result.isSensitive {
                        self.showAlert(message: "Image contains sensitive content.")
                        self.imageView.image = nil
                    } else {
                        self.showAlert(message: "Image is safe.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Image analysis failed.")
                }
            }
        }
    }
    
    private func analyzeVideo(from url: URL) {
        
        if analyzer.analysisPolicy == .disabled {
            showAlert(message: "Please enable sensitive content analysis in Settings > Privacy & Security > Sensitive Content")
            return
        }
        
        Task {
            do {
                let handler = analyzer.videoAnalysis(forFileAt: url)
                let result = try await handler.hasSensitiveContent()
                DispatchQueue.main.async {
                    if result.isSensitive {
                        self.showAlert(message: "Video contains sensitive content.")
                        self.imageView.image = nil
                    } else {
                        self.showAlert(message: "Video is safe.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Video analysis failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

