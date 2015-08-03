//
//  JCHATPersonInfoCell.m
//  JPush IM
//
//  Created by Apple on 15/2/5.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "JCHATPersonInfoCell.h"
#import "JChatConstants.h"
@implementation JCHATPersonInfoCell

- (void)awakeFromNib {
  // Initialization code
  UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(0, 56,kApplicationWidth, 0.5)];
  [line setBackgroundColor:UIColorFromRGB(0xd0d0cf)];
  [self.personInfoConten setTextColor:UIColorFromRGB(0x808080)];
  [self addSubview:line];
  self.personInfoConten.textAlignment = NSTextAlignmentRight;
  [self.personInfoConten setEnabled:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
