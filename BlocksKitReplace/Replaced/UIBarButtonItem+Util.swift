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
    
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, handler: @escaping (UIBarButtonItem) -> ()) {
        self.init(image: image, style: style, target: nil, action: #selector(UIBarButtonItem.tapAction(_:)))
        self.target = self
        self.setHandler(handler: handler)
    }
    
    public convenience init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItemStyle, handler: @escaping (UIBarButtonItem) -> ()) {
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: #selector(UIBarButtonItem.tapAction(_:)))
        self.target = self
        self.setHandler(handler: handler)
    }
    
    public convenience init(barButtonSystemItem: UIBarButtonSystemItem, handler: @escaping (UIBarButtonItem) -> ()) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: #selector(UIBarButtonItem.tapAction(_:)))
        self.target = self
        self.setHandler(handler: handler)
    }
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, handler: @escaping (UIBarButtonItem) -> ()) {
        self.init(title: title, style: style, target: nil, action: #selector(UIBarButtonItem.tapAction(_:)))
        self.target = self
        self.setHandler(handler: handler)
    }
    
    fileprivate func setHandler(handler: @escaping UIBarButtonItemHandler){
        objc_setAssociatedObject(self, &UIBarButtonItemHandlerKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    fileprivate func handler() -> UIBarButtonItemHandler? {
        let handler : ((UIBarButtonItem) -> ()) = objc_getAssociatedObject(self, &UIBarButtonItemHandlerKey) as! UIBarButtonItemHandler
        return handler
    }
    
    func tapAction(_ sender: AnyObject) {
        if nil != self.handler() {
            self.handler()!(self)
        }
    }
}
