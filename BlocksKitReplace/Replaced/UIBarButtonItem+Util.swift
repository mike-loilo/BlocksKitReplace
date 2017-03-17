//
//  UIBarButtonItem+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/15.
//
//

import UIKit

var UIBarButtonItemHandlerKey: UInt8 = 0
typealias UIBarButtonItemHandler = @convention(block) (_ sender: UIBarButtonItem) -> ()

extension UIBarButtonItem {
    
    fileprivate var lbk_handler: UIBarButtonItemHandler? {
        get {
            let object: AnyObject? = objc_getAssociatedObject(self, &UIBarButtonItemHandlerKey) as AnyObject?
            if (nil == object) {
                return nil
            }
            else {
                return object as? UIBarButtonItemHandler
            }
        }
        set {
            if nil == newValue {
                objc_setAssociatedObject(self, &UIBarButtonItemHandlerKey, newValue as AnyObject?, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            else {
                func setHandler(handler: @escaping UIBarButtonItemHandler) {
                    objc_setAssociatedObject(self, &UIBarButtonItemHandlerKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                setHandler(handler: newValue!)
            }
        }
    }
    
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) {
        self.init(image: image, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        self.target = self
        self.lbk_handler = handler
    }
    
    public convenience init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) {
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        self.target = self
        self.lbk_handler = handler
    }
    
    public convenience init(barButtonSystemItem: UIBarButtonSystemItem, handler: ((UIBarButtonItem) -> ())?) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        self.target = self
        self.lbk_handler = handler
    }
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) {
        self.init(title: title, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        self.target = self
        self.lbk_handler = handler
    }
    
    func lbk_tapAction(_ sender: AnyObject) {
        if nil != self.lbk_handler {
            self.lbk_handler!(self)
        }
    }
}
