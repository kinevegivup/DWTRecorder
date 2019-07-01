//
//  PCM2AVFileTypeConvertor.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/30.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

protocol PCM2AVFileTypeConvertorDelegate: class {
    func PCM2AVFileTypeConvertor(_ convertor: PCM2AVFileTypeConvertor, sucesssfuly status: Bool)
}

class PCM2AVFileTypeConvertor: MediaFileConvertor {
    
    var presetName: String = AVAssetExportPresetAppleM4A
    var ouputFileType: AVFileType = .m4a
    
    weak var delegate: PCM2AVFileTypeConvertorDelegate?
    
    func convert(from url: URL, to: URL?) -> URL? {
        let targetUrl = to ?? URL.temporaryFileUrl(ouputFileType.toExtension())
        convert(url, targetUrl: targetUrl)
        return nil
    }
}


extension PCM2AVFileTypeConvertor {
    
    func convert(_ url: URL, targetUrl: URL) {
        
        let asset = AVURLAsset(url: url)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: presetName) else {
            return
        }
    
        exportSession.outputURL = targetUrl
        exportSession.outputFileType = ouputFileType
        exportSession .exportAsynchronously {[unowned self] in
            
            switch exportSession.status {
            case .completed:
                self.delegate?.PCM2AVFileTypeConvertor(self, sucesssfuly: true)
            case .failed:
                self.delegate?.PCM2AVFileTypeConvertor(self, sucesssfuly: false)
                print(exportSession.error ?? "")
            default: ()
            }
        }
    }
}
