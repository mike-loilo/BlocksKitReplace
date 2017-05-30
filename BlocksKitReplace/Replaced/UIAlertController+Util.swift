//
//  UIAlertController+Util.swift
//  LoiloPad
//
//  Created by mike on 2017/03/27.
//
//

import UIKit

/** 現行の実装ではUIAlertControllerを使っていると、スクリーンロック画面・画面配信受信画面で問題が発生するため、一時的にUIAlertViewで代用する。
 * 将来的にはUIAlertControllerへ移行するため、I/Fは変えずにUIAlertViewを使う形にする
 */

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

    #if false
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
        #if false
            let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
                callback?()
            }))
            self.maybePresent(presenter: presenter, viewControllerToPresent: alert, animated: true)
            return alert
        #else
            return UIAlertView.show(withTitle: title, message: message, buttonTitle: buttonTitle, callback: callback)
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
        #if false
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
        #else
            // UIAlertViewが非推奨となったためか、遅延してボタンを有効にする処理が上手く動作しないので強制的に即時実行にする
            return UIAlertView.show(withTitle: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: 0, callback: callback)
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
        
        #if false
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
        #else
            let alert = UIAlertView.showTextInput(withTitle: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitle: otherButtonTitle, text: text, placeholder: placeholder, secureTextEntry: secureTextEntry, keyboardType: keyboardType, limitation: limitation, callback: { (sender, buttonIndex, text) in
                // UIAlertViewの場合は変換中のままOKしてしまうと文字数制限がうまく利かないみたいなので、確定した文字テキストに対して文字数制限をかける
                var validText = text
                if nil != validText && Int(limitation) < validText!.characters.count {
                    validText = (validText! as NSString).substring(to: Int(limitation))
                }
                callback?(sender, buttonIndex, validText)
            })
            _textField = (alert as AnyObject).textField
            return alert
        #endif
    }
    
    public var textField: UITextField? {
        return self.textFields?.first
    }
    
}
