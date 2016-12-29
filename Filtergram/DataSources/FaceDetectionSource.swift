//
//  FaceDetectionSource.swift
//  Filtergram
//
//  Created by MARIO EGUILUZ ALEBICTO on 27/12/2016.
//  Copyright © 2016 MARIO EGUILUZ ALEBICTO. All rights reserved.
//

import Foundation
import UIKit
import CoreImage


final class FaceDetectionSource {
    
    var imageTaken: UIImage?
    var imageInfo: [String : Any] = [:]
    var cameraConfiguration:CameraConfiguration?
    
    init(image:UIImage, imageInfo:[String : Any], cameraConfiguration:CameraConfiguration) {
        imageTaken = image
        self.imageInfo = imageInfo
        self.cameraConfiguration = cameraConfiguration
    }
    
    //Comment
    func detectFaces(imageView:UIImageView, completion: @escaping ([UIView]) -> Void) {
        
        //Execute in Background
        DispatchQueue.global().async {
            
            var viewsForFaces:[UIView] = []
            let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            
            defer {
                //Return completion to main thread
                DispatchQueue.main.async {
                    completion(viewsForFaces)
                }
            }
            
            guard let uiimage = imageView.image,
                let ciImage = CIImage(image:uiimage),
                let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: CIContext(), options: accuracy)
                else {
                    return
            }
            
            let imageOptions : [String:Any] = [CIDetectorImageOrientation : self.imageOrientationToExif(image:uiimage), CIDetectorSmile : true, CIDetectorEyeBlink : true]
            let faces = faceDetector.features(in: ciImage, options: imageOptions)
            
            //Core Image Coordinates to UIView Coordinates
            let ciImageSize = ciImage.extent.size
            var transform = CGAffineTransform(scaleX: 1, y: -1)
            transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
            
            for face in faces as! [CIFaceFeature] {
                
                //Apply the transform to convert the coordinates
                var faceViewBounds = face.bounds.applying(transform)
                
                //Calculate the actual position and size of the rectangle in the image view
                let viewSize = imageView.bounds.size
                let scale = min(viewSize.width / ciImageSize.width,
                                viewSize.height / ciImageSize.height)
                let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
                let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
                
                faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                faceViewBounds.origin.x += offsetX
                faceViewBounds.origin.y += offsetY
                
                let faceBox = UIView(frame: faceViewBounds)
                faceBox.layer.borderWidth = 2
                faceBox.layer.borderColor = face.hasSmile ? UIColor.green.cgColor : UIColor.red.cgColor
                faceBox.backgroundColor = UIColor.clear
                
                viewsForFaces.append(faceBox)
            }
        }
    }
    
    func imageOrientationToExif(image: UIImage) -> uint {
        switch image.imageOrientation {
        case UIImageOrientation.up:
            return 1;
        case UIImageOrientation.down:
            return 3;
        case UIImageOrientation.left:
            return 8;
        case UIImageOrientation.right:
            return 6;
        case UIImageOrientation.upMirrored:
            return 2;
        case UIImageOrientation.downMirrored:
            return 4;
        case UIImageOrientation.leftMirrored:
            return 5;
        case UIImageOrientation.rightMirrored:
            return 7;
        }
    }
}
