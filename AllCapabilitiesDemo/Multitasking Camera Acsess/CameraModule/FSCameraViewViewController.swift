//
//  FSCameraView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import Photos

struct THEME_COLOR {
    let theme_pink_color = UIColor(named: "bg_pink") ?? UIColor.hex("F26A66", alpha: 1)
}

@objc protocol FSCameraViewDelegate1: class {
    func cameraShotFinished(_ image: UIImage)
    func videoButtonPressed()
}

final class FSCameraViewViewController: UIView, UIGestureRecognizerDelegate {

    @IBOutlet weak var btnUltraWideAngle: UIButton!
    @IBOutlet weak var btnWideAngle: UIButton!
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var fullAspectRatioConstraint: NSLayoutConstraint!
    
    var croppedAspectRatioConstraint: NSLayoutConstraint?
    var initialCaptureDevicePosition: AVCaptureDevice.Position = .back

    weak var delegate: FSCameraViewDelegate1? = nil

    private var session: AVCaptureSession?
    private var device: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var imageOutput: AVCaptureStillImageOutput?
    private var videoLayer: AVCaptureVideoPreviewLayer?

    private var focusView: UIView?

    private var flashOffImage: UIImage?
    private var flashOnImage: UIImage?

    private var motionManager: CMMotionManager?
    private var currentDeviceOrientation: UIDeviceOrientation?
    private var zoomFactor: CGFloat = 1.0

    var isUltraWideCamera: Bool = false

    static func instance() -> FSCameraViewViewController {
        return UINib(nibName: "FSCameraViewViewController", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSCameraViewViewController
    }

    func initialize() {

        guard session == nil else { return }
        
        UserDefaults.standard.set(false, forKey: "isFlashOnPhotoStory")

        self.backgroundColor = UIColor.black//fusumaBackgroundColor

        let bundle = Bundle(for: self.classForCoder)

        self.btnUltraWideAngle.superview?.superview?.isHidden = !(hasUltraWideCamera())
        self.btnUltraWideAngle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.btnWideAngle.setTitleColor(THEME_COLOR().theme_pink_color, for: .normal)

        flashOnImage = fusumaFlashOnImage != nil ? fusumaFlashOnImage : UIImage(named: "story_flashOn_ic", in: bundle, compatibleWith: nil)
        flashOffImage = fusumaFlashOffImage != nil ? fusumaFlashOffImage : UIImage(named: "story_flashOff_ic", in: bundle, compatibleWith: nil)
        let flipImage = fusumaFlipImage != nil ? fusumaFlipImage : UIImage(named: "story_rotate_ic", in: bundle, compatibleWith: nil)
//        let shotImage = fusumaShotImage != nil ? fusumaShotImage : UIImage(named: "Camera", in: bundle, compatibleWith: nil)

        flashButton.tintColor = fusumaBaseTintColor
        flipButton.tintColor  = fusumaBaseTintColor
        shotButton.tintColor  = fusumaBaseTintColor

//        flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: .normal)
//        flipButton.setImage(flipImage?.withRenderingMode(.alwaysOriginal), for: .normal)
//        shotButton.setImage(shotImage?.withRenderingMode(.alwaysOriginal), for: .normal)

        isHidden = false

        // AVCapture
        session = AVCaptureSession()

        guard let session = session else { return }

        for device in AVCaptureDevice.devices() {
            if device.position == initialCaptureDevicePosition {
                self.device = device

                if !device.hasFlash {
                    flashButton.isHidden = true
                }
            }
        }

        if let device = device, let _videoInput = try? AVCaptureDeviceInput(device: device) {
            videoInput = _videoInput
            session.addInput(videoInput!)

            imageOutput = AVCaptureStillImageOutput()

            session.addOutput(imageOutput!)

            videoLayer = AVCaptureVideoPreviewLayer(session: session)
            videoLayer?.frame = previewViewContainer.bounds
            videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

            previewViewContainer.layer.addSublayer(videoLayer!)

            session.sessionPreset = AVCaptureSession.Preset.photo
            
            // Configure the capture session.
            session.beginConfiguration()

            if #available(iOS 16.0, *) {
                if session.isMultitaskingCameraAccessSupported {
                    // Enable use of the camera in multitasking modes.
                    session.isMultitaskingCameraAccessEnabled = true
                }
            } else {
                // Fallback on earlier versions
            }
            session.commitConfiguration()

            session.startRunning()

            // Focus View
            focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(FSCameraViewViewController.focus(_:)))
            tapRecognizer.delegate = self
            previewViewContainer.addGestureRecognizer(tapRecognizer)
        }

        flashConfiguration()
        
        //startCamera()
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            DispatchQueue.main.async {
                self.session?.startRunning()
            }
            motionManager = CMMotionManager()
            motionManager!.accelerometerUpdateInterval = 0.2
            motionManager!.startAccelerometerUpdates(to: OperationQueue()) { [unowned self] (data, _) in
                if let data = data {
                    if abs(data.acceleration.y) < abs(data.acceleration.x) {
                        self.currentDeviceOrientation = data.acceleration.x > 0 ? .landscapeRight : .landscapeLeft
                    } else {
                        self.currentDeviceOrientation = data.acceleration.y > 0 ? .portraitUpsideDown : .portrait
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in
                self?.stopCamera()
            }
        default:
            break
        }
        

        NotificationCenter.default.addObserver(self, selector: #selector(FSCameraViewViewController.willEnterForegroundNotification(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchToZoom))
        previewViewContainer.addGestureRecognizer(pinchGestureRecognizer)
    }

    @objc func willEnterForegroundNotification(_ notification: Notification) {
        startCamera()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
//            DispatchQueue.main.async {
//                self.session?.startRunning()
//            }
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.session?.startRunning()
            }
            motionManager = CMMotionManager()
            motionManager!.accelerometerUpdateInterval = 0.2
            motionManager!.startAccelerometerUpdates(to: OperationQueue()) { [unowned self] (data, _) in
                if let data = data {
                    if abs(data.acceleration.y) < abs(data.acceleration.x) {
                        self.currentDeviceOrientation = data.acceleration.x > 0 ? .landscapeRight : .landscapeLeft
                    } else {
                        self.currentDeviceOrientation = data.acceleration.y > 0 ? .portraitUpsideDown : .portrait
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in
                self?.stopCamera()
            }
        default:
            break
        }
    }

    func stopCamera() {
        session?.stopRunning()
        motionManager?.stopAccelerometerUpdates()
        currentDeviceOrientation = nil
    }
    
    @IBAction func btnVideoPressed(_ sender: Any) {
   
        delegate?.videoButtonPressed()
    }
    
    @IBAction func shotButtonPressed(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        guard let imageOutput = imageOutput else {
            return
        }

        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            guard let videoConnection = imageOutput.connection(with: AVMediaType.video) else { return }

            // Configure flash
            if let device = self.device, device.hasFlash {
                do {
                    try device.lockForConfiguration()
                    device.flashMode = UserDefaults.standard.bool(forKey: "isFlashOnPhotoStory") ? .on : .off
                    device.unlockForConfiguration()
                } catch {
                    print("Error configuring flash: \(error.localizedDescription)")
                }
            }

            imageOutput.captureStillImageAsynchronously(from: videoConnection) { (buffer, error) -> Void in
                self.stopCamera()

                guard let buffer = buffer,
                    let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
                    let image = UIImage(data: data),
                    let cgImage = image.cgImage,
                    let delegate = self.delegate,
                    let videoLayer = self.videoLayer
                else {
                    return
                }

                let rect   = videoLayer.metadataOutputRectConverted(fromLayerRect: videoLayer.bounds)
                let width  = CGFloat(cgImage.width)
                let height = CGFloat(cgImage.height)

                let cropRect = CGRect(x: rect.origin.x * width,
                                      y: rect.origin.y * height,
                                      width: rect.size.width * width,
                                      height: rect.size.height * height)

                guard let img = cgImage.cropping(to: cropRect) else {
                    return
                }

                let croppedUIImage = UIImage(cgImage: img, scale: 1.0, orientation: self.videoInput?.device.position == AVCaptureDevice.Position.back ? image.imageOrientation : .leftMirrored)

                DispatchQueue.main.async(execute: { () -> Void in
                    sender.isUserInteractionEnabled = true
                    delegate.cameraShotFinished(croppedUIImage)

                    if fusumaSavesImage {
                        self.saveImageToCameraRoll(image: croppedUIImage)
                    }

                    self.session       = nil
                    self.videoLayer    = nil
                    self.device        = nil
                    self.imageOutput   = nil
                    self.motionManager = nil
                })
            }
        })
    }

    @IBAction func flipButtonPressed(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        
        guard cameraIsAvailable else {
            sender.isUserInteractionEnabled = true
            return
        }

        // Begin session reconfiguration
        session?.beginConfiguration()

        // Remove the current video input
        if let currentInput = videoInput {
            session?.removeInput(currentInput)
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
            session?.commitConfiguration()
            sender.isUserInteractionEnabled = true
            return
        }

        // Create a new video input
        do {
            let newVideoInput = try AVCaptureDeviceInput(device: newDevice)
            
            // Add the new video input to the session
            if session?.canAddInput(newVideoInput) == true {
                session?.addInput(newVideoInput)
                videoInput = newVideoInput
            } else {
                session?.commitConfiguration()
                sender.isUserInteractionEnabled = true
                return
            }
        } catch {
            print("Error creating video input: \(error.localizedDescription)")
            session?.commitConfiguration()
            sender.isUserInteractionEnabled = true
            return
        }

        // Commit the session configuration
        session?.commitConfiguration()

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
        sender.isUserInteractionEnabled = true
    }

    @IBAction func flashButtonPressed(_ sender: UIButton) {
        if !cameraIsAvailable { return }

        if isUltraWideCamera { return }

        if videoInput?.device.position == AVCaptureDevice.Position.front {
            
        } else {
            
            do {
                guard let device = device, device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
//                switch device.torchMode {
//                case .off:
//                    device.torchMode = .on
//                    UserDefaults.standard.set(true, forKey: "isFlashOnPhotoStory")
//                    flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
//                case .on:
//                    device.torchMode = .off
//                    UserDefaults.standard.set(false, forKey: "isFlashOnPhotoStory")
//                    flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
//                default:
//                    break
//                }

                if UserDefaults.standard.bool(forKey: "isFlashOnPhotoStory") {
                    UserDefaults.standard.set(false, forKey: "isFlashOnPhotoStory")
                    flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
                } else {
                    UserDefaults.standard.set(true, forKey: "isFlashOnPhotoStory")
                    flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
                }

                device.unlockForConfiguration()
            } catch _ {
                flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
                
                return
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
        UserDefaults.standard.set(false, forKey: "isFlashOnPhoto")
        flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())

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

fileprivate extension FSCameraViewViewController {
    func saveImageToCameraRoll(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: nil)
    }

    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)

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

        guard let focusView = self.focusView else { return }

        focusView.alpha = 0.0
        focusView.center = point
        focusView.backgroundColor = UIColor.clear
        focusView.layer.borderColor = fusumaBaseTintColor.cgColor
        focusView.layer.borderWidth = 1.0
        focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        addSubview(focusView)

        UIView.animate(withDuration: 0.8,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations:{
                        focusView.alpha = 1.0
                        focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished) in
            focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            focusView.removeFromSuperview()
        })
    }

    func flashConfiguration() {

        do {
            if let device = device {
                guard device.hasFlash else { return }

                try device.lockForConfiguration()
                
                if UserDefaults.standard.value(forKey: "isFlashOnPhotoStory") as? Bool == true {
                    if videoInput?.device.position == AVCaptureDevice.Position.front {
                      
                    } else {
//                        device.torchMode = .on
                        flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
                    }
                } else {
//                    device.torchMode = .off
                    flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
                }
                
                device.unlockForConfiguration()
            }
        } catch _ {
            return
        }
    }

    var cameraIsAvailable: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

        if status == AVAuthorizationStatus.authorized {
            return true
        }

        return false
    }
}

// Check ultra wide angle camera
func hasUltraWideCamera() -> Bool {
    // Create a discovery session to find all available camera devices
    let discoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera],
        mediaType: .video,
        position: .back
    )

    // Check if any of the devices is an ultra-wide camera
    for device in discoverySession.devices {
        if device.deviceType == .builtInUltraWideCamera {
            return true
        }
    }

    return false
}
