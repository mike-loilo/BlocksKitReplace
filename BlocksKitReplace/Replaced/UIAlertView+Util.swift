//
//  UIAlertView+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/17.
//
//

import UIKit

var UIAlertViewDisableFirstOtherButtonKey: UInt8 = 0
var UIAlertViewCallbackKey: UInt8 = 0
var UIAlertViewTextInputCallbackKey: UInt8 = 0
typealias UIAlertViewCallback = @convention(block) (_ sender: AnyObject, _ buttonIndex: NSInteger) -> ()
typealias UIAlertViewTextInputCallback = @convention(block) (_ sender: AnyObject, _ buttonIndex: NSInteger, _ text: String?) -> ()

extension UIAlertView: UIAlertViewDelegate {

    /** UIAlertControllerが使えるかどうか */
    class func controllerIsActive() -> Bool {
        return nil != NSClassFromString("UIAlertController")
    }
    
    /** UIAlertControllerを優先的に使う、メッセージを表示するだけのUIAlertView */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, buttonTitle: String?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, buttonTitle: buttonTitle, callback: nil)
    }
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, buttonTitle: String?, callback: (() -> ())?) -> AnyObject {
        if self.controllerIsActive() && nil != presenter {
            let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
                if nil != callback { callback!() }
            }))
            presenter!.present(alert, animated: true, completion: nil)
            return alert
        }
        else {
            let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: buttonTitle)
            alert.lbk_callback = { (sender, buttonIndex) in
                if nil != callback { callback!() }
            }
            alert.delegate = alert
            alert.show()
            return alert
        }
    }

    /** UIAlertControllerを優先的に使う、cancel/other2つボタンのUIAlertView */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, callback: ((AnyObject, NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: 0, callback: callback)
    }
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, callback: ((AnyObject, NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: 0, callback: callback)
    }
    
    /** UIAlertControllerを優先的に使う、otherButtonを一定時間後に有効にするUIAlertView */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, delayActiveTime: TimeInterval, callback: ((AnyObject, NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: delayActiveTime, callback: callback)
    }
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, delayActiveTime: TimeInterval, callback: ((AnyObject, NSInteger) -> ())?) -> AnyObject {
        if self.controllerIsActive() && nil != presenter {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            weak var w = alert
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .default, handler: { (action) in
                guard let strong = w else { return }
                if nil != callback { callback!(strong, 0) }
            }))
            var loginActions: [UIAlertAction] = []
            if nil != otherButtonTitles {
                for otherButtonTitle in otherButtonTitles! {
                    let index = otherButtonTitles!.index(of: otherButtonTitle)!
                    let loginAction = UIAlertAction(title: otherButtonTitle, style: .default, handler: { (action) in
                        guard let strong = w else { return }
                        if nil != callback { callback!(strong, index + 1) }
                    })
                    alert.addAction(loginAction)
                    loginActions.append(loginAction)
                }
            }
            if 0 < loginActions.count && 0 < delayActiveTime {
                for loginAction in loginActions {
                    loginAction.isEnabled = false
                }
                presenter!.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delayActiveTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                        for loginAction in loginActions {
                            loginAction.isEnabled = true
                        }
                    })
                })
            }
            else {
                presenter!.present(alert, animated: true, completion: nil)
            }
            return alert
        }
        else {
            return UIAlertView(title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: delayActiveTime, callback: callback)
        }
    }
    
    /** UIAlertControllerを優先的に使う、テキスト入力UIAlertView */
    class func showTextInput(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, text: String?, placeholder: String?, secureTextEntry: Bool, keyboardType: UIKeyboardType, limitation: UInt, callback: ((AnyObject, NSInteger, String?) -> ())?) -> AnyObject {
        // UIAlertViewでのテキスト入力中に文字数制限をするため、UITextFieldTextDidChangeNotificationで実現する
        weak var _textField: UITextField? = nil
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nil, queue: nil) { (note) in
            if nil == note.object { return }
            if !(String(describing: type(of: self)) as NSString).isEqual(to: "_UIAlertControllerTextField") { return }
            let textField = note.object as! UITextField
            if textField != _textField { return }
            if 0 == limitation { return }
            
            // 変換中は無視
            if nil != textField.markedTextRange { return }
            
            if nil != textField.text && Int(limitation) < textField.text!.characters.count {
                textField.text = (textField.text! as NSString).substring(to: Int(limitation))
            }
        }
        
        if self.controllerIsActive() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            weak var w = alert
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .default, handler: { (action) in
                guard let strong = w else { return }
                if nil != callback { callback!(strong, 0, nil) }
            }))
            alert.addAction(UIAlertAction(title: otherButtonTitle, style: .default, handler: { (action) in
                guard let strong = w else { return }
                if nil != callback { callback!(strong, 1, strong.textField?.text) }
            }))
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = text
                textField.placeholder = placeholder
                textField.isSecureTextEntry = secureTextEntry
                textField.keyboardType = keyboardType
                _textField = textField
            })
            presenter?.present(alert, animated: true, completion: nil)
            return alert
        }
        else {
            let alert = UIAlertView(title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: 0, callback: nil)
            alert.alertViewStyle = secureTextEntry ? .secureTextInput : .plainTextInput
            if nil != alert.textField {
                alert.textField!.text = text
                alert.textField!.placeholder = placeholder
                alert.textField!.keyboardType = keyboardType
            }
            _textField = alert.textField
            alert.lbk_textInputCallback = callback
            alert.delegate = alert
            alert.show()
            return alert
        }
    }
    
    fileprivate convenience init(title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, delayActiveTime: TimeInterval, callback: ((AnyObject, NSInteger) -> ())?) {
        self.init(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        if nil != otherButtonTitles {
            for otherButtonTitle in otherButtonTitles! {
                self.addButton(withTitle: otherButtonTitle)
            }
        }
        self.lbk_disableFirstOtherButton = 0 < delayActiveTime
        self.lbk_callback = callback
        self.delegate = self
        self.show()
        if 0 < delayActiveTime {
            weak var w = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delayActiveTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                guard let strong = w else { return }
                strong.dismiss(withClickedButtonIndex: 0, animated: false)
                strong.lbk_disableFirstOtherButton = false
                strong.show()
            })
        }
    }

    public var textField: UITextField? {
        return self.textField(at: 0)
    }

    //MARK:- Private Properties
    
    fileprivate var lbk_disableFirstOtherButton: Bool {
        get {
            return objc_getAssociatedObject(self, &UIAlertViewDisableFirstOtherButtonKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIAlertViewDisableFirstOtherButtonKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var lbk_callback: UIAlertViewCallback? {
        get {
            let object: AnyObject? = objc_getAssociatedObject(self, &UIAlertViewCallbackKey) as AnyObject?
            if (nil == object) { return nil }
            return object as? UIAlertViewCallback
        }
        set {
            if nil == newValue {
                objc_setAssociatedObject(self, &UIAlertViewCallbackKey, newValue as AnyObject?, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            else {
                func setHandler(handler: @escaping UIAlertViewCallback) {
                    objc_setAssociatedObject(self, &UIAlertViewCallbackKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                setHandler(handler: newValue!)
            }
        }
    }
    
    fileprivate var lbk_textInputCallback: UIAlertViewTextInputCallback? {
        get {
            let object: AnyObject? = objc_getAssociatedObject(self, &UIAlertViewTextInputCallbackKey) as AnyObject?
            if (nil == object) { return nil }
            return object as? UIAlertViewTextInputCallback
        }
        set {
            if nil == newValue {
                objc_setAssociatedObject(self, &UIAlertViewTextInputCallbackKey, newValue as AnyObject?, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            else {
                func setHandler(handler: @escaping UIAlertViewTextInputCallback) {
                    objc_setAssociatedObject(self, &UIAlertViewTextInputCallbackKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                setHandler(handler: newValue!)
            }
        }
    }

    //MARK:- UIAlertViewDelegate
    
    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if nil != alertView.lbk_callback {
            alertView.lbk_callback!(alertView, buttonIndex)
        }
        if nil != alertView.lbk_textInputCallback {
            alertView.lbk_textInputCallback!(alertView, buttonIndex, nil != alertView.textField ? alertView.textField!.text : nil)
        }

    }
    
    public func alertViewShouldEnableFirstOtherButton(_ alertView: UIAlertView) -> Bool {
        return !alertView.lbk_disableFirstOtherButton
    }
}

extension UIAlertController {
    
    public var textField: UITextField? {
        return self.textFields?.first
    }
    
}
