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
typealias UIControlHandler = @convention(block) (_ sender: Any) -> ()
class UIControlHandlerHolder {
    let handler: UIControlHandler?
    init(_ handler: UIControlHandler?) {
        self.handler = handler
    }
}

extension UIControl {

    private var lbk_handler: UIControlHandler? {
        get {
            if let object = objc_getAssociatedObject(self, &UIControlHandlerKey) {
                return (object as? UIControlHandlerHolder)?.handler
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &UIControlHandlerKey, UIControlHandlerHolder(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /** UIControl+BlocksKitのbk_addEventHandler:forControlEvents:とは異なり、複数のUIControlEventsに対して登録できないので注意 */
    public func lbk_setEvent(handler: @escaping (Any) -> (), forControlEvents: UIControlEvents) {
        self.lbk_handler = handler
        self.addTarget(self, action: #selector(UIControl.lbk_handleAction(_:)), for: forControlEvents)
    }
    
    func lbk_handleAction(_ sender: UIControl) {
        sender.lbk_handler?(sender)
    }

}
