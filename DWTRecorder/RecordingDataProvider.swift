//
//  MediaDataProvider.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/29.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

protocol RecordingDataProviderDelegate: class {
    func recordingDataProvider(_ provider: RecordingDataProvider, didProvide data: Data, extra: Any?)
}

class RecordingDataProvider: NSObject {
    
    weak var delegate: RecordingDataProviderDelegate?
    var isWorking = false
    
    func start() {
        fatalError()
    }
    
    func stop() {
        fatalError()
    }
}
