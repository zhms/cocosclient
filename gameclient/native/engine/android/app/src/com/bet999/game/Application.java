package com.bet999.game;

import android.app.Activity;
import android.util.Log;

import com.mob.MobApplication;
import com.mob.MobSDK;
import com.mob.moblink.MobLink;
import com.mob.moblink.RestoreSceneListener;
import com.mob.moblink.Scene;


public class Application extends MobApplication {
    private static final String TAG = "Application";

    @Override
    public void onCreate() {
        super.onCreate();
        MobSDK.submitPolicyGrantResult(true, null);
        MobLink.setRestoreSceneListener(new SceneListener());
    }

    class SceneListener extends Object implements RestoreSceneListener {

        @Override
        public Class<? extends Activity> willRestoreScene(Scene scene) {
            Log.i("moblinkTest","将要处理回调 willRestoreScene"+scene.getParams().toString());
            return AppActivity.class;
        }

        @Override
        public void notFoundScene(Scene scene) {
            Log.i("moblinkTest","未找到处理scene的activity时回调"+scene.getParams().toString());
        }

        @Override
        public void completeRestore(Scene scene) {
            Log.i("moblinkTest","完成scene的activity时回调"+scene.getParams().toString());
        }
    }
}
