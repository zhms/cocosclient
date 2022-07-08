/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2016 Chukong Technologies Inc.
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
#include "AppDelegate.h"
#import "ViewController.h"
#include "platform/ios/View.h"
#include "platform/Device.h"
#import "sys/utsname.h"
#include "Game.h"
#include "SDKWrapper.h"
#include "cocos/bindings/jswrapper/SeApi.h"
#import "ShareSDK/ShareSDK.h"
#import "MOBFoundation/MobSDK+Privacy.h"
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <ShareSDKExtension/SSEFriendsPaging.h>
#import <LineSDK/LineSDK.h>
#import <MOBFoundation/MobSDK+Privacy.h>
#import <MOBFoundation/MOBFoundation.h>
#import <ShareSDK/SSDKAuthViewManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MobLinkPro/MLSDKScene.h>
#import <MobLinkPro/UIViewController+MLSDKRestore.h>
#import <MobLinkPro/IMLSDKRestoreDelegate.h>
#import <MobLinkPro/MobLink.h>
#import <MobLinkPro/MLSDKScene.h>
#import <MobPush/MobPush.h>
@interface AppDelegate ()<IMLSDKRestoreDelegate>
@property (nonatomic, strong) MLSDKScene *scene;
@end
@interface AppDelegate ()<ISSERestoreSceneDelegate,LineSDKLoginDelegate>
@property (strong, nonatomic) NSDictionary *parameters;
@end
@implementation AppDelegate

Game *      game = nullptr;
ViewController *gameViewController = nullptr;

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[LineSDKLogin sharedInstance]setDelegate:self];
    [ShareSDK setRestoreSceneDelegate:self];
    [ShareSDK setShareVideoEnable:YES];
    [ShareSDK setAutoLogAppEventsEnabled:YES];
    [ShareSDK setBanGetIdfa:YES];
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

    [[SDKWrapper shared] application:application didFinishLaunchingWithOptions:launchOptions];
    // Add the view controller's view to the window and display.
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.window   = [[UIWindow alloc] initWithFrame:bounds];

    // Should create view controller first, cc::Application will use it.
    _viewController                           = [[ViewController alloc] init];
    _viewController.view                      = [[View alloc] initWithFrame:bounds];
    _viewController.view.contentScaleFactor   = UIScreen.mainScreen.scale;
    _viewController.view.multipleTouchEnabled = true;
    [self.window setRootViewController:_viewController];
    gameViewController=_viewController;
    // cocos2d application instance
    game = new Game(bounds.size.width, bounds.size.height);
    game->init();
    [self.window makeKeyAndVisible];
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
        [platformsRegister setupLineAuthType:(SSDKAuthorizeTypeBoth)];
        [platformsRegister setupFacebookWithAppkey:@"441880973935033" appSecret:@"bc76b34584429245b5de939a83b3acfa" displayName:@"999.bet"];
    }];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [[UIApplication sharedApplication] addObserver:self forKeyPath:@"idleTimerDisabled" options:NSKeyValueObservingOptionNew context:nil];

    [MobLink setDelegate:self];

    //[[LineSDKAPI allor] initWithConfiguration:[LineSDKConfiguration defaultConfig]];

    // 设置推送环境

#ifdef DEBUG
    [MobPush setAPNsForProduction:NO];
#else
    [MobPush setAPNsForProduction:YES];
#endif

    //MobPush推送设置（获得角标、声音、弹框提醒权限）
    MPushNotificationConfiguration *configuration = [[MPushNotificationConfiguration alloc] init];
    configuration.types = MPushAuthorizationOptionsBadge | MPushAuthorizationOptionsSound | MPushAuthorizationOptionsAlert;
    [MobPush setupNotification:configuration];

    //此方法需要在AppDelegate的 didFinishLaunchingWithOptions 方法里面注册 可参考Demo
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:MobPushDidReceiveMessageNotification object:nil];

    return YES;
}

- (void)didReceiveMessage:(NSNotification *)notification
{
    MPushMessage *message = notification.object;

         // 推送相关参数获取示例请在各场景回调中对参数进行处理
         //     NSString *body = message.notification.body;
     //     NSString *title = message.notification.title;
     //     NSString *subtitle = message.notification.subTitle;
     //     NSInteger badge = message.notification.badge;
     //     NSString *sound = message.notification.sound;
     //     NSLog(@"收到通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge:%ld,\nsound:%@,\n}",body, title, subtitle, (long)badge, sound);
    switch (message.messageType)
    {
        case MPushMessageTypeCustom:
        {// 自定义消息回调
        }
            break;
        case MPushMessageTypeAPNs:
        {// APNs回调
        }
            break;
        case MPushMessageTypeLocal:
        {// 本地通知回调

        }
            break;
        case MPushMessageTypeClicked:
        {// 点击通知回调

        }
        default:
            break;
    }
}

+(void)facebookLogin:(NSString*)deviceId{

    [MobSDK uploadPrivacyPermissionStatus:YES onResult:^(BOOL success) {}];
    [ShareSDK getUserInfo:SSDKPlatformTypeFacebook onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        switch (state) {
            case SSDKResponseStateFail:
                NSLog(@"%@",error.debugDescription);
                break;
            case SSDKResponseStatePlatformCancel:
                NSLog(@"%@",error.debugDescription);
                break;
                case SSDKResponseStateSuccess:
                NSLog(@"%@",[user.credential rawData]);
                NSString *fun = @"skdmgr.OnLoginCallBack";
                NSString *id = user.uid;
                NSString* eval = [NSString stringWithFormat:@"%@('%@')", fun, id];
                const char *c_eval = [eval UTF8String];
                se::ScriptEngine::getInstance()->evalString(c_eval);
                break;
            break;
        }
    }];
}
+(void)LineLogin:(NSString*)deviceId{
    [[LineSDKLogin sharedInstance] startLoginWithPermissions:@[@"profile",@"friend", @"groups"]];

}


//实现带有场景参数的初始化方法，并根据场景参数还原该控制器：
-(instancetype)initWithMobLinkScene:(MLSDKScene *)scene
{
    if (self = [super init]) {
        self.scene = scene;
    }
    return self;
}

+ (void)getMobId:(NSString*)Invitedstr
{
    NSArray *aArray = [ Invitedstr componentsSeparatedByString:@"-"];
    // 构造自定义参数（可选）
    NSMutableDictionary *customParams = [NSMutableDictionary dictionary];
    customParams[@"key1"] = aArray[0];
    // 根据路径、来源以及自定义参数构造scene(3.0.0以下版本)
    //MLSDKScene *scene = [[MLSDKScene alloc] initWithMLSDKPath:@"控制器对应的路径" source:nil params:customParams];
    // 根据路径、自定义参数构造scene （3.0.0以上版本，推荐）
    MLSDKScene *scene = [MLSDKScene sceneForPath:@"已在Mob后台配置的需要还原的控制器对应的路径" params:customParams];

    // 请求MobId
   [MobLink getMobId:scene result:^(NSString *mobId, NSString *domain, NSError *error) {
        NSString *url = [aArray[1] stringByAppendingString: @"?mobid=" ];
        url = [url stringByAppendingString:mobId];
        [self SaveUrlToImage:url];
    }];
}

+ (void)getMobIdUrl:(NSString*)Invitedstr
{
    NSArray *aArray = [ Invitedstr componentsSeparatedByString:@"-"];
    // 构造自定义参数（可选）
    NSMutableDictionary *customParams = [NSMutableDictionary dictionary];
    customParams[@"key1"] = aArray[0];
    // 根据路径、来源以及自定义参数构造scene(3.0.0以下版本)
    //MLSDKScene *scene = [[MLSDKScene alloc] initWithMLSDKPath:@"控制器对应的路径" source:nil params:customParams];
    // 根据路径、自定义参数构造scene （3.0.0以上版本，推荐）
    MLSDKScene *scene = [MLSDKScene sceneForPath:@"已在Mob后台配置的需要还原的控制器对应的路径" params:customParams];

    // 请求MobId
   [MobLink getMobId:scene result:^(NSString *mobId, NSString *domain, NSError *error) {
        NSString *url = [aArray[1] stringByAppendingString: @"?mobid=" ];
        url = [url stringByAppendingString:mobId];
        NSString *fun = @"skdmgr.OnMobIdUrlBack";
        NSString* eval = [NSString stringWithFormat:@"%@('%@')", fun, url];
        const char *c_eval = [eval UTF8String];
        se::ScriptEngine::getInstance()->evalString(c_eval);
    }];
}

+(void)getInvited:(NSString*)Invitedstr
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"invited.plist"];
    
    NSDictionary*dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString *fun = @"skdmgr.SetInviteCode";
    NSString *id = dict[@"code"];
    NSString* eval = [NSString stringWithFormat:@"%@('%@')", fun, id];
    NSLog(@"invited code = :%@",id);
    const char *c_eval = [eval UTF8String];
    se::ScriptEngine::getInstance()->evalString(c_eval);
}

- (void) IMLSDKWillRestoreScene:(MLSDKScene *)scene Restore:(void (^)(BOOL, RestoreStyle))restoreHandler
{
    NSLog(@"Will Restore Scene - Path:%@",scene.params[@"key1"]);
    NSString *code = scene.params[@"key1"];
    
    NSString *fun = @"skdmgr.SetInviteCode";
    NSString *id = scene.params[@"key1"];
    NSString* eval = [NSString stringWithFormat:@"%@('%@')", fun, id];
    NSLog(@"invited code = :%@",id);
    const char *c_eval = [eval UTF8String];
    se::ScriptEngine::getInstance()->evalString(c_eval);
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"invited.plist"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:id forKey:@"code"];

    [dict writeToFile:filePath  atomically:YES];

    restoreHandler(YES, MLDefault);

}

- (void)IMLSDKCompleteRestore:(MLSDKScene *)scene
{
    NSLog(@"Complete Restore -Path:%@",scene.path);
}

- (void)IMLSDKNotFoundScene:(MLSDKScene *)scene
{

}

+(void)_iosOpenPhotoAlbums:(NSString*)deviceId
{
    [gameViewController showActionSheet];
}

+(void)SaveTextToClipboard:(NSString*)textstring
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = textstring;
}

+(void)SaveUrlToImage:(NSString*)UrlString{
    // 1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2. 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 3. 将字符串转换成NSData
    NSData *data = [UrlString dataUsingEncoding:NSUTF8StringEncoding];
    // 4. 通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    
    // 5. 获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    UIImage *image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];//重绘二维码,使其显示清晰
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

+(void) image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    NSString* result;
    if(error)
    {
        result = @"图片保存到相册失败!";
    }
    else
    {
        result = @"图片保存到相册成功!";
    }
    //NSString *fun = @"skdmgr.OnLoginCallBack";
    //NSString *id = user.uid;
    //NSString* eval = [NSString stringWithFormat:@"%@('%@')", fun, id];
    //const char *c_eval = [eval UTF8String];
    //se::ScriptEngine::getInstance()->evalString(c_eval);
}

/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (void)keepIdleTimerDisabled {
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [[UIApplication sharedApplication] addObserver:self forKeyPath:@"idleTimerDisabled" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (![UIApplication sharedApplication].idleTimerDisabled) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void)dealloc{
    [[UIApplication sharedApplication] removeObserver:self forKeyPath:@"idleTimerDisabled"];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [super dealloc];
}

UIInterfaceOrientationMask orientation = UIInterfaceOrientationMaskLandscape;
//
//
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return orientation;
}
+(NSString*)getDeviceId:(NSString*)deviceId
{
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    return  currentDeviceId;
}
// 获取设备型号然后手动转化为对应名称
+(NSString *)getDeviceName:(NSString*)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceString isEqualToString:@"iPhone12,8"])   return @"iPhone SE 2";
    if ([deviceString isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceString isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceString isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceString isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";

    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";

    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])    return @"iPad 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad6,12"])    return @"iPad 5 (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,1"])     return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])     return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])     return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])     return @"iPad Pro 10.5 inch (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,5"])     return @"iPad 6th generation";
    if ([deviceString isEqualToString:@"iPad7,6"])     return @"iPad 6th generation";
    if ([deviceString isEqualToString:@"iPad8,1"])     return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,2"])     return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,3"])     return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,4"])     return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,5"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,6"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,7"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,8"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,9"])     return @"iPad Pro (11-inch) (2rd generation)";
    if ([deviceString isEqualToString:@"iPad8,10"])   return @"iPad Pro (11-inch) (2rd generation)";
    if ([deviceString isEqualToString:@"iPad8,11"])   return @"iPad Pro (12.9-inch) (4rd generation)";
    if ([deviceString isEqualToString:@"iPad8,12"])   return @"iPad Pro (12.9-inch) (4rd generation)";

    return deviceString;
}
+ (void)setOrientation:(NSString*)dir {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationUnknown] forKey:@"orientation"];
    NSLog(@"setOrientation v is %@",dir);
//    cc::Vec2 logicSize  = game->getViewLogicalSize();
//    NSLog(@"logicSize is %f %f",logicSize.x,logicSize.y);
//    float pixelRatio = cc::Device::getDevicePixelRatio();
//    NSLog(@"pixelRatio is %f",pixelRatio);
//    cc::EventDispatcher::dispatchResizeEvent(pixelRatio*logicSize.x,pixelRatio*1280*logicSize.x/720);
//    game->_viewLogicalSize= cc::Vec2(pixelRatio*844,pixelRatio*1280*844/720);
    if ([dir isEqualToString:@"V"]) {
        orientation = UIInterfaceOrientationMaskPortrait;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    } else {
        orientation = UIInterfaceOrientationMaskLandscape;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [[SDKWrapper shared] applicationWillResignActive:application];
    game->onPause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[SDKWrapper shared] applicationDidBecomeActive:application];
    game->onResume();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [[SDKWrapper shared] applicationDidEnterBackground:application];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [[SDKWrapper shared] applicationWillEnterForeground:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    game->onClose();
    [[SDKWrapper shared] applicationWillTerminate:application];

    delete game;
    game = nullptr;
}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    if ([[LineSDKLogin sharedInstance] handleOpenURL:userActivity.webpageURL]) {
        return YES;
    }
    // Your other code to handle universal links and/or user activities.
}

- (void)didLogin:(LineSDKLogin *)login
    credential:(LineSDKCredential *)credential
        profile:(LineSDKProfile *)profile
        error:(NSError *)error
{
    if (error) {
        // Login failed with an error. Use the error parameter to identify the problem.
        NSLog(@"Error111: %@", error.localizedDescription);
    }
    else {

        // Login success. Extracts the access token, user profile ID, display name, status message, and profile picture.
        NSString * accessToken = credential.accessToken.accessToken;
        NSString * userID = profile.userID;
        NSString * displayName = profile.displayName;
        NSString * statusMessage = profile.statusMessage;
        NSURL * pictureURL = profile.pictureURL;

        NSString * pictureUrlString;

        NSString *fun = @"skdmgr.OnLoginCallBack";
        NSString *id = userID;
        NSString* eval = [NSString stringWithFormat:@"%@('%@')", fun, id];
        const char *c_eval = [eval UTF8String];
        se::ScriptEngine::getInstance()->evalString(c_eval);

    }
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
{
    [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url options:options];
    return [[LineSDKLogin sharedInstance] handleOpenURL:url];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDKWrapper shared] applicationDidReceiveMemoryWarning:application];
    cc::EventDispatcher::dispatchMemoryWarningEvent();
}

@end



