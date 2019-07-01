//
//  VoiceRecorder.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/24.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorder: Recorder {
    
    struct AudioFormat {
        static let PCMFormat: AVAudioFormat = {
            var asbd = AudioStreamDescription.PCMFormat
            return AVAudioFormat(streamDescription: &asbd)!
        }()
    }
    
    struct AudioStreamDescription {
        static let PCMFormat: AudioStreamBasicDescription = {
            
            var asbd = AudioStreamBasicDescription()
            
            asbd.mFormatID = kAudioFormatLinearPCM
            asbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
            
            asbd.mSampleRate = 44100.0
            asbd.mBitsPerChannel = 16
            
            asbd.mChannelsPerFrame = 1
            
            asbd.mBytesPerFrame = (asbd.mBitsPerChannel / 8) * asbd.mChannelsPerFrame
            asbd.mBytesPerPacket = asbd.mBytesPerFrame
            asbd.mFramesPerPacket = asbd.mBytesPerPacket / asbd.mBytesPerFrame
            
            return asbd
        }()
    }
}
