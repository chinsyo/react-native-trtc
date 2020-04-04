//
//  RNTXCloudVideoView.m
//  RNTrtc
//
//  Created by 余保荣 on 2020/2/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNTXCloudVideoView.h"
#import "TRTCCloud.h"
#import "TRTCCloudDef.h"
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
    if (_trtc) {
        if ([_userId isEqualToString: [RNTrtc getSelfUserId]]) {
            [_trtc setLocalViewFillMode:TRTCVideoFillMode_Fill];
            [_trtc startLocalPreview:[RNTrtc isFrontCamera] view:self];
        } else {
            [_trtc setRemoteViewFillMode:_userId mode:TRTCVideoFillMode_Fill];
            [_trtc startRemoteView:_userId view:self];
        }
    }
}

- (void)stop {
    if (_trtc) {
        if ([_userId isEqualToString:[RNTrtc getSelfUserId] ]) {
           // [_trtc stopLocalPreview ];
        } else {
            [_trtc stopRemoteView:_userId ];
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
