//
//  UIAlertController+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/27.
//
//

import UIKit

#if USE_UIALERTVIEW
/** 現行の実装ではUIAlertControllerを使っていると、スクリーンロック画面・画面配信受信画面で問題が発生するため、一時的にUIAlertViewで代用する。
 * 将来的にはUIAlertControllerへ移行するため、インターフェースは変えずにUIAlertViewを使う形にする
 */

var UIAlertViewDisableFirstOtherButtonKey: UInt8 = 0
var UIAlertViewCallbackKey: UInt8 = 0
var UIAlertViewTextInputCallbackKey: UInt8 = 0
typealias UIAlertViewCallback = @convention(block) (_ sender: Any, _ buttonIndex: Int) -> ()
typealias UIAlertViewTextInputCallback = @convention(block) (_ sender: Any, _ buttonIndex: Int, _ text: String?) -> ()
extension UIAlertView: UIAlertViewDelegate {
    
    /** メッセージを表示するだけのUIAlertView */
    @discardableResult
    static func lbk_show(withTitle: String?, message: String?, buttonTitle: String?, callback: (() -> ())?) -> Any {
        let alert = UIAlertView(title: withTitle, message: message, delegate: nil, cancelButtonTitle: buttonTitle)
        alert.lbk_callback = { (sender, buttonIndex) in
            if nil != callback { callback!() }
        }
        alert.delegate = alert
        alert.show()
        return alert
    }
    
    /** otherButtonを一定時間後に有効にするUIAlertView */
    @discardableResult
    static func lbk_show(withTitle: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, delayActiveTime: TimeInterval, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) -> Any {
        return UIAlertView(title: withTitle, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: delayActiveTime, callback: callback)
    }
    
    /** テキスト入力UIAlertView */
    @discardableResult
    static func lbk_showTextInput(withTitle: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, text: String?, placeholder: String?, secureTextEntry: Bool, keyboardType: UIKeyboardType, limitation: UInt, callback: ((_ sender: Any, _ buttonIndex: Int, _ text: String?) -> ())?) -> Any {
        let alert = UIAlertView(title: nil != withTitle ? withTitle! : "", message: nil != message ? message! : "", delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? otherButtonTitle! : "")
        alert.alertViewStyle = secureTextEntry ? .secureTextInput : .plainTextInput
        if nil != alert.textField {
            alert.textField!.text = text
            alert.textField!.placeholder = placeholder
            alert.textField!.keyboardType = keyboardType
        }
        alert.lbk_textInputCallback = callback
        alert.delegate = alert
        alert.show()
        return alert
    }
    
    private convenience init(title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, delayActiveTime: TimeInterval, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) {
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
    
    private var lbk_disableFirstOtherButton: Bool {
        get {
            return objc_getAssociatedObject(self, &UIAlertViewDisableFirstOtherButtonKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIAlertViewDisableFirstOtherButtonKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var lbk_callback: UIAlertViewCallback? {
        get {
            if let object = objc_getAssociatedObject(self, &UIAlertViewCallbackKey) {
                #if swift(>=3.1)
                    return unsafeBitCast(UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(object as AnyObject).toOpaque()), to: UIAlertViewCallback.self)
                #else
                    return object as? UIBarButtonItemHandler
                #endif
            }
            return nil
        }
        set {
            #if swift(>=3.1)
                objc_setAssociatedObject(self, &UIAlertViewCallbackKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            #else
                if nil == newValue {
                    objc_setAssociatedObject(self, &UIAlertViewCallbackKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                else {
                    func setHandler(handler: @escaping UIAlertViewCallback) {
                        objc_setAssociatedObject(self, &UIAlertViewCallbackKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                    }
                    setHandler(handler: newValue!)
                }
            #endif
        }
    }
    
    private var lbk_textInputCallback: UIAlertViewTextInputCallback? {
        get {
            if let object = objc_getAssociatedObject(self, &UIAlertViewTextInputCallbackKey) {
                #if swift(>=3.1)
                    return unsafeBitCast(UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(object as AnyObject).toOpaque()), to: UIAlertViewTextInputCallback.self)
                #else
                    return object as? UIBarButtonItemHandler
                #endif
            }
            return nil
        }
        set {
            #if swift(>=3.1)
                objc_setAssociatedObject(self, &UIAlertViewTextInputCallbackKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            #else
                if nil == newValue {
                    objc_setAssociatedObject(self, &UIAlertViewTextInputCallbackKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                }
                else {
                    func setHandler(handler: @escaping UIAlertViewTextInputCallback) {
                        objc_setAssociatedObject(self, &UIAlertViewTextInputCallbackKey, handler as! AnyObject, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                    }
                    setHandler(handler: newValue!)
                }
            #endif
        }
    }
    
    //MARK:- UIAlertViewDelegate
    
    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        alertView.lbk_callback?(alertView, buttonIndex)
        alertView.lbk_textInputCallback?(alertView, buttonIndex, nil != alertView.textField ? alertView.textField!.text : nil)
    }
    
    public func alertViewShouldEnableFirstOtherButton(_ alertView: UIAlertView) -> Bool {
        return !alertView.lbk_disableFirstOtherButton
    }
}
#endif

/** 元々、UIAlertViewを拡張して、UIAlertControllerを扱えるようにしていたが、
 * iOS8を非サポートにすると、ボタンの有効化を遅延させるときにうまくいかない
 * iOS8以降はUIAlertView自体が非推奨になっていることもあり、UIAlertControllerの拡張として実装する
 *
 * [UIAlertViewでの問題]
 * iOS8が非サポートだとUIAlertViewDelegateのalertViewShouldEnableFirstOtherButtonが呼ばれないみたいなので、キャンセルボタン以外を一時的に無効にしておく処理が実現できない。
 * 仮にalertViewShouldEnableFirstOtherButtonが呼ばれるようになったとしても、ボタンを有効に戻すために一度閉じて開き直す処理が効かない。
 */
extension UIAlertController {

    #if USE_UIALERTVIEW
    #else
    /** presenterがnilの場合は最前面のUIViewControllerを探して表示を試みる */
    private class func maybePresent(presenter: UIViewController?, viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Swift.Void)? = nil) {
        if nil != presenter {
            presenter!.present(viewControllerToPresent, animated: animated, completion: completion)
        }
        else {
            var presenter = UIApplication.shared.keyWindow?.rootViewController
            while nil != presenter && nil != presenter!.presentedViewController && false == presenter!.presentedViewController!.isBeingDismissed {
                presenter = presenter!.presentedViewController!
            }
            if nil != presenter {
                presenter!.present(viewControllerToPresent, animated: animated, completion: completion)
            }
            else {
                completion?()
            }
        }
    }
    #endif
    
    /** メッセージを表示するだけのUIAlertController */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, buttonTitle: String?) -> Any {
        return self.lbk_show(presenter: presenter, title: title, message: message, buttonTitle: buttonTitle, callback: nil)
    }
    /** メッセージを表示するだけのUIAlertController(コールバック付き) */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, buttonTitle: String?, callback: (() -> ())?) -> Any {
        #if USE_UIALERTVIEW
            return UIAlertView.lbk_show(withTitle: title, message: message, buttonTitle: buttonTitle, callback: callback)
        #else
            let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
                callback?()
            }))
            self.maybePresent(presenter: presenter, viewControllerToPresent: alert, animated: true)
            return alert
        #endif
    }

    /** cancel/other2つボタンのUIAlertController */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) -> Any {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: 0, callback: callback)
    }
    /** cancelボタン、複数のotherボタンのUIAlertController */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) -> Any {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: 0, callback: callback)
    }
    
    /** otherボタンを一定時間後に有効にするUIAlertController */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, delayActiveTime: TimeInterval, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) -> Any {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: delayActiveTime, callback: callback)
    }
    /** 複数のotherボタンを一定時間後に有効にするUIAlertController */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, delayActiveTime: TimeInterval, callback: ((_ sender: Any, _ buttonIndex: Int) -> Void)?) -> Any {
        #if USE_UIALERTVIEW
            // UIAlertViewが非推奨となったためか、遅延してボタンを有効にする処理が上手く動作しないので強制的に即時実行にする
            return UIAlertView.lbk_show(withTitle: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: 0, callback: callback)
        #else
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            weak var w = alert
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (action) in
                guard let strong = w else { return }
                callback?(strong, 0)
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
                        callback?(strong, index + 1)
                    })
                    alert.addAction(loginAction)
                    loginActions.append(loginAction)
                }
            }
            if 0 < loginActions.count && 0 < delayActiveTime {
                for loginAction in loginActions {
                    loginAction.isEnabled = false
                }
                self.maybePresent(presenter: presenter, viewControllerToPresent: alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delayActiveTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                        if nil == w { return }
                        for loginAction in loginActions {
                            loginAction.isEnabled = true
                        }
                    })
                })
            }
            else {
                self.maybePresent(presenter: presenter, viewControllerToPresent: alert, animated: true)
            }
            return alert
        #endif
    }
    
    /** テキスト入力UIAlertController */
    @discardableResult
    static func lbk_showTextInput(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, text: String?, placeholder: String?, secureTextEntry: Bool, keyboardType: UIKeyboardType, limitation: UInt, callback: ((_ sender: Any, _ buttonIndex: Int, _ text: String?) -> ())?) -> Any {
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
        
        #if USE_UIALERTVIEW
            let alert = UIAlertView.lbk_showTextInput(withTitle: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitle: otherButtonTitle, text: text, placeholder: placeholder, secureTextEntry: secureTextEntry, keyboardType: keyboardType, limitation: limitation, callback: { (sender, buttonIndex, text) in
                // UIAlertViewの場合は変換中のままOKしてしまうと文字数制限がうまく利かないみたいなので、確定した文字テキストに対して文字数制限をかける
                var validText = text
                if nil != validText && Int(limitation) < validText!.characters.count {
                    validText = (validText! as NSString).substring(to: Int(limitation))
                }
                callback?(sender, buttonIndex, validText)
            })
            _textField = (alert as AnyObject).textField
            return alert
        #else
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            weak var w = alert
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (action) in
                guard let strong = w else { return }
                callback?(strong, 0, nil)
            }))
            alert.addAction(UIAlertAction(title: otherButtonTitle, style: .default, handler: { (action) in
                guard let strong = w else { return }
                callback?(strong, 1, strong.textField?.text)
            }))
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = text
                textField.placeholder = placeholder
                textField.isSecureTextEntry = secureTextEntry
                textField.keyboardType = keyboardType
                _textField = textField
            })
            self.maybePresent(presenter: presenter, viewControllerToPresent: alert, animated: true)
            return alert
        #endif
    }
    
    public var textField: UITextField? {
        return self.textFields?.first
    }
    
}
