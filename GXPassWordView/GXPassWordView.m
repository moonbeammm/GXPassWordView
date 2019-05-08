////  GXPassWordView.m
//
//  Created by sgx on 2019/5/8.
//  Copyright © 2019 Bilibili. All rights reserved.
//

#import "GXPassWordView.h"

@interface GXPassWordView () <UITextFieldDelegate>

@property (nonatomic, strong) CALayer *cursorLayer; //!< 光标
@property (nonatomic, strong) NSMutableArray <CALayer *>*dotArray; //!< 用于存放黑色的点点
@property (nonatomic, strong) NSMutableArray <UILabel *>*passwordLabelArr; //!< 显示密码的label
@property (nonatomic, strong) NSMutableArray <NSString *>*characterArray; //!< 用户输入的所有字符的集合

@end

@implementation GXPassWordView

- (instancetype)init {
    if (self = [super init]) {
        _characterArray = [NSMutableArray array];
        self.dotRadius = 4;
        self.passwordCount = 4;
        self.cursorColor = [UIColor redColor];
        self.dotColor = [UIColor grayColor];
        self.textColor = [UIColor blackColor];
        self.textFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    }
    return self;
}

#pragma mark - Public Method

- (void)installView {
    [self configSubviews];
}

- (NSString *)text {
    if (_characterArray.count == 0) {
        return nil;
    }
    NSString *text = [_characterArray componentsJoinedByString:@""];
    return text;
}

- (void)setText:(NSString *)text {
    [self.characterArray removeAllObjects];
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        if (self.characterArray.count < self.passwordCount) {
            [self.characterArray addObject:substring];
        } else {
            *stop = YES;
        }
    }];
}

#pragma mark UITextInputTraits

/**
 显示纯数字键盘
 */
- (UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}

- (BOOL)isSecureTextEntry {
    return YES;
}

#pragma mark - UIResponder Method

// 禁止复制
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self becomeFirstResponder];
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - UIKeyInput Method

- (BOOL)hasText {
    return self.text.length > 0;
}

/**
 添加一个字符

 @param text 用户最新输入的字符
 */
- (void)insertText:(NSString *)text {
    if (self.characterArray.count >= _passwordCount) {
        return;
    } else {
        // 添加一个字符
        [self.characterArray addObject:text];
    }
    // 更新内容
    [self textDidChanged:self.text];
}

/**
 删除一个字符
 */
- (void)deleteBackward {
    if (self.text.length == 0) {
        return;
    }
    // 删除一个字符
    [self.characterArray removeLastObject];
    // 更新内容
    [self textDidChanged:self.text];
}

#pragma mark - Private Method

/**
 更新内容.
 @param text 用户输入的所有字符
 */
- (void)textDidChanged:(NSString *)text {
    for (int i = 0; i < _passwordCount; i++) {
        if (i < self.characterArray.count) {
            NSString * onePassword = [text substringWithRange:NSMakeRange(i, 1)];
            // 隐藏圆点
            [self.dotArray objectAtIndex:i].hidden = YES;
            // 显示用户输入的字符
            [self.passwordLabelArr objectAtIndex:i].text = onePassword;
        } else {
            // 显示圆点
            [self.dotArray objectAtIndex:i].hidden = NO;
            // 清空label的内容
            [self.passwordLabelArr objectAtIndex:i].text = nil;
        }
    }
    // 更新光标位置
    [self updateCursorIfNeeded];
    // 通知外界.用户输入的文本改变了
    if (self.completionBlock) {
        self.completionBlock(text);
    }
}
/**
 更新光标位置
 */
- (void)updateCursorIfNeeded {
    if (self.characterArray.count == _passwordCount || !self.isFirstResponder) {
        self.cursorLayer.hidden = YES;
    } else {
        self.cursorLayer.hidden = NO;
    }
    
    // 计算光标新位置的frame
    NSInteger index = self.characterArray.count;
    NSInteger itemH = CGRectGetHeight(self.frame);
    NSInteger itemW = CGRectGetWidth(self.frame) / _passwordCount;
    NSInteger cursorLayerX = itemW * index + (itemW / 2.0 - 1);
    CGRect frame = CGRectMake(cursorLayerX, 8, 2, itemH - 16);
    
    // 隐藏圆点
    if (index < self.dotArray.count) {
        CALayer *dotLayer = self.dotArray[index];
        dotLayer.hidden = YES;
    }
    
    // 更新光标位置.并且取消layer的隐式动画.
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationDuration:0];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    self.cursorLayer.frame = frame;
    [CATransaction commit];
}

#pragma mark - init Method

- (void)configSubviews {
    self.dotArray = [NSMutableArray arrayWithCapacity:_passwordCount];
    self.passwordLabelArr = [NSMutableArray arrayWithCapacity:_passwordCount];
    // 生成中间的点和显示密码的label
    for (int i = 0; i < _passwordCount; i++) {
        CALayer *dotLayer = [self createdotLayer];
        [self.layer addSublayer:dotLayer];
        [self.dotArray addObject:dotLayer];
        
        UILabel *pwLabel = [self createPasswordLabel];
        [self addSubview:pwLabel];
        [self.passwordLabelArr addObject:pwLabel];
    }
    [self.layer addSublayer:self.cursorLayer];
}
- (void)layoutSubviews {
    [self updateCursorIfNeeded];
    NSInteger itemH = CGRectGetHeight(self.frame);
    NSInteger itemW = CGRectGetWidth(self.frame) / _passwordCount;
    for (int i = 0; i < _passwordCount; i++) {
        if (i >= self.passwordLabelArr.count || i >= self.dotArray.count) {
            return;
        }
        
        UILabel *pwLabel = self.passwordLabelArr[i];
        CALayer *dotLayer = self.dotArray[i];
        
        pwLabel.frame = CGRectMake(itemW*i, 0, itemW, itemH);
        dotLayer.frame = CGRectMake(itemW*i + (itemW-_dotRadius*2)/2.0, (itemH - _dotRadius*2)/2.0, _dotRadius*2, _dotRadius*2);
    }
}
- (CALayer *)createdotLayer {
    CALayer *dotLayer = [CALayer new];
    dotLayer.backgroundColor = self.dotColor.CGColor;
    dotLayer.cornerRadius = _dotRadius;
    dotLayer.hidden = NO;
    return dotLayer;
}
- (UILabel *)createPasswordLabel {
    UILabel *pwLabel = [[UILabel alloc] init];
    pwLabel.font = self.textFont;
    pwLabel.textColor = self.textColor;
    pwLabel.textAlignment = NSTextAlignmentCenter;
    pwLabel.backgroundColor = [UIColor clearColor];
    return pwLabel;
}
- (CALayer *)cursorLayer {
    if (!_cursorLayer) {
        _cursorLayer = [CALayer layer];
        _cursorLayer.hidden = NO;
        _cursorLayer.opacity = 1;
        _cursorLayer.backgroundColor = self.cursorColor.CGColor;
        
        CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animate.fromValue = @(0);
        animate.toValue = @(1.5);
        animate.duration = 0.5;
        animate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animate.autoreverses = YES;
        animate.removedOnCompletion = NO;
        animate.fillMode = kCAFillModeForwards;
        animate.repeatCount = HUGE_VALF;
        [_cursorLayer addAnimation:animate forKey:nil];
    }
    return _cursorLayer;
}

@end
