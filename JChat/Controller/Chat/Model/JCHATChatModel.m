//
//  JCHATChatModel.m
//  test project
//
//  Created by guan jingFen on 14-3-10.
//  Copyright (c) 2014年 guan jingFen. All rights reserved.
//

#import "JCHATChatModel.h"
#import "JChatConstants.h"
#define headHeight 46

@implementation JCHATChatModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.readState=NO;
        self.sendFlag =YES;
    }
    return self;
}

-(CGSize )getTextSize
{
    if (self.type == kJMSGTextMessage || self.type == kJMSGEventMessage || self.type == kJMSGTimeMessage) {
        UIFont *font =[UIFont systemFontOfSize:18];
        CGSize maxSize = CGSizeMake(200, 2000);
        
        NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize realSize = [self.chatContent boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
//        CGSize realSize =[self.chatContent sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
        CGSize imgSize =realSize;
        imgSize.height=realSize.height+20;
        imgSize.width=realSize.width+2*15;
        return imgSize;
    }else{
        return CGSizeZero;
    }
}
@end
