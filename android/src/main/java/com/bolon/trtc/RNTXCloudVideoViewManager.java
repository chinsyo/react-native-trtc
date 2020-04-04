package com.bolon.trtc;


import android.support.annotation.Nullable;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.util.ReactFindViewUtil;

import java.util.Map;

public class RNTXCloudVideoViewManager extends SimpleViewManager<RNTXCloudVideoView> {
    public static final String REACT_CLASS = "RNTXCloudVideoView";

    public enum Events {
        EVENT_ON_TRAXK("onTrack"),
        EVENT_ON_FACE_DETECT("onFaceDetect");

        private final String mName;

        Events(final String name) {
            mName = name;
        }

        @Override
        public String toString() {
            return mName;
        }
    }

    @Override
    @Nullable
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
        for (Events event : Events.values()) {
            builder.put(event.toString(), MapBuilder.of("registrationName", event.toString()));
        }
        return builder.build();
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public RNTXCloudVideoView createViewInstance(ThemedReactContext context) {
        return new RNTXCloudVideoView(context);
    }

    @Override
    public void onDropViewInstance(RNTXCloudVideoView view) {
        view.stop();
        super.onDropViewInstance(view);
    }

    @ReactProp(name = "userId")
    public void setUserId(RNTXCloudVideoView view, String value) {
        view.setTag(R.id.view_tag_user_id, value);
        view.setUserId(value);
    }
}
