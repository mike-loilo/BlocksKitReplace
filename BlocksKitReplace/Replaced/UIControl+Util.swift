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

    private var lbk_handler: UIControlHandler? {
        get {
            if let object = objc_getAssociatedObject(self, &UIControlHandlerKey) {
                #if swift(>=3.1)
                    return unsafeBitCast(UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(object as AnyObject).toOpaque()), to: UIControlHandler.self)
                #else
                    return object as? UIControlHandler
                #endif
            }
            return nil
        }
        set {
            #if swift(>=3.1)
                objc_setAssociatedObject(self, &UIControlHandlerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            #else
                if nil == newValue {
                    objc_setAssociatedObject(self, &UIControlHandlerKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                else {
                    func setHandler(handler: @escaping UIControlHandler) {
                        objc_setAssociatedObject(self, &UIControlHandlerKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                    }
                    setHandler(handler: newValue!)
                }
            #endif
        }
    }
    
    /** UIControl+BlocksKitのbk_addEventHandler:forControlEvents:とは異なり、複数のUIControlEventsに対して登録できないので注意 */
    public func lbk_setEvent(handler: @escaping (AnyObject) -> (), forControlEvents: UIControlEvents) {
        self.lbk_handler = handler
        self.addTarget(self, action: #selector(UIControl.lbk_handleAction(_:)), for: forControlEvents)
    }
    
    func lbk_handleAction(_ sender: UIControl) {
        sender.lbk_handler?(sender)
    }

}
