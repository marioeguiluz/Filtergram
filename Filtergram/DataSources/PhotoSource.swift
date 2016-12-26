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

enum DeviceError {
    case sourceTypeNotAvailable
    case mediaTypeNotAvailable
    case captureModeNotAvailable
    case permissionNotGranted
    case permissionNotDetermined
}

enum CameraAvailableResult {
    case failure(DeviceError)
    case success
}

protocol PhotoSourceDelegate: class, UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    var imagePicker: UIImagePickerController {get}
    func didGrantedCameraAuthorizationStatus(flag:Bool)
    func willPresentFilterViewController(with image:UIImage)
}

final class PhotoSource: NSObject {
    
    var imageTaken: UIImage?
    var imageInfo: [String : Any] = [:]
    
    weak var delegate:PhotoSourceDelegate?
    
    var cameraConfiguration: CameraConfiguration? {
        didSet {
            guard let delegate = delegate else {
                assert(true, "PhotoSource in cameraConfiguration: needs a delegate")
                return
            }
            
            guard let configuration = cameraConfiguration else {
                assert(true, "PhotoSource in cameraConfiguration: needs a configuration")
                return
            }
            
            delegate.imagePicker.cameraDevice = configuration.camera
            delegate.imagePicker.cameraFlashMode = configuration.flashMode
            
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
        
        imageTaken = image
        self.imageInfo = imageInfo
        
        //push new controller
        delegate.willPresentFilterViewController(with:image)
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
