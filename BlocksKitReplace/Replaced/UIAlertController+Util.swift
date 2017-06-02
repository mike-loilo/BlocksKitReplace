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
class UIAlertViewCallbackHolder {
    let callback: UIAlertViewCallback?
    init(_ callback: UIAlertViewCallback?) {
        self.callback = callback
    }
}
typealias UIAlertViewTextInputCallback = @convention(block) (_ sender: Any, _ buttonIndex: Int, _ text: String?) -> ()
class UIAlertViewTextInputCallbackHolder {
    let callback: UIAlertViewTextInputCallback?
    init(_ callback: UIAlertViewTextInputCallback?) {
        self.callback = callback
    }
}
extension UIAlertView: UIAlertViewDelegate {
    
    /** メッセージを表示するだけのUIAlertView */
    @discardableResult
    static func lbk_show(withTitle: String?, message: String?, buttonTitle: String?, callback: (() -> ())?) -> Any {
        let alert = UIAlertView(title: withTitle, message: message, delegate: nil, cancelButtonTitle: buttonTitle)
        alert.lbk_callback = { (sender, buttonIndex) in
            callback?()
        }
        alert.delegate = alert
        alert.show()
        return alert
    }
    
    /** otherButtonを一定時間後に有効にするUIAlertView */
    @discardableResult
    static func lbk_show(withTitle: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) -> Any {
        return UIAlertView(title: withTitle, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, callback: callback)
    }
    
    /** テキスト入力UIAlertView */
    @discardableResult
    static func lbk_showTextInput(withTitle: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, text: String?, placeholder: String?, secureTextEntry: Bool, keyboardType: UIKeyboardType, limitation: UInt, callback: ((_ sender: Any, _ buttonIndex: Int, _ text: String?) -> ())?) -> Any {
        func nnStr(str: String?) -> String {
            guard let s = str else { return "" }
            return s
        }
        let alert = UIAlertView(title: nnStr(str: withTitle), message: nnStr(str: message), delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nnStr(str: otherButtonTitle))
        alert.alertViewStyle = secureTextEntry ? .secureTextInput : .plainTextInput
        if let textField = alert.textField {
            textField.text = text
            textField.placeholder = placeholder
            textField.keyboardType = keyboardType
        }
        alert.lbk_textInputCallback = callback
        alert.delegate = alert
        alert.show()
        return alert
    }
    
    private convenience init(title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) {
        self.init(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        if let others = otherButtonTitles {
            for otherButtonTitle in others {
                self.addButton(withTitle: otherButtonTitle)
            }
        }
        self.lbk_callback = callback
        self.delegate = self
        self.show()
        // UIAlertViewが非推奨となったためか、遅延してボタンを有効にする処理が上手く動作しないので、無駄な実装は削除しておく
    }
    
    public var textField: UITextField? {
        return self.textField(at: 0)
    }
    
    //MARK:- Private Properties
    
    private var lbk_callback: UIAlertViewCallback? {
        get {
            if let object = objc_getAssociatedObject(self, &UIAlertViewCallbackKey) {
                return (object as? UIAlertViewCallbackHolder)?.callback
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &UIAlertViewCallbackKey, UIAlertViewCallbackHolder(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var lbk_textInputCallback: UIAlertViewTextInputCallback? {
        get {
            if let object = objc_getAssociatedObject(self, &UIAlertViewTextInputCallbackKey) {
                return (object as? UIAlertViewTextInputCallbackHolder)?.callback
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &UIAlertViewTextInputCallbackKey, UIAlertViewTextInputCallbackHolder(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //MARK:- UIAlertViewDelegate
    
    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        alertView.lbk_callback?(alertView, buttonIndex)
        alertView.lbk_textInputCallback?(alertView, buttonIndex, alertView.textField?.text)
    }
}
#endif

func toStrArray(str: String?) -> [String]? {
    guard let s = str else { return nil }
    return [s]
}

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
        if let p = presenter {
            p.present(viewControllerToPresent, animated: animated, completion: completion)
        }
        else {
            var presenter = UIApplication.shared.keyWindow?.rootViewController
            while true {
                guard let p = presenter else { break }
                guard let presented = p.presentedViewController else { break }
                if !presented.isBeingDismissed {
                    presenter = presented
                }
            }
            if let p = presenter {
                p.present(viewControllerToPresent, animated: animated, completion: completion)
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
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: toStrArray(str: otherButtonTitle), delayActiveTime: 0, callback: callback)
    }
    /** cancelボタン、複数のotherボタンのUIAlertController */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) -> Any {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: 0, callback: callback)
    }
    
    /** otherボタンを一定時間後に有効にするUIAlertController */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, delayActiveTime: TimeInterval, callback: ((_ sender: Any, _ buttonIndex: Int) -> ())?) -> Any {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: toStrArray(str: otherButtonTitle), delayActiveTime: delayActiveTime, callback: callback)
    }
    /** 複数のotherボタンを一定時間後に有効にするUIAlertController */
    @discardableResult
    static func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, delayActiveTime: TimeInterval, callback: ((_ sender: Any, _ buttonIndex: Int) -> Void)?) -> Any {
        #if USE_UIALERTVIEW
            return UIAlertView.lbk_show(withTitle: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, callback: callback)
        #else
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { [weak w = alert] (action) in
                guard let strong = w else { return }
                callback?(strong, 0)
            }))
            var loginActions: [UIAlertAction] = []
            if let others = otherButtonTitles {
                for otherButtonTitle in others {
                    let index = others.index(of: otherButtonTitle)
                    var style = UIAlertActionStyle.default
                    if #available(iOS 9, *) {
                        style = 0 < delayActiveTime && 1 == others.count ? .destructive : .default
                    }
                    let loginAction = UIAlertAction(title: otherButtonTitle, style: style, handler: { [weak w = alert] (action) in
                        guard let strong = w else { return }
                        guard let idx = index else { return }
                        callback?(strong, idx + 1)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayActiveTime, execute: {
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
            guard let obj = note.object else { return }
            if !(String(describing: type(of: obj)) as NSString).isEqual(to: "_UIAlertControllerTextField") { return }
            guard let textField = obj as? UITextField else { return }
            if textField != _textField { return }
            if 0 == limitation { return }
            
            // 変換中は無視
            if nil != textField.markedTextRange { return }

            guard let text = textField.text else { return }
            if Int(limitation) < text.characters.count {
                textField.text = (text as NSString).substring(to: Int(limitation))
            }
        }
        
        #if USE_UIALERTVIEW
            let alert = UIAlertView.lbk_showTextInput(withTitle: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitle: otherButtonTitle, text: text, placeholder: placeholder, secureTextEntry: secureTextEntry, keyboardType: keyboardType, limitation: limitation, callback: { (sender, buttonIndex, text) in
                // UIAlertViewの場合は変換中のままOKしてしまうと文字数制限がうまく利かないみたいなので、確定した文字テキストに対して文字数制限をかける
                if var validText = text {
                    if Int(limitation) < validText.characters.count {
                        validText = (validText as NSString).substring(to: Int(limitation))
                    }
                    callback?(sender, buttonIndex, validText)
                }
                else {
                    callback?(sender, buttonIndex, nil)
                }
            })
            _textField = (alert as AnyObject).textField
            return alert
        #else
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { [weak w = alert] (action) in
                guard let strong = w else { return }
                callback?(strong, 0, nil)
            }))
            alert.addAction(UIAlertAction(title: otherButtonTitle, style: .default, handler: { [weak w = alert] (action) in
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
