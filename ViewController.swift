//
//  ViewController.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/24.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let cellReuseId = "recorderCell"
    let audioRecorderVCName = "AudioRecordingAndPlayingViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var recorderModel = RecorderModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recorderModel.loadData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recorderModel.nodes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recorderModel.nodes?[section].nodes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId)!
        
        let node = recorderModel.nodes?[indexPath.section].nodes?[indexPath.row]
        cell.textLabel?.text = node?.title
        cell.detailTextLabel?.text = node?.detail
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let node = recorderModel.nodes?[section]
        return node?.title
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: audioRecorderVCName)
            as! AudioRecordingAndPlayingViewController
        
        let node = recorderModel.nodes?[indexPath.section].nodes?[indexPath.row]
        vc.recorder = recorderModel.getRecorder(at: indexPath)
        vc.title = node?.title
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
