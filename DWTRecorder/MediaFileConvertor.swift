//
//  AudioFileConvertor.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/29.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

protocol MediaFileConvertor {
    func convert(from url: URL, to: URL?) -> URL?
}
