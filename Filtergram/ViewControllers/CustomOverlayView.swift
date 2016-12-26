//
//  CustomOverlayView.swift
//  Filtergram
//
//  Created by MARIO EGUILUZ ALEBICTO on 26/12/2016.
//  Copyright © 2016 MARIO EGUILUZ ALEBICTO. All rights reserved.
//

import UIKit

protocol CustomOverlayDelegate: class {
    func didShoot(overlayView:CustomOverlayView)
    func didChange(configuration:CameraConfiguration)
}

public class CustomOverlayView: UIView {

    @IBOutlet weak var switchCamera: UISegmentedControl!
    @IBOutlet weak var switchFlash: UISegmentedControl!
    @IBOutlet weak var buttonShoot: UIButton!
    @IBOutlet weak var toggleVoiceRecognition: UISwitch!
    
    weak var delegate:CustomOverlayDelegate?
    var cameraConfiguration = CameraConfiguration()
    
    func didChangedConfiguration(){
        delegate?.didChange(configuration: cameraConfiguration)
    }
    
    // MARK: Actions
    
    @IBAction func shootPressed(_ sender: Any) {
        delegate?.didShoot(overlayView: self)
    }
    
    @IBAction func onVoiceCommandChanged(_ sender: Any) {
        cameraConfiguration.autoMode = toggleVoiceRecognition.isOn ? .onVoice : .off
        didChangedConfiguration()
    }
    
    @IBAction func flashModeChanged(_ sender: Any) {
        switch switchFlash.selectedSegmentIndex {
        case 0:
            cameraConfiguration.flashMode = .off
        case 1:
            cameraConfiguration.flashMode = .auto
        case 2:
            cameraConfiguration.flashMode = .on
        default:
            cameraConfiguration.flashMode = .off
        }
        didChangedConfiguration()
    }

    @IBAction func cameraTypeChanged(_ sender: Any) {
        switch switchCamera.selectedSegmentIndex {
        case 0:
            cameraConfiguration.camera = .rear
        case 1:
            cameraConfiguration.camera = .front
        default:
            cameraConfiguration.camera = .rear
        }
        didChangedConfiguration()
    }
}
