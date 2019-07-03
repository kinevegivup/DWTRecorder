//
//  AudioCaptureDeviceDataProvider.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/29.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

class AudioCaptureDeviceDataProvider: AudioDataProvider {
    
    /// Handle queue to capture device.
    private lazy var queue: DispatchQueue = DispatchQueue(label: "com.dwt.\(self)")
    
    /// Capture session.
    private lazy var captureSession = AVCaptureSession()
    private var isAsbdNeed = true
    
    deinit {
        stop()
    }
    
    func prepare() {
        
        guard let device = AVCaptureDevice.default(for: .audio),
            let input = try? AVCaptureDeviceInput(device: device) else {
                return
        }
        
        guard captureSession.canAddInput(input) else { return }
        captureSession.addInput(input)
        
        let output = AVCaptureAudioDataOutput()
        guard captureSession.canAddOutput(output) else { return }
        captureSession.addOutput(output)
        
        output.setSampleBufferDelegate(self, queue: queue)
    }
    
    override func start() {
        
        stop()
        
        prepare()
    
        captureSession.startRunning()
        
        isWorking = true
    }
    
    override func stop() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
        isAsbdNeed = true
        isWorking = false
    }
}

extension AudioCaptureDeviceDataProvider: AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool { () -> Void in
            
            guard let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer) else { return }
            let length = CMBlockBufferGetDataLength(blockBufferRef)
            
            var asbd: UnsafePointer<AudioStreamBasicDescription>?
            if isAsbdNeed {
                isAsbdNeed = false
                let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer)
                asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc!)
            }
            
            let buffer = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: 1)
            CMBlockBufferCopyDataBytes(blockBufferRef, atOffset: 0, dataLength: length, destination: buffer)
            let data = Data(bytes: buffer, count: length)
            delegate?.mediaDataProviderDelegate(self, didProvide: data, extra: asbd?.pointee)
        }
    }
}
