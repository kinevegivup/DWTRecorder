//
//  AVFileType+Extensions.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/30.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation
import AVFoundation

extension AVFileType {
    
    /// Convert AVFileType to a file extension name.
    /// Notice:
    ///     There are extensions only for normal types.
    /// - Returns: File extension name.
    func toExtension() -> String {
        
        var `extension`: String! = ""
        switch self {
        case .mov:
            `extension` = "mov"
        case .mp4:
            `extension` = "mp4"
        case .m4v:
            `extension` = "m4v"
        case .m4a:
            `extension` = "m4a"
        case .mobile3GPP:
            `extension` = "3gpp"
        case .mobile3GPP2:
            `extension` = "3gp2"
        case .caf:
            `extension` = "caf"
        case .wav:
            `extension` = "wav"
        case .aiff:
            `extension` = "aif"
        case .aifc:
            `extension` = "aifc"
        case .amr:
            `extension` = "amr"
        case .au:
            `extension` = "au"
        case .ac3:
            `extension` = "ac3"
        case .eac3:
            `extension` = "eac3"
        default: ()
        }
        return `extension`
    }
}
