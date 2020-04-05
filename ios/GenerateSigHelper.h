//
//  GenerateSigHelper.h
//  RNTrtc
//
//  Created by 余保荣 on 2020/2/25.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface GenerateSigHelper : NSObject

+ (NSString *)genUserSig:(NSInteger)sdkId userId:(NSString *)userId secretKey:(NSString *)secretKey;

@end

NS_ASSUME_NONNULL_END
