//
//  FaceDetectionViewController.swift
//  Filtergram
//
//  Created by MARIO EGUILUZ ALEBICTO on 27/12/2016.
//  Copyright © 2016 MARIO EGUILUZ ALEBICTO. All rights reserved.
//

import UIKit

class FaceDetectionViewController: UIViewController {

    var datasource:FaceDetectionSource?
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var labelFacesDetected: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = datasource else {
            assert(true, "FaceDetectionViewController in viewDidLoad: datasource must exists")
            return
        }
        loadImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawFaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Image and Faces

    func loadImage() {
        imageViewPhoto.image = datasource?.imageTaken
    }
    
    func drawFaces() {
        guard let datasource = datasource else {
            assert(true, "FaceDetectionViewController in viewDidLoad: datasource must exists")
            return
        }
        
        datasource.detectFaces(imageView: imageViewPhoto) { [weak self] (viewsForFaces) in
            guard viewsForFaces.count > 0 else {
                self?.labelFacesDetected.text = "No faces detected 😔"
                return
            }
    
            self?.labelFacesDetected.text = "\(viewsForFaces.count) faces detected 😃"
            for view in viewsForFaces {
                self?.imageViewPhoto.addSubview(view)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func retakePressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
    
    }
}
