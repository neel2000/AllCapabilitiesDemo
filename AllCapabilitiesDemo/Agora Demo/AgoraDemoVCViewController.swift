//
//  AgoraDemoVCViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 10/10/25.
//

/*import UIKit
import AgoraRtcKit
import AVFoundation
import AVKit

class AgoraDemoVCViewController: UIViewController {

    // MARK: - Agora
    var agoraKit: AgoraRtcEngineKit!
    let appId = "dc271dde09854d7985d96e857b378428"
    let token: String? = "007eJxTYGBldqru9T/RoeA5odBlwbX+KSeeTM295XF86tK9yXIcxacUGFKSjcwNU1JSDSwtTE1SzIFkiqVZqoWpeZKxuYWJkcWuQy8yGgIZGRKP6bEyMkAgiM/NUJJaXOKckZiXl5rDwAAAKzwidg=="
    let channelName = "testChannel"

    // MARK: - UI
    let remoteVideoView = UIView()
    let localVideoView = UIView()
    let joinButton = UIButton(type: .system)
    let leaveButton = UIButton(type: .system)
    let pipButton = UIButton(type: .system)
    let roleButton = UIButton(type: .system)


    // MARK: - PiP using sample buffer display layer
    let sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
    var pipController: AVPictureInPictureController?
    var pipSnapshotTimer: Timer?
    var ptsCounter: CMTime = .zero
    
    var selectedRole: AgoraClientRole = .broadcaster


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        initializeAgoraEngine()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sampleBufferDisplayLayer.frame = CGRect(x: 0, y: 0, width: 640, height: 360)
    }

    func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        // Add a blurred effect behind the remote video for premium depth
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
        remoteVideoView.backgroundColor = .black
        remoteVideoView.layer.cornerRadius = 20
        remoteVideoView.layer.masksToBounds = true
        remoteVideoView.layer.borderWidth = 1
        remoteVideoView.layer.borderColor = UIColor.label.withAlphaComponent(0.1).cgColor
        view.addSubview(remoteVideoView)

        // Add shadow to local view for floating effect
        localVideoView.translatesAutoresizingMaskIntoConstraints = false
        localVideoView.backgroundColor = .systemGray5
        localVideoView.layer.cornerRadius = 16
        localVideoView.layer.shadowColor = UIColor.black.cgColor
        localVideoView.layer.shadowOpacity = 0.15
        localVideoView.layer.shadowOffset = CGSize(width: 0, height: 4)
        localVideoView.layer.shadowRadius = 8
        localVideoView.layer.masksToBounds = false
        view.addSubview(localVideoView)

        // Stylish, modern buttons using configuration API
        let buttonConfig = UIButton.Configuration.filled()
        let joinButton = UIButton(configuration: buttonConfig, primaryAction: UIAction(title: "", image: UIImage(systemName: "video.fill")) { _ in self.joinTapped() })
        let leaveButton = UIButton(configuration: buttonConfig, primaryAction: UIAction(title: "", image: UIImage(systemName: "xmark.circle")) { _ in self.leaveTapped() })
        let pipButton = UIButton(configuration: buttonConfig, primaryAction: UIAction(title: "", image: UIImage(systemName: "pip")) { _ in self.pipTapped() })
        let roleButton = UIButton(configuration: buttonConfig, primaryAction: UIAction(title: "", image: UIImage(systemName: "person.2.fill")) { _ in self.selectRoleTapped() })

        for button in [joinButton, leaveButton, pipButton, roleButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 14
            button.layer.shadowColor = UIColor.label.cgColor
            button.layer.shadowOpacity = 0.14
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 6
            view.addSubview(button)
        }

        // Use stack view for control panel, responsive to orientation
        let controlsStack = UIStackView(arrangedSubviews: [joinButton, leaveButton, roleButton, pipButton])
        controlsStack.axis = .horizontal
        controlsStack.distribution = .equalSpacing
        controlsStack.spacing = 24
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            remoteVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            remoteVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            remoteVideoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            remoteVideoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            localVideoView.widthAnchor.constraint(equalToConstant: 120),
            localVideoView.heightAnchor.constraint(equalToConstant: 160),
            localVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            localVideoView.bottomAnchor.constraint(equalTo: remoteVideoView.bottomAnchor, constant: -20),

            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            controlsStack.topAnchor.constraint(equalTo: remoteVideoView.bottomAnchor, constant: 28),
            controlsStack.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    
    // MARK: - Role Selection
    @objc func selectRoleTapped() {
        let alert = UIAlertController(title: "Select Role", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Broadcaster", style: .default, handler: { _ in
            self.selectedRole = .broadcaster
            self.roleButton.setTitle("Role: Broadcaster", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Receiver", style: .default, handler: { _ in
            self.selectedRole = .audience
            self.roleButton.setTitle("Role: Receiver", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    
    // MARK: - Agora Setup
    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        config.areaCode = .global
        config.channelProfile = .liveBroadcasting
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        agoraKit.enableVideo()
        agoraKit.enableAudio()
    }

    @objc func joinTapped() {
        let localCanvas = AgoraRtcVideoCanvas()
        localCanvas.uid = 0
        localCanvas.view = localVideoView
        localCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(localCanvas)
        agoraKit.startPreview()
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        let option = AgoraRtcChannelMediaOptions()
        // In video calling, set the channel use-case to communication
        option.channelProfile = .communication
        // Set the user role as broadcaster (default is audience)
        option.clientRoleType = .broadcaster
        // Publish audio captured by microphone
        option.publishMicrophoneTrack = true
        // Publish video captured by camera
        option.publishCameraTrack = true
        // Auto subscribe to all audio streams
        option.autoSubscribeAudio = true
        // option subscribe to all video streams
        option.autoSubscribeVideo = true
        
        option.publishCameraTrack = true
        option.publishMicrophoneTrack = true
        
        agoraKit.joinChannel(byToken: token, channelId: channelName, uid: 0, mediaOptions: option) { [weak self] (channel, uid, elapsed) in
            print("Joined channel: \(channel) uid: \(uid) elapsed: \(elapsed)")
            DispatchQueue.main.async {
                self?.joinButton.isEnabled = false
                self?.leaveButton.isEnabled = true
            }
        }
    }

    @objc func leaveTapped() {
        agoraKit.leaveChannel(nil)
        agoraKit.stopPreview()
        joinButton.isEnabled = true
        leaveButton.isEnabled = false

        for subview in remoteVideoView.subviews { subview.removeFromSuperview() }
        
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - PiP controls
    @objc func pipTapped() {
        if pipController?.isPictureInPictureActive == true {
            stopPiP()
        } else {
            startPiP()
        }
    }

    func startPiP() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            showAlert("PiP not supported on this device")
            return
        }

        // 1) Start feeding sampleBufferDisplayLayer with frames (demo uses snapshots)
        startSnapshotFeeder()

        // 2) Create PiP controller using sample buffer content source (iOS 15+)
        if #available(iOS 15.0, *) {
            let contentSource = AVPictureInPictureController.ContentSource(
                sampleBufferDisplayLayer: sampleBufferDisplayLayer,
                playbackDelegate: self
            )
            pipController = AVPictureInPictureController(contentSource: contentSource)
        } else {
            showAlert("PiP sample-buffer API requires iOS 15+")
            stopSnapshotFeeder()
            return
        }

        pipController?.delegate = self
        pipController?.startPictureInPicture()
    }

    func stopPiP() {
        pipController?.stopPictureInPicture()
        pipController = nil
        stopSnapshotFeeder()
    }

    // MARK: - Snapshot feeder (demo pattern shown)
    func startSnapshotFeeder() {
        sampleBufferDisplayLayer.videoGravity = .resizeAspect
        sampleBufferDisplayLayer.controlTimebase = nil
        ptsCounter = .zero

        pipSnapshotTimer = Timer.scheduledTimer(withTimeInterval: 1.0/15.0, repeats: true) { [weak self] _ in
            self?.captureRemoteViewAndEnqueue()
        }
    }

    func stopSnapshotFeeder() {
        pipSnapshotTimer?.invalidate()
        pipSnapshotTimer = nil
    }

    func captureRemoteViewAndEnqueue() {
        guard let cgImage = remoteVideoView.asImage().cgImage else { return }
        let width = 640
        let height = Int(CGFloat(width) * CGFloat(cgImage.height) / CGFloat(cgImage.width))
        guard let pixelBuffer = cgImage.pixelBuffer(width: width, height: height) else { return }

        let duration = CMTime(value: 1, timescale: 30)
        let presentationTime = ptsCounter
        guard let sampleBuffer = SampleBufferHelper.sampleBuffer(from: pixelBuffer, pts: presentationTime, duration: duration) else { return }
        ptsCounter = CMTimeAdd(ptsCounter, duration)

        DispatchQueue.main.async {
            if self.sampleBufferDisplayLayer.status == .failed {
                self.sampleBufferDisplayLayer.flush()
            }
            self.sampleBufferDisplayLayer.enqueue(sampleBuffer)
        }
    }

    func showAlert(_ text: String) {
        let a = UIAlertController(title: "Info", message: text, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - Agora delegate
extension AgoraDemoVCViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let remoteCanvas = AgoraRtcVideoCanvas()
            remoteCanvas.uid = uid
            remoteCanvas.view = self.remoteVideoView
            remoteCanvas.renderMode = .hidden
            self.agoraKit.setupRemoteVideo(remoteCanvas)
        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        DispatchQueue.main.async { [weak self] in
            for sv in self?.remoteVideoView.subviews ?? [] { sv.removeFromSuperview() }
        }
    }
}

// MARK: - AVPictureInPictureControllerDelegate
extension AgoraDemoVCViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will start")
    }
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP did start")
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("PiP failed:", error)
    }
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will stop")
    }
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP did stop")
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
}

@available(iOS 15.0, *)
extension AgoraDemoVCViewController: AVPictureInPictureSampleBufferPlaybackDelegate {
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}

    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        return false
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        if playing {
            print("▶️ Resume playback")
        } else {
            print("⏸ Pause playback")
        }
    }

    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        return CMTimeRange(start: .zero, duration: CMTime(seconds: 3600, preferredTimescale: 600))
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime) async {
        print("Skipping by \(CMTimeGetSeconds(skipInterval)) seconds")
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CGSize) {
        print("PiP render size changed to \(newRenderSize)")
    }
}

// MARK: - Helpers for pixel buffer/sample buffer
fileprivate extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in layer.render(in: ctx.cgContext) }
    }
}

fileprivate extension CGImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pb: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary

        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pb)
        guard status == kCVReturnSuccess, let pixelBuffer = pb else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let pxData = CVPixelBufferGetBaseAddress(pixelBuffer)!

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pxData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            return nil
        }
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        return pixelBuffer
    }
}

fileprivate extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        return self.cgImage?.pixelBuffer(width: width, height: height)
    }
}

fileprivate struct SampleBufferHelper {
    static func sampleBuffer(from pixelBuffer: CVPixelBuffer, pts: CMTime, duration: CMTime) -> CMSampleBuffer? {
        var format: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &format)
        guard status == kCVReturnSuccess, let fmt = format else { return nil }
        var sampleBuffer: CMSampleBuffer?
        var timing = CMSampleTimingInfo(duration: duration, presentationTimeStamp: pts, decodeTimeStamp: CMTime.invalid)
        let err = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: pixelBuffer,
                                                     dataReady: true,
                                                     makeDataReadyCallback: nil,
                                                     refcon: nil,
                                                     formatDescription: fmt,
                                                     sampleTiming: &timing,
                                                     sampleBufferOut: &sampleBuffer)
        if err != noErr {
            return nil
        }
        return sampleBuffer
    }
}*/

import UIKit
import AgoraRtcKit
import AVFoundation
import AVKit

class AgoraDemoVCViewController: UIViewController {

    // MARK: - Agora
    var agoraKit: AgoraRtcEngineKit!
    let appId = "dc271dde09854d7985d96e857b378428"
    let token: String? = "007eJxTYGBldqru9T/RoeA5odBlwbX+KSeeTM295XF86tK9yXIcxacUGFKSjcwNU1JSDSwtTE1SzIFkiqVZqoWpeZKxuYWJkcWuQy8yGgIZGRKP6bEyMkAgiM/NUJJaXOKckZiXl5rDwAAAKzwidg=="
    let channelName = "testChannel"

    // MARK: - UI
    let remoteVideoView = UIView()
    let localVideoView = UIView()
    let joinButton = UIButton(type: .system)
    let leaveButton = UIButton(type: .system)
    let pipButton = UIButton(type: .system)
    let roleButton = UIButton(type: .system)


    // MARK: - PiP using sample buffer display layer
    let sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
    var pipController: AVPictureInPictureController?
    var pipSnapshotTimer: Timer?
    var ptsCounter: CMTime = .zero
    
    var selectedRole: AgoraClientRole = .broadcaster


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        initializeAgoraEngine()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sampleBufferDisplayLayer.frame = CGRect(x: 0, y: 0, width: 640, height: 360)
    }

    func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        // Add a blurred effect behind the remote video for premium depth
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
        remoteVideoView.backgroundColor = .black
        remoteVideoView.layer.cornerRadius = 20
        remoteVideoView.layer.masksToBounds = true
        remoteVideoView.layer.borderWidth = 1
        remoteVideoView.layer.borderColor = UIColor.label.withAlphaComponent(0.1).cgColor
        view.addSubview(remoteVideoView)

        // Add shadow to local view for floating effect
        localVideoView.translatesAutoresizingMaskIntoConstraints = false
        localVideoView.backgroundColor = .systemGray5
        localVideoView.layer.cornerRadius = 16
        localVideoView.layer.shadowColor = UIColor.black.cgColor
        localVideoView.layer.shadowOpacity = 0.15
        localVideoView.layer.shadowOffset = CGSize(width: 0, height: 4)
        localVideoView.layer.shadowRadius = 8
        localVideoView.layer.masksToBounds = false
        view.addSubview(localVideoView)

        // Stylish, modern buttons using configuration API
        let buttonConfig = UIButton.Configuration.filled()
        let joinButton = UIButton(configuration: buttonConfig, primaryAction: UIAction(title: "", image: UIImage(systemName: "video.fill")) { _ in self.joinTapped() })
        let leaveButton = UIButton(configuration: buttonConfig, primaryAction: UIAction(title: "", image: UIImage(systemName: "xmark.circle")) { _ in self.leaveTapped() })
        let pipButton = UIButton(configuration: buttonConfig, primaryAction: UIAction(title: "", image: UIImage(systemName: "pip")) { _ in self.pipTapped() })
        let roleButton = UIButton(configuration: buttonConfig, primaryAction: UIAction(title: "", image: UIImage(systemName: "person.2.fill")) { _ in self.selectRoleTapped() })

        for button in [joinButton, leaveButton, pipButton, roleButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 14
            button.layer.shadowColor = UIColor.label.cgColor
            button.layer.shadowOpacity = 0.14
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 6
            view.addSubview(button)
        }

        // Use stack view for control panel, responsive to orientation
        let controlsStack = UIStackView(arrangedSubviews: [joinButton, leaveButton, roleButton, pipButton])
        controlsStack.axis = .horizontal
        controlsStack.distribution = .equalSpacing
        controlsStack.spacing = 24
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            remoteVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            remoteVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            remoteVideoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            remoteVideoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            localVideoView.widthAnchor.constraint(equalToConstant: 120),
            localVideoView.heightAnchor.constraint(equalToConstant: 160),
            localVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            localVideoView.bottomAnchor.constraint(equalTo: remoteVideoView.bottomAnchor, constant: -20),

            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            controlsStack.topAnchor.constraint(equalTo: remoteVideoView.bottomAnchor, constant: 28),
            controlsStack.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    
    // MARK: - Role Selection
    @objc func selectRoleTapped() {
        let alert = UIAlertController(title: "Select Role", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Broadcaster", style: .default, handler: { _ in
            self.selectedRole = .broadcaster
            self.roleButton.setTitle("Role: Broadcaster", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Receiver", style: .default, handler: { _ in
            self.selectedRole = .audience
            self.roleButton.setTitle("Role: Receiver", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    
    // MARK: - Agora Setup
    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        config.areaCode = .global
        config.channelProfile = .liveBroadcasting
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        agoraKit.enableVideo()
        agoraKit.enableAudio()
    }

    @objc func joinTapped() {
        let localCanvas = AgoraRtcVideoCanvas()
        localCanvas.uid = 0
        localCanvas.view = localVideoView
        localCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(localCanvas)
        agoraKit.startPreview()
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        let option = AgoraRtcChannelMediaOptions()
        // In video calling, set the channel use-case to communication
        option.channelProfile = .communication
        // Set the user role as broadcaster (default is audience)
        option.clientRoleType = .broadcaster
        // Publish audio captured by microphone
        option.publishMicrophoneTrack = true
        // Publish video captured by camera
        option.publishCameraTrack = true
        // Auto subscribe to all audio streams
        option.autoSubscribeAudio = true
        // option subscribe to all video streams
        option.autoSubscribeVideo = true
        
        option.publishCameraTrack = true
        option.publishMicrophoneTrack = true
        
        agoraKit.joinChannel(byToken: token, channelId: channelName, uid: 0, mediaOptions: option) { [weak self] (channel, uid, elapsed) in
            print("Joined channel: \(channel) uid: \(uid) elapsed: \(elapsed)")
            DispatchQueue.main.async {
                self?.joinButton.isEnabled = false
                self?.leaveButton.isEnabled = true
            }
        }
    }

    @objc func leaveTapped() {
        agoraKit.leaveChannel(nil)
        agoraKit.stopPreview()
        joinButton.isEnabled = true
        leaveButton.isEnabled = false

        for subview in remoteVideoView.subviews { subview.removeFromSuperview() }
        
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - PiP controls
    @objc func pipTapped() {
        if pipController?.isPictureInPictureActive == true {
            stopPiP()
        } else {
            startPiP()
        }
    }

    func startPiP() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            showAlert("PiP not supported on this device")
            return
        }

        // 1) Start feeding sampleBufferDisplayLayer with frames (demo uses snapshots)
        startSnapshotFeeder()

        // 2) Create PiP controller using sample buffer content source (iOS 15+)
        if #available(iOS 15.0, *) {
            let contentSource = AVPictureInPictureController.ContentSource(
                sampleBufferDisplayLayer: sampleBufferDisplayLayer,
                playbackDelegate: self
            )
            pipController = AVPictureInPictureController(contentSource: contentSource)
        } else {
            showAlert("PiP sample-buffer API requires iOS 15+")
            stopSnapshotFeeder()
            return
        }

        pipController?.delegate = self
        pipController?.startPictureInPicture()
    }

    func stopPiP() {
        pipController?.stopPictureInPicture()
        pipController = nil
        stopSnapshotFeeder()
    }

    // MARK: - Snapshot feeder (demo pattern shown)
    func startSnapshotFeeder() {
        sampleBufferDisplayLayer.videoGravity = .resizeAspect
        sampleBufferDisplayLayer.controlTimebase = nil
        ptsCounter = .zero

        pipSnapshotTimer = Timer.scheduledTimer(withTimeInterval: 1.0/15.0, repeats: true) { [weak self] _ in
            self?.captureRemoteViewAndEnqueue()
        }
    }

    func stopSnapshotFeeder() {
        pipSnapshotTimer?.invalidate()
        pipSnapshotTimer = nil
    }

    func captureRemoteViewAndEnqueue() {
        guard let cgImage = remoteVideoView.asImage().cgImage else { return }
        let width = 640
        let height = Int(CGFloat(width) * CGFloat(cgImage.height) / CGFloat(cgImage.width))
        guard let pixelBuffer = cgImage.pixelBuffer(width: width, height: height) else { return }

        let duration = CMTime(value: 1, timescale: 30)
        let presentationTime = ptsCounter
        guard let sampleBuffer = SampleBufferHelper.sampleBuffer(from: pixelBuffer, pts: presentationTime, duration: duration) else { return }
        ptsCounter = CMTimeAdd(ptsCounter, duration)

        DispatchQueue.main.async {
            if self.sampleBufferDisplayLayer.status == .failed {
                self.sampleBufferDisplayLayer.flush()
            }
            self.sampleBufferDisplayLayer.enqueue(sampleBuffer)
        }
    }

    func showAlert(_ text: String) {
        let a = UIAlertController(title: "Info", message: text, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - Agora delegate
extension AgoraDemoVCViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let remoteCanvas = AgoraRtcVideoCanvas()
            remoteCanvas.uid = uid
            remoteCanvas.view = self.remoteVideoView
            remoteCanvas.renderMode = .hidden
            self.agoraKit.setupRemoteVideo(remoteCanvas)
        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        DispatchQueue.main.async { [weak self] in
            for sv in self?.remoteVideoView.subviews ?? [] { sv.removeFromSuperview() }
        }
    }
}

// MARK: - AVPictureInPictureControllerDelegate
extension AgoraDemoVCViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will start")
    }
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP did start")
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("PiP failed:", error)
    }
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will stop")
    }
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        stopSnapshotFeeder()
        print("PiP did stop")
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
}

@available(iOS 15.0, *)
extension AgoraDemoVCViewController: AVPictureInPictureSampleBufferPlaybackDelegate {
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}

    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        return false
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        if playing {
            print("▶️ Resume playback")
        } else {
            print("⏸ Pause playback")
        }
    }

    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        return CMTimeRange(start: .zero, duration: CMTime(seconds: 3600, preferredTimescale: 600))
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime) async {
        print("Skipping by \(CMTimeGetSeconds(skipInterval)) seconds")
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CGSize) {
        print("PiP render size changed to \(newRenderSize)")
    }
}

// MARK: - Helpers for pixel buffer/sample buffer
fileprivate extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in layer.render(in: ctx.cgContext) }
    }
}

fileprivate extension CGImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pb: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary

        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pb)
        guard status == kCVReturnSuccess, let pixelBuffer = pb else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let pxData = CVPixelBufferGetBaseAddress(pixelBuffer)!

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pxData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            return nil
        }
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        return pixelBuffer
    }
}

fileprivate extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        return self.cgImage?.pixelBuffer(width: width, height: height)
    }
}

fileprivate struct SampleBufferHelper {
    static func sampleBuffer(from pixelBuffer: CVPixelBuffer, pts: CMTime, duration: CMTime) -> CMSampleBuffer? {
        var format: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &format)
        guard status == kCVReturnSuccess, let fmt = format else { return nil }
        var sampleBuffer: CMSampleBuffer?
        var timing = CMSampleTimingInfo(duration: duration, presentationTimeStamp: pts, decodeTimeStamp: CMTime.invalid)
        let err = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: pixelBuffer,
                                                     dataReady: true,
                                                     makeDataReadyCallback: nil,
                                                     refcon: nil,
                                                     formatDescription: fmt,
                                                     sampleTiming: &timing,
                                                     sampleBufferOut: &sampleBuffer)
        if err != noErr {
            return nil
        }
        return sampleBuffer
    }
}
