////  GXPassWordView.h
//
//  Created by sgx on 2019/5/8.
//  Copyright © 2019 Bilibili. All rights reserved.
//
//  https://www.tapd.cn/20055921/prong/stories/view/1120055921001137346
//  密码输入框

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GXPassWordView : UIView <UIKeyInput,UITextInputTraits>

@property (nonatomic, strong, readonly) NSString *text; //!< 用户输入的字符串

/*****外界可自定义的属性******/
@property (nonatomic, assign) NSInteger passwordCount; //!< 密码个数.默认4个
@property (nonatomic, assign) NSInteger dotRadius; //!< 圆点半径.默认4
@property (nonatomic, strong) UIColor *cursorColor; //!< 光标颜色.默认FB7299
@property (nonatomic, strong) UIColor *dotColor; //!< 圆点颜色.默认E7E7E7
@property (nonatomic, strong) UIColor *textColor; //!< 文本颜色.默认212121
@property (nonatomic, strong) UIFont *textFont; //!< 文本字体大小.默认18
/*****外界可自定义的属性******/

/**
 加载内容.只有调了这个方法才会添加子视图.
 */
- (void)installView;
/**
 清空用户输入的密码
 */
- (void)clear;
/**
 用户输入的文本改变的回调
 */
@property (nonatomic, copy) void (^completionBlock)(NSString *password);

@end

NS_ASSUME_NONNULL_END
