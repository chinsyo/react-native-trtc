
#import "RNTrtc.h"
#import "GenerateSigHelper.h"
#import "TRTCCloud.h"
#import "TRTCCloudDelegate.h"
#import "TXLiteAVCode.h"
#import "TRTCCloudDef.h"
#import "TRTCStatistics.h"
#import "RNTXCloudVideoView.h"

static BOOL mFrontCamera=true;
static NSString *selfUserId;

@interface RNTrtc()<TRTCCloudDelegate, TRTCLogDelegate, TRTCAudioFrameDelegate>{
    TRTCCloud *trtcCloud;
}

@end


@implementation RNTrtc

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


RCT_EXPORT_MODULE();

+ (NSString *)getSelfUserId {
    return selfUserId;
}

+ (BOOL)isFrontCamera {
    return mFrontCamera;
}

+ (id)allocWithZone:(NSZone *)zone {
    static RNTrtc *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"onWarning",
             @"onError",
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
             @"onUserEnter",
             @"onUserExit",
             @"onNetworkQuality",
             @"onStatistics",
             @"onConnectionLost",
             @"onTryToReconnect",
             @"onConnectionRecovery",
             @"onSpeedTest",
             @"onCameraDidReady",
             @"onMicDidReady",
             @"onAudioRouteChanged",
             @"onUserVoiceVolume",
             @"onRecvCustomCmdMsg",
             @"onMissCustomCmdMsg",
             @"onRecvSEIMsg",
             @"onStartPublishing",
             @"onStopPublishing",
             @"onStartPublishCDNStream",
             @"onStopPublishCDNStream",
             @"onSetMixTranscodingConfig",
             @"onAudioEffectFinished",
             ];
}

RCT_EXPORT_METHOD(creatUserSig:(NSInteger)sdkAppId secretKey:(NSString *) secretKey userId:(NSString *) userId  resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"creatUserSig sdkAppId:%d secretKey:%@", sdkAppId, secretKey);
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
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

RCT_EXPORT_METHOD(disableScreenOn)
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - TRTCCloud
#pragma mark 创建与销毁
RCT_EXPORT_METHOD(sharedInstance:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"sharedInstance ");
    @try
    {
        [TRTCCloud setLogDelegate:self];
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
RCT_EXPORT_METHOD(enterRoom:(NSDictionary *) data scene:(NSInteger) scene )
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
//    TRTCTranscodingConfig *transConfig=[[TRTCTranscodingConfig alloc] init];
//    transConfig.appId = [config[@"appId"] integerValue];
//    transConfig.bizId = [config[@"bizId"] integerValue];
//    transConfig.audioBitrate = [config[@"audioBitrate"] integerValue];
//    transConfig.audioChannels = [config[@"audioChannels"] integerValue];
//    transConfig.audioSampleRate = [config[@"audioSampleRate"] integerValue];
//    transConfig.backgroundColor = [config[@"backgroundColor"] integerValue];
//    transConfig.mode = [config[@"mode"] integerValue];
//    transConfig.videoBitrate = [config[@"videoBitrate"] integerValue];
//    transConfig.videoFramerate = [config[@"videoFramerate"] integerValue];
//    transConfig.videoGOP = [config[@"videoGOP"] integerValue];
//    transConfig.videoHeight = [config[@"videoHeight"] integerValue];
//    transConfig.videoWidth = [config[@"videoWidth"] integerValue];
//
//
//    NSArray *temp=config[@"mixUsers"];
//      int count = temp.count;//减少调用次数
//    NSMutableArray *array=[[NSMutableArray alloc] initWithCapacity:count];
//
//
//    for( int i=0; i<count; i++){
//        NSDictionary *item=[array objectAtIndex:i];
//        TRTCMixUser *user=[[TRTCMixUser alloc] init];
//        user.userId=item[@"userId"];
//        user.roomID=item[@"roomId"];
//        user.zOrder=[item[@"zOrder"] integerValue];
//        user.streamType=[item[@"streamType"] integerValue];
//        user.pureAudio=[item[@"pureAudio"] boolValue];
//
//        int width=[item[@"width"] integerValue];
//        int height=[item[@"height"] integerValue];
//        int x=[item[@"x"] integerValue];
//        int y=[item[@"y"] integerValue];
//        user.rect=CGRectMake(x,y,width,height);
//        [array replaceObjectAtIndex:i withObject:user];
//    }
//    transConfig.mixUsers = array;
//
//    [trtcCloud setMixTranscodingConfig:transConfig];
}

#pragma mark 视频相关接口函数
RCT_EXPORT_METHOD(startLocalPreview:(BOOL) frontCamera){
    NSLog(@"startLocalPreview:frontCamera=%u",frontCamera);
    mFrontCamera=frontCamera;
    RNTXCloudVideoView *coludView=[self findViewByUserId:([UIApplication sharedApplication].delegate).window.rootViewController.view userId:selfUserId];
    if (coludView) {
        [trtcCloud startLocalPreview:frontCamera view:coludView];
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
    RNTXCloudVideoView *coludView=[self findViewByUserId:([UIApplication sharedApplication].delegate).window.rootViewController.view userId:userId];
    if(coludView){
        [trtcCloud startRemoteView:userId view:coludView];
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
    TRTCVideoEncParam *encParam= [[TRTCVideoEncParam alloc] init];
    encParam.videoResolution=[data[@"videoResolution"] integerValue];
    encParam.enableAdjustRes=[data[@"enableAdjustRes"] boolValue];
    encParam.videoBitrate=[data[@"videoBitrate"] integerValue];
    encParam.videoFps=[data[@"videoFps"] integerValue];
    encParam.resMode=[data[@"videoResolutionMode"] integerValue];
    [trtcCloud setVideoEncoderParam:encParam];
}

RCT_EXPORT_METHOD(setNetworkQosParam:(NSDictionary *) data)
{  NSLog(@"setNetworkQosParam");
    TRTCNetworkQosParam *qosParam=[[TRTCNetworkQosParam alloc]init];
    qosParam.preference=[data[@"preference"] integerValue];
    qosParam.controlMode=[data[@"controlMode"] integerValue];
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
    TRTCVideoEncParam *encParam= [[TRTCVideoEncParam alloc] init];
    encParam.videoResolution=[smallVideoEncParam[@"videoResolution"] integerValue];
    encParam.enableAdjustRes=[smallVideoEncParam[@"enableAdjustRes"] boolValue];
    encParam.videoBitrate=[smallVideoEncParam[@"videoBitrate"] integerValue];
    encParam.videoFps=[smallVideoEncParam[@"videoFps"] integerValue];
    encParam.resMode=[smallVideoEncParam[@"videoResolutionMode"] integerValue];
    
    int result=  [trtcCloud enableEncSmallVideoStream:enable withQuality:encParam];
    resolve(@(result));
}

RCT_EXPORT_METHOD(setRemoteVideoStreamType:(NSString *) userId  streamType:(NSInteger) streamType resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"setRemoteVideoStreamType");
    [trtcCloud setRemoteVideoStreamType:userId type:streamType];
    resolve(@(1));
}

RCT_EXPORT_METHOD(setPriorRemoteVideoStreamType:(NSInteger) streamType   resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"setPriorRemoteVideoStreamType");
    [trtcCloud setPriorRemoteVideoStreamType:streamType];
    resolve(@(1));
}

RCT_EXPORT_METHOD(snapshotVideo:(NSString *) userId  streamType:(NSInteger) streamType resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"snapshotVideo");
    [trtcCloud snapshotVideo:userId type:streamType completionBlock:^(TXImage *image) {
        if (image) {
            NSString *base64= [UIImagePNGRepresentation(image)base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            resolve(base64);
        }
    }];
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
    TRTCAudioRecordingParams *recordParam=[[TRTCAudioRecordingParams alloc] init];
    recordParam.filePath=param[@"filePath"];
    NSInteger result= [trtcCloud startAudioRecording:recordParam];
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
    BOOL result=  [trtcCloud isCameraZoomSupported];
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
    BOOL result=  [trtcCloud isCameraTorchSupported];
    resolve(@(result));
}

RCT_EXPORT_METHOD(enableTorch:(BOOL ) enable  resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    NSLog(@"enableTorch");
    BOOL result=  [trtcCloud enbaleTorch:enable];
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
    BOOL result=  [trtcCloud isCameraAutoFocusFaceModeSupported];
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

#pragma mark 音频设备相关接口
#pragma mark 美颜滤镜相关接口函数
#pragma mark 辅流相关接口函数(MAC)
#pragma mark 自定义采集和渲染
#pragma mark 自定义消息发送
#pragma mark 背景混音相关接口函数
#pragma mark 音效相关接口函数
#pragma mark 设备和网络测试
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

#pragma mark 弃用接口函数

#pragma mark - TRTCLogDelegate
- (void)onLog:(NSString *)log LogLevel:(TRTCLogLevel)level WhichModule:(NSString *)module
{
    NSLog(@"onLog:%@ LogLevel:%d WhichModule:%@", log, level, module);
}

#pragma mark - TRTCAudioFrameDelegate
- (void)onCapturedAudioFrame:(TRTCAudioFrame *)frame
{
    NSLog(@"onCapturedAudioFrame:%@", frame);
}

- (void)onPlayAudioFrame:(TRTCAudioFrame *)frame userId:(NSString *)userId
{
    NSLog(@"onPlayAudioFrame:%@ userId:%@", frame, userId);
}

- (void)onMixedPlayAudioFrame:(TRTCAudioFrame *)frame
{
    NSLog(@"onMixedPlayAudioFrame:%@", frame);
}

#pragma mark - TRTCCloudDelegate

/**
 * WARNING 大多是一些可以忽略的事件通知，SDK内部会启动一定的补救机制
 */
- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(NSString *)warningMsg {
    [self sendEventWithName:@"onWarning" body:@{@"warningCode": @(warningCode), @"warningMsg": warningMsg ?: @""}];
}

/**
 * 大多是不可恢复的错误，需要通过 UI 提示用户
 */
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(nullable NSDictionary *)extInfo {
    [self sendEventWithName:@"onError" body:@{@"errCode": @(errCode), @"errMsg": errMsg ?: @""}];
}

#pragma mark - 房间事件回调
- (void)onEnterRoom:(NSInteger)elapsed {
    [self sendEventWithName:@"onEnterRoom" body:@{@"elapsed": @(elapsed)}];
}


- (void)onExitRoom:(NSInteger)reason {
    [self sendEventWithName:@"onExitRoom" body:@{@"reason": @(reason)}];
}

- (void)onSwitchRole:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    [self sendEventWithName:@"onSwitchRole" body:@{@"errCode":@(errCode), @"errMsg":errMsg ?: @""}];
}

- (void)onConnectOtherRoom:(NSString *)userId errCode:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    [self sendEventWithName:@"onConnectOtherRoom" body:@{@"errCode":@(errCode),@"errMsg":errMsg ?: @""}];
}

- (void)onDisconnectOtherRoom:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    [self sendEventWithName:@"onDisconnectOtherRoom" body:@{@"errCode": @(errCode), @"errMsg": errMsg ?: @""}];
}

#pragma mark - 成员时间回调
/**
 * 有新的用户加入了当前视频房间
 */
- (void)onRemoteUserEnterRoom:(NSString *)userId {
    [self sendEventWithName:@"onRemoteUserEnterRoom" body:@{@"userId":userId}];
}
/**
 * 有用户离开了当前视频房间
 */
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    [self sendEventWithName:@"onRemoteUserLeaveRoom" body:@{@"userId":userId,@"reason":@(reason)}];
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserAudioAvailable:userId:%@ available:%u", userId, available);
    [self sendEventWithName:@"onUserAudioAvailable" body:@{@"userId":userId?userId:@"",@"available":@(available)}];
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserVideoAvailable:userId:%@ available==:%u", userId, available);
    [self sendEventWithName:@"onUserVideoAvailable" body:@{@"userId":userId?userId:@"",@"available":@(available)}];
}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserSubStreamAvailable:userId:%@ available:%u", userId, available);
    [self sendEventWithName:@"onUserSubStreamAvailable" body:@{@"userId":userId?userId:@"",@"available":@(available)}];
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    NSLog(@"onFirstVideoFrame userId:%@ streamType:%@ width:%d height:%d", userId, @(streamType), width, height);
    if (userId) {
        [self sendEventWithName:@"onFirstVideoFrame" body:@{@"userId":userId?userId:@"",@"streamType":@(streamType),@"width":@(width),@"height":@(height)}];
    }
}

- (void)onFirstAudioFrame:(NSString *)userId  {
    [self sendEventWithName:@"onFirstAudioFrame" body:@{@"userId":userId?userId:@""}];
}

- (void)onSendFirstLocalVideoFrame:(NSInteger)streamType  {
    [self sendEventWithName:@"onSendFirstLocalVideoFrame" body:@{@"streamType":@(streamType)}];
}

- (void)onSendFirstLocalAudioFrame  {
    [self sendEventWithName:@"onSendFirstLocalAudioFrame" body:nil];
}

#pragma mark - 统计和质量回调
- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    NSObject *localQui = @{
        @"userId": @"",
        @"quality": @""
    };
    if (localQuality) {
        localQui =@{@"userId":localQuality.userId?localQuality.userId:@"",@"quality":@(localQuality.quality)};
    }
    NSMutableArray *remoteQui = [[NSMutableArray alloc] init];
    if (remoteQuality) {
        for (TRTCQualityInfo* qualityInfo in remoteQuality) {
            [remoteQui addObject:@{@"userId":qualityInfo.userId?qualityInfo.userId:@"",@"quality":@(qualityInfo.quality)}];
        }
    }
    [self sendEventWithName:@"onNetworkQuality" body:@{@"localQuality":localQui,@"remoteQuality":remoteQui}];
}

- (void)onStatistics:(TRTCStatistics *) statistics {
    NSMutableArray *localArray = [[NSMutableArray alloc] init];
    if(statistics&&statistics.localStatistics){
        for (TRTCLocalStatistics* local in statistics.localStatistics) {
            [localArray addObject:@{@"width":@(local.width),@"height":@(local.height),@"frameRate":@(local.frameRate),@"videoBitrate":@(local.videoBitrate),@"audioSampleRate":@(local.audioSampleRate),@"audioBitrate":@(local.audioBitrate),@"streamType":@(local.streamType)}];
        }
    }

    NSMutableArray *remoteArray = [[NSMutableArray alloc] init];
    if (statistics && statistics.remoteStatistics) {
        for (TRTCRemoteStatistics* remote in statistics.remoteStatistics) {
            [remoteArray addObject:@{@"width":@(remote.width),@"height":@(remote.height),@"frameRate":@(remote.frameRate),@"videoBitrate":@(remote.videoBitrate),@"audioSampleRate":@(remote.audioSampleRate),@"audioBitrate":@(remote.audioBitrate),@"streamType":@(remote.streamType),@"userId":remote.userId?remote.userId:@"",@"finalLoss":@(remote.finalLoss)}];
        }
    }

    [self sendEventWithName:@"onStatistics" body:@{@"appCpu":@(statistics.appCpu),@"downLoss":@(statistics.downLoss),@"rtt":@(statistics.rtt),@"systemCpu":@(statistics.systemCpu),@"upLoss":@(statistics.upLoss),@"receiveBytes":@(statistics.receivedBytes),@"sendBytes":@(statistics.sentBytes),@"localArray":localArray,@"remoteArray":remoteArray}];
}

#pragma mark - 硬件设备事件回调
- (void)onAudioRouteChanged:(TRTCAudioRoute)route fromRoute:(TRTCAudioRoute)fromRoute {
    NSLog(@"TRTC onAudioRouteChanged %@ -> %@", @(fromRoute), @(route));
    [self sendEventWithName:@"onAudioRouteChanged" body:@{@"newRoute":@(route),@"oldRoute":@(fromRoute)}];
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    NSMutableArray *volumes = [[NSMutableArray alloc] init];
    if (userVolumes) {
        for (TRTCVolumeInfo* vol in userVolumes) {
            [volumes addObject:@{@"userId":vol.userId?vol.userId:@"",@"volume":@(vol.volume)}];
        }
    }
    [self sendEventWithName:@"onUserVoiceVolume" body:@{@"userVolumes":volumes,@"totalVolume":@(totalVolume)}];
}

#pragma mark - 自定义消息的接收回调
- (void)onRecvCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID seq:(UInt32)seq message:(NSData *)message {
    [self sendEventWithName:@"onRecvCustomCmdMsgUserId" body:@{@"userId":userId?userId:@"",@"cmdID":@(cmdID),@"seq":@(seq),@"message":message?[message base64EncodedStringWithOptions:0]:@""}];
}

- (void)onRecvSEIMsg:(NSString *)userId message:(NSData*)message {
    [self sendEventWithName:@"onRecvSEIMsg" body:@{@"userId":userId ?: @"", @"message":message?[message base64EncodedStringWithOptions:0]:@""}];
}

#pragma mark - CDN旁路转推回调
- (void)onSetMixTranscodingConfig:(int)err errMsg:(NSString *)errMsg {
    NSLog(@"onSetMixTranscodingConfig err:%d errMsg:%@", err, errMsg);
    [self sendEventWithName:@"onSetMixTranscodingConfig" body:@{@"err":@(err),@"errMsg":errMsg ?: @""}];
}

#pragma mark - 音效回调
- (void)onAudioEffectFinished:(int)effectId code:(int)code {
    [self sendEventWithName:@"onAudioEffectFinished" body:@{@"effectId": @(effectId), @"code": @(code)}];
}

#pragma mark -
- (RNTXCloudVideoView *) findViewByUserId:(UIView *) root userId:(NSString *)userId {
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
