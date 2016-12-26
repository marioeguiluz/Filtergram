//
//  ViewController.swift
//  Filtergram
//
//  Created by MARIO EGUILUZ ALEBICTO on 15/12/2016.
//  Copyright © 2016 MARIO EGUILUZ ALEBICTO. All rights reserved.
//

import UIKit

final class CameraViewController: UIViewController {

    var picker = UIImagePickerController()
    var datasource: PhotoSource!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasource = PhotoSource(delegate:self)
        startCamera()
    }
    
    // MARK: Camera methods
    
    func startCamera() {
        let cameraAvailable = datasource.shouldStartCamera(with: .camera, mediaType: .camera)
        switch cameraAvailable {
        case .success:
            initCustomCamera()
        case .failure(let error):
            if error == .permissionNotGranted {
                showCameraGrantPermissionsAlert()
            }
            else if error != .permissionNotDetermined {
                showCameraNotAvailableAlert(with:error)
            }
            return
        }
    }
    
    func initCustomCamera() {
        picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.delegate = self
        picker.allowsEditing = false
        picker.cameraCaptureMode = .photo
        picker.showsCameraControls = false
        picker.mediaTypes = ["public.image"]
        picker.modalPresentationStyle = .fullScreen
        picker.cameraFlashMode = .auto
        
        let customViewController = CustomCameraViewController(nibName:"CustomCameraViewController", bundle: nil)
        let customView:CustomOverlayView = customViewController.view as! CustomOverlayView
        customView.frame = self.picker.view.frame
        customView.delegate = datasource
        
        present(picker, animated: true, completion: {
            self.picker.cameraOverlayView = customView
        })
    }
    
    func showCameraNotAvailableAlert(with error:DeviceError) {
        var errorMessage = "Error message"
        switch error {
        case .captureModeNotAvailable:
            errorMessage = "Capture Mode Not Available"
        case .mediaTypeNotAvailable:
            errorMessage = "Media Type Not Available"
        case .sourceTypeNotAvailable:
            errorMessage = "Source Type Not Available"
        case .permissionNotGranted:
            errorMessage = "Camera Permission Not Granted"
        case .permissionNotDetermined:
            errorMessage = "Source Type Not Determined yet"
        }
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showCameraGrantPermissionsAlert() {
        let alert = UIAlertController(title: "Hey!", message: "Camera access required for this app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            guard let url = NSURL(string: UIApplicationOpenSettingsURLString) as? URL else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension CameraViewController: PhotoSourceDelegate {
    
    internal var imagePicker: UIImagePickerController {
        get {
            return picker
        }
    }
    
    func didGrantedCameraAuthorizationStatus(flag:Bool) {
        startCamera()
    }

    func willPresentFilterViewController(with image:UIImage) {
        //push new controller
    }
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let datasource = datasource, let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            assert(true, "CameraViewController in didFinishPickingMediaWithInfo: guard")
            return
        }
        datasource.didTake(image: image, imageInfo: info)
    }
}

