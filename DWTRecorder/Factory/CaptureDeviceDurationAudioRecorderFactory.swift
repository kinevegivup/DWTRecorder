//
//  CaptureDeviceDurationAudioRecorderFactory.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

class CaptureDeviceDurationAudioRecorderFactory: BaseRecorderFactory {
    override func create(with parameters: Any? = nil) -> Recorder {
        
        let duration = (parameters as? TimeInterval) ?? 5.0
        
        let format = AudioRecorder.AudioStreamDescription.PCMFormat
        let recorder = DurationByDataProviderAudioRecorder(duration: duration, audioFormat: format)
        
        let privider = AudioCaptureDeviceDataProvider()
        recorder.dataProvider = privider
        
        let fileConvertor = PCM2WAVConvertor(asbd: format)
        recorder.fileConvertor = fileConvertor
        
        return recorder
    }
}
