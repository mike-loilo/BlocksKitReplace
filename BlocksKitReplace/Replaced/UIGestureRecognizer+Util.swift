//
//  UIGestureRecognizer+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/17.
//
//

import UIKit

var UIGestureRecognizerHandlerKey: UInt8 = 0
var UIGestureRecognizerHandlerDelayKey: UInt8 = 0
var UIGestureRecognizerShouldHandleActionKey: UInt8 = 0
typealias UIGestureRecognizerHandler = @convention(block) (_ sender: UIGestureRecognizer, _ state: UIGestureRecognizerState, _ location: CGPoint) -> ()
class UIGestureRecognizerHandlerHolder {
    let handler: UIGestureRecognizerHandler?
    init(_ handler: UIGestureRecognizerHandler?) {
        self.handler = handler
    }
}

extension UIGestureRecognizer {

    private var lbk_handler: UIGestureRecognizerHandler? {
        get {
            if let object = objc_getAssociatedObject(self, &UIGestureRecognizerHandlerKey) {
                return (object as? UIGestureRecognizerHandlerHolder)?.handler
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &UIGestureRecognizerHandlerKey, UIGestureRecognizerHandlerHolder(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static func lbk_recognizer(handler: ((UIGestureRecognizer, UIGestureRecognizerState, CGPoint) -> ())?, delay: TimeInterval) -> AnyObject {
        let recognizer = self.init()
        recognizer.addTarget(recognizer, action: #selector(UIGestureRecognizer.lbk_handleAction(_:)))
        recognizer.lbk_handler = handler
        recognizer.lbk_handlerDelay = delay
        return recognizer
    }
    
    static func lbk_recognizer(handler: ((UIGestureRecognizer, UIGestureRecognizerState, CGPoint) -> ())?) -> AnyObject {
        let recognizer = self.init()
        recognizer.addTarget(recognizer, action: #selector(UIGestureRecognizer.lbk_handleAction(_:)))
        recognizer.lbk_handler = handler
        recognizer.lbk_handlerDelay = 0
        return recognizer
    }
    
    func lbk_handleAction(_ recognizer: UIGestureRecognizer) {
        let delay = self.lbk_handlerDelay
        let location = self.location(in: self.view)
        func block() {
            if !self.lbk_shouldHandleAction { return }
            recognizer.lbk_handler?(self, self.state, location)
        }
        
        self.lbk_shouldHandleAction = true
        
        if 0 == delay {
            block()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
    }

    private var lbk_handlerDelay: TimeInterval {
        get {
            if let object = objc_getAssociatedObject(self, &UIGestureRecognizerHandlerDelayKey) {
                if let number = object as? NSNumber {
                    return number.doubleValue
                }
                return 0
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &UIGestureRecognizerHandlerDelayKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var lbk_shouldHandleAction: Bool {
        get {
            return objc_getAssociatedObject(self, &UIGestureRecognizerShouldHandleActionKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIGestureRecognizerShouldHandleActionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func lbk_cancel() {
        self.lbk_shouldHandleAction = false
    }
    
}
