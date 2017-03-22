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
    
    public class func lbk_item(image: UIImage?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) -> UIBarButtonItem {
        let item = UIBarButtonItem(image: image, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        item.target = item
        item.lbk_handler = handler
        return item
    }
    
    public class func lbk_item(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) -> UIBarButtonItem {
        let item = UIBarButtonItem(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        item.target = item
        item.lbk_handler = handler
        return item
    }
    
    public class func lbk_item(barButtonSystemItem: UIBarButtonSystemItem, handler: ((UIBarButtonItem) -> ())?) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        item.target = item
        item.lbk_handler = handler
        return item
    }
    
    public class func lbk_item(title: String?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: title, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        item.target = item
        item.lbk_handler = handler
        return item
    }
    
    func lbk_tapAction(_ sender: AnyObject) {
        if nil != self.lbk_handler {
            self.lbk_handler!(self)
        }
    }
}
