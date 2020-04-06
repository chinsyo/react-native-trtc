
#import "RNTrtc.h"
#import "GenerateSigHelper.h"
#import "RNTXCloudVideoView.h"
#import <TXLiteAVSDK_TRTC/TRTCCloud.h>
#import <TXLiteAVSDK_TRTC/TRTCCloudDef.h>
#import <TXLiteAVSDK_TRTC/TRTCCloudDelegate.h>
#import <TXLiteAVSDK_TRTC/TXLiteAVCode.h>
#import <TXLiteAVSDK_TRTC/TRTCStatistics.h>

static BOOL mFrontCamera = true;
static NSString *selfUserId;

@interface RNTrtc() <TRTCCloudDelegate, TRTCLogDelegate, TRTCAudioFrameDelegate> {
    TRTCCloud *trtcCloud;
}

@end


@implementation RNTrtc

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

+ (NSString *)getSelfUserId {
    return selfUserId;
}

+ (BOOL)isFrontCamera {
    return mFrontCamera;
}

+ (instancetype)allocWithZone:(NSZone *)zone {
    static RNTrtc *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"onCapturedAudioFrame",
             @"onPlayAudioFrame",
             @"onMixedPlayAudioFrame",
             @"onLog",
             @"onError",
             @"onWarning",
             @"onEnterRoom",
             @"onExitRoom",
             @"onSwitchRole",
             @"onConnectOtherRoom",
             @"onDisconnectOtherRoom",
             @"onRemoteUserEnterRoom",
             @"onRemoteUserLeaveRoom",
             @"onUserVideoAvailable",
             @"onUserSubStreamAvailable",
             @"onUserAudioAvailable",
             @"onFirstVideoFrame",
             @"onFirstAudioFrame",
             @"onSendFirstLocalVideoFrame",
             @"onSendFirstLocalAudioFrame",
             @"onNetworkQuality",
             @"onStatistics",
             @"onConnectionLost",
             @"onTryToReconnect",
             @"onConnectionRecovery",
             @"onCameraDidReady",
             @"onMicDidReady",
             @"onAudioRouteChanged",
             @"onUserVoiceVolume",
             @"onRecvCustomCmdMsg",
             @"onMissCustomCmdMsg",
             @"onRecvSEIMsg",
             @"onStartPublishing", //TODO
             @"onStopPublishing", //TODO
             @"onStartPublishCDNStream", //TODO
             @"onStopPublishCDNStream", //TODO
             @"onSetMixTranscodingConfig",
             @"onAudioEffectFinished",
             @"onBackgroundMusicProgress",
             @"onBackgroundMusicComplete",
             @"onSpeedTestProgress",
             ];
}

RCT_EXPORT_METHOD(setLogEnabled:(BOOL)enabled) {
    if (enabled) {
        [TRTCCloud setLogDelegate:self];
    } else {
        [TRTCCloud setLogDelegate:nil];
    }
}

RCT_EXPORT_METHOD(creatUserSig:(NSInteger)sdkAppId secretKey:(NSString *) secretKey userId:(NSString *) userId  resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"creatUserSig sdkAppId:%ld secretKey:%@", (long)sdkAppId, secretKey);
    @try
    {
        NSString *userSig = [GenerateSigHelper genUserSig:sdkAppId userId:userId secretKey:secretKey];
        resolve(userSig);
    }
    @catch (NSException *exception)
    {
        // reject(@"",@"",exception);
    }
}

RCT_EXPORT_METHOD(enableScreenOn)
{
    NSLog(@"enableScreenOn");
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

RCT_EXPORT_METHOD(disableScreenOn)
{
    NSLog(@"disableScreenOn");
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - TRTCCloud
#pragma mark 创建与销毁
RCT_EXPORT_METHOD(sharedInstance:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"sharedInstance ");
    @try
    {
        trtcCloud = [TRTCCloud sharedInstance];
        trtcCloud.delegate = self;
        [trtcCloud setAudioFrameDelegate:self];
        resolve(@(YES));
    }
    @catch (NSException *exception)
    {
        // reject(@"",@"",exception);
    }
    
}

RCT_EXPORT_METHOD(destroySharedInstance)
{
    NSLog(@"destroySharedInstance");
    [TRTCCloud destroySharedIntance];
}

#pragma mark 房间相关接口函数
RCT_EXPORT_METHOD(enterRoom:(NSDictionary *)data scene:(NSInteger)scene)
{
    NSLog(@"enterRoom");
    // TRTC相关参数设置
    TRTCParams *param = [[TRTCParams alloc] init];
    param.sdkAppId = (UInt32)[data[@"sdkAppId"] integerValue];
    param.userId = data[@"userId"];
    param.roomId = (UInt32)[data[@"roomId"] integerValue];
    param.userSig = data[@"userSig"];
    
    if (data[@"privateMapKey"]) {
         param.privateMapKey = data[@"privateMapKey"];
    }
    if (data[@"businessInfo"]) {
         param.bussInfo = data[@"businessInfo"];
    }

    param.role = [data[@"role"] integerValue];
    selfUserId = data[@"userId"];
    [trtcCloud enterRoom:param appScene:scene];
}

RCT_EXPORT_METHOD(exitRoom)
{
    NSLog(@"exitRoom");
    [trtcCloud exitRoom];
}

RCT_EXPORT_METHOD(switchRole:(NSInteger) role)
{
    NSLog(@"switchRole");
    [trtcCloud switchRole:role];
}

RCT_EXPORT_METHOD(connectOtherRoom:(NSString *) param)
{
    NSLog(@"connectOtherRoom");
    [trtcCloud connectOtherRoom:param];
}

RCT_EXPORT_METHOD(disconnectOtherRoom)
{
    NSLog(@"disconnectOtherRoom");
    [trtcCloud disconnectOtherRoom];
}

RCT_EXPORT_METHOD(setDefaultStreamRecvMode:(BOOL) autoRecvAudio autoRecvVideo: (BOOL) autoRecvVideo)
{
    NSLog(@"setDefaultStreamRecvMode");
    [trtcCloud setDefaultStreamRecvMode:autoRecvAudio video:autoRecvVideo];
}

#pragma mark CDN相关接口函数
RCT_EXPORT_METHOD(startPublishing:(NSString *) streamId streamType:(NSInteger) streamType)
{
    NSLog(@"startPublishing");
    [trtcCloud startPublishing:streamId type:streamType];
}

RCT_EXPORT_METHOD(stopPublishing)
{
    NSLog(@"stopPublishing");
    [trtcCloud stopPublishing];
}

RCT_EXPORT_METHOD(startPublishCDNStream:(NSDictionary *) param )
{
    NSLog(@"startPublishCDNStream");
    TRTCPublishCDNParam *cdnParam=[[TRTCPublishCDNParam alloc] init];
    cdnParam.appId = [param[@"appId"] integerValue];
    cdnParam.bizId = [param[@"bizId"] integerValue];
    cdnParam.url = param[@"url"];
    [trtcCloud startPublishCDNStream:cdnParam];
}

RCT_EXPORT_METHOD(stopPublishCDNStream)
{
    NSLog(@"stopPublishCDNStream");
    [trtcCloud stopPublishCDNStream];
}

RCT_EXPORT_METHOD(setMixTranscodingConfig:(NSDictionary *) config )
{
    NSLog(@"setMixTranscodingConfig");
//    TRTCTranscodingConfig *transConfig = [[TRTCTranscodingConfig alloc] init];
//    transConfig.appId               = [config[@"appId"] integerValue];
//    transConfig.bizId               = [config[@"bizId"] integerValue];
//    transConfig.audioBitrate        = [config[@"audioBitrate"] integerValue];
//    transConfig.audioChannels       = [config[@"audioChannels"] integerValue];
//    transConfig.audioSampleRate     = [config[@"audioSampleRate"] integerValue];
//    transConfig.backgroundColor     = [config[@"backgroundColor"] integerValue];
//    transConfig.mode                = [config[@"mode"] integerValue];
//    transConfig.videoBitrate        = [config[@"videoBitrate"] integerValue];
//    transConfig.videoFramerate      = [config[@"videoFramerate"] integerValue];
//    transConfig.videoGOP            = [config[@"videoGOP"] integerValue];
//    transConfig.videoHeight         = [config[@"videoHeight"] integerValue];
//    transConfig.videoWidth          = [config[@"videoWidth"] integerValue];
//    
//    NSArray *temp = config[@"mixUsers"];
//    int count = temp.count;//减少调用次数
//    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
//    for (int i=0; i<count; i++) {
//        NSDictionary *item          = [array objectAtIndex:i];
//        TRTCMixUser *user           = [[TRTCMixUser alloc] init];
//        user.userId                 = item[@"userId"];
//        user.roomID                 = item[@"roomId"];
//        user.zOrder                 = [item[@"zOrder"] integerValue];
//        user.streamType             = [item[@"streamType"] integerValue];
//        user.pureAudio              = [item[@"pureAudio"] boolValue];
//        
//        int width                   = [item[@"width"] integerValue];
//        int height                  = [item[@"height"] integerValue];
//        int x                       = [item[@"x"] integerValue];
//        int y                       = [item[@"y"] integerValue];
//        user.rect                   = CGRectMake(x,y,width,height);
//        [array replaceObjectAtIndex:i withObject:user];
//    }
//    transConfig.mixUsers = array;
//    [trtcCloud setMixTranscodingConfig:transConfig];
}

#pragma mark 视频相关接口
RCT_EXPORT_METHOD(startLocalPreview:(BOOL)frontCamera){
    NSLog(@"startLocalPreview:%u", frontCamera);
    mFrontCamera = frontCamera;
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    UIView *rootView = appDelegate.window.rootViewController.view;
    RNTXCloudVideoView *cloudView = [self findViewByUserId:rootView userId:selfUserId];
    if (cloudView) {
        [trtcCloud startLocalPreview:frontCamera view:cloudView];
    }
}

RCT_EXPORT_METHOD(stopLocalPreview)
{
    NSLog(@"stopLocalPreview");
    [trtcCloud stopLocalPreview ];
}

RCT_EXPORT_METHOD(muteLocalVideo:(BOOL) mute)
{
    NSLog(@"muteLocalVideo");
    [trtcCloud muteLocalVideo:mute ];
}

RCT_EXPORT_METHOD(startRemoteView:(NSString *) userId)
{
    NSLog(@"startRemoteView");
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    UIView *rootView = appDelegate.window.rootViewController.view;
    RNTXCloudVideoView *cloudView = [self findViewByUserId:rootView userId:selfUserId];
    if (cloudView) {
        [trtcCloud startRemoteView:userId view:cloudView];
    }
}


RCT_EXPORT_METHOD(stopRemoteView:(NSString *) userId)
{
    NSLog(@"stopRemoteView");
    [trtcCloud stopRemoteView:userId ];
}


RCT_EXPORT_METHOD(stopAllRemoteView)
{
    NSLog(@"stopAllRemoteView");
    [trtcCloud stopAllRemoteView ];
    
}

RCT_EXPORT_METHOD(muteRemoteVideoStream:(NSString *) userId mute:(BOOL) mute)
{
    NSLog(@"muteRemoteVideoStream");
    [trtcCloud muteRemoteVideoStream:userId  mute:mute];
}

RCT_EXPORT_METHOD(muteAllRemoteVideoStreams:(BOOL) mute)
{
    NSLog(@"muteAllRemoteVideoStreams");
    [trtcCloud muteAllRemoteVideoStreams:mute];
}

RCT_EXPORT_METHOD(setVideoEncoderParam:(NSDictionary *) data)
{
    NSLog(@"setVideoEncoderParam");
    TRTCVideoEncParam *encParam = [[TRTCVideoEncParam alloc] init];
    encParam.videoResolution    = [data[@"videoResolution"] integerValue];
    encParam.enableAdjustRes    = [data[@"enableAdjustRes"] boolValue];
    encParam.videoBitrate       = [data[@"videoBitrate"] integerValue];
    encParam.videoFps           = [data[@"videoFps"] integerValue];
    encParam.resMode            = [data[@"videoResolutionMode"] integerValue];
    [trtcCloud setVideoEncoderParam:encParam];
}

RCT_EXPORT_METHOD(setNetworkQosParam:(NSDictionary *) data)
{  NSLog(@"setNetworkQosParam");
    TRTCNetworkQosParam *qosParam   = [[TRTCNetworkQosParam alloc]init];
    qosParam.preference             = [data[@"preference"] integerValue];
    qosParam.controlMode            = [data[@"controlMode"] integerValue];
    [trtcCloud setNetworkQosParam:qosParam];
}

RCT_EXPORT_METHOD(setLocalViewFillMode:(NSInteger) mode)
{
    NSLog(@"setLocalViewFillMode");
    [trtcCloud setLocalViewFillMode:mode];
}

RCT_EXPORT_METHOD(setRemoteViewFillMode:(NSString *) userId mode:(NSInteger) mode)
{
    NSLog(@"setRemoteViewFillMode");
    [trtcCloud setRemoteViewFillMode:userId mode:mode];
}

RCT_EXPORT_METHOD(setLocalViewRotation:(NSInteger) rotation)
{
    NSLog(@"setLocalViewRotation");
    [trtcCloud setLocalViewRotation:rotation];
}

RCT_EXPORT_METHOD(setRemoteViewRotation:(NSString *) userId rotation:(NSInteger) rotation)
{
    NSLog(@"setRemoteViewRotation");
    [trtcCloud setRemoteViewRotation:userId rotation:rotation];
}


RCT_EXPORT_METHOD(setVideoEncoderRotation:(NSInteger) rotation)
{
    NSLog(@"setVideoEncoderRotation");
    [trtcCloud setVideoEncoderRotation:rotation];
}

RCT_EXPORT_METHOD(setLocalViewMirror:(NSInteger) mirrorType)
{
    NSLog(@"setLocalViewMirror");
    [trtcCloud setLocalViewMirror:mirrorType];
}

RCT_EXPORT_METHOD(setVideoEncoderMirror:(BOOL) mirror)
{
    NSLog(@"setVideoEncoderMirror");
    [trtcCloud setVideoEncoderMirror:mirror];
}

RCT_EXPORT_METHOD(setGSensorMode:(NSInteger) mode)
{
    NSLog(@"setGSensorMode");
    [trtcCloud setGSensorMode:mode];
}

RCT_EXPORT_METHOD(enableEncSmallVideoStream:(BOOL) enable  smallVideoEncParam:(NSDictionary *) smallVideoEncParam resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"enableEncSmallVideoStream");
    TRTCVideoEncParam *encParam = [[TRTCVideoEncParam alloc] init];
    encParam.videoResolution    = [smallVideoEncParam[@"videoResolution"] integerValue];
    encParam.enableAdjustRes    = [smallVideoEncParam[@"enableAdjustRes"] boolValue];
    encParam.videoBitrate       = [smallVideoEncParam[@"videoBitrate"] integerValue];
    encParam.videoFps           = [smallVideoEncParam[@"videoFps"] integerValue];
    encParam.resMode            = [smallVideoEncParam[@"videoResolutionMode"] integerValue];
    int result = [trtcCloud enableEncSmallVideoStream:enable withQuality:encParam];
    resolve(@(result));
}

RCT_EXPORT_METHOD(setRemoteVideoStreamType:(NSString *)userId  streamType:(NSInteger) streamType resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"setRemoteVideoStreamType");
    [trtcCloud setRemoteVideoStreamType:userId type:streamType];
    resolve(@(1));
}

RCT_EXPORT_METHOD(setPriorRemoteVideoStreamType:(NSInteger)streamType   resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"setPriorRemoteVideoStreamType");
    [trtcCloud setPriorRemoteVideoStreamType:streamType];
    resolve(@(1));
}

RCT_EXPORT_METHOD(snapshotVideo:(NSString *)userId  streamType:(NSInteger)streamType resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"snapshotVideo");
    [trtcCloud snapshotVideo:userId
                        type:streamType
             completionBlock:^(TXImage *image) {
                 if (image) {
                     NSData *imageData = UIImagePNGRepresentation(image);
                     NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                     resolve(base64);
                 }
             }
     ];
}


#pragma mark 音频相关接口函数
RCT_EXPORT_METHOD(startLocalAudio)
{
    NSLog(@"startLocalAudio");
    [trtcCloud startLocalAudio];
}

RCT_EXPORT_METHOD(stopLocalAudio)
{
    NSLog(@"stopLocalAudio");
    [trtcCloud stopLocalAudio];
}

RCT_EXPORT_METHOD(muteLocalAudio:(BOOL) var)
{
    NSLog(@"muteLocalAudio");
    [trtcCloud muteLocalAudio:var];
}

RCT_EXPORT_METHOD(setAudioRoute:(NSInteger) route)
{
    NSLog(@"setAudioRoute");
    [trtcCloud setAudioRoute:route];
}

RCT_EXPORT_METHOD(muteRemoteAudio:(NSString *) userId mute:(BOOL) mute)
{
    NSLog(@"muteRemoteAudio");
    [trtcCloud muteRemoteAudio:userId mute:mute];
}

RCT_EXPORT_METHOD(muteAllRemoteAudio:(BOOL) mute)
{
    NSLog(@"muteAllRemoteAudio");
    [trtcCloud muteAllRemoteAudio:mute];
}


RCT_EXPORT_METHOD(setRemoteAudioVolume:(NSString *) userId volume:(NSInteger) volume)
{
    NSLog(@"setRemoteAudioVolume");
    [trtcCloud setRemoteAudioVolume:userId volume:volume];
}

RCT_EXPORT_METHOD(setAudioCaptureVolume:(NSInteger) volume)
{
    NSLog(@"setAudioCaptureVolume");
    [trtcCloud setAudioCaptureVolume:volume];
}

RCT_EXPORT_METHOD(getAudioCaptureVolume:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"getAudioCaptureVolume");
    NSInteger result= [trtcCloud getAudioCaptureVolume];
    resolve(@(result));
}

RCT_EXPORT_METHOD(setAudioPlayoutVolume:(NSInteger) volume)
{
    NSLog(@"setAudioPlayoutVolume");
    [trtcCloud setAudioPlayoutVolume:volume];
}

RCT_EXPORT_METHOD(getAudioPlayoutVolume:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"getAudioPlayoutVolume");
    NSInteger result= [trtcCloud getAudioPlayoutVolume];
    resolve(@(result));
}

RCT_EXPORT_METHOD(enableAudioVolumeEvaluation:(NSInteger) intervalMs)
{
    NSLog(@"enableAudioVolumeEvaluation");
    [trtcCloud enableAudioVolumeEvaluation:intervalMs];
}

RCT_EXPORT_METHOD(startAudioRecording:(NSDictionary *) param  resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"startAudioRecording");
    TRTCAudioRecordingParams *recordParam = [[TRTCAudioRecordingParams alloc] init];
    recordParam.filePath = param[@"filePath"];
    NSInteger result = [trtcCloud startAudioRecording:recordParam];
    resolve(@(result));
}

RCT_EXPORT_METHOD(stopAudioRecording)
{
    NSLog(@"stopAudioRecording");
    [trtcCloud stopAudioRecording];
}

RCT_EXPORT_METHOD(setSystemVolumeType:(NSInteger) type)
{
    NSLog(@"setSystemVolumeType");
    [trtcCloud setSystemVolumeType:type];
}

RCT_EXPORT_METHOD(enableAudioEarMonitoring:(BOOL) enable)
{
    NSLog(@"enableAudioEarMonitoring");
    [trtcCloud enableAudioEarMonitoring:enable];
}

#pragma mark 摄像头相关接口函数
RCT_EXPORT_METHOD(switchCamera)
{
    NSLog(@"switchCamera");
    [trtcCloud switchCamera];
}

RCT_EXPORT_METHOD(isCameraZoomSupported:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"isCameraZoomSupported");
    BOOL result = [trtcCloud isCameraZoomSupported];
    resolve(@(result));
}

RCT_EXPORT_METHOD(setZoom:(NSInteger) distance)
{
    NSLog(@"setZoom");
    [trtcCloud setZoom:distance];
}

RCT_EXPORT_METHOD(isCameraTorchSupported:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"isCameraTorchSupported");
    BOOL result = [trtcCloud isCameraTorchSupported];
    resolve(@(result));
}

RCT_EXPORT_METHOD(enableTorch:(BOOL ) enable  resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"enableTorch");
    BOOL result = [trtcCloud enbaleTorch:enable];
    resolve(@(result));
}

RCT_EXPORT_METHOD(isCameraFocusPositionInPreviewSupported:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"isCameraFocusPositionInPreviewSupported");
    BOOL result=  [trtcCloud isCameraFocusPositionInPreviewSupported];
    resolve(@(result));
}


RCT_EXPORT_METHOD(setFocusPosition:(NSInteger) x y:(NSInteger)y )
{
    NSLog(@"setFocusPosition");
    CGPoint point = CGPointMake(x, y);
    [trtcCloud setFocusPosition:point];
}

RCT_EXPORT_METHOD(isCameraAutoFocusFaceModeSupported:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"isCameraAutoFocusFaceModeSupported");
    BOOL result = [trtcCloud isCameraAutoFocusFaceModeSupported];
    resolve(@(result));
}


RCT_EXPORT_METHOD(startScreenRecord)
{
    NSLog(@"startScreenRecord");
}

RCT_EXPORT_METHOD(stopScreenRecord:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"stopScreenRecord");
}

#pragma mark 音频设备相关接口(MAC)
#pragma mark 美颜滤镜相关接口函数(TODO)
#pragma mark 辅流相关接口函数(MAC)
#pragma mark 自定义采集和渲染
/**
(void)     - enableCustomVideoCapture
(void)     - sendCustomVideoData
(int)     - setLocalVideoRenderDelegate
(int)     - setRemoteVideoRenderDelegate
(void)     - enableCustomAudioCapture
(void)     - sendCustomAudioData
(void)     - setAudioFrameDelegate
 */
RCT_EXPORT_METHOD(enableCustomVideoCapture:(BOOL)enabled) {
    NSLog(@"enableCustomVideoCapture");
    [trtcCloud enableCustomVideoCapture:enabled];
}

RCT_EXPORT_METHOD(sendCustomVideoData:(NSDictionary *)videoData resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"sendCustomVideoData");
    TRTCVideoFrame *frame = [[TRTCVideoFrame alloc] init];
    [trtcCloud sendCustomVideoData:frame];
    resolve(@(1));
}

RCT_EXPORT_METHOD(setLocalVideoRenderDelegate) {
    NSLog(@"setLocalVideoRenderDelegate");
}

RCT_EXPORT_METHOD(setRemoteVideoRenderDelegate) {
    NSLog(@"setRemoteVideoRenderDelegate");
}

RCT_EXPORT_METHOD(enableCustomAudioCapture:(BOOL)enabled) {
    NSLog(@"enableCustomAudioCapture");
    [trtcCloud enableCustomAudioCapture:enabled];
}

RCT_EXPORT_METHOD(sendCustomAudioData:(NSDictionary *)audioData resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"sendCustomAudioData");
    TRTCAudioFrame *frame = [[TRTCAudioFrame alloc] init];
    [trtcCloud sendCustomAudioData:frame];
    resolve(@(1));
}

RCT_EXPORT_METHOD(setAudioFrameDelegate) {
    NSLog(@"setAudioFrameDelegate");
}

#pragma mark 自定义消息发送
/**
(BOOL)     - sendCustomCmdMsg
(BOOL)     - sendSEIMsg
 */
RCT_EXPORT_METHOD(sendCustomCmdMsg:(NSInteger)cmdID data:(NSString *)msg reliable:(BOOL)reliable ordered:(BOOL)ordered resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"sendCustomCmdMsg");
    NSData *data = [[NSData alloc] initWithBase64EncodedString:msg options:0];
    BOOL result = [trtcCloud sendCustomCmdMsg:cmdID data:data reliable:reliable ordered:ordered];
    if (result) {
        resolve(@(result));
    } else {
        reject(@"-1", @"sendCustomCmdMsg failed", nil);
    }
}

RCT_EXPORT_METHOD(sendSEIMsg:(NSString *)msg repeatCount:(int)repeatCount resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"sendSEIMsg");
    NSData *data = [[NSData alloc] initWithBase64EncodedString:msg options:0];
    BOOL result = [trtcCloud sendSEIMsg:data repeatCount:repeatCount];
    if (result) {
        resolve(@(result));
    } else {
        reject(@"-1", @"sendSEIMsg failed", nil);
    }
}

#pragma mark 背景混音相关接口函数
/**
(void)     - playBGM
(void)     - stopBGM
(void)     - pauseBGM
(void)     - resumeBGM
(NSInteger)     - getBGMDuration
(int)     - setBGMPosition
(void)     - setBGMVolume
(void)     - setBGMPlayoutVolume
(void)     - setBGMPublishVolume
(void)     - setReverbType
(void)     - setVoiceChangerType
 */
RCT_EXPORT_METHOD(playBGM:(NSString *)path resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"playBGM");
    [trtcCloud playBGM:path
       withBeginNotify:^(NSInteger errCode) {
        if (errCode < 0) {
            NSString *code = [NSString stringWithFormat:@"%d", errCode];
            reject(code, @"playBGM failed", nil);
        } else {
            resolve(@(errCode));
        }
    }
    withProgressNotify:^(NSInteger progressMS, NSInteger durationMS) {
        [self sendEventWithName:@"onBackgroundMusicProgress" body:@{
            @"progress": @(progressMS),
            @"duration": @(durationMS),
        }];
    }
     andCompleteNotify:^(NSInteger errCode) {
        [self sendEventWithName:@"onBackgroundMusicComplete" body:@{
            @"errorCode": @(errCode),
        }];
    }];
}

RCT_EXPORT_METHOD(stopBGM) {
    NSLog(@"stopBGM");
    [trtcCloud stopBGM];
}

RCT_EXPORT_METHOD(pauseBGM) {
    NSLog(@"pauseBGM");
    [trtcCloud pauseBGM];
}

RCT_EXPORT_METHOD(resumeBGM) {
    NSLog(@"resumeBGM");
    [trtcCloud resumeBGM];
}

RCT_EXPORT_METHOD(getBGMDuration:(NSString *)path resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"getBGMDuration");
    NSInteger duration = [trtcCloud getBGMDuration:path];
    if (duration == -1) {
        reject(@"-1", @"getBGMDuration failed", nil);
    }
    resolve(@(duration));
}

RCT_EXPORT_METHOD(setBGMPosition:(NSInteger)position) {
    NSLog(@"setBGMPosition");
    [trtcCloud setBGMPosition:position];
}

RCT_EXPORT_METHOD(setBGMVolume:(NSInteger)volume) {
    NSLog(@"setBGMVolume");
    [trtcCloud setBGMVolume:volume];
}

RCT_EXPORT_METHOD(setBGMPlayoutVolume:(NSInteger)volume) {
    NSLog(@"setBGMPlayoutVolume");
    [trtcCloud setBGMPlayoutVolume:volume];
}

RCT_EXPORT_METHOD(setBGMPublishVolume:(NSInteger)volume) {
    NSLog(@"setBGMPublishVolume");
    [trtcCloud setBGMPublishVolume:volume];
}

RCT_EXPORT_METHOD(setReverbType:(TRTCReverbType)type) {
    NSLog(@"setReverbType");
    [trtcCloud setReverbType:type];
}

RCT_EXPORT_METHOD(setVoiceChangerType:(TRTCVoiceChangerType)type) {
    NSLog(@"setVoiceChangerType");
    [trtcCloud setVoiceChangerType:type];
}

#pragma mark 音效相关接口函数
/**
(void)     - playAudioEffect
(void)     - setAudioEffectVolume
(void)     - stopAudioEffect
(void)     - stopAllAudioEffects
(void)     - setAllAudioEffectsVolume
(void)     - pauseAudioEffect
(void)     - resumeAudioEffect
 */
RCT_EXPORT_METHOD(playAudioEffect) {
    NSLog(@"playAudioEffect");
}

RCT_EXPORT_METHOD(setAudioEffectVolume) {
    NSLog(@"setAudioEffectVolume");
}

RCT_EXPORT_METHOD(stopAudioEffect) {
    NSLog(@"stopAudioEffect");
}

RCT_EXPORT_METHOD(stopAllAudioEffects) {
    NSLog(@"stopAllAudioEffects");
}

RCT_EXPORT_METHOD(setAllAudioEffectsVolume) {
    NSLog(@"setAllAudioEffectsVolume");
}

RCT_EXPORT_METHOD(pauseAudioEffect) {
    NSLog(@"pauseAudioEffect");
}

RCT_EXPORT_METHOD(resumeAudioEffect) {
    NSLog(@"resumeAudioEffect");
}

#pragma mark 设备和网络测试
/**
(void)     - startSpeedTest
(void)     - stopSpeedTest
 */
RCT_EXPORT_METHOD(startSpeedTest:(uint32_t)sdkAppId userId:(NSString *)userId userSig:(NSString *)userSig) {
    NSLog(@"startSpeedTest");
    [trtcCloud startSpeedTest:sdkAppId
                       userId:userId
                      userSig:userSig
                   completion:^(TRTCSpeedTestResult* result, NSInteger completedCount, NSInteger totalCount) {
        [self sendEventWithName:@"onSpeedTestProgress" body:@{
            @"completedCount": @(completedCount),
            @"totalCount": @(totalCount),
            @"upLostRate": @(result.upLostRate),
            @"downLostRate": @(result.downLostRate),
            @"rtt": @(result.rtt),
            @"quality": @(result.quality),
        }];
    }];
}

RCT_EXPORT_METHOD(stopSpeedTest) {
    NSLog(@"stopSpeedTest");
    [trtcCloud stopSpeedTest];
}

#pragma mark Log 相关接口函数
RCT_EXPORT_METHOD(getSDKVersion:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *version = [TRTCCloud getSDKVersion];
    resolve(version);
}

RCT_EXPORT_METHOD(setLogLevel:(NSInteger)level)
{
    [TRTCCloud setLogLevel:level];
}

RCT_EXPORT_METHOD(setConsoleEnabled:(BOOL)enable)
{
    [TRTCCloud setConsoleEnabled:enable];
}

RCT_EXPORT_METHOD(setLogCompressEnabled:(BOOL)enable)
{
    [TRTCCloud setLogCompressEnabled:enable];
}

RCT_EXPORT_METHOD(setLogDirPath:(NSString *)dir)
{
    [TRTCCloud setLogDirPath:dir];
}

#pragma mark 弃用接口函数(TODO)


#pragma mark - TRTCAudioFrameDelegate
- (void)onCapturedAudioFrame:(TRTCAudioFrame *)frame
{
    NSLog(@"onCapturedAudioFrame:%@", frame);
    NSString *base64String = [frame.data base64EncodedStringWithOptions:0];
    [self sendEventWithName:@"onCapturedAudioFrame" body:@{
        @"data": base64String ?: @"",
        @"channels": @(frame.channels),
        @"timestamp": @(frame.timestamp),
        @"sampleRate": @(frame.sampleRate),
    }];
}

- (void)onPlayAudioFrame:(TRTCAudioFrame *)frame userId:(NSString *)userId
{
    NSLog(@"onPlayAudioFrame:%@ userId:%@", frame, userId);
    NSString *base64String = [frame.data base64EncodedStringWithOptions:0];
    [self sendEventWithName:@"onPlayAudioFrame" body:@{
        @"userId": userId ?: @"",
        @"data": base64String ?: @"",
        @"channels": @(frame.channels),
        @"timestamp": @(frame.timestamp),
        @"sampleRate": @(frame.sampleRate),
    }];
}

- (void)onMixedPlayAudioFrame:(TRTCAudioFrame *)frame
{
    NSLog(@"onMixedPlayAudioFrame:%@", frame);
    NSString *base64String = [frame.data base64EncodedStringWithOptions:0];
    [self sendEventWithName:@"onMixedPlayAudioFrame" body:@{
        @"data": base64String ?: @"",
        @"channels": @(frame.channels),
        @"timestamp": @(frame.timestamp),
        @"sampleRate": @(frame.sampleRate),
    }];
}

#pragma mark - TRTCLogDelegate
- (void)onLog:(NSString *)log LogLevel:(TRTCLogLevel)level WhichModule:(NSString *)module
{
    NSLog(@"onLog:%@ LogLevel:%d WhichModule:%@", log, level, module);
    [self sendEventWithName:@"onLog" body:@{
        @"log": log ?: @"",
        @"logLevel": @(level),
        @"module": module ?: @"",
    }];
}


#pragma mark - TRTCCloudDelegate
#pragma mark 错误事件与警告事件
/**
 * WARNING 大多是一些可以忽略的事件通知，SDK内部会启动一定的补救机制
 */
- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(NSString *)warningMsg {
    [self sendEventWithName:@"onWarning" body:@{
        @"warningCode": @(warningCode),
        @"warningMsg": warningMsg ?: @"",
    }];
}

/**
 * 大多是不可恢复的错误，需要通过 UI 提示用户
 */
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(nullable NSDictionary *)extInfo {
    [self sendEventWithName:@"onError" body:@{
        @"errCode": @(errCode),
        @"errMsg": errMsg ?: @"",
    }];
}

#pragma mark 房间事件回调
- (void)onEnterRoom:(NSInteger)elapsed {
    [self sendEventWithName:@"onEnterRoom" body:@{
        @"elapsed": @(elapsed),
    }];
}


- (void)onExitRoom:(NSInteger)reason {
    [self sendEventWithName:@"onExitRoom" body:@{
        @"reason": @(reason),
    }];
}

- (void)onSwitchRole:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    [self sendEventWithName:@"onSwitchRole" body:@{
        @"errCode": @(errCode),
        @"errMsg": errMsg ?: @"",
    }];
}

- (void)onConnectOtherRoom:(NSString *)userId errCode:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    [self sendEventWithName:@"onConnectOtherRoom" body:@{
        @"errCode": @(errCode),
        @"errMsg": errMsg ?: @"",
    }];
}

- (void)onDisconnectOtherRoom:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    [self sendEventWithName:@"onDisconnectOtherRoom" body:@{
        @"errCode": @(errCode),
        @"errMsg": errMsg ?: @"",
    }];
}

#pragma mark 成员事件回调
/**
 * 有新的用户加入了当前视频房间
 */
- (void)onRemoteUserEnterRoom:(NSString *)userId {
    [self sendEventWithName:@"onRemoteUserEnterRoom" body:@{
        @"userId": userId ?: @"",
    }];
}
/**
 * 有用户离开了当前视频房间
 */
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    [self sendEventWithName:@"onRemoteUserLeaveRoom" body:@{
        @"userId": userId ?: @"",
        @"reason": @(reason),
    }];
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserAudioAvailable:userId:%@ available:%u", userId, available);
    [self sendEventWithName:@"onUserAudioAvailable" body:@{
        @"userId": userId ?: @"",
        @"available": @(available),
    }];
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserVideoAvailable:userId:%@ available==:%u", userId, available);
    [self sendEventWithName:@"onUserVideoAvailable" body:@{
        @"userId": userId ?: @"",
        @"available": @(available),
    }];
}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserSubStreamAvailable:userId:%@ available:%u", userId, available);
    [self sendEventWithName:@"onUserSubStreamAvailable" body:@{
        @"userId": userId ?: @"",
        @"available": @(available),
    }];
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    NSLog(@"onFirstVideoFrame userId:%@ streamType:%@ width:%d height:%d", userId, @(streamType), width, height);
    if (userId) {
        [self sendEventWithName:@"onFirstVideoFrame" body:@{
            @"userId": userId ?: @"",
            @"streamType": @(streamType),
            @"width": @(width),
            @"height": @(height),
        }];
    }
}

- (void)onFirstAudioFrame:(NSString *)userId  {
    [self sendEventWithName:@"onFirstAudioFrame" body:@{
        @"userId": userId ?: @"",
    }];
}

- (void)onSendFirstLocalVideoFrame:(TRTCVideoStreamType)streamType  {
    [self sendEventWithName:@"onSendFirstLocalVideoFrame" body:@{
        @"streamType": @(streamType),
    }];
}

- (void)onSendFirstLocalAudioFrame  {
    [self sendEventWithName:@"onSendFirstLocalAudioFrame" body:nil];
}

#pragma mark 统计和质量回调
- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    NSObject *localQui = @{
        @"userId": @"",
        @"quality": @"",
    };
    if (localQuality) {
        localQui = @{
            @"userId": localQuality.userId ?: @"",
            @"quality": @(localQuality.quality),
        };
    }
    NSMutableArray *remoteQui = [[NSMutableArray alloc] init];
    if (remoteQuality) {
        for (TRTCQualityInfo* qualityInfo in remoteQuality) {
            [remoteQui addObject:@{
                @"userId": qualityInfo.userId ?: @"",
                @"quality": @(qualityInfo.quality),
            }];
        }
    }
    [self sendEventWithName:@"onNetworkQuality" body:@{
        @"localQuality": localQui,
        @"remoteQuality": remoteQui,
    }];
}

- (void)onStatistics:(TRTCStatistics *) statistics {
    NSMutableArray *localArray = [[NSMutableArray alloc] init];
    if (statistics && statistics.localStatistics) {
        for (TRTCLocalStatistics* local in statistics.localStatistics) {
            [localArray addObject:@{
                @"width": @(local.width),
                @"height": @(local.height),
                @"frameRate": @(local.frameRate),
                @"videoBitrate": @(local.videoBitrate),
                @"audioSampleRate": @(local.audioSampleRate),
                @"audioBitrate": @(local.audioBitrate),
                @"streamType": @(local.streamType),
            }];
        }
    }

    NSMutableArray *remoteArray = [[NSMutableArray alloc] init];
    if (statistics && statistics.remoteStatistics) {
        for (TRTCRemoteStatistics* remote in statistics.remoteStatistics) {
            [remoteArray addObject:@{
                @"width": @(remote.width),
                @"height": @(remote.height),
                @"frameRate": @(remote.frameRate),
                @"videoBitrate": @(remote.videoBitrate),
                @"audioSampleRate": @(remote.audioSampleRate),
                @"audioBitrate": @(remote.audioBitrate),
                @"streamType": @(remote.streamType),
                @"userId": remote.userId ?: @"",
                @"finalLoss": @(remote.finalLoss),
            }];
        }
    }

    [self sendEventWithName:@"onStatistics" body:@{
        @"appCpu": @(statistics.appCpu),
        @"downLoss": @(statistics.downLoss),
        @"rtt": @(statistics.rtt),
        @"systemCpu": @(statistics.systemCpu),
        @"upLoss": @(statistics.upLoss),
        @"receiveBytes": @(statistics.receivedBytes),
        @"sendBytes": @(statistics.sentBytes),
        @"localArray": localArray,
        @"remoteArray": remoteArray,
    }];
}

- (void)onConnectionLost {
    NSLog(@"onConnectionLost");
    [self sendEventWithName:@"onConnectionLost" body:nil];
}

- (void)onTryToReconnect {
    NSLog(@"onTryToReconnect");
    [self sendEventWithName:@"onTryToReconnect" body:nil];
}

- (void)onConnectionRecovery {
    NSLog(@"onConnectionRecovery");
    [self sendEventWithName:@"onConnectionRecovery" body:nil];
}

#pragma mark 硬件设备事件回调
- (void)onCameraDidReady {
    NSLog(@"onCameraDidReady");
    [self sendEventWithName:@"onCameraDidReady" body:nil];
}

- (void)onMicDidReady {
    NSLog(@"onMicDidReady");
    [self sendEventWithName:@"onMicDidReady" body:nil];
}

- (void)onAudioRouteChanged:(TRTCAudioRoute)route fromRoute:(TRTCAudioRoute)fromRoute {
    NSLog(@"TRTC onAudioRouteChanged %@ -> %@", @(fromRoute), @(route));
    [self sendEventWithName:@"onAudioRouteChanged" body:@{
        @"newRoute": @(route),
        @"oldRoute": @(fromRoute),
    }];
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    NSMutableArray *volumes = [[NSMutableArray alloc] init];
    if (userVolumes) {
        for (TRTCVolumeInfo* vol in userVolumes) {
            [volumes addObject:@{
                @"userId": vol.userId ?: @"",
                @"volume": @(vol.volume),
            }];
        }
    }
    [self sendEventWithName:@"onUserVoiceVolume" body:@{
        @"userVolumes": volumes,
        @"totalVolume": @(totalVolume),
    }];
}

#pragma mark 自定义消息的接收回调
- (void)onRecvCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID seq:(UInt32)seq message:(NSData *)message {
    [self sendEventWithName:@"onRecvCustomCmdMsgUserId" body:@{
        @"userId": userId?: @"",
        @"cmdID": @(cmdID),
        @"seq": @(seq),
        @"message": message? [message base64EncodedStringWithOptions:0]: @"",
    }];
}

- (void)onMissCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID errCode:(NSInteger)errCode missed:(NSInteger)missed {
    [self sendEventWithName:@"onMissCustomCmdMsgUserId" body:@{
        @"userId": userId ?: @"",
        @"cmdID": @(cmdID),
        @"errCode": @(errCode),
        @"missed": @(missed),
    }];
}

- (void)onRecvSEIMsg:(NSString *)userId message:(NSData*)message {
    [self sendEventWithName:@"onRecvSEIMsg" body:@{
        @"userId": userId ?: @"",
        @"message": message? [message base64EncodedStringWithOptions:0]: @"",
    }];
}

#pragma mark CDN旁路转推回调
- (void)onStartPublishing:(int)err errMsg:(NSString*)errMsg {
    NSLog(@"onStartPublishing err:%d errMsg:%@", err, errMsg);
    [self sendEventWithName:@"onStartPublishing" body:@{
        @"err": @(err),
        @"errMsg": errMsg ?: @"",
    }];
}

- (void)onStopPublishing:(int)err errMsg:(NSString*)errMsg {
    NSLog(@"onStopPublishing err:%d errMsg:%@", err, errMsg);
    [self sendEventWithName:@"onStopPublishing" body:@{
        @"err": @(err),
        @"errMsg": errMsg ?: @"",
    }];
}

- (void)onStartPublishCDNStream:(int)err errMsg:(NSString *)errMsg {
    NSLog(@"onStartPublishCDNStream err:%d errMsg:%@", err, errMsg);
    [self sendEventWithName:@"onStartPublishCDNStream" body:@{
        @"err": @(err),
        @"errMsg": errMsg ?: @"",
    }];
}

- (void)onStopPublishCDNStream:(int)err errMsg:(NSString *)errMsg {
    NSLog(@"onStopPublishCDNStream err:%d errMsg:%@", err, errMsg);
    [self sendEventWithName:@"onStopPublishCDNStream" body:@{
        @"err": @(err),
        @"errMsg": errMsg ?: @"",
    }];
}

- (void)onSetMixTranscodingConfig:(int)err errMsg:(NSString *)errMsg {
    NSLog(@"onSetMixTranscodingConfig err:%d errMsg:%@", err, errMsg);
    [self sendEventWithName:@"onSetMixTranscodingConfig" body:@{
        @"err": @(err),
        @"errMsg": errMsg ?: @"",
    }];
}

#pragma mark 音效回调
- (void)onAudioEffectFinished:(int)effectId code:(int)code {
    [self sendEventWithName:@"onAudioEffectFinished" body:@{
        @"effectId": @(effectId),
        @"code": @(code),
    }];
}

#pragma mark -
- (RNTXCloudVideoView *)findViewByUserId:(UIView *)root userId:(NSString *)userId {
    if ([root isKindOfClass:[RNTXCloudVideoView class]]) {
        RNTXCloudVideoView *cloudView = (RNTXCloudVideoView *)root;
        if ([userId isEqualToString:[cloudView getUserId]]) {
            return cloudView;
        }
    }
    
    for (UIView *subview in root.subviews) {
        RNTXCloudVideoView *cloudView = [self findViewByUserId:subview userId:userId];
        if (cloudView) {
            return cloudView;
        }
    }
    return nil;
}

@end
