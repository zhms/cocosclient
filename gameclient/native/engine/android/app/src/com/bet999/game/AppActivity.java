/****************************************************************************
 Copyright (c) 2015-2016 Chukong Technologies Inc.
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
package com.bet999.game;


import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.content.pm.ActivityInfo;
import com.cocos.lib.GlobalObject;

import com.blankj.utilcode.util.SPUtils;
import com.cocos.lib.JsbBridge;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.login.LoginResult;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.mob.MobSDK;

import com.cocos.service.SDKWrapper;
import com.cocos.lib.CocosActivity;
import com.cocos.lib.CocosHelper;
import com.cocos.lib.CocosJavascriptJavaBridge;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import com.facebook.AccessToken;
import com.facebook.LoginStatusCallback;
import com.facebook.login.LoginManager;
import com.mob.moblink.ActionListener;
import com.mob.moblink.MobLink;
import com.mob.moblink.Scene;
import com.mob.moblink.SceneRestorable;

import cn.sharesdk.facebook.Facebook;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.PlatformActionListener;
import cn.sharesdk.framework.PlatformDb;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.framework.loopshare.LoopSharePasswordListener;
import cn.sharesdk.framework.loopshare.watermark.ReadQrImageListener;
import cn.sharesdk.framework.utils.QRCodeUtil.WriterException;
import cn.sharesdk.line.Line;
import cn.sharesdk.telegram.Telegram;
import cn.sharesdk.whatsapp.WhatsApp;

public class AppActivity extends CocosActivity implements SceneRestorable {
    private CallbackManager callbackManager;
    private int js_call_login = 0;
    private int ja_call_alubm = 1;
    private int ja_call_screen = 2;
    private int ja_call_per = 3;
    private int ja_call_copy = 4;
    private int ja_call_getcode = 5;
    private int ja_call_getUrl = 6;
    private  String mobID;
    private static Activity sFirstInstance;
    private static String invitecode;
    private static ImageView sSplashBgImageView = null;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (null == sFirstInstance) {
            sFirstInstance = this;
        }

        /*// 添加启动图
        sSplashBgImageView = new ImageView(this);
        sSplashBgImageView.setImageResource(R.drawable.launch);
        sSplashBgImageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
        this.addContentView(sSplashBgImageView,
                new WindowManager.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
        );*/


        // DO OTHER INITIALIZATION BELOW
        SDKWrapper.shared().init(this);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        callbackManager = CallbackManager.Factory.create();
        LoginManager.getInstance().registerCallback(callbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                        // App code， 登陆成功，自己编写成功后的方法
                        //获取FB返回的uid：loginResult.getAccessToken().getUserId();

                        Log.e(loginResult.getAccessToken().getUserId(), "==========");
                        JsbBridge.sendToScript(loginResult.getAccessToken().getUserId(), "true");
                    }

                    @Override
                    public void onCancel() {
                        // App code， 登陆取消，自行编写
                    }

                    @Override
                    public void onError(FacebookException exception) {
                        // App code
                        Log.e("error:", "exception: " + exception);
                    }
                });

        this.regeditEvent();
    }

    @Override
    protected void onResume() {
        super.onResume();
        SDKWrapper.shared().onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        SDKWrapper.shared().onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Workaround in https://stackoverflow.com/questions/16283079/re-launch-of-activity-on-home-button-but-only-the-first-time/16447508
        if (!isTaskRoot()) {
            return;
        }
        SDKWrapper.shared().onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        SDKWrapper.shared().onActivityResult(requestCode, resultCode, data);
        callbackManager.onActivityResult(requestCode, resultCode, data);

        if (resultCode != 0) {
            if (data != null) {
                if (requestCode == 2) {
                    this.startPhotoZoom(data.getData());
                }

                if (requestCode == 3) {
                    Bundle extras = data.getExtras();
                    if (extras != null) {
                        Bitmap photo = (Bitmap)extras.getParcelable("data");
                        JsbBridge.sendToScript(bitmapToString(photo), "true");
                    }
                }


            }
        }
    }

    private  void regeditEvent(){
        JsbBridge.setCallback(new JsbBridge.ICallback() {
            @Override
            public void onScript(String arg0, String arg1) {
                if (arg0.equals("closeSplish")) {
                    sFirstInstance.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (sSplashBgImageView != null) {
                                sSplashBgImageView.animate().alpha(0f).setDuration(400).setListener(new AnimatorListenerAdapter() {
                                    @Override
                                    public void onAnimationEnd(Animator animation) {
                                        sSplashBgImageView.setVisibility(View.GONE);
                                    }
                                });
                            }
                        }
                    });
                } else if (arg0.equals("changeOrientation")) {
                    int flag = arg1.equals("true") ? ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT : ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE;
                    GlobalObject.getActivity().setRequestedOrientation(flag);
                } else if (arg0.equals("login")){
                    LoginByPlatform(arg1);
                }else {
                    if(Integer.valueOf(arg0) == ja_call_alubm) {
                        TakePhoto("openAlubm");
                    } else if(Integer.valueOf(arg0) == ja_call_screen) {
                        OnGetMobId(arg1);
                        //createQRImage(arg1, 200,200, "url");
                    } else if (Integer.valueOf(arg0) == ja_call_per) {
                        requestMyPermissions();
                    } else if (Integer.valueOf(arg0) == ja_call_copy) {
                        SaveTextToClipboard(arg1);
                    } else if (Integer.valueOf(arg0) == ja_call_getcode) {
                        String code = SPUtils.getInstance().getString("invitecode");
                        JsbBridge.sendToScript(code, "true");
                    } else if (Integer.valueOf(arg0) == ja_call_getUrl) {
                        OnGetShareUrl(arg1);
                    }
                }
            }
        });
    }

    public void startPhotoZoom(Uri uri) {
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/*");
        intent.putExtra("crop", "true");
        intent.putExtra("aspectX", 3);
        intent.putExtra("aspectY", 4);
        intent.putExtra("outputX", 300);
        intent.putExtra("outputY", 300);
        intent.putExtra("return-data", true);
        this.startActivityForResult(intent, 3);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        SDKWrapper.shared().onNewIntent(intent);

        setIntent(intent);
        MobLink.updateNewIntent(getIntent(), this);
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        SDKWrapper.shared().onRestart();
    }

    @Override
    protected void onStop() {
        super.onStop();
        SDKWrapper.shared().onStop();
    }

    @Override
    public void onBackPressed() {
        SDKWrapper.shared().onBackPressed();
        super.onBackPressed();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        SDKWrapper.shared().onConfigurationChanged(newConfig);
        super.onConfigurationChanged(newConfig);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        SDKWrapper.shared().onRestoreInstanceState(savedInstanceState);
        super.onRestoreInstanceState(savedInstanceState);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        SDKWrapper.shared().onSaveInstanceState(outState);
        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onStart() {
        SDKWrapper.shared().onStart();
        super.onStart();
    }

    @Override
    public void onLowMemory() {
        SDKWrapper.shared().onLowMemory();
        super.onLowMemory();
    }


    // 关闭启动图
    public static void closeSplish() {
        sFirstInstance.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (sSplashBgImageView != null) {
                    sSplashBgImageView.animate().alpha(0f)
                            .setDuration(400).setListener(new AnimatorListenerAdapter() {
                                @Override
                                public void onAnimationEnd(Animator animation) {
                                    sSplashBgImageView.setVisibility(View.GONE);
                                }
                            });
                }
            }
        });
    }

    public void SubmitGrant()
    {
        MobSDK.submitPolicyGrantResult(true, null);
    }

    public void LoginByPlatform(String platform_typ)//2 telegram 3 facebook 4 line 5 wahtsapp
    {
        //SubmitGrant();
        Platform plat = null;


        if (Integer.valueOf(platform_typ) == 2)
        {
            plat = ShareSDK.getPlatform(Telegram.NAME);
        }
        else if (Integer.valueOf(platform_typ) == 3)
        {
            plat = ShareSDK.getPlatform(Facebook.NAME);
        }
        else if(Integer.valueOf(platform_typ) == 4)
        {
            plat = ShareSDK.getPlatform(Line.NAME);
        }
        else if(Integer.valueOf(platform_typ) == 5)
        {
            plat = ShareSDK.getPlatform(WhatsApp.NAME);
        }
        else
        {
            plat = ShareSDK.getPlatform(Line.NAME);
        }

        ShareSDK.setActivity(this);

        if (Integer.valueOf(platform_typ) == 3)
        {
            LoginManager.getInstance().logInWithReadPermissions(AppActivity.this, Arrays.asList("public_profile"));
        }
        else
        {
            //授权回调监听，监听oncomplete，onerror，oncancel三种状态
            plat.setPlatformActionListener(new PlatformActionListener() {
                public void onError(Platform arg0, int arg1, Throwable arg2) {
                    //失败的回调，arg:平台对象，arg1:表示当前的动作(8:有用户信息登录, 1:无用户信息登录)，arg2:异常信息
                    Log.e("授权错误", arg1+"========");

                    arg2.printStackTrace();
                }
                public void onComplete(Platform arg0, int arg1, HashMap arg2) {
                    //分享成功的回调
                    Log.e("授权成功", "==========1122");
                    PlatformDb platDB = arg0.getDb();//获取数平台数据DB
                    //通过DB获取各种数据
                    platDB.getToken();
                    platDB.getUserGender();
                    platDB.getUserIcon();
                    platDB.getUserId();
                    platDB.getUserName();

                    Log.e(platDB.getUserId(), "==========");
                    JsbBridge.sendToScript(platDB.getUserId(), "true");
                }
                public void onCancel(Platform arg0, int arg1) {
                    Log.e("授权取消", "==========1133");
                    //取消分享的回调
                }
            });
            plat.showUser(null);
        }
    }

    public String SaveTextToClipboard(String szText) {
        String szResult = "OK";

        try {
            ClipboardManager cm = (ClipboardManager)this.getSystemService("clipboard");
            ClipData mClipData = ClipData.newPlainText("Label", szText);
            cm.setPrimaryClip(mClipData);
        } catch (Exception var5) {
            szResult = "SaveTextToClipboard ERROR " + var5.toString();
        }

        return szResult;
    }

    private void updateGallery(String filename) {
        try {
            ContentResolver localContentResolver = this.getContentResolver();
            File tempFile = new File(filename);
            ContentValues localContentValues = getImageContentValues(tempFile, System.currentTimeMillis());
            Uri uri = localContentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, localContentValues);

            copyFileAfterQ(this, localContentResolver, tempFile, uri);
            this.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    /**
     * 获取图片的ContentValue
     */
    public static ContentValues getImageContentValues(File paramFile, long timestamp) {
        ContentValues localContentValues = new ContentValues();
        if (Build.VERSION.SDK_INT >= 29) {
            localContentValues.put("relative_path", "DCIM/Camera");
        }
        localContentValues.put(MediaStore.Images.Media.TITLE, paramFile.getName());
        localContentValues.put(MediaStore.Images.Media.DISPLAY_NAME, paramFile.getName());
        localContentValues.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
        localContentValues.put(MediaStore.Images.Media.DATE_TAKEN, timestamp);
        localContentValues.put(MediaStore.Images.Media.DATE_MODIFIED, timestamp);
        localContentValues.put(MediaStore.Images.Media.DATE_ADDED, timestamp);
        localContentValues.put(MediaStore.Images.Media.ORIENTATION, 0);
        localContentValues.put(MediaStore.Images.Media.DATA, paramFile.getAbsolutePath());
        localContentValues.put(MediaStore.Images.Media.SIZE, paramFile.length());
        return localContentValues;
    }


    private static void copyFileAfterQ(Context context, ContentResolver localContentResolver, File tempFile, Uri localUri) throws IOException {
        if (Build.VERSION.SDK_INT >= 29 &&
                context.getApplicationInfo().targetSdkVersion >= 29) {
            //拷贝文件到相册的uri,android11及以上得这么干，否则不会显示。可以参考ScreenMediaRecorder的save方法
            OutputStream os = localContentResolver.openOutputStream(localUri, "w");
            Files.copy(tempFile.toPath(), os);
            os.close();
            tempFile.deleteOnExit();
        }
    }

    private void requestMyPermissions() {

        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            //没有授权，编写申请权限代码
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 100);
        } else {
            Log.d("   ", "requestMyPermissions: 有写SD权限");
        }
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            //没有授权，编写申请权限代码
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 100);
        } else {
            Log.d("----", "requestMyPermissions: 有读SD权限");
        }
    }

    public void TakePhoto(String type) {
        Intent intent;
        if (type.equals("takePhoto")) {
            intent = new Intent("android.media.action.IMAGE_CAPTURE");
            intent.putExtra("output", Uri.fromFile(new File(Environment.getExternalStorageDirectory(), "temp.jpg")));
            this.startActivityForResult(intent, 1);
        } else {
            intent = new Intent("android.intent.action.PICK", (Uri) null);
            intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
            this.startActivityForResult(intent, 2);
        }
    }

    public String bitmapToString(Bitmap bm) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        if (bm == null)
        {
            return "noop";
        }
        // 1.5M的压缩后在100Kb以内，测试得值,压缩后的大小=94486字节,压缩后的大小=74473字节
        // 这里的JPEG 如果换成PNG，那么压缩的就有600kB这样.
        // 实际项目中，可以根据需要考虑图片压缩以及压缩的质量。
        bm.compress(Bitmap.CompressFormat.JPEG, 40, baos);
        byte[] b = baos.toByteArray();
        // 在这里获取到图片转换后的字符串，然后就可以将这个字符串当做普通的String字符串参数传给后台
        // 如果有很多张图片要上传，那么可以考虑将转换后的Base64字符串添加到一个List里面，一并传给后台。
        return Base64.encodeToString(b, Base64.DEFAULT);
    }

    public  String createQRImage(String url, final int width, final int height, String oirginalid) {
        try {
            // 判断URL合法性
            if (url == null || "".equals(url) || url.length() < 1) {
                return "fail";
            }
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
            // 图像数据转换，使用了矩阵转换
            BitMatrix bitMatrix = new QRCodeWriter().encode(url, BarcodeFormat.QR_CODE, width, height, hints);
            int[] pixels = new int[width * height];
            // 下面这里按照二维码的算法，逐个生成二维码的图片，
            // 两个for循环是图片横列扫描的结果
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    if (bitMatrix.get(x, y)) {
                        pixels[y * width + x] = 0xff000000;
                    } else {
                        pixels[y * width + x] = 0xffffffff;
                    }
                }
            }
            Bitmap bitmap = Bitmap.createBitmap(pixels, 0, width, width, height, Bitmap.Config.RGB_565);

            File appDir = new File(Environment.getExternalStorageDirectory(), "Pictures");
            if (!appDir.exists()) {
                appDir.mkdirs();
            }
            String fileName = (new Date().getTime()) + ".png";
            File file = new File(appDir, fileName);
            try {
                if(!file.exists()){
                    file.createNewFile();
                }
                FileOutputStream fos = new FileOutputStream(file);
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
                bitmap.recycle();
                fos.flush();
                fos.close();
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                return "fail";
            } catch (IOException e) {
                e.printStackTrace();
                return "fail";
            }
            bitmap.recycle();
            // 其次把文件插入到系统图库
            String path = file.getAbsolutePath();
            updateGallery(path);
            return path;
        } catch (com.google.zxing.WriterException e) {
            e.printStackTrace();
            return "fail";
        }
    }
    protected static void launcherMainIfNecessary(Activity current) {
        if (null == sFirstInstance) {
            Intent intent = new Intent(current, AppActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
            current.startActivity(intent);
        }
    }

    public void OnGetMobId(String invitecode)
    {
        String[] str = invitecode.split("-");
        HashMap<String, Object> params = new HashMap<String, Object>();
        params.put("key1", str[0]);
        Scene s = new Scene();
        s.setPath("/AppActivity");
        s.setParams(params);
        MobLink.getMobID(s, new ActionListener<String>() {
            @Override
            public void onResult(String ID) {
                mobID = ID;
                String shareUrl = str[1];//"http://47.57.2.1:8989" ;//mobID;
                if (!TextUtils.isEmpty(mobID)) {
                    shareUrl += "?mobid=" + mobID;
                }
                createQRImage(shareUrl, 200,200, "url");
            }

            @Override
            public void onError(Throwable t) {
                Log.v("============", "error = " + t.getMessage());
            }
        });
    }

    public void OnGetShareUrl(String invitecode)
    {
        String[] str = invitecode.split("-");
        HashMap<String, Object> params = new HashMap<String, Object>();
        params.put("key1", str[0]);
        Scene s = new Scene();
        s.setPath("/AppActivity");
        s.setParams(params);
        MobLink.getMobID(s, new ActionListener<String>() {
            @Override
            public void onResult(String ID) {
                mobID = ID;
                String shareUrl = str[1];//"http://47.57.2.1:8989" ;//mobID;
                if (!TextUtils.isEmpty(mobID)) {
                    shareUrl += "?mobid=" + mobID;
                }
                JsbBridge.sendToScript(shareUrl, "true");
            }

            @Override
            public void onError(Throwable t) {
                Log.v("============", "error = " + t.getMessage());
            }
        });
    }

    @Override
    public void onReturnSceneData(Scene scene) {
        // 处理场景还原数据, 可以在这里做更新画面等操作
        Set keys = scene.getParams().keySet();
        invitecode = scene.getParams().get("key1").toString();
        SPUtils.getInstance().put("invitecode",invitecode);
        Log.v("-=-=-=-=--=-=-=-=-11111", invitecode);
    }
}

