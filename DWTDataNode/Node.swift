//
//  Node.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

class Node: NSObject {
    
    weak var parent: Node?
    
    var nodes: [Node]?
    
    var number: Int = 0
    var title: String?
    var detail: String?
    var attachement: Any?
    
    var path: String { return parent?.path ?? "" + "/\(number)" }
    
}
