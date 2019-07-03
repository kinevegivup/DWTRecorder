//
//  MediaDataProvider.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/29.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

protocol MediaDataProviderDelegate: class {
    func mediaDataProviderDelegate(_ provider: MediaDataProvider, didProvide data: Data, extra: Any?)
}

class MediaDataProvider: NSObject {
    
    weak var delegate: MediaDataProviderDelegate?
    var isWorking = false
    
    func start() {
        fatalError()
    }
    
    func stop() {
        fatalError()
    }
}
