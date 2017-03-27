//
//  UIAlertController+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/27.
//
//

import UIKit

var UIAlertControllerCallbackKey: UInt8 = 0
var UIAlertControllerTextInputCallbackKey: UInt8 = 0
typealias UIAlertControllerCallback = @convention(block) (_ sender: AnyObject, _ buttonIndex: NSInteger) -> ()
typealias UIAlertControllerTextInputCallback = @convention(block) (_ sender: AnyObject, _ buttonIndex: NSInteger, _ text: String?) -> ()

/** 元々、UIAlertViewを拡張して、UIAlertControllerを扱えるようにしていたが、
 * Swiftで実装すると、ボタンの有効化を遅延させたり、入力用のテキストボックスを開いたりするときにうまくいかない
 * iOS8以降はUIAlertView自体が非推奨になっていることもあり、UIAlertControllerの拡張として実装する
 *
 * [UIAlertViewでの問題]
 * SwiftだとUIAlertViewDelegateのalertViewShouldEnableFirstOtherButtonが呼ばれないみたいなので、キャンセルボタン以外を一時的に無効にしておく処理が実現できない。
 * 仮にalertViewShouldEnableFirstOtherButtonが呼ばれるようになったとしても、ボタンを有効に戻すために一度閉じて開き直す処理が効かない。
 * 入力用のテキストボックスに関しては、alertViewStyleに.secureTextInputや.plainTextInputを設定しているにも関わらず表示されない。
 */
extension UIAlertController {

    /** メッセージを表示するだけのUIAlertController */
    class func lbk_show(presenter: UIViewController, title: String?, message: String?, buttonTitle: String?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, buttonTitle: buttonTitle, callback: nil)
    }
    class func lbk_show(presenter: UIViewController, title: String?, message: String?, buttonTitle: String?, callback: (() -> ())?) -> AnyObject {
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            if nil != callback { callback!() }
        }))
        presenter.present(alert, animated: true, completion: nil)
        return alert
    }

    /** cancel/other2つボタンのUIAlertController */
    class func lbk_show(presenter: UIViewController, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: 0, callback: callback)
    }
    class func lbk_show(presenter: UIViewController, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: 0, callback: callback)
    }
    
    /** otherButtonを一定時間後に有効にするUIAlertController */
    class func lbk_show(presenter: UIViewController, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, delayActiveTime: TimeInterval, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: delayActiveTime, callback: callback)
    }
    class func lbk_show(presenter: UIViewController, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, delayActiveTime: TimeInterval, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger) -> ())?) -> AnyObject {
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
                var style = UIAlertActionStyle.default
                if #available(iOS 9, *) {
                    style = 0 < delayActiveTime && 1 == otherButtonTitles!.count ? .destructive : .default
                }
                let loginAction = UIAlertAction(title: otherButtonTitle, style: style, handler: { (action) in
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
            presenter.present(alert, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delayActiveTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    if nil == w { return }
                    for loginAction in loginActions {
                        loginAction.isEnabled = true
                    }
                })
            })
        }
        else {
            presenter.present(alert, animated: true, completion: nil)
        }
        return alert
    }
    
    /** テキスト入力UIAlertController */
    class func lbk_showTextInput(presenter: UIViewController, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, text: String?, placeholder: String?, secureTextEntry: Bool, keyboardType: UIKeyboardType, limitation: UInt, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger, _ text: String?) -> ())?) -> AnyObject {
        // UIAlertControllerでのテキスト入力中に文字数制限をするため、UITextFieldTextDidChangeNotificationで実現する
        weak var _textField: UITextField? = nil
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nil, queue: nil) { (note) in
            if nil == note.object { return }
            if !(String(describing: type(of: note.object!)) as NSString).isEqual(to: "_UIAlertControllerTextField") { return }
            let textField = note.object as! UITextField
            if textField != _textField { return }
            if 0 == limitation { return }
            
            // 変換中は無視
            if nil != textField.markedTextRange { return }
            
            if nil != textField.text && Int(limitation) < textField.text!.characters.count {
                textField.text = (textField.text! as NSString).substring(to: Int(limitation))
            }
        }
        
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
        presenter.present(alert, animated: true, completion: nil)
        return alert
    }
    
    public var textField: UITextField? {
        return self.textFields?.first
    }

    //MARK:- Private Properties
    
    fileprivate var lbk_callback: UIAlertControllerCallback? {
        get {
            let object: AnyObject? = objc_getAssociatedObject(self, &UIAlertControllerCallbackKey) as AnyObject?
            if (nil == object) { return nil }
            return object as? UIAlertControllerCallback
        }
        set {
            if nil == newValue {
                objc_setAssociatedObject(self, &UIAlertControllerCallbackKey, newValue as AnyObject?, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            else {
                func setHandler(handler: @escaping UIAlertControllerCallback) {
                    objc_setAssociatedObject(self, &UIAlertControllerCallbackKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                setHandler(handler: newValue!)
            }
        }
    }
    
    fileprivate var lbk_textInputCallback: UIAlertControllerTextInputCallback? {
        get {
            let object: AnyObject? = objc_getAssociatedObject(self, &UIAlertControllerTextInputCallbackKey) as AnyObject?
            if (nil == object) { return nil }
            return object as? UIAlertControllerTextInputCallback
        }
        set {
            if nil == newValue {
                objc_setAssociatedObject(self, &UIAlertControllerTextInputCallbackKey, newValue as AnyObject?, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            else {
                func setHandler(handler: @escaping UIAlertControllerTextInputCallback) {
                    objc_setAssociatedObject(self, &UIAlertControllerTextInputCallbackKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                setHandler(handler: newValue!)
            }
        }
    }
    
}
