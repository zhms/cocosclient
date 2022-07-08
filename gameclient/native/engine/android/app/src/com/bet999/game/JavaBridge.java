package com.bet999.game;

import android.content.pm.ActivityInfo;
import com.cocos.lib.GlobalObject;

public class JavaBridge {
    /**
     * 改变屏幕方向
     * @param isPortrait true 竖屏 false 横屏
     */
    public static void changeOrientation(boolean isPortrait) {
        if (isPortrait){
            GlobalObject.getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }
        else{
            GlobalObject.getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        }
    }
}
