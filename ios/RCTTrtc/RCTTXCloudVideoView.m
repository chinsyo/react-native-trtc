//
//  RCTTXCloudVideoView.m
//  RCTTrtc
//
//  Created by 余保荣 on 2020/2/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RCTTXCloudVideoView.h"

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK_TRTC/TRTCCloud.h>
#import <TXLiteAVSDK_TRTC/TRTCCloudDef.h>

#import "RCTTrtc.h"

@interface RCTTXCloudVideoView()

@property (nonatomic, strong, readonly) TRTCCloud *trtc;
@property (nonatomic, strong) NSString *userId;

@end

@implementation RCTTXCloudVideoView

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
        if ([self.userId isEqualToString: [RCTTrtc getSelfUserId]]) {
            [self.trtc setLocalViewFillMode:TRTCVideoFillMode_Fill];
            [self.trtc startLocalPreview:[RCTTrtc isFrontCamera] view:self];
        } else {
            [self.trtc setRemoteViewFillMode:_userId mode:TRTCVideoFillMode_Fill];
            [self.trtc startRemoteView:_userId view:self];
        }
    }
}

- (void)stop {
    if (self.trtc) {
        if ([self.userId isEqualToString:[RCTTrtc getSelfUserId] ]) {
           // [_trtc stopLocalPreview ];
        } else {
            [self.trtc stopRemoteView:_userId ];
        }
    }
}

- (void)setUserId:(NSString *)userId {
    [self stop];
    _userId = userId;
    [self start];
}

- (NSString *)getUserId {
    return _userId;
}

@end
