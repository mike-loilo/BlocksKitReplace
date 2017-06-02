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
class UIBarButtonItemHandlerHolder {
    let handler: UIBarButtonItemHandler?
    init(_ handler: UIBarButtonItemHandler?) {
        self.handler = handler
    }
}

extension UIBarButtonItem {
    
    private var lbk_handler: UIBarButtonItemHandler? {
        get {
            if let object = objc_getAssociatedObject(self, &UIBarButtonItemHandlerKey) {
                return (object as? UIBarButtonItemHandlerHolder)?.handler
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &UIBarButtonItemHandlerKey, UIBarButtonItemHandlerHolder(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static func lbk_item(image: UIImage?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) -> UIBarButtonItem {
        let item = UIBarButtonItem(image: image, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        item.target = item
        item.lbk_handler = handler
        return item
    }
    
    static func lbk_item(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) -> UIBarButtonItem {
        let item = UIBarButtonItem(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        item.target = item
        item.lbk_handler = handler
        return item
    }
    
    static func lbk_item(barButtonSystemItem: UIBarButtonSystemItem, handler: ((UIBarButtonItem) -> ())?) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        item.target = item
        item.lbk_handler = handler
        return item
    }
    
    static func lbk_item(title: String?, style: UIBarButtonItemStyle, handler: ((UIBarButtonItem) -> ())?) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: title, style: style, target: nil, action: #selector(UIBarButtonItem.lbk_tapAction(_:)))
        item.target = item
        item.lbk_handler = handler
        return item
    }
    
    func lbk_tapAction(_ sender: AnyObject) {
        self.lbk_handler?(self)
    }
}
