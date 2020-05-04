
import { NativeModules, NativeEventEmitter, requireNativeComponent } from 'react-native';
import * as React from 'react';

var RCTTXCloudVideoView = requireNativeComponent("RCTTXCloudVideoView");
const { Trtc } = NativeModules;
const eventEmitter = new NativeEventEmitter(Trtc);

class TXCloudVideoView extends React.Component {
    constructor(props) {
        super(props)
    }
    render() {
        console.log("RTCVIew render", this.props)
        return <RCTTXCloudVideoView {...this.props} />;
    }
}

export default {
    setLogEnabled(enabled) {
        Trtc.setLogEnabled(enabled);
    },
    creatUserSig(sdkAppId, secretKey, userId) {
        return Trtc.creatUserSig(sdkAppId, secretKey, userId)
    },
    enableScreenOn() {
        Trtc.enableScreenOn()
    },
    disableScreenOn() {
        Trtc.disableScreenOn()
    },
    sharedInstance() {
        return Trtc.sharedInstance()
    },
    destroySharedInstance() {
        Trtc.destroySharedInstance()
    },
    /**
     * 房间相关
     */
    enterRoom(data, scene) {
        data.privateMapKey = data.privateMapKey || "";
        data.businessInfo = data.businessInfo || "";
        Trtc.enterRoom(data, scene)
    },
    exitRoom() {
        Trtc.exitRoom()
    },
    switchRole(role) {
        Trtc.switchRole(role)
    },
    connectOtherRoom(param) {
        Trtc.connectOtherRoom(param)
    },
    disconnectOtherRoom() {
        Trtc.disconnectOtherRoom()
    },
    setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo) {
        Trtc.setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo)
    },
    /**
     * CDN相关接口函数
     */
    startPublishing(streamId, streamType) {
        Trtc.startPublishing(streamId, streamType)
    },
    stopPublishing() {
        Trtc.stopPublishing()
    },
    startPublishCDNStream(param) {
        Trtc.startPublishCDNStream(param)
    },
    stopPublishCDNStream() {
        Trtc.stopPublishCDNStream()
    },
    setMixTranscodingConfig(config) {
        Trtc.setMixTranscodingConfig(config)
    },
    /**
     * 视频相关接口
     */
    startLocalPreview(frontCamera) {
        Trtc.startLocalPreview(frontCamera)
    },
    stopLocalPreview() {
        Trtc.stopLocalPreview()
    },
    muteLocalVideo(mute) {
        Trtc.muteLocalVideo(mute)
    },
    startRemoteView(userId) {
        Trtc.startRemoteView(userId)
    },
    stopRemoteView(userId) {
        Trtc.stopRemoteView(userId)
    },
    stopAllRemoteView() {
        Trtc.stopAllRemoteView()
    },
    muteRemoteVideoStream(userId, mute) {
        Trtc.muteRemoteVideoStream(userId, mute)
    },
    muteAllRemoteVideoStreams(mute) {
        Trtc.muteAllRemoteVideoStreams(mute)
    },
    setVideoEncoderParam(data) {
        Trtc.setVideoEncoderParam(data)
    },
    setNetworkQosParam(data) {
        Trtc.setNetworkQosParam(data)
    },
    setLocalViewFillMode(mode) {
        Trtc.setLocalViewFillMode(mode)
    },
    setRemoteViewFillMode(userId, mode) {
        Trtc.setRemoteViewFillMode(userId, mode)
    },
    setLocalViewRotation(rotation) {
        Trtc.setLocalViewRotation(rotation)
    },
    setRemoteViewRotation(userId, rotation) {
        Trtc.setRemoteViewRotation(userId, rotation)
    },
    setVideoEncoderRotation(rotation) {
        Trtc.setVideoEncoderRotation(rotation)
    },
    setLocalViewMirror(mirrorType) {
        Trtc.setLocalViewMirror(mirrorType)
    },
    setVideoEncoderMirror(mirror) {
        Trtc.setVideoEncoderMirror(mirror)
    },
    setGSensorMode(mode) {
        Trtc.setGSensorMode(mode)
    },
    enableEncSmallVideoStream(enable, smallVideoEncParam) {
        return Trtc.enableEncSmallVideoStream(enable, smallVideoEncParam)
    },
    setRemoteVideoStreamType(userId, streamType) {
        return Trtc.setRemoteVideoStreamType(userId, streamType)
    },
    setPriorRemoteVideoStreamType(streamType) {
        return Trtc.setPriorRemoteVideoStreamType(streamType)
    },
    snapshotVideo(userId, streamType) {
        return Trtc.snapshotVideo(userId, streamType)
    },
    /**
     * 音频相关接口
     */
    startLocalAudio() {
        Trtc.startLocalAudio()
    },
    stopLocalAudio() {
        Trtc.stopLocalAudio()
    },
    muteLocalAudio(mute) {
        Trtc.muteLocalAudio(mute)
    },
    muteRemoteAudio(userId, mute) {
        Trtc.muteRemoteAudio(userId, mute)
    },
    muteAllRemoteAudio(mute) {
        Trtc.muteAllRemoteAudio(mute)
    },
    setRemoteAudioVolume(userId, volume) {
        Trtc.setRemoteAudioVolume(userId, volume)
    },
    setAudioCaptureVolume(volume) {
        Trtc.setAudioCaptureVolume(volume)
    },
    getAudioCaptureVolume() {
        return Trtc.getAudioCaptureVolume()
    },
    setAudioPlayoutVolume(volume) {
        Trtc.setAudioPlayoutVolume(volume)
    },
    getAudioPlayoutVolume() {
        return Trtc.getAudioPlayoutVolume()
    },
    enableAudioVolumeEvaluation(intervalMs) {
        Trtc.enableAudioVolumeEvaluation(intervalMs)
    },
    startAudioRecording(param) {
        return Trtc.startAudioRecording(param)
    },
    stopAudioRecording() {
        Trtc.stopAudioRecording()
    },
    setSystemVolumeType(type) {
        Trtc.setSystemVolumeType(type)
    },
    enableAudioEarMonitoring(enable) {
        Trtc.enableAudioEarMonitoring(enable)
    },
    /**
     * 摄像头相关接口函数
     */
    switchCamera() {
        Trtc.switchCamera()
    },
    isCameraZoomSupported() {
        return Trtc.isCameraZoomSupported()
    },
    setZoom(distance) {
        Trtc.setZoom(distance)
    },
    isCameraTorchSupported() {
        return Trtc.isCameraTorchSupported()
    },
    enableTorch(enable) {
        return Trtc.enableTorch(enable)
    },
    isCameraFocusPositionInPreviewSupported() {
        return Trtc.isCameraFocusPositionInPreviewSupported()
    },
    setFocusPosition(x, y) {
        Trtc.setFocusPosition(x, y)
    },
    isCameraAutoFocusFaceModeSupported() {
        return Trtc.isCameraAutoFocusFaceModeSupported()
    },
    startScreenRecord() {
        Trtc.startScreenRecord()
    },
    stopScreenRecord() {
        Trtc.stopScreenRecord()
    },
    getSDKVersion() {
        return Trtc.getSDKVersion();
    },
    /*
     * setAudioRoute
     * int  0 Speaker 1 Earpiece
     */
    setAudioRoute(router) {
        Trtc.setAudioRoute(router)
    },
    addListener(eventName, handler) {
        if (!eventName || !handler) return;
        return eventEmitter.addListener(eventName, handler)
    },
    removeListener(eventName, handler) {
        if (!eventName) return;
        if (!handler) {
            eventEmitter.removeAllListeners(eventName)
            return
        }
        eventEmitter.removeListener(eventName, handler)
    },

    TRTC_VIDEO_RESOLUTION_120_120: 1,
    TRTC_VIDEO_RESOLUTION_160_160: 3,
    TRTC_VIDEO_RESOLUTION_270_270: 5,
    TRTC_VIDEO_RESOLUTION_480_480: 7,
    TRTC_VIDEO_RESOLUTION_160_120: 50,
    TRTC_VIDEO_RESOLUTION_240_180: 52,
    TRTC_VIDEO_RESOLUTION_280_210: 54,
    TRTC_VIDEO_RESOLUTION_320_240: 56,
    TRTC_VIDEO_RESOLUTION_400_300: 58,
    TRTC_VIDEO_RESOLUTION_480_360: 60,
    TRTC_VIDEO_RESOLUTION_640_480: 62,
    TRTC_VIDEO_RESOLUTION_960_720: 64,
    TRTC_VIDEO_RESOLUTION_160_90: 100,
    TRTC_VIDEO_RESOLUTION_256_144: 102,
    TRTC_VIDEO_RESOLUTION_320_180: 104,
    TRTC_VIDEO_RESOLUTION_480_270: 106,
    TRTC_VIDEO_RESOLUTION_640_360: 108,
    TRTC_VIDEO_RESOLUTION_960_540: 110,
    TRTC_VIDEO_RESOLUTION_1280_720: 112,
    TRTC_VIDEO_RESOLUTION_MODE_LANDSCAPE: 0,
    TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT: 1,
    TRTC_VIDEO_STREAM_TYPE_BIG: 0,
    TRTC_VIDEO_STREAM_TYPE_SMALL: 1,
    TRTC_VIDEO_STREAM_TYPE_SUB: 2,
    TRTC_QUALITY_UNKNOWN: 0,
    TRTC_QUALITY_Excellent: 1,
    TRTC_QUALITY_Good: 2,
    TRTC_QUALITY_Poor: 3,
    TRTC_QUALITY_Bad: 4,
    TRTC_QUALITY_Vbad: 5,
    TRTC_QUALITY_Down: 6,
    TRTC_VIDEO_RENDER_MODE_FILL: 0,
    TRTC_VIDEO_RENDER_MODE_FIT: 1,
    TRTC_VIDEO_ROTATION_0: 0,
    TRTC_VIDEO_ROTATION_90: 1,
    TRTC_VIDEO_ROTATION_180: 2,
    TRTC_VIDEO_ROTATION_270: 3,
    TRTC_BEAUTY_STYLE_SMOOTH: 0,
    TRTC_BEAUTY_STYLE_NATURE: 1,
    TRTC_VIDEO_PIXEL_FORMAT_UNKNOWN: 0,
    TRTC_VIDEO_PIXEL_FORMAT_I420: 1,
    TRTC_VIDEO_PIXEL_FORMAT_Texture_2D: 2,
    TRTC_VIDEO_PIXEL_FORMAT_TEXTURE_EXTERNAL_OES: 3,
    TRTC_VIDEO_PIXEL_FORMAT_NV21: 4,
    TRTC_VIDEO_MIRROR_TYPE_AUTO: 0,
    TRTC_VIDEO_MIRROR_TYPE_ENABLE: 1,
    TRTC_VIDEO_MIRROR_TYPE_DISABLE: 2,
    TRTC_VIDEO_BUFFER_TYPE_UNKNOWN: 0,
    TRTC_VIDEO_BUFFER_TYPE_BYTE_BUFFER: 1,
    TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY: 2,
    TRTC_VIDEO_BUFFER_TYPE_TEXTURE: 3,
    TRTC_APP_SCENE_VIDEOCALL: 0,
    TRTC_APP_SCENE_LIVE: 1,
    TRTC_APP_SCENE_AUDIOCALL: 2,
    TRTC_APP_SCENE_VOICE_CHATROOM: 3,
    TRTCRoleAnchor: 20,
    TRTCRoleAudience: 21,
    VIDEO_QOS_CONTROL_CLIENT: 0,
    VIDEO_QOS_CONTROL_SERVER: 1,
    TRTC_VIDEO_QOS_PREFERENCE_SMOOTH: 1,
    TRTC_VIDEO_QOS_PREFERENCE_CLEAR: 2,
    TRTCAudioSampleRate16000: 16000,
    TRTCAudioSampleRate32000: 32000,
    TRTCAudioSampleRate44100: 44100,
    TRTCAudioSampleRate48000: 48000,
    TRTC_AUDIO_ROUTE_SPEAKER: 0,
    TRTC_AUDIO_ROUTE_EARPIECE: 1,
    TRTC_REVERB_TYPE_0: 0,
    TRTC_REVERB_TYPE_1: 1,
    TRTC_REVERB_TYPE_2: 2,
    TRTC_REVERB_TYPE_3: 3,
    TRTC_REVERB_TYPE_4: 4,
    TRTC_REVERB_TYPE_5: 5,
    TRTC_REVERB_TYPE_6: 6,
    TRTC_REVERB_TYPE_7: 7,
    TRTC_VOICE_CHANGER_TYPE_0: 0,
    TRTC_VOICE_CHANGER_TYPE_1: 1,
    TRTC_VOICE_CHANGER_TYPE_2: 2,
    TRTC_VOICE_CHANGER_TYPE_3: 3,
    TRTC_VOICE_CHANGER_TYPE_4: 4,
    TRTC_VOICE_CHANGER_TYPE_5: 5,
    TRTC_VOICE_CHANGER_TYPE_6: 6,
    TRTC_VOICE_CHANGER_TYPE_7: 7,
    TRTC_VOICE_CHANGER_TYPE_8: 8,
    TRTC_VOICE_CHANGER_TYPE_9: 9,
    TRTC_VOICE_CHANGER_TYPE_10: 10,
    TRTC_VOICE_CHANGER_TYPE_11: 11,
    TRTC_AUDIO_FRAME_FORMAT_PCM: 1,
    TRTCSystemVolumeTypeAuto: 0,
    TRTCSystemVolumeTypeMedia: 1,
    TRTCSystemVolumeTypeVOIP: 2,
    TRTC_DEBUG_VIEW_LEVEL_GONE: 0,
    TRTC_DEBUG_VIEW_LEVEL_STATUS: 1,
    TRTC_DEBUG_VIEW_LEVEL_ALL: 2,
    TRTC_LOG_LEVEL_VERBOSE: 0,
    TRTC_LOG_LEVEL_DEBUG: 1,
    TRTC_LOG_LEVEL_INFO: 2,
    TRTC_LOG_LEVEL_WARN: 3,
    TRTC_LOG_LEVEL_ERROR: 4,
    TRTC_LOG_LEVEL_FATAL: 5,
    TRTC_LOG_LEVEL_NULL: 6,
    TRTC_GSENSOR_MODE_DISABLE: 0,
    TRTC_GSENSOR_MODE_UIAUTOLAYOUT: 1,
    TRTC_GSENSOR_MODE_UIFIXLAYOUT: 2,
    TRTC_TranscodingConfigMode_Unknown: 0,
    TRTC_TranscodingConfigMode_Manual: 1,
};

export {
    TXCloudVideoView
}
