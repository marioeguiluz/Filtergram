//
//  PhotoManager.swift
//  Filtergram
//
//  Created by MARIO EGUILUZ ALEBICTO on 15/12/2016.
//  Copyright © 2016 MARIO EGUILUZ ALEBICTO. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


enum CameraAvailableResult {
    case failure(DeviceError)
    case success
}

enum DeviceError : CustomStringConvertible {
    case sourceTypeNotAvailable
    case mediaTypeNotAvailable
    case captureModeNotAvailable
    case permissionNotGranted
    case permissionNotDetermined
    
    var description: String {
        switch self {
        case .captureModeNotAvailable:
            return "Capture Mode not available"
        case .mediaTypeNotAvailable:
            return "Media Type not available"
        case .sourceTypeNotAvailable:
            return "Source Type not available"
        case .permissionNotGranted:
            return "Camera Permission not granted"
        case .permissionNotDetermined:
            return "Source Type not determined"
        }
    }
}

protocol PhotoSourceDelegate: class, UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    var imagePicker: UIImagePickerController {get}
    func didGrantedCameraAuthorizationStatus(flag:Bool)
    func willPresentFilterViewController(with image:UIImage)
}

final class PhotoSource: NSObject {
    
    weak var delegate:PhotoSourceDelegate?
    var imageTaken: UIImage?
    var imageInfo: [String : Any] = [:]
    var cameraConfiguration = CameraConfiguration() {
        didSet {
            guard let delegate = delegate else {
                assert(true, "PhotoSource in cameraConfiguration: needs a delegate")
                return
            }
            
            delegate.imagePicker.cameraDevice = cameraConfiguration.camera
            delegate.imagePicker.cameraFlashMode = cameraConfiguration.flashMode
            
            //Voice detection
            //configuration.autoMode
        }
    }
    
    // MARK: Init
    
    init(delegate:PhotoSourceDelegate) {
        self.delegate = delegate
    }
    
    // MARK: Camera Availability and permissions
    
    func shouldStartCamera(with sourceType:UIImagePickerControllerSourceType, mediaType:UIImagePickerControllerSourceType) -> CameraAvailableResult {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) == true else {
            return .failure(.sourceTypeNotAvailable)
        }
        
        guard UIImagePickerController.availableMediaTypes(for: sourceType)?.contains("public.image") == true else {
            return .failure(.mediaTypeNotAvailable)
        }
        
        guard UIImagePickerController.availableCaptureModes(for: .rear) != nil || UIImagePickerController.availableCaptureModes(for: .front) != nil else {
            return .failure(.captureModeNotAvailable)
        }
        
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .denied: return .failure(.permissionNotGranted)
        case .authorized: return .success
        case .restricted: return .success
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { granted in
                DispatchQueue.main.async {
                    self.delegate?.didGrantedCameraAuthorizationStatus(flag:granted)
                }
            }
            return .failure(.permissionNotDetermined)
        }
    }
    
    // MARK: Methods
    
    func didTake(image:UIImage, imageInfo: [String : Any]) {
        
        guard let delegate = delegate else {
            assert(true, "PhotoSource in didTake: needs a delegate")
            return
        }
        
        //Image has metada indicating that is in landscape mode (even when taking it in portrait).
        //We need to modify it show later when detecting faces the Detector has the correct orientation
        imageTaken = fixOrientation(img: image)
        self.imageInfo = imageInfo
        
        //push new controller
        delegate.willPresentFilterViewController(with:image)
    }
    
    func fixOrientation(img:UIImage) -> UIImage {
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
}

extension PhotoSource: CustomOverlayDelegate {
    
    func didShoot(overlayView: CustomOverlayView) {
        delegate?.imagePicker.takePicture()
    }
    
    func didChange(configuration: CameraConfiguration) {
        cameraConfiguration = configuration
    }
}
