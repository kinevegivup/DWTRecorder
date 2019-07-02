//
//  AudioRecordingAndPlayingViewController.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/7/1.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecordingAndPlayingViewController: UIViewController {
    
    let movingSpace: CGFloat = 90

    @IBOutlet weak var progressTopView: UIView!
    @IBOutlet weak var progressBottomView: UIView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var widthConstraintOfProgressView: NSLayoutConstraint!
    
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var EndLabel: UILabel!
    
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var playingButton: UIButton!
    @IBOutlet weak var widthContraintOfRecordingButton: NSLayoutConstraint!
    
    
    var recorder: Recorder?
    var player: AVAudioPlayer?
    var url: URL?
    
    var timer: Timer?
    var duration: TimeInterval = 0
    
    deinit {
        recorder?.stop()
        player?.stop()
        stopTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setButton(recordingButton)
        setButton(playingButton)
        
        recorder?.delegate = self
        recorder?.isTimerEnabled = true
    }
    
    func setButton(_ button: UIButton) {
        let color = UIColor.lightGray.cgColor
        button.layer.borderColor = color
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 3.0
    }
}


extension AudioRecordingAndPlayingViewController {
    
    @IBAction func didClickRecordingButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        switchControls(isHidden: true)
        
        if sender.isSelected {
            player?.stop()
            
            recorder?.record()
            recorder?.timer?.start(interval: 1.0)
            
            playingButton.isEnabled = false
            playingButton.isSelected = false
            moveWithAnimation(offset: movingSpace)
        } else {
            
            recorder?.stop()
            recorder?.timer?.stop()
            
            playingButton.isEnabled = true
            moveWithAnimation(offset: -movingSpace)
        }
    }
    
    @IBAction func didClickPlayingButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        switchControls(isHidden: false)
        self.widthConstraintOfProgressView.constant = 0
        format(for: startLabel, time: 0)
        
        if sender.isSelected {
            guard let url = url else { return }
            
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(.playAndRecord)
            try? audioSession.setActive(true, options: [])
            
            let asset = AVAsset(url: url)
            print(url, "\nduration: " , CMTimeGetSeconds(asset.duration))
            duration = ceil(CMTimeGetSeconds(asset.duration))
            
            format(for: EndLabel, time: Int(duration))
            
            player = try? AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            
            player?.prepareToPlay()
            player?.play()
            
            startTimer()
        } else {
            player?.stop()
            stopTimer()
        }
    }
}

extension AudioRecordingAndPlayingViewController {
    func moveWithAnimation(offset: CGFloat) {
        widthContraintOfRecordingButton.constant = offset
        UIView.animate(withDuration: 0.25) {
            self.recordingButton.superview?.layoutIfNeeded()
        }
    }
    
    func switchControls(isHidden: Bool) {
        progressContainerView.isHidden = isHidden
        recordingTimeLabel.isHidden = !isHidden
    }
    
    func format(for target: UILabel?, time: Int) {
        target?.text = String(format: "%02d:%02d", time / 60, time % 60)
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer({[unowned self] (event) in
            DispatchQueue.main.async {
                self.format(for: self.startLabel, time: event.number)
                let percent = min(TimeInterval(event.number) / self.duration, 1.0)
                let width = self.progressBottomView.frame.width * CGFloat(percent)
                self.widthConstraintOfProgressView.constant = width
            }
        })
        timer?.start(interval: 1.0)
    }
    
    func stopTimer() {
        timer?.stop()
    }
}


extension AudioRecordingAndPlayingViewController: RecorderDelegate {
    
    func recorder(_ recorder: Recorder, didRecordAt time: Timer.TimeEvent) {
        DispatchQueue.main.async {
            self.format(for: self.recordingTimeLabel, time: time.number)
        }
    }
    
    func recorder(_ recorder: Recorder, didFinishWith url: URL?) {
        self.url = url
    }
}


extension AudioRecordingAndPlayingViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error ?? "")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Stop player.
        didClickPlayingButton(playingButton)
    }
}
