
package com.bolon.trtc;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.media.projection.MediaProjectionManager;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.TRTCStatistics;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;

import static android.app.Activity.RESULT_OK;

public class RNTrtcModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    private final ReactApplicationContext reactContext;
    public static TRTCCloud mEngine;
    public static Boolean frontCamera = true;
    private String TAG = RNTrtcModule.class.getName();
    public static String selfUserId = "";

    /**
     * 是否已经开启视频录制
     */
    private boolean isScreenRecord = false;
    private ScreenRecord screenRecord;

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent intent) {
            if (requestCode == 1334) {
                if (resultCode == RESULT_OK) {
                    // 获得权限，启动Service开始录制

//          Intent service = new Intent(reactContext, ScreenRecordService.class);
//          service.putExtra("code", resultCode);
//          service.putExtra("data", intent);
//          reactContext.startService(service);

                    screenRecord = new ScreenRecord(reactContext);
                    screenRecord.init(resultCode, intent);
                    screenRecord.start();
                    // 已经开始屏幕录制，修改UI状态
                    isScreenRecord = true;
                    Log.i(TAG, "Started screen recording");
                } else {
                    Log.i(TAG, "User cancelled");
                }
            }
        }
    };


    public RNTrtcModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addLifecycleEventListener(this);
        reactContext.addActivityEventListener(mActivityEventListener);
    }

    @Override
    public void onHostResume() {
        // Activity `onResume`
    }

    @Override
    public void onHostPause() {
        // Activity `onPause`
//    if (mEngine == null) {
//      return;
//    }
//    try {
//      mEngine.stopLocalPreview();
//    } catch (Exception e) {
//      e.printStackTrace();
//    }
    }

    @Override
    public void onHostDestroy() {
        // Activity `onDestroy`
        if (mEngine == null) {
            return;
        }
        TRTCCloud.destroySharedInstance();
    }

    @ReactMethod
    public void creatUserSig(int sdkAppId, String secretKey, String userId, Promise promise) {
        try {
            String tempSig = GenerateSigHelper.genUserSig(sdkAppId, userId, secretKey);
            Log.i(TAG, "creatUserSig====>>>tempSig:" + tempSig + ",sdkAppId=" + sdkAppId + ",secretKey=" + secretKey + ",userId=" + userId);
            promise.resolve(tempSig);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void enableScreenOn() {
        final Activity activity = reactContext.getCurrentActivity();
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        });

    }

    @ReactMethod
    public void disableScreenOn() {
        final Activity activity = reactContext.getCurrentActivity();
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        });
    }


    @ReactMethod
    public void sharedInstance(Promise promise) {
        try {
            mEngine = TRTCCloud.sharedInstance(reactContext);
            mEngine.setListener(_TRTCCloudListener);
//      mEngine.setListenerHandler();
            promise.resolve(true);
        } catch (Exception e) {
            promise.reject(e);
        }

    }

    @ReactMethod
    public void destroySharedInstance() {
        TRTCCloud.destroySharedInstance();
    }


    @ReactMethod
    public void enterRoom(ReadableMap data, Integer scene) {
        Log.i(TAG, "enterRoom");
        TRTCCloudDef.TRTCParams userInfo = new TRTCCloudDef.TRTCParams();
        userInfo.sdkAppId = data.getInt("sdkAppId");
        userInfo.userId = data.getString("userId");
        userInfo.userSig = data.getString("userSig");
        userInfo.roomId = data.getInt("roomId");
        userInfo.role = data.getInt("role");

        if (data.hasKey("privateMapKey")) {
            userInfo.privateMapKey = data.getString("privateMapKey");
        }
        if (data.hasKey("businessInfo")) {
            userInfo.businessInfo = data.getString("businessInfo");
        }
        // 加入频道
        selfUserId = userInfo.userId;
        mEngine.enterRoom(userInfo, scene);
    }

    @ReactMethod
    public void exitRoom() {
        Log.i(TAG, "exitRoom");
        mEngine.exitRoom();
    }

    @ReactMethod
    public void switchRole(Integer role) {
        Log.i(TAG, "switchRole");
        mEngine.switchRole(role);
    }

    @ReactMethod
    public void connectOtherRoom(String param) {
        Log.i(TAG, "ConnectOtherRoom");
        mEngine.ConnectOtherRoom(param);
    }

    @ReactMethod
    public void disconnectOtherRoom() {
        Log.i(TAG, "DisconnectOtherRoom");
        mEngine.DisconnectOtherRoom();
    }

    @ReactMethod
    public void setDefaultStreamRecvMode(Boolean autoRecvAudio, Boolean autoRecvVideo) {
        Log.i(TAG, "setDefaultStreamRecvMode");
        mEngine.setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo);
    }

    @ReactMethod
    public void startPublishing(String streamId, Integer streamType) {
        Log.i(TAG, "startPublishing");
        mEngine.startPublishing(streamId, streamType);
    }

    @ReactMethod
    public void stopPublishing() {
        Log.i(TAG, "stopPublishing");
        mEngine.stopPublishing();
    }

    @ReactMethod
    public void startPublishCDNStream(ReadableMap param) {
        Log.i(TAG, "startPublishCDNStream");
        TRTCCloudDef.TRTCPublishCDNParam cndParam = new TRTCCloudDef.TRTCPublishCDNParam();
        cndParam.appId = param.getInt("appId");
        cndParam.bizId = param.getInt("bizId");
        cndParam.url = param.getString("url");
        mEngine.startPublishCDNStream(cndParam);
    }

    @ReactMethod
    public void stopPublishCDNStream() {
        Log.i(TAG, "stopPublishCDNStream");
        mEngine.stopPublishCDNStream();
    }

    @ReactMethod
    public void setMixTranscodingConfig(ReadableMap config) {
        Log.i(TAG, "setMixTranscodingConfig");
        TRTCCloudDef.TRTCTranscodingConfig mConfig = new TRTCCloudDef.TRTCTranscodingConfig();
        mConfig.appId = config.getInt("appId");
        mConfig.audioBitrate = config.getInt("audioBitrate");
        mConfig.audioChannels = config.getInt("audioChannels");
        mConfig.audioSampleRate = config.getInt("audioSampleRate");
        mConfig.backgroundColor = config.getInt("backgroundColor");
        mConfig.bizId = config.getInt("bizId");
        mConfig.mode = config.getInt("mode");
        mConfig.videoBitrate = config.getInt("videoBitrate");
        mConfig.videoFramerate = config.getInt("videoFramerate");
        mConfig.videoGOP = config.getInt("videoGOP");
        mConfig.videoHeight = config.getInt("videoHeight");
        mConfig.videoWidth = config.getInt("videoWidth");

        ArrayList<TRTCCloudDef.TRTCMixUser> mixUsers = new ArrayList<>();
        ReadableArray array = config.getArray("mixUsers");
        for (int i = 0; i < array.size(); i++) {
            TRTCCloudDef.TRTCMixUser user = new TRTCCloudDef.TRTCMixUser();
            ReadableMap item = array.getMap(i);
            user.userId = item.getString("userId");
            user.height = item.getInt("height");
            user.width = item.getInt("width");
            user.streamType = item.getInt("streamType");
            user.pureAudio = item.getBoolean("pureAudio");
            user.roomId = item.getString("roomId");
            user.x = item.getInt("x");
            user.y = item.getInt("y");
            user.zOrder = item.getInt("zOrder");
            mixUsers.add(user);
        }
        mConfig.mixUsers = mixUsers;
        mEngine.setMixTranscodingConfig(mConfig);
    }


    @ReactMethod
    public void startLocalPreview(final Boolean frontCamera) {
        Log.i(TAG, "startLocalPreview");
        View view = findViewByUserId(getCurrentActivity().getWindow().getDecorView(), selfUserId);
        TXCloudVideoView videoView = null;
        if (view != null) {
            videoView = ((RNTXCloudVideoView) view).getCloudVideoView();
            final TXCloudVideoView finalVideoView = videoView;
            view.post(new Runnable() {
                @Override
                public void run() {
                    mEngine.startLocalPreview(frontCamera, finalVideoView);
                }
            });
        }
    }

    @ReactMethod
    public void stopLocalPreview() {
        mEngine.stopLocalPreview();
        Log.i(TAG, "stopLocalPreview");
    }

    @ReactMethod
    public void muteLocalVideo(Boolean mute) {
        Log.i(TAG, "muteLocalVideo");
        mEngine.muteLocalVideo(mute);
    }

    @ReactMethod
    public void startRemoteView(final String userId) {
        Log.i(TAG, "startRemoteView");
        View view = findViewByUserId(getCurrentActivity().getWindow().getDecorView(), userId);
        TXCloudVideoView videoView = null;
        if (view != null) {
            videoView = ((RNTXCloudVideoView) view).getCloudVideoView();
            final TXCloudVideoView finalVideoView = videoView;
            view.post(new Runnable() {
                @Override
                public void run() {
                    mEngine.startRemoteView(userId, finalVideoView);
                }
            });
        }
    }

    @ReactMethod
    public void stopRemoteView(String userId) {
        Log.i(TAG, "stopRemoteView");
        mEngine.stopRemoteView(userId);
    }

    @ReactMethod
    public void stopAllRemoteView() {
        Log.i(TAG, "stopAllRemoteView");
        mEngine.stopAllRemoteView();
    }

    @ReactMethod
    public void muteRemoteVideoStream(String userId, Boolean mute) {
        Log.i(TAG, "muteRemoteVideoStream");
        mEngine.muteRemoteVideoStream(userId, mute);
    }

    @ReactMethod
    public void muteAllRemoteVideoStreams(Boolean mute) {
        Log.i(TAG, "muteAllRemoteVideoStreams");
        mEngine.muteAllRemoteVideoStreams(mute);
    }

    @ReactMethod
    public void setVideoEncoderParam(ReadableMap data) {
        Log.i(TAG, "setVideoEncoderParam");
        TRTCCloudDef.TRTCVideoEncParam param = new TRTCCloudDef.TRTCVideoEncParam();
        param.enableAdjustRes = data.getBoolean("enableAdjustRes");
        param.videoBitrate = data.getInt("videoBitrate");
        param.videoFps = data.getInt("videoFps");
        param.videoResolution = data.getInt("videoResolution");
        param.videoResolutionMode = data.getInt("videoResolutionMode");
        mEngine.setVideoEncoderParam(param);
    }

    @ReactMethod
    public void setNetworkQosParam(ReadableMap data) {
        Log.i(TAG, "setNetworkQosParam");
        TRTCCloudDef.TRTCNetworkQosParam param = new TRTCCloudDef.TRTCNetworkQosParam();
        param.controlMode = data.getInt("controlMode");
        param.preference = data.getInt("preference");
        mEngine.setNetworkQosParam(param);
    }

    @ReactMethod
    public void setLocalViewFillMode(Integer mode) {
        Log.i(TAG, "setLocalViewFillMode");
        mEngine.setLocalViewFillMode(mode);
    }

    @ReactMethod
    public void setRemoteViewFillMode(String userId, Integer mode) {
        Log.i(TAG, "setRemoteViewFillMode");
        mEngine.setRemoteViewFillMode(userId, mode);
    }

    @ReactMethod
    public void setLocalViewRotation(int rotation) {
        Log.i(TAG, "setLocalViewRotation");
        mEngine.setLocalViewRotation(rotation);
    }

    @ReactMethod
    public void setRemoteViewRotation(String userId, Integer rotation) {
        Log.i(TAG, "setRemoteViewRotation");
        mEngine.setRemoteViewRotation(userId, rotation);
    }

    @ReactMethod
    public void setVideoEncoderRotation(Integer rotation) {
        Log.i(TAG, "setVideoEncoderRotation");
        mEngine.setVideoEncoderRotation(rotation);
    }

    @ReactMethod
    public void setLocalViewMirror(int mirrorType) {
        Log.i(TAG, "setLocalViewMirror");
        mEngine.setLocalViewMirror(mirrorType);
    }

    @ReactMethod
    public void setVideoEncoderMirror(boolean mirror) {
        Log.i(TAG, "setVideoEncoderMirror");
        mEngine.setVideoEncoderMirror(mirror);
    }

    @ReactMethod
    public void setGSensorMode(int mode) {
        Log.i(TAG, "setGSensorMode");
        mEngine.setGSensorMode(mode);
    }

    @ReactMethod
    public void enableEncSmallVideoStream(boolean enable, WritableMap smallVideoEncParam, Promise promise) {
        Log.i(TAG, "enableEncSmallVideoStream");
        TRTCCloudDef.TRTCVideoEncParam param = new TRTCCloudDef.TRTCVideoEncParam();
        param.videoResolutionMode = smallVideoEncParam.getInt("videoResolutionMode");
        param.videoResolution = smallVideoEncParam.getInt("videoResolution");
        param.videoFps = smallVideoEncParam.getInt("videoFps");
        param.videoBitrate = smallVideoEncParam.getInt("videoBitrate");
        param.enableAdjustRes = smallVideoEncParam.getBoolean("enableAdjustRes");
        int result = mEngine.enableEncSmallVideoStream(enable, param);
        promise.resolve(result);
    }

    @ReactMethod
    public void setRemoteVideoStreamType(String userId, int streamType, Promise promise) {
        Log.i(TAG, "setRemoteVideoStreamType");
        int result = mEngine.setRemoteVideoStreamType(userId, streamType);
        promise.resolve(result);
    }

    @ReactMethod
    public void setPriorRemoteVideoStreamType(int streamType, Promise promise) {
        Log.i(TAG, "setPriorRemoteVideoStreamType");
        int result = mEngine.setPriorRemoteVideoStreamType(streamType);
        promise.resolve(result);
    }

    @ReactMethod
    public void snapshotVideo(String userId, int streamType, final Promise promise) {
        Log.i(TAG, "snapshotVideo");
        TRTCCloudListener.TRTCSnapshotListener listener = new TRTCCloudListener.TRTCSnapshotListener() {
            @Override
            public void onSnapshotComplete(Bitmap bitmap) {
                String result = null;
                ByteArrayOutputStream baos = null;
                try {
                    if (bitmap != null) {
                        baos = new ByteArrayOutputStream();
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);

                        baos.flush();
                        baos.close();

                        byte[] bitmapBytes = baos.toByteArray();
                        result = Base64.encodeToString(bitmapBytes, Base64.DEFAULT);
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (baos != null) {
                            baos.flush();
                            baos.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                promise.resolve(result);
            }
        };
        mEngine.snapshotVideo(userId, streamType, listener);
    }


    //音频相关接口函数
    @ReactMethod
    public void startLocalAudio() {
        Log.i(TAG, "startLocalAudio");
        mEngine.startLocalAudio();
    }

    @ReactMethod
    public void stopLocalAudio() {
        Log.i(TAG, "stopLocalAudio");
        mEngine.stopLocalAudio();
    }

    @ReactMethod
    public void muteLocalAudio(Boolean var) {
        Log.i(TAG, "muteLocalAudio");
        mEngine.muteLocalAudio(var);
    }

    @ReactMethod
    public void setAudioRoute(Integer route) {
        Log.i(TAG, "setAudioRoute");
        mEngine.setAudioRoute(route);
    }

    @ReactMethod
    public void muteRemoteAudio(String userId, Boolean mute) {
        Log.i(TAG, "muteRemoteAudio");
        mEngine.muteRemoteAudio(userId, mute);
    }

    @ReactMethod
    public void muteAllRemoteAudio(Boolean mute) {
        Log.i(TAG, "muteAllRemoteAudio");
        mEngine.muteAllRemoteAudio(mute);
    }

    @ReactMethod
    public void setRemoteAudioVolume(String userId, int volume) {
        Log.i(TAG, "setRemoteAudioVolume");
        mEngine.setRemoteAudioVolume(userId, volume);
    }

    @ReactMethod
    public void setAudioCaptureVolume(int volume) {
        Log.i(TAG, "setAudioCaptureVolume");
        mEngine.setAudioCaptureVolume(volume);
    }

    @ReactMethod
    public void getAudioCaptureVolume(Promise promise) {
        Log.i(TAG, "getAudioCaptureVolume");
        int result = mEngine.getAudioCaptureVolume();
        promise.resolve(result);
    }

    @ReactMethod
    public void setAudioPlayoutVolume(int volume) {
        Log.i(TAG, "setAudioPlayoutVolume");
        mEngine.setAudioPlayoutVolume(volume);
    }

    @ReactMethod
    public void getAudioPlayoutVolume(Promise promise) {
        Log.i(TAG, "getAudioPlayoutVolume");
        int result = mEngine.getAudioPlayoutVolume();
        promise.resolve(result);
    }

    @ReactMethod
    public void enableAudioVolumeEvaluation(Integer intervalMs) {
        Log.i(TAG, "enableAudioVolumeEvaluation");
        mEngine.enableAudioVolumeEvaluation(intervalMs);
    }

    @ReactMethod
    public void startAudioRecording(ReadableMap param, Promise promise) {
        Log.i(TAG, "startAudioRecording");
        TRTCCloudDef.TRTCAudioRecordingParams data = new TRTCCloudDef.TRTCAudioRecordingParams();
        data.filePath = param.getString("filePath");
        int ret = mEngine.startAudioRecording(data);
        promise.resolve(ret);
    }

    @ReactMethod
    public void stopAudioRecording() {
        Log.i(TAG, "startAudioRecording");
        mEngine.stopAudioRecording();
    }

    @ReactMethod
    public void setSystemVolumeType(Integer type) {
        Log.i(TAG, "setSystemVolumeType");
        mEngine.setSystemVolumeType(type);
    }

    @ReactMethod
    public void enableAudioEarMonitoring(boolean enable) {
        Log.i(TAG, "enableAudioEarMonitoring");
        mEngine.enableAudioEarMonitoring(enable);
    }

    @ReactMethod
    public void switchCamera() {
        Log.i(TAG, "switchCamera");
        mEngine.switchCamera();
    }

    @ReactMethod
    public void isCameraZoomSupported(Promise promise) {
        Log.i(TAG, "isCameraZoomSupported");
        boolean result = mEngine.isCameraZoomSupported();
        promise.resolve(result);
    }

    @ReactMethod
    public void setZoom(int distance) {
        Log.i(TAG, "setZoom");
        mEngine.setZoom(distance);
    }

    @ReactMethod
    public void isCameraTorchSupported(Promise promise) {
        Log.i(TAG, "isCameraTorchSupported");
        boolean result = mEngine.isCameraTorchSupported();
        promise.resolve(result);
    }

    @ReactMethod
    public void enableTorch(boolean enable, Promise promise) {
        Log.i(TAG, "enableTorch");
        boolean result = mEngine.enableTorch(enable);
        promise.resolve(result);
    }

    @ReactMethod
    public void isCameraFocusPositionInPreviewSupported(Promise promise) {
        Log.i(TAG, "isCameraFocusPositionInPreviewSupported");
        boolean result = mEngine.isCameraFocusPositionInPreviewSupported();
        promise.resolve(result);
    }

    @ReactMethod
    public void setFocusPosition(int x, int y) {
        Log.i(TAG, "setFocusPosition");
        mEngine.setFocusPosition(x, y);
    }

    @ReactMethod
    public void isCameraAutoFocusFaceModeSupported(Promise promise) {
        Log.i(TAG, "isCameraAutoFocusFaceModeSupported");
        boolean result = mEngine.isCameraAutoFocusFaceModeSupported();
        promise.resolve(result);
    }

    @TargetApi(21)
    @ReactMethod
    public void startScreenRecord() {
        if (isScreenRecord) {
            screenRecord.start();
            return;
        }
        MediaProjectionManager mediaProjectionManager = (MediaProjectionManager) reactContext.getSystemService(Context.MEDIA_PROJECTION_SERVICE);
        Intent permissionIntent = mediaProjectionManager.createScreenCaptureIntent();
        reactContext.startActivityForResult(permissionIntent, 1334, null);
    }


    @ReactMethod
    public void stopScreenRecord(Promise promise) {
        if (!isScreenRecord) {
            promise.resolve(true);
            return;
        }
        screenRecord.stop();
        promise.resolve(true);
    }

    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }


    @Override
    public String getName() {
        return "RNTrtc";
    }

    private TRTCCloudListener _TRTCCloudListener = new TRTCCloudListener() {
        @Override
        public void onWarning(int warningCode, String warningMsg, Bundle bundle) {
            Log.i(TAG, "onWarning: warningCode = " + warningCode + " warningMsg = " + warningMsg);
            WritableMap params = Arguments.createMap();
            params.putInt("warningCode", warningCode);
            params.putString("warningMsg", warningMsg);
            sendEvent(reactContext, "onWarning", params);
        }

        /**
         * ERROR 大多是不可恢复的错误，需要通过 UI 提示用户
         * 然后执行退房操作
         *
         * @param errCode   错误码 TXLiteAVError
         * @param errMsg    错误信息
         * @param extraInfo 扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
         */
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.i(TAG, "onError: errCode = " + errCode + " errMsg = " + errMsg);
            WritableMap params = Arguments.createMap();
            params.putInt("errCode", errCode);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onError", params);
        }

        /**
         * 加入房间回调
         *
         * @param elapsed 加入房间耗时，单位毫秒
         */
        @Override
        public void onEnterRoom(long elapsed) {
            Log.i(TAG, "onEnterRoom: elapsed = " + elapsed);
            WritableMap params = Arguments.createMap();
            params.putDouble("elapsed", elapsed);
            sendEvent(reactContext, "onEnterRoom", params);
        }

        @Override
        public void onExitRoom(int reason) {
            Log.i(TAG, "onExitRoom: reason = " + reason);
            WritableMap params = Arguments.createMap();
            params.putInt("reason", reason);
            sendEvent(reactContext, "onExitRoom", params);
        }

        @Override
        public void onSwitchRole(int errCode, String errMsg) {
            WritableMap params = Arguments.createMap();
            params.putInt("errCode", errCode);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onSwitchRole", params);
        }

        /**
         * 跨房连麦会结果回调
         *
         * @param userId
         * @param errMsg
         * @param errMsg
         */
        @Override
        public void onConnectOtherRoom(String userId, int errCode, String errMsg) {
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putInt("errCode", errCode);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onConnectOtherRoom", params);
        }

        /**
         * 断开跨房连麦结果回调
         *
         * @param errCode
         * @param errMsg
         */
        @Override
        public void onDisconnectOtherRoom(final int errCode, final String errMsg) {
            WritableMap params = Arguments.createMap();
            params.putInt("errCode", errCode);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onDisconnectOtherRoom", params);
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            sendEvent(reactContext, "onRemoteUserEnterRoom", params);
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putInt("reason", reason);
            sendEvent(reactContext, "onRemoteUserLeaveRoom", params);
        }


        /**
         * 若当对应 userId 的主播有上行的视频流的时候，该方法会被回调，available 为 true；
         * 若对应的主播通过{@link TRTCCloud#muteLocalVideo(boolean)}，该方法也会被回调，available 为 false。
         * Demo 在收到主播有上行流的时候，会通过{@link TRTCCloud#startRemoteView(String, TXCloudVideoView)} 开始渲染
         * Demo 在收到主播停止上行的时候，会通过{@link TRTCCloud#stopRemoteView(String)} 停止渲染，并且更新相关 UI
         *
         * @param userId    用户标识
         * @param available 画面是否开启
         */
        @Override
        public void onUserVideoAvailable(final String userId, boolean available) {
            Log.i(TAG, "onUserVideoAvailable: userId = " + userId + " available = " + available);
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putBoolean("available", available);
            sendEvent(reactContext, "onUserVideoAvailable", params);
        }


        /**
         * 是否有辅路上行的回调，Demo 中处理方式和主画面的一致 }
         *
         * @param userId    用户标识
         * @param available 屏幕分享是否开启
         */
        @Override
        public void onUserSubStreamAvailable(final String userId, boolean available) {
            Log.i(TAG, "onUserSubStreamAvailable: userId = " + userId + " available = " + available);
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putBoolean("available", available);
            sendEvent(reactContext, "onUserSubStreamAvailable", params);
        }

        /**
         * 是否有音频上行的回调
         * <p>
         * 您可以根据您的项目要求，设置相关的 UI 逻辑，比如显示对端闭麦的图标等
         *
         * @param userId    用户标识
         * @param available true：音频可播放，false：音频被关闭
         */
        @Override
        public void onUserAudioAvailable(String userId, boolean available) {
            Log.i(TAG, "onUserAudioAvailable: userId = " + userId + " available = " + available);
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putBoolean("available", available);
            sendEvent(reactContext, "onUserAudioAvailable", params);
        }

        /**
         * 视频首帧渲染回调
         * <p>
         * 一般客户可不关注，专业级客户质量统计等；您可以根据您的项目情况决定是否进行统计或实现其他功能。
         *
         * @param userId     用户 ID
         * @param streamType 视频流类型
         * @param width      画面宽度
         * @param height     画面高度
         */
        @Override
        public void onFirstVideoFrame(String userId, int streamType, int width, int height) {
            Log.i(TAG, "onFirstVideoFrame: userId = " + userId + " streamType = " + streamType + " width = " + width + " height = " + height);
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putInt("streamType", streamType);
            params.putInt("width", width);
            params.putInt("height", height);
            sendEvent(reactContext, "onFirstVideoFrame", params);
        }

        @Override
        public void onFirstAudioFrame(String userId) {
            Log.i(TAG, "onFirstAudioFrame");
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            sendEvent(reactContext, "onFirstAudioFrame", params);
        }

        @Override
        public void onSendFirstLocalVideoFrame(int streamType) {
            Log.i(TAG, "onSendFirstLocalVideoFrame");
            WritableMap params = Arguments.createMap();
            params.putInt("streamType", streamType);
            sendEvent(reactContext, "onSendFirstLocalVideoFrame", params);
        }

        @Override
        public void onSendFirstLocalAudioFrame() {
            Log.i(TAG, "onSendFirstLocalAudioFrame");
            sendEvent(reactContext, "onSendFirstLocalAudioFrame", null);
        }

        /**
         * 有新的主播{@link TRTCCloudDef#TRTCRoleAnchor}加入了当前视频房间
         * 该方法会在主播加入房间的时候进行回调，此时音频数据会自动拉取下来，但是视频需要有 View 承载才会开始渲染。
         * 为了更好的交互体验，Demo 选择在 onUserVideoAvailable 中，申请 View 并且开始渲染。
         * 您可以根据实际需求，选择在 onUserEnter 还是 onUserVideoAvailable 中发起渲染。
         *
         * @param userId 用户标识
         */
        @Override
        public void onUserEnter(String userId) {
            Log.i(TAG, "onUserEnter: userId = " + userId);
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            sendEvent(reactContext, "onUserEnter", params);
        }

        /**
         * 主播{@link TRTCCloudDef#TRTCRoleAnchor}离开了当前视频房间
         * 主播离开房间，要释放相关资源。
         * 1. 释放主画面、辅路画面
         * 2. 如果您有混流的需求，还需要重新发起混流，保证混流的布局是您所期待的。
         *
         * @param userId 用户标识
         * @param reason 离开原因代码，区分用户是正常离开，还是由于网络断线等原因离开。
         */
        @Override
        public void onUserExit(String userId, int reason) {
            Log.i(TAG, "onUserExit: userId = " + userId + " reason = " + reason);
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putInt("reason", reason);
            sendEvent(reactContext, "onUserExit", params);
        }

        /**
         * 网络行质量回调
         * <p>
         * 您可以用来在 UI 上显示当前用户的网络质量，提高用户体验
         *
         * @param localQuality  上行网络质量
         * @param remoteQuality 下行网络质量
         */
        @Override
        public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality) {
            Log.i(TAG, "onNetworkQuality: localQuality = " + localQuality + " remoteQuality = " + remoteQuality);
            WritableMap params = Arguments.createMap();

            WritableMap local = Arguments.createMap();
            local.putString("userId", localQuality.userId);
            local.putInt("quality", localQuality.quality);
            params.putMap("localQuality", local);

            WritableArray remote = Arguments.createArray();
            for (int i = 0; i < remoteQuality.size(); i++) {
                WritableMap item = Arguments.createMap();
                item.putString("userId", remoteQuality.get(i).userId);
                item.putInt("quality", remoteQuality.get(i).quality);
                remote.pushMap(item);
            }
            params.putArray("remoteQuality", remote);
            sendEvent(reactContext, "onNetworkQuality", params);
        }

        /**
         * SDK 状态数据回调
         * <p>
         * 一般客户无需关注，专业级客户可以用来进行统计相关的性能指标；您可以根据您的项目情况是否实现统计等功能
         *
         * @param statics 状态数据
         */
        @Override
        public void onStatistics(TRTCStatistics statics) {
            Log.i(TAG, "onStatistics");
            WritableMap params = Arguments.createMap();
            params.putInt("appCpu", statics.appCpu);
            params.putInt("downLoss", statics.downLoss);
            params.putInt("rtt", statics.rtt);
            params.putInt("systemCpu", statics.systemCpu);
            params.putInt("upLoss", statics.upLoss);
            params.putDouble("receiveBytes", statics.receiveBytes);
            params.putDouble("sendBytes", statics.sendBytes);

            ArrayList<TRTCStatistics.TRTCLocalStatistics> localArray = statics.localArray;
            WritableArray array1 = Arguments.createArray();
            for (int i = 0; i < localArray.size(); i++) {
                WritableMap item = Arguments.createMap();
                item.putInt("audioBitrate", localArray.get(i).audioBitrate);
                item.putInt("audioSampleRate", localArray.get(i).audioSampleRate);
                item.putInt("frameRate", localArray.get(i).frameRate);
                item.putInt("height", localArray.get(i).height);
                item.putInt("width", localArray.get(i).width);
                item.putInt("streamType", localArray.get(i).streamType);
                item.putInt("videoBitrate", localArray.get(i).videoBitrate);
                array1.pushMap(item);
            }
            params.putArray("localArray", array1);

            ArrayList<TRTCStatistics.TRTCRemoteStatistics> remoteArray = statics.remoteArray;
            WritableArray array2 = Arguments.createArray();
            for (int i = 0; i < localArray.size(); i++) {
                WritableMap item = Arguments.createMap();
                item.putInt("audioBitrate", localArray.get(i).audioBitrate);
                item.putInt("audioSampleRate", localArray.get(i).audioSampleRate);
                item.putInt("frameRate", localArray.get(i).frameRate);
                item.putInt("height", localArray.get(i).height);
                item.putInt("width", localArray.get(i).width);
                item.putInt("streamType", localArray.get(i).streamType);
                item.putInt("videoBitrate", localArray.get(i).videoBitrate);
                array2.pushMap(item);
            }
            params.putArray("remoteArray", array2);
            sendEvent(reactContext, "onStatistics", params);
        }

        @Override
        public void onConnectionLost() {
            Log.i(TAG, "onConnectionLost");
            sendEvent(reactContext, "onConnectionLost", null);
        }

        @Override
        public void onTryToReconnect() {
            Log.i(TAG, "onTryToReconnect");
            sendEvent(reactContext, "onTryToReconnect", null);
        }

        @Override
        public void onConnectionRecovery() {
            Log.i(TAG, "onConnectionRecovery");
            sendEvent(reactContext, "onConnectionRecovery", null);
        }

        @Override
        public void onSpeedTest(TRTCCloudDef.TRTCSpeedTestResult currentResult, int finishedCount, int totalCount) {
            Log.i(TAG, "onSpeedTest");
            WritableMap params = Arguments.createMap();
            params.putInt("totalCount", totalCount);
            params.putInt("finishedCount", finishedCount);

            WritableMap result = Arguments.createMap();
            result.putInt("quality", currentResult.quality);
            result.putInt("rtt", currentResult.rtt);
            result.putDouble("downLostRate", currentResult.downLostRate);
            result.putString("ip", currentResult.ip);
            result.putDouble("upLostRate", currentResult.upLostRate);
            params.putMap("currentResult", result);

            sendEvent(reactContext, "onSpeedTest", params);
        }

        @Override
        public void onCameraDidReady() {
            Log.i(TAG, "onCameraDidReady");
            sendEvent(reactContext, "onCameraDidReady", null);
        }

        @Override
        public void onMicDidReady() {
            Log.i(TAG, "onMicDidReady");
            sendEvent(reactContext, "onMicDidReady", null);
        }

        @Override
        public void onAudioRouteChanged(int newRoute, int oldRoute) {
            Log.i(TAG, "onAudioRouteChanged");
            WritableMap params = Arguments.createMap();
            params.putInt("newRoute", newRoute);
            params.putInt("oldRoute", oldRoute);
            sendEvent(reactContext, "onAudioRouteChanged", params);
        }

        /**
         * 音量大小回调
         * <p>
         * 您可以用来在 UI 上显示当前用户的声音大小，提高用户体验
         *
         * @param userVolumes 所有正在说话的房间成员的音量（取值范围0 - 100）。即 userVolumes 内仅包含音量不为0（正在说话）的用户音量信息。其中本地进房 userId 对应的音量，表示 local 的音量，也就是自己的音量。
         * @param totalVolume 所有远端成员的总音量, 取值范围 [0, 100]
         */
        @Override
        public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
            Log.i(TAG, "onUserVoiceVolume");
            WritableMap params = Arguments.createMap();
            params.putInt("totalVolume", totalVolume);

            WritableArray array = Arguments.createArray();
            for (int i = 0; i < userVolumes.size(); i++) {
                WritableMap item = Arguments.createMap();
                item.putString("userId", userVolumes.get(i).userId);
                item.putInt("volume", userVolumes.get(i).volume);
                array.pushMap(item);
            }
            params.putArray("userVolumes", array);
            sendEvent(reactContext, "onUserVoiceVolume", params);
        }

        @Override
        public void onRecvCustomCmdMsg(String userId, int cmdID, int seq, byte[] message) {
            Log.i(TAG, "onRecvCustomCmdMsg");
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putInt("cmdID", cmdID);
            params.putInt("seq", seq);
            params.putString("message", Base64.encodeToString(message, Base64.DEFAULT));
            sendEvent(reactContext, "onRecvCustomCmdMsg", params);
        }

        @Override
        public void onMissCustomCmdMsg(String userId, int cmdID, int errCode, int missed) {
            Log.i(TAG, "onMissCustomCmdMsg");
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putInt("cmdID", cmdID);
            params.putInt("errCode", errCode);
            params.putInt("missed", missed);
            sendEvent(reactContext, "onMissCustomCmdMsg", params);
        }

        @Override
        public void onRecvSEIMsg(String userId, byte[] data) {
            Log.i(TAG, "onRecvSEIMsg");
            WritableMap params = Arguments.createMap();
            params.putString("userId", userId);
            params.putString("data", Base64.encodeToString(data, Base64.DEFAULT));
            sendEvent(reactContext, "onRecvSEIMsg", params);
        }

        @Override
        public void onStartPublishing(int err, String errMsg) {
            Log.i(TAG, "onStartPublishing");
            WritableMap params = Arguments.createMap();
            params.putInt("err", err);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onStartPublishing", params);
        }

        @Override
        public void onStopPublishing(int err, String errMsg) {
            Log.i(TAG, "onStopPublishing");
            WritableMap params = Arguments.createMap();
            params.putInt("err", err);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onStopPublishing", params);
        }

        @Override
        public void onStartPublishCDNStream(int err, String errMsg) {
            Log.i(TAG, "onStartPublishCDNStream");
            WritableMap params = Arguments.createMap();
            params.putInt("err", err);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onStartPublishCDNStream", params);
        }

        @Override
        public void onStopPublishCDNStream(int err, String errMsg) {
            Log.i(TAG, "onStopPublishCDNStream");
            WritableMap params = Arguments.createMap();
            params.putInt("err", err);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onStopPublishCDNStream", params);
        }

        @Override
        public void onSetMixTranscodingConfig(int err, String errMsg) {
            Log.i(TAG, "onSetMixTranscodingConfig");
            WritableMap params = Arguments.createMap();
            params.putInt("err", err);
            params.putString("errMsg", errMsg);
            sendEvent(reactContext, "onSetMixTranscodingConfig", params);
        }

        @Override
        public void onAudioEffectFinished(int effectId, int code) {
            Log.i(TAG, "onAudioEffectFinished");
            WritableMap params = Arguments.createMap();
            params.putInt("effectId", effectId);
            params.putInt("code", code);
            sendEvent(reactContext, "onAudioEffectFinished", params);
        }

    };

    private @Nullable
    View findViewByUserId(View root, String userId) {
        String tag = getUserId(root);
        if (tag != null && tag.equals(userId)) {
            return root;
        }
        if (root instanceof ViewGroup) {
            ViewGroup viewGroup = (ViewGroup) root;
            for (int i = 0; i < viewGroup.getChildCount(); i++) {
                View view = findViewByUserId(viewGroup.getChildAt(i), userId);
                if (view != null) {
                    return view;
                }
            }
        }

        return null;
    }

    private @Nullable
    String getUserId(View view) {
        Object tag = view.getTag(R.id.view_tag_user_id);
        return tag instanceof String ? (String) tag : null;
    }

}