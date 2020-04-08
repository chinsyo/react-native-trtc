
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>


@interface RNTrtc : RCTEventEmitter <RCTBridgeModule>

+ (BOOL)isFrontCamera;
+ (NSString *)getSelfUserId;

@end

