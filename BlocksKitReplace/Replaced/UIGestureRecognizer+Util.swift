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

extension UIGestureRecognizer {

    fileprivate var lbk_handler: UIGestureRecognizerHandler? {
        get {
            let object: AnyObject? = objc_getAssociatedObject(self, &UIGestureRecognizerHandlerKey) as AnyObject?
            if (nil == object) {
                return nil
            }
            else {
                return object as? UIGestureRecognizerHandler
            }
        }
        set {
            if nil == newValue {
                objc_setAssociatedObject(self, &UIGestureRecognizerHandlerKey, newValue as AnyObject?, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            else {
                func setHandler(handler: @escaping UIGestureRecognizerHandler) {
                    objc_setAssociatedObject(self, &UIGestureRecognizerHandlerKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                setHandler(handler: newValue!)
            }
        }
    }
    
    public class func lbk_recognizer(handler: ((UIGestureRecognizer, UIGestureRecognizerState, CGPoint) -> ())?, delay: TimeInterval) -> AnyObject {
        let recognizer = self.init()
        recognizer.addTarget(recognizer, action: #selector(UIGestureRecognizer.lbk_handleAction(_:)))
        recognizer.lbk_handler = handler
        recognizer.lbk_handlerDelay = delay
        return recognizer
    }
    
    public class func lbk_recognizer(handler: ((UIGestureRecognizer, UIGestureRecognizerState, CGPoint) -> ())?) -> AnyObject {
        let recognizer = self.init()
        recognizer.addTarget(recognizer, action: #selector(UIGestureRecognizer.lbk_handleAction(_:)))
        recognizer.lbk_handler = handler
        recognizer.lbk_handlerDelay = 0
        return recognizer
    }
    
    func lbk_handleAction(_ recognizer: UIGestureRecognizer) {
        let handler = recognizer.lbk_handler
        if nil == handler { return }
        
        let delay = self.lbk_handlerDelay
        let location = self.location(in: self.view)
        func block() {
            if !self.lbk_shouldHandleAction { return }
            handler!(self, self.state, location)
        }
        
        self.lbk_shouldHandleAction = true
        
        if 0 == delay {
            block()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
    }

    fileprivate var lbk_handlerDelay: TimeInterval {
        get {
            let object: NSNumber? = objc_getAssociatedObject(self, &UIGestureRecognizerHandlerDelayKey) as? NSNumber
            if (nil == object) {
                return 0
            }
            else {
                return object!.doubleValue
            }
        }
        set {
            objc_setAssociatedObject(self, &UIGestureRecognizerHandlerDelayKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var lbk_shouldHandleAction: Bool {
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
