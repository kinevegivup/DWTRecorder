//
//  PCM2WAVConvertor.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/29.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

class PCM2WAVConvertor: MediaFileConvertor {
    
    private var asbd: AudioStreamBasicDescription!
    
    init(asbd: AudioStreamBasicDescription? = nil) {
        self.asbd = asbd
    }
    
    func convert(from url: URL, to: URL?) -> URL? {
        let toUrl = to ?? URL.temporaryFileUrl("wav")
        // Create a empty file.
        FileManager.default.createFile(atPath: toUrl.path, contents: nil, attributes: [:])
        pcmToWav(inFileName: url.path, outFileName: toUrl.path)
        return toUrl
    }
}

extension PCM2WAVConvertor {
    
    func pcmToWav(inFileName: String, outFileName: String) {
        
        guard let input: URL = URL(string: inFileName) else { return }
        guard let output: URL = URL(string: outFileName) else { return }
        
        var totalAudioLen: Int64
        var totalDataLen: Int64
        let longSampleRate: Int64 = Int64(asbd.mSampleRate)
        
        let channels = 1
        let byteRate: Int64 = Int64(Double(asbd.mBitsPerChannel) *
            asbd.mSampleRate * Double(asbd.mChannelsPerFrame) / 8)
        
        totalAudioLen = Int64(FileManager.default.getFileSize(inFileName))
        totalDataLen = totalAudioLen + 36
        
        // Write header of wav file.
        writewaveFileHeader(output: output, totalAudioLen: totalAudioLen,
                            totalDataLen: totalDataLen,
                            longSampleRate: longSampleRate,
                            channels: channels, byteRate: byteRate)
        
        do {
            let readHandler = try FileHandle(forReadingFrom: input)
            let writeHandler = try FileHandle(forWritingTo: output)
            
            // Set file offset wav header struct.
            writeHandler.seek(toFileOffset: 44)
            
            let data = readHandler.readDataToEndOfFile()
            writeHandler.write(data)
        } catch {
            print(error)
        }
    }
    
    func writewaveFileHeader(output: URL, totalAudioLen: Int64, totalDataLen: Int64,
                             longSampleRate: Int64, channels: Int, byteRate: Int64) {
        
        var header: [UInt8] = Array(repeating: 0, count: 44)
        
        // RIFF/WAVE header
        header[0] = UInt8(ascii: "R")
        header[1] = UInt8(ascii: "I")
        header[2] = UInt8(ascii: "F")
        header[3] = UInt8(ascii: "F")
        header[4] = (UInt8)(totalDataLen & 0xff)
        header[5] = (UInt8)((totalDataLen >> 8) & 0xff)
        header[6] = (UInt8)((totalDataLen >> 16) & 0xff)
        header[7] = (UInt8)((totalDataLen >> 24) & 0xff)
        
        //WAVE
        header[8] = UInt8(ascii: "W")
        header[9] = UInt8(ascii: "A")
        header[10] = UInt8(ascii: "V")
        header[11] = UInt8(ascii: "E")
        
        // 'fmt' chunk
        header[12] = UInt8(ascii: "f")
        header[13] = UInt8(ascii: "m")
        header[14] = UInt8(ascii: "t")
        header[15] = UInt8(ascii: " ")
        
        // 4 bytes: size of 'fmt ' chunk
        header[16] = 16
        header[17] = 0
        header[18] = 0
        header[19] = 0
        
        // format = 1
        header[20] = 1
        header[21] = 0
        header[22] = UInt8(channels)
        header[23] = 0
        
        header[24] = (UInt8)(longSampleRate & 0xff)
        header[25] = (UInt8)((longSampleRate >> 8) & 0xff)
        header[26] = (UInt8)((longSampleRate >> 16) & 0xff)
        header[27] = (UInt8)((longSampleRate >> 24) & 0xff)
        
        header[28] = (UInt8)(byteRate & 0xff)
        header[29] = (UInt8)((byteRate >> 8) & 0xff)
        header[30] = (UInt8)((byteRate >> 16) & 0xff)
        header[31] = (UInt8)((byteRate >> 24) & 0xff)
        
        // block align
        header[32] = UInt8(2 * 16 / 8)
        header[33] = 0
        
        // bits per sample
        header[34] = 16
        header[35] = 0
        
        //data
        header[36] = UInt8(ascii: "d")
        header[37] = UInt8(ascii: "a")
        header[38] = UInt8(ascii: "t")
        header[39] = UInt8(ascii: "a")
        header[40] = UInt8(totalAudioLen & 0xff)
        header[41] = UInt8((totalAudioLen >> 8) & 0xff)
        header[42] = UInt8((totalAudioLen >> 16) & 0xff)
        header[43] = UInt8((totalAudioLen >> 24) & 0xff)
        
        guard let writeHandler = try? FileHandle(forWritingTo: output) else { return }
        let data = Data(header)
        writeHandler.write(data)
    }
}

extension FileManager {
    func getFileSize(_ filePath: String) -> UInt64 {
        
        var size: UInt64 = 0
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        let isExists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        
        if isExists {
            if isDir.boolValue {
                let enumerator = fileManager.enumerator(atPath: filePath)
                for subPath in enumerator! {
                    
                    let fullPath =  filePath.appending("/\(subPath)")
                    do {
                        let attr = try fileManager.attributesOfItem(atPath: fullPath)
                        size += attr[FileAttributeKey.size] as! UInt64
                    } catch  {
                        print("error :\(error)")
                    }
                }
            } else {
                do {
                    let attr = try fileManager.attributesOfItem(atPath: filePath)
                    size += attr[FileAttributeKey.size] as! UInt64
                } catch  {
                    print("error :\(error)")
                }
            }
        }
        return size
    }
}
