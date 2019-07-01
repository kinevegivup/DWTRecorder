//
//  AudioQueueDataProvider.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/29.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class AudioQueueDataProvider: AudioDataProvider {
    
    /// Number of buffers in audio queue.
    var numberOfBuffers: Int = 3
    
    /// Buffer size. Default is 2KB.
    var bufferSize: Int = 2048
    
    lazy var audioFormat = AudioStreamBasicDescription()
    
    
    init(audioFormat: AudioStreamBasicDescription) {
        super.init()
        
        self.audioFormat = audioFormat
    }
    
    // Audio queue relations.
    private var audioQueue: AudioQueueRef?
    private var audioQueueBuffers: [AudioQueueBufferRef] = {
        return []
    }()
    
    // MARK:-
    // MARK: Life cycles.
    
    deinit {
        stop()
    }
    
    // MARK:-
    // MARK: Public interface.
    
    func prepareToRecord() {
        
        // Configure audio session.
        configureAudioSession()
        
        // Set call back function.
        let selfPointer = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        AudioQueueNewInput(&audioFormat, audioQueueCallback, selfPointer, nil, nil, 0, &audioQueue)
        AudioQueueReset(audioQueue!)
        
        for _ in 0..<numberOfBuffers {
            var audioQueuebuffer: AudioQueueBufferRef? = nil
            AudioQueueAllocateBuffer(audioQueue!, UInt32(bufferSize), &audioQueuebuffer);
            AudioQueueEnqueueBuffer(audioQueue!, audioQueuebuffer!, 0, nil);
            audioQueueBuffers.append(audioQueuebuffer!)
        }
    }
    
    // MARK:-
    // MARK: Recording.
    
    func clearAudioQueue() {
    
        if noErr == AudioQueueStop(audioQueue!, true) {
            audioQueueBuffers.forEach { (buffer) in
                AudioQueueFreeBuffer(audioQueue!, buffer)
            }
            audioQueueBuffers.removeAll()
        }
        
        AudioQueueDispose(audioQueue!, true);
        audioQueue = nil
        
        delegate = nil
    }
    
    override func start() {
        
        guard !isWorking else { return }
        
        // Set flag.
        isWorking = true
        
        prepareToRecord()
        
        AudioQueueStart(audioQueue!, nil)
    }
    
    override func stop() {
        // Stop it in Audio queue.
        guard isWorking else { return }
        isWorking = false
        
        clearAudioQueue()
    }
    
}

extension AudioQueueDataProvider {
    
    func configureAudioSession() {
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if #available(iOS 10.0, *) {
                do {
                    let options: AVAudioSession.CategoryOptions = [.defaultToSpeaker, .allowBluetooth, .mixWithOthers]
                    try audioSession.setCategory(.playAndRecord, mode: .default, options: options)
                }
            } else {
                try audioSession.setCategory(.playAndRecord)
            }
            
            for inputPort in audioSession.availableInputs ?? [] {
                if inputPort.portType == .usbAudio {
                    try audioSession.setPreferredInput(inputPort)
                    try audioSession.setPreferredInputNumberOfChannels(2)
                    break
                }
            }
            
            try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
            for portDesc in audioSession.currentRoute.outputs {
                if portDesc.portType == .builtInReceiver {
                    try audioSession.overrideOutputAudioPort(.speaker)
                    break
                }
            }
            
        } catch let error {
            print("Set audio session with error: \(error)")
        }
    }
    
}

extension AudioQueueDataProvider {
    
    func handleData(_ pointer: UnsafeMutableRawPointer, size: Int) {
        guard isWorking else { return }
        
        let data = Data(bytes: pointer, count: size)
        delegate?.recordingDataProvider(self, didProvide: data, extra: nil)
    }
}

// MARK: -
// MARK: Callback for audio queue.

func audioQueueCallback(_ a :UnsafeMutableRawPointer?, _ b : AudioQueueRef, _ c :AudioQueueBufferRef,
                        _ d :UnsafePointer<AudioTimeStamp>, _ e :UInt32, _ f :UnsafePointer<AudioStreamPacketDescription>?) {
    
    guard e > 0 else { return }
    
    let this = Unmanaged<AudioQueueDataProvider>.fromOpaque(a!).takeUnretainedValue()
    this.handleData(c.pointee.mAudioData, size: Int(c.pointee.mAudioDataByteSize))
    AudioQueueEnqueueBuffer(b, c, 0, nil);
}


