//
//  NSArray+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/15.
//
//

import UIKit

extension NSArray {

    public func lbk_map(block: (AnyObject) -> (AnyObject?)) -> NSArray {
        let result = NSMutableArray(capacity: self.count)
        self.enumerateObjects({ (obj, idx, stop) in
            let value = block(obj as AnyObject)
            NSLog("\(obj) -> \(value)")
            if nil == value {
                result.add(NSNull())
            }
            else {
                result.add(value!)
            }
        })
        return result
    }
}
