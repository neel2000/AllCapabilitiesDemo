//
//  MultitaskingCameraAccessVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 25/08/25.
//

import UIKit

class MultitaskingCameraAccessVC: UIViewController, FusumaDelegate1 {
    func fusuImageSelected(_ image: UIImage, source: FusumaMode1) {
        
    }
    
    func fusuMultipleImageSelected(_ images: [UIImage], source: FusumaMode1) {
        
    }
    
    func fusuVideoCompleted(withFileURL fileURL: URL) {
    
    }
    
    func fusuCameraRollUnauthorized() {
        
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode1, metaData: ImageMetadata1) {
        
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode1, metaData: [ImageMetadata1]) {
        
    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode1) {
        
    }
    
    func fusumaClosed() {
        
    }
    
    func fusumaWillClosed() {
    
    }
    
    func fusumaLimitReached() {
        
    }
    
 
    func cameraDidCapturePhoto(_ image: UIImage) {
        
    }
    
    func cameraDidCaptureVideo(url: URL) {
        
    }
    
    func cameraDidCancel() {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    @IBAction func btnOpenCameraAction(_ sender: Any) {
        let fusuma = FusumaVC()
        fusuma.delegate = self
        fusuma.availableModes = [.camera, .video]
        fusuma.modalPresentationStyle = .custom
        fusuma.modalTransitionStyle = .crossDissolve
//        present(fusuma, animated: true, completion: nil)
        self.present(fusuma, animated: false)
        
    }
    
}

internal extension UIColor {
    class func hex(_ hexStr: NSString, alpha: CGFloat) -> UIColor {
        let realHexStr = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: realHexStr as String)
        var color: UInt32 = 0

        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        } else {
            return UIColor.white
        }
    }
}

extension Int {
    
    func secondsToTime() -> String {
        //let (h,m,s) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
        let (m,s) = ((self % 3600) / 60, (self % 3600) % 60)
        // let h_string = h < 10 ? "0\(h)" : "\(h)"
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"
        
        // return "\(h_string):\(m_string):\(s_string)"
        return "\(m_string):\(s_string)"
    }
    
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        }
        else {
            return "\(self)"
        }
    }
}

final class FSImageCropView: UIScrollView, UIScrollViewDelegate {
    var imageView = UIImageView()
    var imageSize: CGSize?
    var image: UIImage! = nil {
        didSet {
            guard image != nil else {
                imageView.image = nil
                return
            }

            if !imageView.isDescendant(of: self) {
                imageView.alpha = 1.0
                addSubview(imageView)
            }

            guard fusumaCropImage else {
                imageView.frame = frame
                imageView.contentMode = .scaleAspectFit
                isUserInteractionEnabled = false

                imageView.image = image
                return
            }

            let imageSize = self.imageSize ?? image.size
            let ratioW = frame.width / imageSize.width // 400 / 1000 => 0.4
            let ratioH = frame.height / imageSize.height // 300 / 500 => 0.6

            if ratioH > ratioW {
                imageView.frame = CGRect(
                    origin: CGPoint.zero,
                    size: CGSize(width: imageSize.width  * ratioH, height: frame.height)
                )
            } else {
                imageView.frame = CGRect(
                    origin: CGPoint.zero,
                    size: CGSize(width: frame.width, height: imageSize.height  * ratioW)
                )
            }

            contentOffset = CGPoint(
                x: imageView.center.x - center.x,
                y: imageView.center.y - center.y
            )

            contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)

            imageView.image = image

            zoomScale = 1.0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        backgroundColor = fusumaBackgroundColor
        frame.size      = CGSize.zero
        clipsToBounds   = true

        imageView.alpha = 0.0
        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)

        maximumZoomScale = 2.0
        minimumZoomScale = 0.8
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator   = false
        bouncesZoom = true
        bounces = true
        scrollsToTop = false
        delegate = self
    }


    func changeScrollable(_ isScrollable: Bool) {
        isScrollEnabled = isScrollable
    }

    // MARK: UIScrollViewDelegate Protocol

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame

        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }

        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }

        imageView.frame = contentsFrame
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
    }
}
