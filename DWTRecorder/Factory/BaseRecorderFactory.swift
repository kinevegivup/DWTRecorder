//
//  BaseRecorderFactory.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

class BaseRecorderFactory: RecorderFactory {
    
    required init() {}
    
    func create(with parameters: Any?) -> Recorder {
        return Recorder()
    }
}
