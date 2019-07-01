//
//  NativeWrappedAudioRecorder.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

class NativeWrappedAudioRecorderFactory: BaseRecorderFactory {
    override func create(with parameters: Any? = nil) -> Recorder {
        return NativeWrappedAudioRecorder()
    }
}
