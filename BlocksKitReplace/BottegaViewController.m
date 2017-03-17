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
    
    NSTimer *const timer = [NSTimer lbk_timerWithTimeInterval:1 block:^(NSTimer *timer) {
        @strongify(self)
        if (!self) return;
        
        [self helloWorld];
    } repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
//    [NSTimer lbk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
//        @strongify(self)
//        if (!self) return;
//        
//        [self helloWorld];
//    } repeats:YES];
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
