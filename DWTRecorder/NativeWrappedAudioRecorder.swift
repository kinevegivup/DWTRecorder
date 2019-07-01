//
//  NativeWrappedAudioRecorder.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/29.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

class NativeWrappedAudioRecorder: AudioRecorder {
    
    private(set) var recorder: AVAudioRecorder!
    override var isRecording: Bool { return recorder.isRecording }
    
    var audioFormat: AVAudioFormat! = AudioFormat.PCMFormat
    
    // MARK: - Contructors.
    init(_ recorder: AVAudioRecorder? = nil) {
        super.init()
        
        self.recorder = recorder
        if nil == recorder {
            let url = URL.temporaryFileUrl("wav")
            self.recorder = try? AVAudioRecorder(url: url, format: audioFormat)
        }
        
        self.localUrl = self.recorder?.url
        self.recorder.delegate = self
    }
    
    // MARK: - Template methods.
    
    override func record(_ callback: RecorderCallback? = nil, recordingCallback: RecorderRecordingCallback? = nil) {
        self.callback = callback
        self.recordingCallback = recordingCallback
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission {[unowned self] (isAllowed) in
            guard isAllowed else { return }
            
            do {
                try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try audioSession.setActive(true)
                
                self.recorder.prepareToRecord()
                self.recorder.record()
            } catch {
                print(error)
            }
        }
    }
    
    override func stop() {
        recorder.stop()
    }
    
    override func pause() {
        recorder.pause()
    }
    
    override func resume() {
        recorder.record()
    }
    
}


extension NativeWrappedAudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        callback?(false, nil)
        delegate?.recorder(self, didFinishWith: nil)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        callback?(flag, flag ? localUrl : nil)
        delegate?.recorder(self, didFinishWith: flag ? localUrl : nil)
    }
}
