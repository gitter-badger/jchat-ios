//
//  JCHATAvatarView.h
//  JChat
//
//  Created by HuminiOS on 15/7/28.
//  Copyright (c) 2015年 HXHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JChatConstants.h"
#import "UIImageView+LBBlurredImage.h"
@interface JCHATAvatarView : UIImageView
@property(strong,nonatomic)UIImage *originImage;
@property(strong,nonatomic)UIImageView *centeraverter;
@property(strong,nonatomic)UILabel *nameLable;


- (void)updataNameLable;
@end
