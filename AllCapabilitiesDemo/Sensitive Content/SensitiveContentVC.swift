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
import AVFoundation
import UniformTypeIdentifiers

//For Testing this capability,
  //1) Install "SensitiveContentAnalysis.mobileconfig" profile in ios device. ("SensitiveContentAnalysis.mobileconfig" profile is available in "Sensitive Content Folder")
  //2) add "qr-sca.jpg" & "qr-sca.mov" in the ios device photo library. ("qr-sca.jpg" & "qr-sca.mov" are available in "Sensitive Content Folder")
  //3) Select "qr-sca.jpg" for image sensitive testing OR Select "qr-sca.mov" for video sensitive testing.

@available(iOS 17.0, *)
final class SensitiveContentVC: UIViewController, PHPickerViewControllerDelegate {
    
    
    // UI
    private let imageView = UIImageView()
    private let selectButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .large)
    
    // Analyzer
    private let analyzer = SCSensitivityAnalyzer()
    
    // State
    private var isVideo = false
    private var thumbnail: UIImage?
    private var videoHandler: SCSensitivityAnalyzer.VideoAnalysisHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkFeatureAvailability()
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        selectButton.setTitle("Select Image or Video", for: .normal)
        selectButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        selectButton.addTarget(self, action: #selector(selectMediaTapped), for: .touchUpInside)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(selectButton)
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func checkFeatureAvailability() {
        let policy = analyzer.analysisPolicy
        if policy == .disabled {
            showAlert(title: "Sensitive Content Disabled",
                      message: "Enable it in Settings > Privacy & Security > Sensitive Content Warning.")
            selectButton.isEnabled = false
        }
    }
    
    // MARK: - Actions
    
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
    
    // MARK: - Picker Delegate
    
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
        
        let canLoadImage = itemProvider.canLoadObject(ofClass: UIImage.self)
        let isVideoFile = videoTypeIdentifiers.contains { itemProvider.hasItemConformingToTypeIdentifier($0) }
        
        guard canLoadImage || isVideoFile else {
            showAlert(message: "Unsupported media format.")
            return
        }
        
        isVideo = isVideoFile
        
        if canLoadImage && !isVideoFile {
            // Image flow
            spinner.startAnimating()
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                Task { @MainActor in
                    guard let self else { return }
                    self.spinner.stopAnimating()
                    if let error = error {
                        self.showAlert(message: "Failed to load image: $$error.localizedDescription)")
                        return
                    }
                    guard let image = object as? UIImage else {
                        self.showAlert(message: "Failed to load image.")
                        return
                    }
                    self.imageView.image = image
                    self.analyzeImage(image)
                }
            }
        } else if isVideoFile {
            // Video flow: stage a persistent temp copy first
            for type in videoTypeIdentifiers where itemProvider.hasItemConformingToTypeIdentifier(type) {
                spinner.startAnimating()
                itemProvider.loadFileRepresentation(forTypeIdentifier: type) { [weak self] sandboxURL, error in
                    guard let self else { return }
                    if let error = error {
                        Task { @MainActor in
                            self.spinner.stopAnimating()
                            self.showAlert(message: "Failed to load video: $$error.localizedDescription)")
                        }
                        return
                    }
                    guard let sandboxURL else {
                        Task { @MainActor in
                            self.spinner.stopAnimating()
                            self.showAlert(message: "Failed to load video.")
                        }
                        return
                    }
                    
                    let ext = sandboxURL.pathExtension.isEmpty ? "mov" : sandboxURL.pathExtension
                    let tmpURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension(ext)
                    
                    do {
                        let needsAccess = sandboxURL.startAccessingSecurityScopedResource()
                        defer { if needsAccess { sandboxURL.stopAccessingSecurityScopedResource() } }
                        
                        try? FileManager.default.removeItem(at: tmpURL)
                        try FileManager.default.copyItem(at: sandboxURL, to: tmpURL)
                        
                        let thumb = self.generateThumbnail(from: tmpURL)
                        
                        Task { @MainActor in
                            if let thumb { self.thumbnail = thumb; self.imageView.image = thumb }
                            self.analyzeVideo(from: tmpURL)
                        }
                    } catch {
                        Task { @MainActor in
                            self.spinner.stopAnimating()
                            self.showAlert(message: "Failed to stage video: $$error.localizedDescription)")
                        }
                    }
                }
                break
            }
        }
    }
    
    // MARK: - Analysis
    
    private func analyzeImage(_ image: UIImage) {
        guard analyzer.analysisPolicy != .disabled else {
            showAlert(message: "Enable Sensitive Content Warning in Settings > Privacy & Security.")
            return
        }
        
        guard let cgImage = image.cgImage else {
            showAlert(message: "Invalid image data.")
            return
        }
        
        spinner.startAnimating()
        Task {
            do {
                let result = try await analyzer.analyzeImage(cgImage)
                await MainActor.run {
                    self.spinner.stopAnimating()
                    if result.isSensitive {
                        self.showAlert(message: "Image contains sensitive content.")
                        self.imageView.image = nil
                    } else {
                        self.showAlert(message: "Image is safe.")
                    }
                }
            } catch {
                await MainActor.run {
                    self.spinner.stopAnimating()
                    self.showAlert(message: "Image analysis failed: $$error.localizedDescription)")
                }
            }
        }
    }
    
    private func analyzeVideo(from url: URL) {
        guard analyzer.analysisPolicy != .disabled else {
            spinner.stopAnimating()
            showAlert(message: "Enable Sensitive Content Warning in Settings > Privacy & Security.")
            return
        }
        
        Task {
            do {
                // Retain handler strongly during analysis
                let handler = analyzer.videoAnalysis(forFileAt: url)
                self.videoHandler = handler
                
                let result = try await handler.hasSensitiveContent()
                
                await MainActor.run {
                    self.videoHandler = nil
                    self.spinner.stopAnimating()
                    if result.isSensitive {
                        self.showAlert(message: "Video contains sensitive content.")
                        self.imageView.image = nil
                    } else {
                        self.showAlert(message: "Video is safe.")
                    }
                }
            } catch {
                await MainActor.run {
                    self.videoHandler = nil
                    self.spinner.stopAnimating()
                    self.showAlert(message: "Video analysis failed: $$error.localizedDescription)")
                }
            }
            
            // Optional cleanup: remove temp file after analysis
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    // MARK: - Utilities
    
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
    
    private func showAlert(title: String = "Info", message: String) {
        // Ensure presented alert doesn’t clash with another
        if presentedViewController is UIAlertController { dismiss(animated: false) }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

