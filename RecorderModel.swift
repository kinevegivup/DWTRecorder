//
//  RecorderModel.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import Foundation

class RecorderModel: NSObject {
    
    let dataSourcePath = "RecorderConfig.plist"
    
    lazy var nodes: [Node]? = []
    
    func loadData() {
        
        // Load data from plist.
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: dataSourcePath, ofType: nil),
              let data = NSArray(contentsOf: URL(fileURLWithPath: path)) else {
            return
        }
        
        // Compsite data.
        for (index, item) in data.enumerated() {
            let dic = item as! [String : Any]
            let section = Section()
            section.title = dic["title"] as? String
            section.detail = dic["detail"] as? String
            section.number = index
            nodes?.append(section)
            
            section.nodes = []
            
            for (index, row) in (dic["rows"] as? [Any] ?? []).enumerated() {
                let rowDic = row as! [String : Any]
                
                let row = Row()
                row.parent = section
                row.number = index
                row.title = rowDic["title"] as? String
                row.detail = rowDic["detail"] as? String
                row.attachement = rowDic["attachment"]
                section.nodes?.append(row)
            }
        }
    }
    
    func getRecorder(at indexPath: IndexPath) -> Recorder? {
        
        let node = nodes?[indexPath.section].nodes?[indexPath.row]
        guard let attachement = node?.attachement as? [String : String] else { return nil }
        
        let factory = attachement["factory"] ?? ""
        let parameters = attachement["parameters"]
        
        guard let factoryInstance = instantiate(factory) else { return nil }
        return factoryInstance.create(with: parameters)
    }
    
    func instantiate(_ className: String) -> RecorderFactory? {
        if  let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? {
            let classStringName = "\(appName).\(className)"
            if let classType = NSClassFromString(classStringName) as? RecorderFactory.Type {
                return classType.init()
            }
        }
        return nil
    }
}

