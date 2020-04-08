
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>


@interface RCTTrtc : RCTEventEmitter <RCTBridgeModule>

+ (BOOL)isFrontCamera;
+ (NSString *)getSelfUserId;

@end

