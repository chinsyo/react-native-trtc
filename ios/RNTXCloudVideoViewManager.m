//
//  RNTXCloudVideoViewManager.m
//  RNTrtc
//
//  Created by 余保荣 on 2020/2/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RNTXCloudVideoViewManager.h"
#import "RNTXCloudVideoView.h"
#import <React/RCTUIManager.h>
#import <UIKit/UIKit.h>

@implementation RNTXCloudVideoViewManager

RCT_EXPORT_MODULE(RNTXCloudVideoView)
RCT_EXPORT_VIEW_PROPERTY(userId, NSString)

- (UIView *)view
{
    //创建组件实例
    RNTXCloudVideoView * viewInstance = [[RNTXCloudVideoView alloc] init];
    return viewInstance;
}

@end
