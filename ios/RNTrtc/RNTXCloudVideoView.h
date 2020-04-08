//
//  RNTXCloudVideoView.h
//  RNTrtc
//
//  Created by 余保荣 on 2020/2/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNTXCloudVideoView : UIView

- (void)setUserId:(NSString *)userId;
- (NSString *)getUserId;

@end

NS_ASSUME_NONNULL_END
