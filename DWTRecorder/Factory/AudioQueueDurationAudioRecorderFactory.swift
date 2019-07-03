//
//  AudioQueueDurationAudioRecorder.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

class AudioQueueDurationAudioRecorderFactory: BaseRecorderFactory {
    
    override func create(with parametes: Any? = nil) -> Recorder {
        
        let duration = (parametes as? TimeInterval) ?? 5.0
        
        let format = AudioRecorder.AudioStreamDescription.PCMFormat
        let recorder = DurationWithDataProviderAudioRecorder(duration: duration, audioFormat: format)
        
        let privider = AudioQueueDataProvider(audioFormat: format)
        recorder.dataProvider = privider
        
        let fileConvertor = PCM2WAVConvertor(asbd: format)
        recorder.fileConvertor = fileConvertor

        return recorder
    }
}
