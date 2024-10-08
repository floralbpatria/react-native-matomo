package de.bonify.reactnativematomo;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import org.matomo.sdk.Matomo;
import org.matomo.sdk.Tracker;
import org.matomo.sdk.TrackerBuilder;
import org.matomo.sdk.extra.TrackHelper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;


public class MatomoModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    private static final String LOGGER_TAG = "MatomoModule";
    private static Map<Integer, String> customDimensions = new HashMap<>();

    public MatomoModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addLifecycleEventListener(this);
    }

    private Matomo matomo;
    private Tracker mMatomoTracker;

    @ReactMethod
    public void initTracker(String url, int id) {
        TrackerBuilder builder = TrackerBuilder.createDefault(url, id);
        mMatomoTracker = builder.build(Matomo.getInstance(getReactApplicationContext()));
    }

    @ReactMethod
    public void setAppOptOut(Boolean isOptedOut) {
        mMatomoTracker.setOptOut(isOptedOut);
    }

    @ReactMethod
    public void setUserId(String userId) {
        mMatomoTracker.setUserId(userId);
    }

    @ReactMethod
    public void setCustomDimension(int id, @Nullable String value){
        if(value == null || value.length() == 0) {
            customDimensions.remove(id);
            return;
        }
        customDimensions.put(id, value);
    }

    private TrackHelper getTrackHelper(){
        if (mMatomoTracker == null) {
            throw new RuntimeException("Tracker must be initialized before usage");
        }
        TrackHelper trackHelper = TrackHelper.track();
        for(Map.Entry<Integer, String> entry : customDimensions.entrySet()){
            trackHelper = trackHelper.dimension(entry.getKey(), entry.getValue());
        }
        return trackHelper;
    }

    @ReactMethod
    public void trackScreen(@NonNull String screen, String title) {
        getTrackHelper().screen(screen).title(title).with(mMatomoTracker);
    }

    @ReactMethod
    public void trackEvent(@NonNull String category, @NonNull String action, ReadableMap values) {
        String name = null;
        Float value = null;
        if (values.hasKey("name") && !values.isNull("name")) {
            name = values.getString("name");
        }
        if (values.hasKey("value") && !values.isNull("value")) {
            value = (float)values.getDouble("value");
        }
        getTrackHelper().event(category, action).name(name).value(value).with(mMatomoTracker);
    }

    @ReactMethod
    public void trackGoal(int goalId, ReadableMap values) {
        Float revenue = null;
        if (values.hasKey("revenue") && !values.isNull("revenue")) {
            revenue = (float)values.getDouble("revenue");
        }
        getTrackHelper().goal(goalId).revenue(revenue).with(mMatomoTracker);
    }

    @ReactMethod
    public void trackCampaign(String name, String keyboard) {}

    @ReactMethod
    public void trackContentImpression(@NonNull String name, @NonNull ReadableMap values) {
        String piece = null;
        String target = null;

        if (values.hasKey("piece") && !values.isNull("piece")) {
            piece = values.getString("piece");
        }
        if (values.hasKey("target") && !values.isNull("target")) {
            target = values.getString("target");
        }

        getTrackHelper().impression(name).target(target).piece(piece).with(mMatomoTracker);

    }
    @ReactMethod
    public void trackContentInteraction(@NonNull String name, @NonNull ReadableMap values) {
        String interaction = null;
        String piece = null;
        String target = null;

        if (values.hasKey("interaction") && !values.isNull("interaction")) {
            interaction = values.getString("interaction");
        }
        if (values.hasKey("piece") && !values.isNull("piece")) {
            piece = values.getString("piece");
        }
        if (values.hasKey("target") && !values.isNull("target")) {
            target = values.getString("target");
        }

        getTrackHelper().interaction(name, interaction).target(target).piece(piece).with(mMatomoTracker);
    }

    @ReactMethod
    public void trackSearch(@NonNull String query, @NonNull ReadableMap values) {}

    @ReactMethod
    public void trackAppDownload() {
        getTrackHelper().track().download().with(mMatomoTracker);
    }

    @Override
    public String getName() {
        return "Matomo";
    }

    @Override
    public void onHostResume() {}

    @Override
    public void onHostPause() {
        if (mMatomoTracker != null) {
            mMatomoTracker.dispatch();
        }
    }

    @Override
    public void onHostDestroy() {}

}
