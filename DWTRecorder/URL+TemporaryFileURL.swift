//
//  URL+TemporaryFileURL.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/25.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

extension URL {
    static func temporaryFileUrl(_ `extension`: String = "") -> URL {
        
        let tempDir = NSTemporaryDirectory() as NSString
        
        let uuid = UUID.init().uuidString
        let fileName = (`extension`.isEmpty ? "" : (uuid as NSString).appendingPathExtension(`extension`)) ?? ""
        return URL(fileURLWithPath: tempDir.appendingPathComponent(fileName))
    }
}
