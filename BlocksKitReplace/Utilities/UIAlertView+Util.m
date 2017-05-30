//
//  UIAlertView+Util.m
//  LoiloPad
//
//  Created by mike on 2015/07/17.
//
//

#import "UIAlertView+Util.h"
#import <objc/runtime.h>

@implementation UIAlertView (Util)

+ (id _Nonnull)showWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)message cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle otherButtonTitles:(NSArray<NSString *> * _Nullable)otherButtonTitles delayActiveTime:(NSTimeInterval)delayActiveTime callback:(void (^ _Nullable)(id _Nonnull sender, NSInteger buttonIndex))callback
{
    return [UIAlertView.alloc initAndShowWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles delayActiveTime:delayActiveTime callback:callback];
}

- (instancetype)initAndShowWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)message cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle otherButtonTitles:(NSArray<NSString *> * _Nullable)otherButtonTitles delayActiveTime:(NSTimeInterval)delayActiveTime callback:(void (^ _Nullable)(id _Nonnull sender, NSInteger buttonIndex))callback
{
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    [otherButtonTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addButtonWithTitle:obj];
    }];
    self.disableFirstOtherButton = 0 < delayActiveTime;
    self.callback = callback;
    self.delegate = self;
    [self show];
    if (0 < delayActiveTime) {
//        @weakify(self)
        __weak UIAlertView *__self = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayActiveTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            @strongify(self)
            __strong UIAlertView *self = __self;
            if (!self) return;
            [self dismissWithClickedButtonIndex:0 animated:NO];
            self.disableFirstOtherButton = NO;
            [self show];
        });
    }
    return self;
}

+ (id _Nonnull)showTextInputWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)message cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle otherButtonTitle:(NSString * _Nullable)otherButtonTitle text:(NSString * _Nullable)text placeholder:(NSString * _Nullable)placeholder secureTextEntry:(BOOL)secureTextEntry keyboardType:(UIKeyboardType)keyboardType limitation:(NSUInteger)limitation callback:(void (^ _Nullable)(id _Nonnull sender, NSInteger buttonIndex, NSString * _Nullable text))callback
{
    // UIAlertViewでのテキスト入力中に文字数制限をするため、UITextFieldTextDidChangeNotificationで実現する
    __block __weak UITextField *_textField = nil;
    [NSNotificationCenter.defaultCenter addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (![NSStringFromClass([note.object class]) isEqualToString:@"_UIAlertControllerTextField"]) return;
        UITextField *const textField = note.object;
        if (textField != _textField) return;
        if (0 == limitation) return;

        // 変換中は無視
        if (textField.markedTextRange) return;
        
        if (limitation < textField.text.length)
            textField.text = [textField.text substringToIndex:limitation];
    }];
    
    UIAlertView *alert = [UIAlertView.alloc initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    alert.alertViewStyle = secureTextEntry ? UIAlertViewStyleSecureTextInput : UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = text;
    textField.placeholder = placeholder;
    textField.keyboardType = keyboardType;
    _textField = textField;
    alert.textInputCallback = callback;
    alert.delegate = alert;
    [alert show];
    return alert;
}

+ (id _Nonnull)showWithTitle:(NSString * _Nullable)title message:(NSString * _Nullable)message buttonTitle:(NSString * _Nullable)buttonTitle callback:(void (^)())callback
{
    UIAlertView *alert = [UIAlertView.alloc initWithTitle:title message:message delegate:self cancelButtonTitle:buttonTitle otherButtonTitles:nil, nil];
    alert.callback = callback;
    alert.delegate = alert;
    [alert show];
    return alert;
}

#pragma mark - Accessors

static char const *const UIAlertViewDisableFirstOtherButton = "UIAlertViewDisableFirstOtherButton";
- (void)setDisableFirstOtherButton:(BOOL)disableFirstOtherButton
{
    objc_setAssociatedObject(self, &UIAlertViewDisableFirstOtherButton, @(disableFirstOtherButton), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)disableFirstOtherButton
{
    return [objc_getAssociatedObject(self, &UIAlertViewDisableFirstOtherButton) boolValue];
}

static char const *const UIAlertViewCallback = "UIAlertViewCallback";
- (void)setCallback:(void (^)(UIAlertView *, NSInteger))callback
{
    objc_setAssociatedObject(self, &UIAlertViewCallback, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(UIAlertView *, NSInteger))callback
{
    return objc_getAssociatedObject(self, &UIAlertViewCallback);
}

static char const *const UIAlertViewTextInputCallback = "UIAlertViewTextInputCallback";
- (void)setTextInputCallback:(void (^)(UIAlertView *, NSInteger, NSString *))textInputCallback
{
    objc_setAssociatedObject(self, &UIAlertViewTextInputCallback, textInputCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(UIAlertView *, NSInteger, NSString *))textInputCallback
{
    return objc_getAssociatedObject(self, &UIAlertViewTextInputCallback);
}

- (UITextField * _Nullable)textField
{
    return [self textFieldAtIndex:0];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.callback) alertView.callback(alertView, buttonIndex);
    if (alertView.textInputCallback) alertView.textInputCallback(alertView, buttonIndex, [alertView textFieldAtIndex:0].text);
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return !alertView.disableFirstOtherButton;
}

@end
