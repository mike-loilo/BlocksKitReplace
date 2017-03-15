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
