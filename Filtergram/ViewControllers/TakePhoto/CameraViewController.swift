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
        //startCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCamera()
    }
    
    // MARK: Camera methods
    
    func startCamera() {
        let cameraAvailable = datasource.shouldStartCamera(with: .camera, mediaType: .camera)
        switch cameraAvailable {
        case .success:
            presentCustomCamera()
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
    
    func presentCustomCamera() {
        picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.delegate = self
        picker.allowsEditing = false
        picker.cameraCaptureMode = .photo
        picker.showsCameraControls = false
        picker.mediaTypes = ["public.image"]
        picker.modalPresentationStyle = .fullScreen
        picker.cameraFlashMode = .auto
        
        //let screenSize:CGSize = UIScreen.main.bounds.size
        //let ratio:CGFloat = 4.0 / 3.0
        //let cameraHeight:CGFloat = screenSize.width * ratio
        //let scale:CGFloat = screenSize.height / cameraHeight
        //Put Camera full screen. Resulting image will have less zoom (we can correct it by applying the same scale factor to the image taken)
        //picker.cameraViewTransform = CGAffineTransform(translationX: 0, y: (screenSize.height - cameraHeight) / 2.0)
        //picker.cameraViewTransform = picker.cameraViewTransform.scaledBy(x: scale, y: scale)
        
        let customViewController = CustomCameraViewController()
        let customView:CustomOverlayView = customViewController.view as! CustomOverlayView
        customView.frame = self.picker.view.frame
        customView.delegate = datasource
        
        present(picker, animated: true, completion: {
            self.picker.cameraOverlayView = customView
        })
    }
    
    func showCameraNotAvailableAlert(with error:DeviceError) {
        let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showCameraGrantPermissionsAlert() {
        let alert = UIAlertController(title: "Hey!", message: "Camera access required for taking photos", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            guard let url = NSURL(string: UIApplicationOpenSettingsURLString) as? URL else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Helper methods
    
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
        
        guard let image = datasource.imageTaken,
            let navController = navigationController
        else {
            assert(true, "CameraViewController in willPresentFilterViewController: guard")
            return
        }
        
        let nextVC = FaceDetectionViewController(nibName: "FaceDetectionViewController", bundle: nil)
        let nextDatasource = FaceDetectionSource(image: image, imageInfo: datasource.imageInfo, cameraConfiguration:datasource.cameraConfiguration)
        nextVC.datasource = nextDatasource

        navController.isNavigationBarHidden = true
        navController.pushViewController(nextVC, animated: true)
        picker.dismiss(animated: false, completion: nil)
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

