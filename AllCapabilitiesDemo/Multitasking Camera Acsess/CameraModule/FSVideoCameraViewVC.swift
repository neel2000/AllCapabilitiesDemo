//
//  FSVideoCameraView.swift
//  Fusuma
//
//  Created by Brendan Kirchner on 3/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol FSVideoCameraViewDelegate1: class {
    func videoFinishedFusu(withFileURL fileURL: URL)
    func photoButtonPressed()
}

final class FSVideoCameraViewVC: UIView {
    
    @IBOutlet weak var btnUltraWideAngle: UIButton!
    @IBOutlet weak var btnWideAngle: UIButton!
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var lblStoryTimer: UILabel!
    

    weak var delegate: FSVideoCameraViewDelegate1? = nil

    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var videoOutput: AVCaptureMovieFileOutput?
    var focusView: UIView?

    var flashOffImage: UIImage?
    var flashOnImage: UIImage?
    var videoStartImage: UIImage?
    var videoStopImage: UIImage?

    private var zoomFactor: CGFloat = 1.0
    private var isRecording = false
    
    private var recordingStartTimer : Timer?
    var tempCounter = 0

    var isUltraWideCamera: Bool = false

    static func instance() -> FSVideoCameraViewVC {
        return UINib(nibName: "FSVideoCameraViewVC", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSVideoCameraViewVC
    }

    func initialize() {
        if session != nil { return }
        
        UserDefaults.standard.set(false, forKey: "isFlashOnVideoStory")


        backgroundColor = UIColor.black//fusumaBackgroundColor

        self.btnUltraWideAngle.superview?.superview?.isHidden = !(hasUltraWideCamera())
        self.btnUltraWideAngle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.btnWideAngle.setTitleColor(THEME_COLOR().theme_pink_color, for: .normal)

        isHidden = false

        // AVCapture
        session = AVCaptureSession()

        guard let session = session else { return }

        for device in AVCaptureDevice.devices() {
            if device.position == AVCaptureDevice.Position.back {
                self.device = device
            }
        }

        guard let device = device else { return }

        // 30FPS frame rate
        do {
            try device.lockForConfiguration()

            // Set the desired frame rate (e.g., 30 FPS)
            let desiredFrameRate: Int32 = 30
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: desiredFrameRate)
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: desiredFrameRate)

            device.unlockForConfiguration() // Always unlock after changes
        } catch {
            print("Error locking device for configuration: \(error.localizedDescription)")
        }

        do {
            videoInput = try AVCaptureDeviceInput(device: device)

            session.addInput(videoInput!)
            
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioInput = try AVCaptureDeviceInput.init(device: audioDevice!)
            session.addInput(audioInput)

            videoOutput = AVCaptureMovieFileOutput()
            let totalSeconds = 60.0 //Total Seconds of capture time
            let timeScale: Int32 = 30 //FPS

            let maxDuration = CMTimeMakeWithSeconds(totalSeconds, preferredTimescale: timeScale)

            videoOutput?.maxRecordedDuration = maxDuration
            videoOutput?.minFreeDiskSpaceLimit = 1024 * 1024 //SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME

            if session.canAddOutput(videoOutput!) {
                session.addOutput(videoOutput!)

                // Stabilization
                if let videoConnection = videoOutput?.connection(with: .video) {
                    if videoConnection.isVideoStabilizationSupported {
                        videoConnection.preferredVideoStabilizationMode = .auto
                        print("Video Stabilization Enabled: \(videoConnection.activeVideoStabilizationMode.rawValue)")
                    } else {
                        print("Video Stabilization Not Supported")
                    }
                }
            }

            let videoLayer = AVCaptureVideoPreviewLayer(session: session)
            videoLayer.frame = self.previewViewContainer.bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

            previewViewContainer.layer.addSublayer(videoLayer)
            
            // Configure the capture session.
            session.beginConfiguration()

            if session.isMultitaskingCameraAccessSupported {
                // Enable use of the camera in multitasking modes.
                session.isMultitaskingCameraAccessEnabled = true
            }
            session.commitConfiguration()

            session.startRunning()

            // Focus View
            focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FSVideoCameraViewVC.focus(_:)))
            previewViewContainer.addGestureRecognizer(tapRecognizer)
            
            tempCounter = 0
            self.lblStoryTimer.text = "\(tempCounter.secondsToTime())"
        } catch {
        }

        let bundle = Bundle(for: self.classForCoder)

        flashOnImage = fusumaFlashOnImage != nil ? fusumaFlashOnImage : UIImage(named: "story_flashOn_ic", in: bundle, compatibleWith: nil)
        flashOffImage = fusumaFlashOffImage != nil ? fusumaFlashOffImage : UIImage(named: "story_flashOff_ic", in: bundle, compatibleWith: nil)
        let flipImage = fusumaFlipImage != nil ? fusumaFlipImage : UIImage(named: "story_rotate_ic", in: bundle, compatibleWith: nil)
        videoStartImage = fusumaVideoStartImage != nil ? fusumaVideoStartImage : UIImage(named: "Camera", in: bundle, compatibleWith: nil)
        videoStopImage = fusumaVideoStopImage != nil ? fusumaVideoStopImage : UIImage(named: "ic_shutter_recording", in: bundle, compatibleWith: nil)

        flashButton.tintColor = fusumaBaseTintColor
        flipButton.tintColor  = fusumaBaseTintColor
        shotButton.tintColor  = fusumaBaseTintColor

        flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        flipButton.setImage(flipImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        shotButton.setImage(videoStartImage?.withRenderingMode(.alwaysOriginal), for: .normal)

        flashConfiguration()
        startCamera()

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchToZoom))
        previewViewContainer.addGestureRecognizer(pinchGestureRecognizer)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func startCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if status == AVAuthorizationStatus.authorized {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session?.startRunning()
            }
        } else if status == AVAuthorizationStatus.denied ||
                    status == AVAuthorizationStatus.restricted {
            DispatchQueue.main.async { [weak self] in
                self?.session?.stopRunning()
            }
        }
        flashConfiguration()
    }

    func stopCamera() {
        
        recordingStartTimer?.invalidate()
        recordingStartTimer = nil
        
        if isRecording {
            toggleRecording()
        }

        session?.stopRunning()
    }
    
    

    @IBAction func shotButtonPressed(_ sender: UIButton) {
        toggleRecording()
        if isRecording {
            runRecordingStartTimer()
        }
    }
    
    @available(iOS 10.0, *)
    func runRecordingStartTimer() {
        self.lblStoryTimer.text = "\(tempCounter.secondsToTime())"
        self.recordingStartTimer?.invalidate()
        self.recordingStartTimer = nil
        self.lblStoryTimer.isHidden = false
        self.recordingStartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: tempCounter != 15, block: { timer in
            self.tempCounter+=1
            debugPrint("Decrease Timer", self.tempCounter)
            debugPrint(self.tempCounter)
            self.lblStoryTimer.text = "\(self.tempCounter.secondsToTime())"
            if self.tempCounter == 15 {
                self.recordingStartTimer?.invalidate()
                self.recordingStartTimer = nil
                self.lblStoryTimer.isHidden = true
                  self.stopCamera()
//                self.videoOutput!.stopRecording()
//                self.flipButton.isEnabled = true
//                self.flashButton.isEnabled = true
//                self.shotButton.tintColor = fusumaBaseTintColor
                // self.cameraManager?.stopRecording()
                // self.setupStartButton()
            }
        })
    }

    @IBAction func flipButtonPressed(_ sender: UIButton) {
        guard let session = session else { return }

        // Begin session reconfiguration
        session.beginConfiguration()

        // Remove the current video input
        for input in session.inputs {
            session.removeInput(input)
        }

        // Determine the new camera position
        let newPosition: AVCaptureDevice.Position = (videoInput?.device.position == .front) ? .back : .front

        // Find the new camera device
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: newPosition
        )

        guard let newDevice = deviceDiscoverySession.devices.first else {
            session.commitConfiguration()
            return
        }

        // Create a new video input
        do {
            let newVideoInput = try AVCaptureDeviceInput(device: newDevice)
            
            // Add the new video input to the session
            if session.canAddInput(newVideoInput) {
                session.addInput(newVideoInput)
                videoInput = newVideoInput
            } else {
                session.commitConfiguration()
                return
            }

            // Add audio input
            if let audioDevice = AVCaptureDevice.default(for: .audio) {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                }
            }
        } catch {
            print("Error creating device input: \(error.localizedDescription)")
            session.commitConfiguration()
            return
        }

        // Update flash button visibility
        flashButton.isHidden = (newPosition == .front)

        // Commit the session configuration
        session.commitConfiguration()

        // Update flash configuration if needed
        if newPosition == .back {
            self.btnWideAngle.superview?.superview?.isHidden = !(hasUltraWideCamera())
            flashConfiguration()
        } else {
            self.btnWideAngle.superview?.superview?.isHidden = true
            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        }

        self.isUltraWideCamera = false
        self.btnWideAngle.transform = .identity
        self.btnUltraWideAngle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        self.btnWideAngle.setTitleColor(THEME_COLOR().theme_pink_color, for: .normal)
        self.btnUltraWideAngle.setTitleColor(.white, for: .normal)

        // Add a flip animation for a smoother transition
        UIView.transition(
            with: previewViewContainer, // Your preview layer's container view
            duration: 0.5,
            options: [.transitionFlipFromLeft, .curveEaseInOut],
            animations: nil,
            completion: nil
        )
    }
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        delegate?.photoButtonPressed()
    }

    @IBAction func flashButtonPressed(_ sender: UIButton) {

        if isUltraWideCamera { return }

        if videoInput?.device.position == AVCaptureDevice.Position.front {
        
            
        } else {
            // check if the device has torch
            if let avDevice = AVCaptureDevice.default(for: .video), avDevice.hasTorch {
                // lock your device for configuration
                do {
                    let abv = try avDevice.lockForConfiguration()
                } catch {
                    print("aaaa")
                }
                
                // check if your torchMode is on or off. If on turns it off otherwise turns it on
                if avDevice.isTorchActive {
                    UserDefaults.standard.set(false, forKey: "isFlashOnVideoStory")
                    avDevice.torchMode = AVCaptureDevice.TorchMode.off
                    flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    // sets the torch intensity to 100%
                    UserDefaults.standard.set(true, forKey: "isFlashOnVideoStory")
                    do {
                        try avDevice.setTorchModeOn(level: 1.0)
                    } catch {
                        print("bbb")
                    }
                    flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
                // unlock your device
                avDevice.unlockForConfiguration()
            }
        }
        
    }

    @objc private func handlePinchToZoom(_ pinch: UIPinchGestureRecognizer) {
        guard let device = device else { return }

        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor)
        }

        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                debugPrint(error)
            }
        }

        let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)

        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            zoomFactor = minMaxZoom(newScaleFactor)
            update(scale: zoomFactor)
        default: break
        }
    }

    @IBAction func btnUltraWideAngleAction(_ sender: Any) {
        if isUltraWideCamera { return }
        self.btnUltraWideAngle.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.3) {
            self.btnUltraWideAngle.transform = .identity
            self.btnWideAngle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

            self.btnUltraWideAngle.setTitleColor(THEME_COLOR().theme_pink_color, for: .normal)
            self.btnWideAngle.setTitleColor(.white, for: .normal)
        }

        self.isUltraWideCamera = true
        self.switchCameraToZoomFactor(0.5)
    }

    @IBAction func btnWideAngleAction(_ sender: Any) {
        if !isUltraWideCamera { return }
        self.btnWideAngle.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.3) {
            self.btnWideAngle.transform = .identity
            self.btnUltraWideAngle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

            self.btnWideAngle.setTitleColor(THEME_COLOR().theme_pink_color, for: .normal)
            self.btnUltraWideAngle.setTitleColor(.white, for: .normal)
        }

        self.isUltraWideCamera = false
        self.switchCameraToZoomFactor(1)
    }

    func switchCameraToZoomFactor(_ zoomFactor: CGFloat) {
        guard let session = self.session else { return }

        self.shotButton.isUserInteractionEnabled = false
        UserDefaults.standard.set(false, forKey: "isFlashOnVideo")
        flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: .normal)

        session.beginConfiguration()

        // Remove existing video inputs
        if let currentInput = videoInput {
            session.removeInput(currentInput)
        }

        var newDevice: AVCaptureDevice?

        if zoomFactor == 0.5 {
            // Use Ultra-Wide Camera for 0.5x zoom
            newDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)
        } else {
            // Use Wide Camera for 1x zoom
            newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }

        guard let selectedDevice = newDevice, let newInput = try? AVCaptureDeviceInput(device: selectedDevice) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(newInput) {
            session.addInput(newInput)
            videoInput = newInput
        }

        session.commitConfiguration()
        animateCameraSwitch()
    }

    func animateCameraSwitch() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.previewViewContainer.alpha = 0.0
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    self.previewViewContainer.alpha = 1.0
                    self.shotButton.isUserInteractionEnabled = true
                    self.btnUltraWideAngle.isUserInteractionEnabled = true
                    self.btnWideAngle.isUserInteractionEnabled = true
                }
            }
        }
    }
}

extension FSVideoCameraViewVC: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("started recording to: \(fileURL)")
    }

    func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("finished recording to: \(outputFileURL)")
        //        delegate?.videoFinishedFusu(withFileURL: outputFileURL)
        let asset = AVAsset(url: outputFileURL)
        let composition = AVMutableComposition()
        guard let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video).last else { return }
//        let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video).last!
        let trackTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        do {
            
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                    preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            try? compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration),
                                                        of: assetVideoTrack,
                                                        at: CMTime.zero)
            
            if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first,
               let audioCompositionTrack = composition
                .addMutableTrack(withMediaType: AVMediaType.audio,
                                 preferredTrackID: kCMPersistentTrackID_Invalid) {
                try audioCompositionTrack.insertTimeRange(trackTimeRange, of: audioTrack, at: CMTime.zero)
            }
            
            let position = videoInput?.device.position == AVCaptureDevice.Position.front ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front
            
            if videoInput?.device.position == AVCaptureDevice.Position.back {
                compositionVideoTrack?.preferredTransform = assetVideoTrack.preferredTransform
            } else {
                compositionVideoTrack?.preferredTransform = CGAffineTransform(scaleX: -1.0, y: 1.0).rotated(by: CGFloat(Double.pi/2))
            }
            
            if let exporter = AVAssetExportSession(asset: composition,
                                                   presetName: AVAssetExportPreset1280x720 /*AVAssetExportPreset640x480*/) { //AVAssetExportPreset1280x720
                let outputFileUrl = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), "\(NSUUID().uuidString).mov"])
                exporter.outputURL = outputFileUrl
                exporter.outputFileType = AVFileType.mov
                exporter.shouldOptimizeForNetworkUse = true
                exporter.exportAsynchronously() {
                    DispatchQueue.main.async {
                        if let url = exporter.outputURL, exporter.status == .completed {
//                            Common_Class().hide_hud()
                            print(url)
                            self.delegate?.videoFinishedFusu(withFileURL: url)
                        } else {
                            let error = exporter.error
                            print("error exporting video \(String(describing: error))")
                        }
                    }
                }
            }
        } catch let error {
//            Common_Class().hide_hud()
            print("⚠️ PHCachingImageManager >>> \(error)")
        }
    }
}

fileprivate extension FSVideoCameraViewVC {
    func toggleRecording() {
        guard let videoOutput = videoOutput else { return }

        isRecording = !isRecording
        self.btnPhoto.isEnabled = !isRecording

        let shotImage = isRecording ? videoStopImage : videoStartImage

        self.shotButton.setImage(shotImage, for: UIControl.State())

        if isRecording {
            let outputPath = "\(NSTemporaryDirectory())output.mov"
            let outputURL = URL(fileURLWithPath: outputPath)

            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: outputPath) {
                do {
                    try fileManager.removeItem(atPath: outputPath)
                } catch {
                    print("error removing item at path: \(outputPath)")
                    self.isRecording = false
                    return
                }
            }

            flipButton.isEnabled = false
            flashButton.isEnabled = false
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
            shotButton.tintColor = UIColor.hex("ff6965", alpha: 1)
            self.btnUltraWideAngle.superview?.superview?.isHidden = true
        } else {
//            Common_Class().show()
            videoOutput.stopRecording()
            self.recordingStartTimer?.invalidate()
            self.recordingStartTimer = nil
            flipButton.isEnabled = true
            flashButton.isEnabled = true
            shotButton.tintColor = .white
            self.btnUltraWideAngle.superview?.superview?.isHidden = !(hasUltraWideCamera())
        }
    }

    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        let point    = recognizer.location(in: self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y / viewsize.height, y: 1.0-point.x / viewsize.width)

        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }

        do {
            try device.lockForConfiguration()
        } catch _ {
            return
        }

        if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) == true {
            device.focusMode = AVCaptureDevice.FocusMode.autoFocus
            device.focusPointOfInterest = newPoint
        }

        if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) == true {
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.exposurePointOfInterest = newPoint
        }

        device.unlockForConfiguration()

        guard let focusView = focusView else { return }

        focusView.alpha  = 0.0
        focusView.center = point
        focusView.backgroundColor   = UIColor.clear
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 1.0
        focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        addSubview(focusView)

        UIView.animate(
            withDuration: 0.8,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 3.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: {
                focusView.alpha = 1.0
                focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: { finished in
            focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            focusView.removeFromSuperview()
        })
    }

    func flashConfiguration() {
        do {
            if let device = device {
                guard device.hasFlash else { return }

                try device.lockForConfiguration()
                
                if UserDefaults.standard.value(forKey: "isFlashOnVideoStory") as? Bool == true {
                    if videoInput?.device.position == AVCaptureDevice.Position.front {
                      
                    } else {
                        device.torchMode = .on
                        flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
                    }
                } else {
                    device.torchMode = .off
                    flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
                }
                
                device.unlockForConfiguration()
            }
        } catch _ {
            return
        }
    }
    
}
