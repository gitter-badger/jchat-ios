//
//  JCHATVoiceTableViewCell.m
//  JPush IM
//
//  Created by Apple on 15/1/4.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "JCHATVoiceTableViewCell.h"
#import "JChatConstants.h"
#import "MBProgressHUD+Add.h"

#define headHeight 46
#define gapWidth 5
#define chatBgViewHeight 50


@implementation JCHATVoiceTableViewCell {
  float chatBgViewWidth;
}

- (instancetype)init {
  self = [super init];
  if (self) {

  }
  return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    chatBgViewWidth = 60;
    [self setBackgroundColor:[UIColor clearColor]];
    self.voiceTimeLable = [[UILabel alloc] init];
    self.voiceBgView = [[UIImageView alloc] init];
    [self.voiceBgView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.voiceBgView];

    self.headView = [[UIImageView alloc] init];
    [self.headView setImage:[UIImage imageNamed:@"headDefalt_34.png"]];
    [self addSubview:self.headView];

    self.headView.layer.cornerRadius = 23;
    [self.headView.layer setMasksToBounds:YES];

    self.voiceImgView = [[UIImageView alloc] init];
    [self.voiceImgView setBackgroundColor:[UIColor clearColor]];
    [self.voiceImgView setImage:[UIImage imageNamed:@"SenderVoiceNodePlaying.png"]];
    [self addSubview:self.voiceTimeLable];
    [self.voiceImgView setFrame:CGRectMake(30, 5, 20, 30)];

    [self.voiceTimeLable setBackgroundColor:[UIColor clearColor]];
    [self.voiceTimeLable setFrame:CGRectMake(5, 5, 45, 30)];
    self.voiceTimeLable.textAlignment = NSTextAlignmentCenter;
    self.voiceTimeLable.font = [UIFont systemFontOfSize:18];
    self.voiceTimeLable.text = @"60''";
    [self.voiceBgView addSubview:self.voiceImgView];

    UIImage *img = nil;
    img = [UIImage imageNamed:@"mychatBg"];
    UIImage *newImg = [img resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 28, 20)];
    [self.voiceBgView setImage:newImg];
    [self.voiceBgView setFrame:CGRectMake(kApplicationWidth - 70, 0, 100, 60)];
    self.voiceBgView.layer.cornerRadius = 6;
    [self.voiceBgView.layer setMasksToBounds:YES];

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoice:)];
    [self.voiceBgView addGestureRecognizer:gesture];
    [self.voiceBgView setUserInteractionEnabled:YES];
    self.playing = NO;
    self.stateView = [[UIActivityIndicatorView alloc] init];
    [self addSubview:self.stateView];
    [self.stateView setBackgroundColor:[UIColor clearColor]];
    [self.stateView setHidden:NO];
    self.stateView.hidesWhenStopped = YES;

    self.sendFailView = [[UIImageView alloc] init];
    [self.sendFailView setImage:[UIImage imageNamed:@"fail05"]];
    [self.sendFailView setUserInteractionEnabled:YES];
    [self.sendFailView setBackgroundColor:[UIColor clearColor]];
    [self.sendFailView setHidden:YES];
    [self addSubview:self.sendFailView];

    self.readView = [[UIImageView alloc] init];
    [self.readView setBackgroundColor:[UIColor redColor]];
    self.readView.layer.cornerRadius = 4;
    [self addSubview:self.readView];
    self.continuePlayer = NO;
    [self headAddGesture];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendMessageResponse:)
                                                 name:JMSGNotification_SendMessageResult object:nil];
  }
  return self;
}

#pragma mark --发送消息响应
- (void)sendMessageResponse:(NSNotification *)response {
  DDLogDebug(@"Event - sendMessageResponse");

  JPIMMAINTHEAD(^{
    [self.stateView stopAnimating];

    NSDictionary *responseDic = [response userInfo];
    NSError *error = responseDic[JMSGSendMessageError];
    JMSGVoiceMessage *message = responseDic[JMSGSendMessageObject];

    if (![message.messageId isEqualToString:_message.messageId]) {
      DDLogWarn(@"The response msgId is not for this cell");
      return;
    }

    if (error == nil) {
      DDLogVerbose(@"VoiceMessage response - %@", message);
      self.model.messageStatus = kJMSGStatusSendSucceed;
      [self.sendFailView setHidden:YES];
      [self.stateView stopAnimating];
      [self.stateView setHidden:YES];
    } else {
      DDLogDebug(@"VoiceMessage response error - %@", error);
      self.model.messageStatus = kJMSGStatusSendFail;
      [self.sendFailView setHidden:NO];
      [self.stateView stopAnimating];
      [self.stateView setHidden:YES];
      _voiceFailMessage = message;
    }

    [self updateFrame];
  });
}

#pragma mark -- 语音时长算法
- (float)getLengthWithDuration:(NSInteger)duration {
  if (duration <= 2) {
    chatBgViewWidth = 60;
  } else if (duration >2 && duration <=20) {
    chatBgViewWidth = 60 + 4 * duration;
  }else if (duration > 20 && duration < 30){
    chatBgViewWidth = 130 + 2 * duration;
  }else if (duration >30  && duration < 60) {
    chatBgViewWidth = 160 + 1.3 * duration;
  }else {
    chatBgViewWidth = 300;
  }
  
  return chatBgViewWidth;
}

- (void)headAddGesture {
  [self.headView setUserInteractionEnabled:YES];
  [self.voiceBgView setUserInteractionEnabled:YES];
  [self.voiceImgView setUserInteractionEnabled:YES];
  UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushPersonInfoCtlClick)];
  [self.headView addGestureRecognizer:gesture];

  UITapGestureRecognizer *messageFailGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reSendMessage)];
  [self.sendFailView addGestureRecognizer:messageFailGesture];
}

- (void)reSendMessage {
  DDLogDebug(@"Action - reSendMessage");
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                      message:@"是否重新发送消息"
                                                     delegate:self
                                            cancelButtonTitle:@"取消"
                                            otherButtonTitles:@"确定", nil];
  [alertView show];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  DDLogDebug(@"Action - alertView");
  if (buttonIndex == 1) {
    [self.sendFailView setHidden:YES];
    [self.stateView setHidden:NO];
    [self.stateView startAnimating];
    self.model.messageStatus = kJMSGStatusSending;
    if (!self.voiceFailMessage) {
      [self.conversation getMessage:self.model.messageId
                  completionHandler:^(id resultObject, NSError *error) {
        if (error == nil) {
          self.voiceFailMessage = resultObject;
          self.voiceFailMessage.resourcePath = self.model.voicePath;
          self.voiceFailMessage.conversationType = self.conversation.chatType;
          self.message = resultObject;
          [JMSGMessage sendMessage:self.voiceFailMessage];
        } else {
          JPIMLog(@"获取消息失败!");
        }
      }];
    } else {
      self.voiceFailMessage.resourcePath = self.model.voicePath;
      [JMSGMessage sendMessage:self.voiceFailMessage];
    }
  }
}

- (void)pushPersonInfoCtlClick {
  if (self.delegate && [self.delegate respondsToSelector:@selector(selectHeadView:)]) {
    [self.delegate selectHeadView:self.model];
  }
}

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super initWithCoder:decoder];
  if (!self) {
    return nil;
  }
  return self;
}

- (void)drawRect:(CGRect)rect {

}

- (void)changeVoiceImage {
  if (!self.playing) {
    return;
  }
  NSString *voiceImagePreStr = @"";
  if (self.model.who) {
    voiceImagePreStr = @"SenderVoiceNodePlaying00";
  } else {
    voiceImagePreStr = @"ReceiverVoiceNodePlaying00";
  }
  self.voiceImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%zd.png", voiceImagePreStr, self.index % 4]];
  if (self.playing) {
    self.index++;
    [self performSelector:@selector(changeVoiceImage) withObject:nil afterDelay:0.25];
  }
}

- (void)setCellData:(JCHATChatModel *)model
           delegate:(id)delegate
            message:(JMSGVoiceMessage *)message
          indexPath:(NSIndexPath *)indexPath {
  self.conversation = model.conversation;
  self.delegate = delegate;
  _message = message;
  [self.stateView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
  self.model = model;
  if ([[NSFileManager defaultManager] fileExistsAtPath:model.avatar]) {
    [self.headView setImage:[UIImage imageWithContentsOfFile:model.avatar]];
  } else {
    [self.headView setImage:[UIImage imageNamed:@"headDefalt_34"]];
  }
  self.indexPath = indexPath;
  if ([model.voiceTime rangeOfString:@"''"].location != NSNotFound) {
    self.voiceTimeLable.text = model.voiceTime;
  } else {
    self.voiceTimeLable.text = [model.voiceTime stringByAppendingString:@"''"];
  }
  self.delegate = (id) delegate;
  [self.voiceBgView setImage:[UIImage imageNamed:@""]];
  if (self.model.who) {
    [self.voiceImgView setImage:[UIImage imageNamed:@"SenderVoiceNodePlaying.png"]];
  } else {
    [self.voiceImgView setImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying.png"]];
  }
  if (!_model.sendFlag) {
    _model.sendFlag = YES;
    // 展示这一条消息时检查状态，从而发送
    [self sendVoiceMessage];
  }
  [self getLengthWithDuration:[model.voiceTime integerValue]];
}

- (void)tapVoice:(UIGestureRecognizer *)gesture {
  [self playVoice];
}

#pragma mark --连续播放语音
- (void)playVoice {
  DDLogDebug(@"Action - playVoice");
  __block NSString *status = nil;
  if (self.model.messageStatus == kJMSGStatusReceiveDownloadFailed) {
    // 这条消息之前的状态是下载失败，则先重新下载
    [self.conversation getMessage:self.model.messageId
                completionHandler:^(id resultObject, NSError *error) {
      if (error == nil) {
        NSProgress *progress = [NSProgress progressWithTotalUnitCount:1000];
        [JMSGMessage downloadVoice:resultObject
                            withProgress:progress
                       completionHandler:^(id resultObject, NSError *error) {
          JPIMMAINTHEAD(^{
            if (error == nil) {
              self.model.voicePath = [(NSURL *) resultObject path];
              self.model.messageStatus = kJMSGStatusReceiveSucceed;
              status = @"下载语音成功";
              DDLogDebug(@"%@ -%@", status, [(NSURL *) resultObject path]);
              [self playVoice];
            } else {
              status = @"下载语音失败";
              DDLogWarn(@"%@ -%@", status, [(NSURL *) resultObject path]);
              [MBProgressHUD showMessage:status view:self];
            }
          });
        }];
      } else {
        status = @"获取消息失败。。。";
        DDLogDebug(status);
        JPIMMAINTHEAD(^{
          [MBProgressHUD showMessage:status view:self];
        });
      }
    }];
    return;
  }

  self.continuePlayer = NO;
  if ([self.delegate respondsToSelector:@selector(getContinuePlay:indexPath:)]) {
    [self.delegate getContinuePlay:self indexPath:self.indexPath];
  }
  [self.readView setHidden:YES];
  self.model.readState = YES;
  self.index = 0;
  if (!self.playing) {
    if ([[JCHATAudioPlayerHelper shareInstance] isPlaying]) {
      [[JCHATAudioPlayerHelper shareInstance] stopAudio];
      [[JCHATAudioPlayerHelper shareInstance] setDelegate:nil];
    }
    [[JCHATAudioPlayerHelper shareInstance] setDelegate:(id) self];
    [[JCHATAudioPlayerHelper shareInstance] managerAudioWithFileName:self.model.voicePath toPlay:YES];
    self.playing = YES;
  } else {
    self.playing = NO;
    self.continuePlayer = NO;
    [[JCHATAudioPlayerHelper shareInstance] stopAudio];
    [[JCHATAudioPlayerHelper shareInstance] setDelegate:nil];
  }
  [self changeVoiceImage];
}

#pragma mark ---播放完成后
- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
  [[JCHATAudioPlayerHelper shareInstance] setDelegate:nil];
  self.playing = NO;
  self.index = 0;
  if (self.model.who) {
    [self.voiceImgView setImage:[UIImage imageNamed:@"SenderVoiceNodePlaying.png"]];
  } else {
    [self.voiceImgView setImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying.png"]];
  }
  if (self.continuePlayer) {
    self.continuePlayer = NO;
    if ([self.delegate respondsToSelector:@selector(successionalPlayVoice:indexPath:)]) {
      [self performSelector:@selector(prepare) withObject:nil afterDelay:0.5];
    }
  }
}

#pragma mark --
- (void)prepare {
  [self.delegate successionalPlayVoice:self indexPath:self.indexPath];
}

#pragma mark-上传语音
- (void)sendVoiceMessage {
  DDLogDebug(@"Action - sendVoiceMessage");
  [self.stateView setHidden:NO];
  [self.stateView startAnimating];
  self.model.messageStatus = kJMSGStatusSending;
  DDLogVerbose(@"The voiceMessage - %@", _message);
  [JMSGMessage sendMessage:_message];
}

- (void)layoutSubviews {
  [self updateFrame];
}

- (void)updateFrame {
  /*信息读取状态显示*/
  if (self.model.readState) {
    [self.readView setHidden:YES];
  } else {
    [self.readView setHidden:NO];
  }
  if (self.model.messageStatus == kJMSGStatusSending) {
    [self.stateView setHidden:NO];
    [self.sendFailView setHidden:YES];
  } else if (self.model.messageStatus == kJMSGStatusSendSucceed) {
    [self.stateView setHidden:YES];
    [self.sendFailView setHidden:YES];
  } else if (self.model.messageStatus == kJMSGStatusSendFail) {
    [self.stateView setHidden:YES];
    [self.sendFailView setHidden:NO];
  } else {
    [self.stateView setHidden:YES];
    [self.sendFailView setHidden:YES];
  }
  UIImage *img = nil;
  if (self.model.who) {
    img = [UIImage imageNamed:@"mychatBg"];
    [self.headView setFrame:CGRectMake(kApplicationWidth - headHeight - gapWidth, 0, headHeight, headHeight)];//头像位置
    [self.voiceBgView setFrame:CGRectMake(kApplicationWidth - chatBgViewWidth - (headHeight + 2 * gapWidth), 0, chatBgViewWidth, chatBgViewHeight)];
    [self.voiceImgView setFrame:CGRectMake(20, 15, 20, 20)];
    [self.voiceTimeLable setFrame:CGRectMake(self.voiceBgView.frame.origin.x - 50, 10, 40, 30)];
    [self.stateView setFrame:CGRectMake(self.voiceTimeLable.frame.origin.x - 40, 10, 30, 30)];
    [self.sendFailView setFrame:CGRectMake(self.voiceTimeLable.frame.origin.x - 20, (50 - 15) / 2, 17, 15)];
    [self.readView setFrame:CGRectMake(self.voiceBgView.frame.origin.x - 10, 5, 8, 8)];
  } else {
    img = [UIImage imageNamed:@"otherChatBg"];
    [self.headView setFrame:CGRectMake(gapWidth, 0, headHeight, headHeight)];
    [self.voiceBgView setFrame:CGRectMake(headHeight + 2 * gapWidth, 0, chatBgViewWidth, chatBgViewHeight)];
    [self.voiceImgView setFrame:CGRectMake(20, 15, 20, 20)];
    [self.voiceTimeLable setFrame:CGRectMake(self.voiceBgView.frame.origin.x + chatBgViewWidth + gapWidth + 10, 10, 40, 30)];
    [self.stateView setFrame:CGRectMake(self.voiceTimeLable.frame.origin.x + self.voiceTimeLable.frame.size.width + 5, 10, 30, 30)];
    [self.sendFailView setFrame:CGRectMake(self.voiceTimeLable.frame.origin.x + self.voiceTimeLable.frame.size.width + 5, (50 - 15) / 2, 17, 15)];
    [self.readView setFrame:CGRectMake(self.voiceBgView.frame.origin.x + self.voiceBgView.frame.size.width + 10, 5, 8, 8)];
  }
  UIImage *newImg = [img resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 28, 20)];
  [self.voiceBgView setImage:newImg];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)successionalPlayVoice:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {

}

- (void)getContinuePlay:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {

}

- (void)selectHeadView:(JCHATChatModel *)model {

}


@end
