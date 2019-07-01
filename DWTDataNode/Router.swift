//
//  Router.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

class Router: NSObject {
    
    private lazy var presenters = [String : Presenter]()
    
    func register(path: String, presenter: Presenter) {}
    func route(path: String) {}
    func remove(path: String) {}
}
