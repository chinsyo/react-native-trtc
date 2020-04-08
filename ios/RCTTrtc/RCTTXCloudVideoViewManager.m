//
//  RCTTXCloudVideoViewManager.m
//  RCTTrtc
//
//  Created by 余保荣 on 2020/2/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RCTTXCloudVideoViewManager.h"
#import "RCTTXCloudVideoView.h"
#import <React/RCTUIManager.h>
#import <UIKit/UIKit.h>

@implementation RCTTXCloudVideoViewManager

RCT_EXPORT_MODULE(RCTTXCloudVideoView)
RCT_EXPORT_VIEW_PROPERTY(userId, NSString)

- (UIView *)view {
    //创建组件实例
    RCTTXCloudVideoView * viewInstance = [[RCTTXCloudVideoView alloc] init];
    return viewInstance;
}

@end
