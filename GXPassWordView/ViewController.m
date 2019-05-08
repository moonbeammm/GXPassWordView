//
//  ViewController.m
//  GXPassWordView
//
//  Created by sgx on 2019/5/8.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "ViewController.h"
#import "GXPassWordView.h"

@interface ViewController ()
@property (nonatomic, strong) GXPassWordView *passwordView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.passwordView];
    self.passwordView.frame = CGRectMake(20, 200, self.view.bounds.size.width-40, 50);
    self.passwordView.completionBlock = ^(NSString * _Nonnull password) {
        NSLog(@"%@",password);
    };
}

- (GXPassWordView *)passwordView {
    if (!_passwordView) {
        _passwordView = [GXPassWordView new];
        _passwordView.backgroundColor = [UIColor clearColor];
        _passwordView.layer.masksToBounds = YES;
        _passwordView.layer.cornerRadius = 4;
        _passwordView.layer.borderWidth = 0.5;
        _passwordView.layer.borderColor = [UIColor grayColor].CGColor;
        [_passwordView installView];
        [_passwordView becomeFirstResponder];
    }
    return _passwordView;
}

@end
