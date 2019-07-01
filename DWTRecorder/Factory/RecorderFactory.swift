//
//  RecorderFactory.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import AVFoundation

protocol RecorderFactory {
    init()
    func create(with parameters: Any?) -> Recorder
}
