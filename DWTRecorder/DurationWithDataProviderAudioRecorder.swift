//
//  LastDurationAudioRecorder.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/26.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

class DurationWithDataProviderAudioRecorder: AudioRecorder {
    
    var dataProvider: MediaDataProvider?
    
    // Audio parameters.
    private var bytesLimited = 0
    private(set) var audioFormat: AudioStreamBasicDescription!
    var duration: TimeInterval = 0
    
    override var isRecording: Bool { return dataProvider?.isWorking ?? false }
    
    // Data container.
    private lazy var dataContainer = Data()
    
    init(duration: TimeInterval, audioFormat: AudioStreamBasicDescription = AudioRecorder.AudioStreamDescription.PCMFormat) {
        super.init()
        
        self.duration = duration
        self.audioFormat = audioFormat
        
        self.initBytesLimited()
    }
    
    func initBytesLimited() {
        self.bytesLimited = Int(Double(duration) * Double(audioFormat.mSampleRate) * Double(audioFormat.mBytesPerFrame))
    }
    
    override func prepareToRecord() {
        dataProvider?.delegate = self
    }
    
    override func record(_ callback: RecorderCallback? = nil, recordingCallback: RecorderRecordingCallback? = nil) {
        self.callback = callback
        self.recordingCallback = recordingCallback
        
        prepareToRecord()
        
        dataProvider?.start()
    }
    
    override func stop() {
        
        guard isRecording else { return }
        dataProvider?.stop()
        
        handleEndEvent()
    }
    
    override func pause() {
        stop()
    }
    
    override func resume() {
        record(self.callback, recordingCallback: self.recordingCallback)
    }
    
    private func handleEndEvent() {
        let url = URL.temporaryFileUrl("pcm")
        localUrl = url
        
        do {

            try dataContainer.write(to: url)
            
            localUrl = fileConvertor?.convert(from: localUrl!, to: nil) ?? localUrl
            delegate?.recorder(self, didFinishWith: localUrl)
            
            dataContainer.removeAll()
            
        } catch {
            delegate?.recorder(self, didFinishWith: nil)
            print(error)
        }
    }
}

extension DurationWithDataProviderAudioRecorder: MediaDataProviderDelegate {
    func mediaDataProviderDelegate(_ provider: MediaDataProvider, didProvide data: Data, extra: Any?) {
        dataContainer.append(data)
        
        if extra != nil && audioFormat == nil, let af = extra as? AudioStreamBasicDescription {
            audioFormat = af
            initBytesLimited()
        }
        
        let count = dataContainer.count
        if bytesLimited > 0 && count > bytesLimited {
            dataContainer.removeSubrange(0..<(count - bytesLimited))
        }
    }
}
