//
//  BottegaViewController.m
//  BlocksKitReplace
//
//  Created by mike on 2017/03/15.
//  Copyright © 2017年 mike. All rights reserved.
//

#import "BottegaViewController.h"
#import "BlocksKitReplace-Swift.h"
#import <libextobjc/EXTScope.h>

@implementation BottegaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self)
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"TEST" style:UIBarButtonItemStylePlain handler:^(UIBarButtonItem * _Nonnull sender) {
        @strongify(self)
        if (!self) return;
        
        [self helloWorld];
    }];
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"NULL" style:UIBarButtonItemStylePlain handler:NULL];
    
//    NSArray *array = @[@"a", @"b", @"c"];
//    array = [array lbk_mapWithBlock:^id(id obj) {
//        if ([obj isEqualToString:@"b"])
//            return @"d";
//        else
//            return obj;
//    }];
//    array = [array lbk_selectWithBlock:^BOOL(id obj) {
//        return [obj isEqualToString:@"c"];
//    }];
//    array = [array lbk_rejectWithBlock:^BOOL(id obj) {
//        return [obj isEqualToString:@"c"];
//    }];
//    NSLog(@"ARRAY : %@", array);
//    NSLog(@"ARRAY ANY : %@", [array lbk_anyWithBlock:^BOOL(id obj) { return [obj isEqualToString:@"a"]; }] ? @"YES" : @"NO");
    
    [self.view addGestureRecognizer:[UIPanGestureRecognizer.alloc initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if (!self) return;
        
        self.view.backgroundColor = UIColor.blueColor;
    } delay:5.0]];
    
//    NSTimer *const timer = [NSTimer lbk_timerWithTimeInterval:1 block:^(NSTimer *timer) {
//        @strongify(self)
//        if (!self) return;
//        
//        [self helloWorld];
//    } repeats:YES];
//    [NSRunLoop.mainRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
//    [NSTimer lbk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
//        @strongify(self)
//        if (!self) return;
//        
//        [self helloWorld];
//    } repeats:YES];
    
    UIButton *const button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [button lbk_setEventWithHandler:^(id sender) {
        @strongify(self)
        if (!self) return;
        
        [UIAlertView lbk_showWithPresenter:self
                                     title:@"Title"
                                   message:@"Message"
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:@[@"1", @"2", @"3"]
                                  callback:^(id _Nonnull sender, NSInteger buttonIndex) {
                                      NSLog(@"Close[%ld] : %@", buttonIndex, sender);
                                      [self helloWorld];
                                  }];
//        [UIAlertView lbk_showWithPresenter:self
//                                     title:@"Title2"
//                                   message:@"Message"
//                               buttonTitle:@"OK"];
//        [UIAlertView lbk_showWithPresenter:self
//                                     title:@"Title3"
//                                   message:@"Message"
//                               buttonTitle:@"OK"
//                                  callback:^{
//                                      NSLog(@"Close");
//                                      [self helloWorld];
//                                  }];
//        [UIAlertView lbk_showWithPresenter:self
//                                     title:@"Title4"
//                                   message:@"Message"
//                         cancelButtonTitle:@"Cancel"
//                          otherButtonTitle:@"OK"
//                                  callback:^(id _Nonnull sender, NSInteger buttonIndex) {
//                                      NSLog(@"Close[%ld] : %@", buttonIndex, sender);
//                                      [self helloWorld];
//                                  }];
//        [UIAlertView lbk_showWithPresenter:self
//                                     title:@"Title5"
//                                   message:@"Message"
//                         cancelButtonTitle:@"Cancel"
//                          otherButtonTitle:@"OK"
//                           delayActiveTime:3
//                                  callback:^(id _Nonnull sender, NSInteger buttonIndex) {
//                                      NSLog(@"Close[%ld] : %@", buttonIndex, sender);
//                                      [self helloWorld];
//                                  }];
//        [UIAlertView lbk_showWithPresenter:self
//                                     title:@"Title6"
//                                   message:@"Message"
//                         cancelButtonTitle:@"Cancel"
//                         otherButtonTitles:@[@"1", @"2", @"3"]
//                           delayActiveTime:5
//                                  callback:^(id _Nonnull sender, NSInteger buttonIndex) {
//                                      NSLog(@"Close[%ld] : %@", buttonIndex, sender);
//                                      [self helloWorld];
//                                  }];
//        UIAlertView *const alertView = [UIAlertView lbk_showTextInputWithPresenter:self
//                                                                             title:@"Title7"
//                                                                           message:@"Message"
//                                                                 cancelButtonTitle:@"Cancel"
//                                                                  otherButtonTitle:@"OK"
//                                                                              text:@"Text"
//                                                                       placeholder:@"Placeholder"
//                                                                   secureTextEntry:NO
//                                                                      keyboardType:UIKeyboardTypeDefault
//                                                                        limitation:0
//                                                                          callback:^(id _Nonnull sender, NSInteger buttonIndex, NSString * _Nullable text) {
//                                                                              NSLog(@"Close[%ld] : %@ -> %@", buttonIndex, sender, text);
//                                                                              [self helloWorld];
//                                                                          }];
//        UITextField *const textField = alertView.textField;
//        // iOS8以降だと、遅延実行しないと選択状態にできない
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            textField.selectedTextRange = [textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument];
//        });
    } forControlEvents:UIControlEventTouchUpInside];
    button.center = self.view.center;
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)helloWorld {
    NSLog(@"%s", __FUNCTION__);
}

@end
