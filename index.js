
import { NativeModules, NativeEventEmitter, requireNativeComponent } from 'react-native';
import * as React from 'react';

var RNTXCloudVideoView = requireNativeComponent("RNTXCloudVideoView");
const RNModule = NativeModules.RNTrtc;
const eventEmitter = new NativeEventEmitter(RNModule);

class TXCloudVideoView extends React.Component {
    constructor(props) {
        super(props)
    }
    render() {
        console.log("RTCVIew render", this.props)
        return <RNTXCloudVideoView {...this.props} />;
    }
}

export default {
    creatUserSig(sdkAppId, secretKey, userId) {
        return RNModule.creatUserSig(sdkAppId, secretKey, userId)
    },
    enableScreenOn() {
        RNModule.enableScreenOn()
    },
    disableScreenOn() {
        RNModule.disableScreenOn()
    },
    sharedInstance() {
        return RNModule.sharedInstance()
    },
    destroySharedInstance() {
        RNModule.destroySharedInstance()
    },

    enterRoom(data, scene) {
        data.privateMapKey = data.privateMapKey || "";
        data.businessInfo = data.businessInfo || "";
        RNModule.enterRoom(data, scene)
    },
    exitRoom() {
        RNModule.exitRoom()
    },
    switchRole(role) {
        RNModule.switchRole(role)
    },
    connectOtherRoom(param) {
        RNModule.connectOtherRoom(param)
    },

    disconnectOtherRoom() {
        RNModule.disconnectOtherRoom()
    },

    setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo) {
        RNModule.setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo)
    },

    startPublishing(streamId, streamType) {
        RNModule.startPublishing(streamId, streamType)
    },

    stopPublishing() {
        RNModule.stopPublishing()
    },

    startPublishCDNStream(param) {
        RNModule.startPublishCDNStream(param)
    },

    stopPublishCDNStream() {
        RNModule.stopPublishCDNStream()
    },

    setMixTranscodingConfig(config) {
        RNModule.setMixTranscodingConfig(config)
    },
    startLocalPreview(frontCamera) {
        RNModule.startLocalPreview(frontCamera)
    },
    stopLocalPreview() {
        RNModule.stopLocalPreview()
    },

    muteLocalVideo(mute) {
        RNModule.muteLocalVideo(mute)
    },

    startRemoteView(userId) {
        RNModule.startRemoteView(userId)
    },

    stopRemoteView(userId) {
        RNModule.stopRemoteView(userId)
    },

    stopAllRemoteView() {
        RNModule.stopAllRemoteView()
    },

    muteRemoteVideoStream(userId, mute) {
        RNModule.muteRemoteVideoStream(userId, mute)
    },

    muteAllRemoteVideoStreams(mute) {
        RNModule.muteAllRemoteVideoStreams(mute)
    },

    setVideoEncoderParam(data) {
        RNModule.setVideoEncoderParam(data)
    },
    setNetworkQosParam(data) {
        RNModule.setNetworkQosParam(data)
    },

    setLocalViewFillMode(mode) {
        RNModule.setLocalViewFillMode(mode)
    },

    setRemoteViewFillMode(userId, mode) {
        RNModule.setRemoteViewFillMode(userId, mode)
    },

    setLocalViewRotation(rotation) {
        RNModule.setLocalViewRotation(rotation)
    },

    setRemoteViewRotation(userId, rotation) {
        RNModule.setRemoteViewRotation(userId, rotation)
    },

    setVideoEncoderRotation(rotation) {
        RNModule.setVideoEncoderRotation(rotation)
    },

    setLocalViewMirror(mirrorType) {
        RNModule.setLocalViewMirror(mirrorType)
    },

    setVideoEncoderMirror(mirror) {
        RNModule.setVideoEncoderMirror(mirror)
    },

    setGSensorMode(mode) {
        RNModule.setGSensorMode(mode)
    },

    enableEncSmallVideoStream(enable, smallVideoEncParam) {
        return RNModule.enableEncSmallVideoStream(enable, smallVideoEncParam)
    },

    setRemoteVideoStreamType(userId, streamType) {
        return RNModule.setRemoteVideoStreamType(userId, streamType)
    },

    setPriorRemoteVideoStreamType(streamType) {
        return RNModule.setPriorRemoteVideoStreamType(streamType)
    },

    snapshotVideo(userId, streamType) {
        return RNModule.snapshotVideo(userId, streamType)
    },

    startLocalAudio() {
        RNModule.startLocalAudio()
    },
    stopLocalAudio() {
        RNModule.stopLocalAudio()
    },

    muteLocalAudio(mute) {
        RNModule.muteLocalAudio(mute)
    },
    muteRemoteAudio(userId, mute) {
        RNModule.muteRemoteAudio(userId, mute)
    },
    muteAllRemoteAudio(mute) {
        RNModule.muteAllRemoteAudio(mute)
    },

    setRemoteAudioVolume(userId, volume) {
        RNModule.setRemoteAudioVolume(userId, volume)
    },

    setAudioCaptureVolume(volume) {
        RNModule.setAudioCaptureVolume(volume)
    },

    getAudioCaptureVolume() {
        return RNModule.getAudioCaptureVolume()
    },

    setAudioPlayoutVolume(volume) {
        RNModule.setAudioPlayoutVolume(volume)
    },

    getAudioPlayoutVolume() {
        return RNModule.getAudioPlayoutVolume()
    },

    enableAudioVolumeEvaluation(intervalMs) {
        RNModule.enableAudioVolumeEvaluation(intervalMs)
    },

    startAudioRecording(param) {
        return RNModule.startAudioRecording(param)
    },

    stopAudioRecording() {
        RNModule.stopAudioRecording()
    },

    setSystemVolumeType(type) {
        RNModule.setSystemVolumeType(type)
    },

    enableAudioEarMonitoring(enable) {
        RNModule.enableAudioEarMonitoring(enable)
    },

    switchCamera() {
        RNModule.switchCamera()
    },
    isCameraZoomSupported() {
        return RNModule.isCameraZoomSupported()
    },

    setZoom(distance) {
        RNModule.setZoom(distance)
    },

    isCameraTorchSupported() {
        return RNModule.isCameraTorchSupported()
    },

    enableTorch(enable) {
        return RNModule.enableTorch(enable)
    },

    isCameraFocusPositionInPreviewSupported() {
        return RNModule.isCameraFocusPositionInPreviewSupported()
    },

    setFocusPosition(x, y) {
        RNModule.setFocusPosition(x, y)
    },

    isCameraAutoFocusFaceModeSupported() {
        return RNModule.isCameraAutoFocusFaceModeSupported()
    },

    startScreenRecord() {
        RNModule.startScreenRecord()
    },
    stopScreenRecord() {
        RNModule.stopScreenRecord()
    },

    getSDKVersion() {
        return RNModule.getSDKVersion();
    },
    /*
     * setAudioRoute
     * int  0 Speaker 1 Earpiece
     */
    setAudioRoute(router) {
        RNModule.setAudioRoute(router)
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
