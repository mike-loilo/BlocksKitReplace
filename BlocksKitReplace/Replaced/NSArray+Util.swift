//
//  NSArray+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/17.
//
//

import UIKit

extension NSArray {
    
    public func lbk_match(block: @escaping (Any) -> Bool) -> Any? {
        let index = self.indexOfObject(passingTest:) { (obj, idx, stop) -> Bool in
            return block(obj)
        }
        if index == NSNotFound {
            return nil
        }
        return self[index]
    }
    
    public func lbk_select(block: @escaping (Any) -> Bool) -> [Any] {
        return self.objects(at: self.indexesOfObjects(passingTest:) { (obj, idx, stop) -> Bool in
            return block(obj)
        })
    }
    
    public func lbk_reject(block: @escaping (Any) -> Bool) -> [Any] {
        return self.lbk_select(block: { (obj) -> Bool in
            return !block(obj)
        })
    }

    public func lbk_map(block: (Any) -> (Any?)) -> [Any] {
        var result = [Any]()
        result.reserveCapacity(self.count)
        for obj in self {
            if let value = block(obj) {
                result.append(value)
            }
            else {
                result.append(NSNull())
            }
        }
        return result
    }
    
    public func lbk_any(block: @escaping (Any) -> Bool) -> Bool {
        return self.lbk_match(block: block) != nil
    }
}
