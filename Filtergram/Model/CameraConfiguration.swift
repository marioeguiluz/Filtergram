//
//  CameraConfiguration.swift
//  Filtergram
//
//  Created by MARIO EGUILUZ ALEBICTO on 15/12/2016.
//  Copyright © 2016 MARIO EGUILUZ ALEBICTO. All rights reserved.
//

import UIKit

enum CameraAutoMode {
    case off
    case onVoice
}

struct CameraConfiguration {
    var camera:UIImagePickerControllerCameraDevice = .rear
    var flashMode:UIImagePickerControllerCameraFlashMode = .off
    var autoMode:CameraAutoMode = .off
}
