package com.bolon.trtc;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;



import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.uimanager.ThemedReactContext;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloudDef;

import static com.bolon.trtc.RNTrtcModule.frontCamera;
import static com.bolon.trtc.RNTrtcModule.mEngine;
import static com.bolon.trtc.RNTrtcModule.selfUserId;


public class RNTXCloudVideoView extends FrameLayout implements LifecycleEventListener {

    private TXCloudVideoView mLocalView;
    private ThemedReactContext _context;

    private String userId = "";

    public RNTXCloudVideoView(ThemedReactContext context) {
        super(context);
        this._context = context;
        context.addLifecycleEventListener(this);

        RelativeLayout mCameraView = new RelativeLayout(this._context);
        mCameraView.setGravity(17);
        mCameraView.setBackgroundColor(255);

        mCameraView.layout(0,0,0,0);
        mLocalView = new TXCloudVideoView(this._context);

        mCameraView.addView(mLocalView);

        this.addView(mCameraView);

        start();

    }

    @Override
    public void requestLayout() {
        super.requestLayout();
        post(measureAndLayout);
    }
    private final Runnable measureAndLayout = new Runnable() {
        @Override
        public void run() {
            measure(
                    MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
            layout(getLeft(), getTop(), getRight(), getBottom());
        }
    };

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed,l,t,r,b);
    }

    public void start(){
        if (mEngine == null) {
            return ;
        }
        if(userId.equals(selfUserId)){
            mEngine.setLocalViewFillMode(TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL);
            mEngine.startLocalPreview(frontCamera,mLocalView);
        }else{
            mEngine.setRemoteViewFillMode(userId, TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL);

            mEngine.startRemoteView(userId, mLocalView);
        }

    }
    public void stop(){
        if (mEngine == null) {
            return ;
        }
        if(userId.equals(selfUserId)){
//            mEngine.stopLocalPreview();
        }else{
            mEngine.stopRemoteView(userId);
        }

    }
    public void setUserId(String var1){
        stop();
        this.userId = var1;
        mLocalView.setUserId(var1);
        start();
    }

    public TXCloudVideoView getCloudVideoView() {
        return mLocalView;
    }

    @Override
    public void onHostResume() {
        if (hasCameraPermissions()) {

            //防止其他Activity resume触发刷新
//            Activity activity  = mReactContext.getCurrentActivity();
//            if (activity != null && activity == _context){
            Log.d("xm", "onHostResume: "+userId);
            start();
//            }

        } else {
            Log.e("xm", "没有摄像机权限" );
        }

    }

    @Override
    public void onHostPause() {
        stop();
    }

    @Override
    public void onHostDestroy() {
        //友情提示：rn的ReactContext传给了不同activity，如果不作处理，
        //其他RN Activity onDestroy时候会使得监听注销，页面无法刷新.
//        Activity activity  = _context.getCurrentActivity();
//        if (activity != null && activity == _context){
        stop();
        _context.removeLifecycleEventListener(this);
//        }

    }
    private boolean hasCameraPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            int result = ContextCompat.checkSelfPermission(getContext(), Manifest.permission.CAMERA);
            return result == PackageManager.PERMISSION_GRANTED;
        } else {
            return true;
        }
    }
}