//
//  NSArray+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/15.
//
//

import UIKit

extension NSArray {
    
    public func lbk_match(block: @escaping (AnyObject) -> Bool) -> AnyObject? {
        let index = self.indexOfObject(passingTest:) { (obj, idx, stop) -> Bool in
            return block(obj as AnyObject)
        }
        if index == NSNotFound {
            return nil
        }
        return self[index] as AnyObject?
    }
    
    public func lbk_select(block: @escaping (AnyObject) -> Bool) -> NSArray {
        return self.objects(at: self.indexesOfObjects(passingTest:) { (obj, idx, stop) -> Bool in
            return block(obj as AnyObject)
        }) as NSArray
    }
    
    public func lbk_reject(block: @escaping (AnyObject) -> Bool) -> NSArray {
        return self.lbk_select(block: { (obj) -> Bool in
            return !block(obj as AnyObject)
        })
    }

    public func lbk_map(block: (AnyObject) -> (AnyObject?)) -> NSArray {
        let result = NSMutableArray(capacity: self.count)
        self.enumerateObjects({ (obj, idx, stop) in
            let value = block(obj as AnyObject)
            if nil == value {
                result.add(NSNull())
            }
            else {
                result.add(value!)
            }
        })
        return result
    }
    
    public func lbk_any(block: @escaping (AnyObject) -> Bool) -> Bool {
        return self.lbk_match(block: block) != nil
    }
}
