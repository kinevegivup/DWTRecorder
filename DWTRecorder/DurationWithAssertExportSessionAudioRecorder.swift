//
//  DurationLastCutAudioRecorder.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/29.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

class DurationWithAssertExportSessionAudioRecorder: NativeWrappedAudioRecorder {
    
    var duration: TimeInterval = 0
    var presetName: String!
    var ouputFileType: AVFileType!
    
    init(_ recorder: AVAudioRecorder? = nil, duration: TimeInterval, presetName: String = AVAssetExportPresetAppleM4A, outputFileType: AVFileType = .m4a) {
        self.duration = duration
        self.presetName = presetName
        self.ouputFileType = outputFileType
    }
    
    func cutAudioForDuration() {
        
        guard let url = self.localUrl else { return }
        let asset = AVURLAsset(url: url)
        
        let duration = CMTimeGetSeconds(asset.duration)
        guard duration > self.duration else {
            delegate?.recorder(self, didFinishWith: url)
            return
        }
     
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: presetName) else {
            return
        }
        
        let outputFilePath = URL.temporaryFileUrl(ouputFileType.toExtension())
        exportSession.outputURL = outputFilePath
        exportSession.outputFileType = ouputFileType
        
        let startPoint = (duration - self.duration) * TimeInterval(asset.duration.timescale)
        let startTime = CMTimeMake(value: Int64(startPoint), timescale: asset.duration.timescale)
        print(CMTimeGetSeconds(asset.duration),CMTimeGetSeconds(startTime))
        exportSession.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: asset.duration)
        exportSession .exportAsynchronously {[unowned self] in
        
            switch exportSession.status {
            case .completed:
                self.delegate?.recorder(self, didFinishWith: outputFilePath)
                // Delete original recording file.
                self.recorder.deleteRecording()
            case .failed:
                print(exportSession.error ?? "")
                self.delegate?.recorder(self, didFinishWith: nil)
            default: ()
            }
        }
    }
}


extension DurationWithAssertExportSessionAudioRecorder {
    override func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        cutAudioForDuration()
    }
}
