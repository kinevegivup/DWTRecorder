//
//  AssertExportSessionDurationAudioRecorderFactory.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

class AssertExportSessionDurationAudioRecorderFactory: BaseRecorderFactory {
    override func create(with parameters: Any? = nil) -> Recorder {
        let duration = (parameters as? TimeInterval) ?? 5.0
        return DurationByAssertSessionAudioRecorder(duration: duration)
    }
}
