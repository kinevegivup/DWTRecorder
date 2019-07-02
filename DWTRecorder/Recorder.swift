//
//  Recorder.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/24.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

typealias RecorderCallback = (_ isSuccess: Bool, _ url: URL?) -> Void
typealias RecorderRecordingCallback = (_ time: TimeInterval) -> Void

protocol RecorderDelegate: class {
    func recorder(_ recorder: Recorder, didFinishWith url: URL?)
    func recorder(_ recorder: Recorder, didRecordAt time: Timer.TimeEvent)
}

// Default delegate implementation.
extension RecorderDelegate {
    func recorder(_ recorder: Recorder, didFinishWith url: URL?) {}
    func recorder(_ recorder: Recorder, didRecordAt time: Timer.TimeEvent) {}
}

// Abstract class.
class Recorder: NSObject {
    
    // Callback properties.
    weak var delegate: RecorderDelegate?
    var callback: RecorderCallback?
    var recordingCallback: RecorderRecordingCallback?
    
    var isRecording: Bool { return false }
    
    // Url for recoder file.
    var localUrl: URL?
    
    // File convertor.
    var fileConvertor: MediaFileConvertor?
    
    // Whether enable timer for progress.
    var isTimerEnabled = false
    lazy var timer: Timer? = isTimerEnabled ? Timer({[weak self] (event) in
        guard let strongSelf = self else { return }
        strongSelf.delegate?.recorder(strongSelf, didRecordAt: event)
    }) : nil

    // Template methods.
    func prepareToRecord() {}
    func record(_ callback: RecorderCallback? = nil,
                recordingCallback: RecorderRecordingCallback? = nil) { fatalError() }
    func stop() { fatalError() }
    func pause() { fatalError() }
    func resume() { fatalError() }
}

