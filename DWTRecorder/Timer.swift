//
//  Time.swift
//  DWTRecorder
//
//  Created by kinevegivup on 2019/6/25.
//  Copyright © 2019 kinevegivup. All rights reserved.
//

import UIKit

typealias TimerCallback = (_ event: Timer.TimeEvent) -> Void

class Timer: NSObject {
    
    struct TimeEvent {
        
        var number: Int = 0
        var interval: TimeInterval = 0
        
        var beginTime: TimeInterval = 0
        var endTime: TimeInterval = 0
        
        var thisTimeStartTime: TimeInterval = 0
        var thisTimeEndTime: TimeInterval = 0
        
        var intervalOfThisTime: TimeInterval { return thisTimeEndTime - thisTimeStartTime }
        var intervalOfTimerStarting: TimeInterval { return endTime - beginTime }
        var timeConsuming: TimeInterval { return Double(number) * interval }
    }
    
    private(set) var startTime: TimeInterval = 0
    private(set) var thisTimeStartTime: TimeInterval = 0
    private(set) var interval: TimeInterval = 0
    private(set) var count = 0
    private(set) var timer: DispatchSourceTimer?
    
    private lazy var queue = DispatchQueue(label: "com.dw.\(self)")
    
    private(set) lazy var timeEvent = TimeEvent()
    
    var callback: TimerCallback!
    
    init(_ callback: TimerCallback? = nil) {
        super.init()
        
        self.callback = callback
    }
    
    func start(deadline: DispatchTime = .now(), interval: TimeInterval, leeway: DispatchTimeInterval = .milliseconds(100)) {
        
        stop()
        
        startTime = TimeInterval(deadline.rawValue)
        thisTimeStartTime = startTime
        self.interval = interval
        
        self.timeEvent.beginTime = startTime
        self.timeEvent.interval = interval
        
        timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer?.setEventHandler(handler: {[unowned self] in
            self.fillTimeEvent()
            self.callback(self.timeEvent)
        })
        timer?.schedule(deadline: deadline, repeating: interval, leeway: leeway)
        timer?.resume()
    }
    
    func stop() {
        
        guard timer?.isCancelled == false else { return }
        
        timer?.cancel()
        
        count = 0
        startTime = 0
    }
    
    private func fillTimeEvent() {
        count += 1
        timeEvent.number = count
        timeEvent.thisTimeStartTime = thisTimeStartTime
        
        thisTimeStartTime = TimeInterval(DispatchTime.now().rawValue)
        timeEvent.endTime = thisTimeStartTime
    }
}
