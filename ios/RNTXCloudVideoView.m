//
//  RNTXCloudVideoView.m
//  RNTrtc
//
//  Created by 余保荣 on 2020/2/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RNTXCloudVideoView.h"

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK_TRTC/TRTCCloud.h>
#import <TXLiteAVSDK_TRTC/TRTCCloudDef.h>

#import "RNTrtc.h"

@interface RNTXCloudVideoView()

@property (nonatomic, strong) TRTCCloud *trtc;

@end

@implementation RNTXCloudVideoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _trtc = [TRTCCloud sharedInstance];
    }
    return self;
}

- (void)start {
    if (self.trtc) {
        if ([self.userId isEqualToString: [RNTrtc getSelfUserId]]) {
            [self.trtc setLocalViewFillMode:TRTCVideoFillMode_Fill];
            [self.trtc startLocalPreview:[RNTrtc isFrontCamera] view:self];
        } else {
            [self.trtc setRemoteViewFillMode:_userId mode:TRTCVideoFillMode_Fill];
            [self.trtc startRemoteView:_userId view:self];
        }
    }
}

- (void)stop {
    if (self.trtc) {
        if ([self.userId isEqualToString:[RNTrtc getSelfUserId] ]) {
           // [_trtc stopLocalPreview ];
        } else {
            [self.trtc stopRemoteView:_userId ];
        }
    }
}



- (void)setUserId:(NSString *)userId {
    [self stop];
    _userId = [userId copy];
    [self start];
}

- (NSString *)getUserId {
    return _userId;
}

@end
