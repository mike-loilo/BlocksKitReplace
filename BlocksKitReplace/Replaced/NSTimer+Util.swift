//
//  NSTimer+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/17.
//
//

import Foundation

extension Timer {

    @discardableResult
    static func lbk_scheduledTimer(timeInterval: TimeInterval, block: @escaping (Timer) -> (), repeats: Bool) -> Timer {
        return self.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(Timer.lbk_executeBlockFromTimer(aTimer:)), userInfo: block, repeats: repeats)
    }
    
    static func lbk_timer(timeInterval: TimeInterval, block: @escaping (Timer) -> (), repeats: Bool) -> Timer {
        return Timer.init(timeInterval: timeInterval, target: self, selector: #selector(Timer.lbk_executeBlockFromTimer(aTimer:)), userInfo: block, repeats: repeats)
    }
    
    static func lbk_executeBlockFromTimer(aTimer: Timer) {
        let block = aTimer.userInfo as! ((Timer) -> ())?
        block?(aTimer)
    }
    
}
