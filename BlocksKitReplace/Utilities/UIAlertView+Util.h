//
//  UIAlertView+Util.h
//  LoiloPad
//
//  Created by mike on 2015/07/17.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Util) <UIAlertViewDelegate>

/** otherButtonを一定時間後に有効にするUIAlertView */
+ (id _Nonnull)showWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)message cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle otherButtonTitles:(NSArray<NSString *> * _Nullable)otherButtonTitles delayActiveTime:(NSTimeInterval)delayActiveTime callback:(void (^ _Nullable)(id _Nonnull sender, NSInteger buttonIndex))callback;

/** テキスト入力UIAlertView */
+ (id _Nonnull)showTextInputWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)message cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle otherButtonTitle:(NSString * _Nullable)otherButtonTitle text:(NSString * _Nullable)text placeholder:(NSString * _Nullable)placeholder secureTextEntry:(BOOL)secureTextEntry keyboardType:(UIKeyboardType)keyboardType limitation:(NSUInteger)limitation callback:(void (^_Nullable)(id _Nonnull sender, NSInteger buttonIndex, NSString * _Nullable text))callback;

/** メッセージを表示するだけのUIAlertView */
+ (id _Nonnull)showWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)message buttonTitle:(NSString * _Nullable)buttonTitle callback:(void (^ _Nullable)())callback;

@property (nonatomic, readonly) UITextField * _Nullable textField;

@end
