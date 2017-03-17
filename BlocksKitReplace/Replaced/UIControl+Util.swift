//
//  UIControl+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/17.
//
//

import UIKit

var UIControlHandlerKey: UInt8 = 0
var UIControlControlEventKey: UInt8 = 0
typealias UIControlHandler = @convention(block) (_ sender: AnyObject) -> ()

extension UIControl {

    fileprivate var lbk_handler: UIControlHandler? {
        get {
            let object: AnyObject? = objc_getAssociatedObject(self, &UIControlHandlerKey) as AnyObject?
            if (nil == object) {
                return nil
            }
            else {
                return object as? UIControlHandler
            }
        }
        set {
            if nil == newValue {
                objc_setAssociatedObject(self, &UIControlHandlerKey, newValue as AnyObject?, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            else {
                func setHandler(handler: @escaping UIControlHandler) {
                    objc_setAssociatedObject(self, &UIControlHandlerKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                setHandler(handler: newValue!)
            }
        }
    }
    
    /** UIControl+BlocksKitのbk_addEventHandler:forControlEvents:とは異なり、複数のUIControlEventsに対して登録できない */
    public func lbk_setEvent(handler: @escaping (AnyObject) -> (), controlEvents: UIControlEvents) {
        self.lbk_handler = handler
        self.addTarget(self, action: #selector(UIControl.lbk_handleAction(_:)), for: controlEvents)
    }
    
    func lbk_handleAction(_ sender: UIControl) {
        let handler = sender.lbk_handler
        if nil == handler { return }
        
        handler!(sender)
    }

}
