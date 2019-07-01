//
//  PCM2MP3Convertor.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/30.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

class PCM2MP3Convertor: MediaFileConvertor {
    
    var asbd: AudioStreamBasicDescription!
    
    init(asbd: AudioStreamBasicDescription) {
        self.asbd = asbd
    }
    
    func convert(from url: URL, to: URL?) -> URL? {
        let targetUrl = to ?? URL.temporaryFileUrl("mp3")
        if !FileManager.default.isExecutableFile(atPath: targetUrl.path) {
            FileManager.default.createFile(atPath: targetUrl.path, contents: nil, attributes: [:])
        }
        let isSuccess = convert(from: url.path, to: targetUrl.path, sampleRate: asbd!.mSampleRate, channels: Int32(asbd!.mChannelsPerFrame))
        return isSuccess ? targetUrl : nil
    }
}


extension PCM2MP3Convertor {
    
    func convert(from: String, to: String, sampleRate: Double, channels: Int32) -> Bool {
        
        var read = 0, write = 0
        
        guard let lame = lame_init() else { return false }
        
        let sr = channels == 2 ? sampleRate : sampleRate / 2.0
        lame_set_in_samplerate(lame, Int32(sr))
        lame_set_out_samplerate(lame, Int32(sr));
        lame_set_num_channels(lame, channels);
        
        lame_set_VBR(lame, vbr_default)
        lame_init_params(lame)
        
        let bufferSize = 8192
        var readBuffer: [CShort] = Array<CShort>(repeating: 0, count: bufferSize * 2)
        var writeBuffer: [UInt8] = Array<UInt8>(repeating: 0, count: bufferSize)
        
        let reader = fopen(from.cString(using: .utf8), "rb")
        
        // Skip file header.
        fseek(reader, 4 * 1024, SEEK_CUR)
        
        let writer = fopen(to.cString(using: .utf8), "wb")
        
        let shortIntSize = MemoryLayout<CShort>.size * 2
        repeat {
            read = fread(&readBuffer, shortIntSize, bufferSize, reader)
            if read == 0 {
                write = Int(lame_encode_flush(lame, &writeBuffer, Int32(bufferSize)))
            } else {
                write = Int(lame_encode_buffer_interleaved(lame, &readBuffer, Int32(read), &writeBuffer, Int32(bufferSize)))
            }
            
            fwrite(writeBuffer, write, 1, writer)
            
        } while read != 0
        
        // Release resurce.
        lame_close(lame)
        
        fclose(reader)
        fclose(writer)
        
        return true
    }
}
