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

    /** presenterがnilの場合は最前面のUIViewControllerを探して表示を試みる */
    fileprivate class func maybePresent(presenter: UIViewController?, viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Swift.Void)? = nil) {
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
    
    /** メッセージを表示するだけのUIAlertController */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, buttonTitle: String?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, buttonTitle: buttonTitle, callback: nil)
    }
    /** メッセージを表示するだけのUIAlertController(コールバック付き) */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, buttonTitle: String?, callback: (() -> ())?) -> AnyObject {
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            callback?()
        }))
        self.maybePresent(presenter: presenter, viewControllerToPresent: alert, animated: true)
        return alert
    }

    /** cancel/other2つボタンのUIAlertController */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: 0, callback: callback)
    }
    /** cancelボタン、複数のotherボタンのUIAlertController */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, delayActiveTime: 0, callback: callback)
    }
    
    /** otherボタンを一定時間後に有効にするUIAlertController */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, delayActiveTime: TimeInterval, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger) -> ())?) -> AnyObject {
        return self.lbk_show(presenter: presenter, title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: nil != otherButtonTitle ? [otherButtonTitle!] : nil, delayActiveTime: delayActiveTime, callback: callback)
    }
    /** 複数のotherボタンを一定時間後に有効にするUIAlertController */
    class func lbk_show(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String]?, delayActiveTime: TimeInterval, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger) -> ())?) -> AnyObject {
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
    }
    
    /** テキスト入力UIAlertController */
    class func lbk_showTextInput(presenter: UIViewController?, title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle: String?, text: String?, placeholder: String?, secureTextEntry: Bool, keyboardType: UIKeyboardType, limitation: UInt, callback: ((_ sender: AnyObject, _ buttonIndex: NSInteger, _ text: String?) -> ())?) -> AnyObject {
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
    }
    
    public var textField: UITextField? {
        return self.textFields?.first
    }
    
}
