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
    
    public convenience init(title: String?, style: UIBarButtonItemStyle, handler: @escaping (UIBarButtonItem) -> ()) {
        self.init()
        self.title = title
        self.style = style
        self.target = self
        self.action = #selector(UIBarButtonItem.tapAction(_:))
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
