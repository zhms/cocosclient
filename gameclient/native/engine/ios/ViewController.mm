/****************************************************************************
 Copyright (c) 2013      cocos2d-x.org
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
#import "ViewController.h"
#include "cocos/bindings/event/EventDispatcher.h"
#include "cocos/platform/Device.h"
#include "SDKWrapper.h"
#include "cocos/bindings/jswrapper/SeApi.h"
//namespace {
//    cc::Device::Orientation _lastOrientation;
//}

@interface ViewController ()

@end

@implementation ViewController

- (BOOL) shouldAutorotate {
    return YES;
}

//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// Controls the application's preferred home indicator auto-hiding when this view controller is shown.
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinaØtor {
    cc::Device::Orientation orientation = cc::Device::getDeviceOrientation();
    // reference: https://developer.apple.com/documentation/uikit/uiinterfaceorientation?language=objc
    // UIInterfaceOrientationLandscapeRight = UIDeviceOrientationLandscapeLeft
    // UIInterfaceOrientationLandscapeLeft = UIDeviceOrientationLandscapeRight
    cc::EventDispatcher::dispatchOrientationChangeEvent((int) orientation);

    float    pixelRatio = cc::Device::getDevicePixelRatio();
    cc::EventDispatcher::dispatchResizeEvent(size.width * pixelRatio
                                             , size.height * pixelRatio);
    if (@available(iOS 13.0, *)) {
        CAMetalLayer *layer = (CAMetalLayer *)self.view.layer;
        CGSize tsize        = CGSizeMake(static_cast<int>(size.width * pixelRatio),static_cast<int>(size.height * pixelRatio));
        layer.drawableSize = tsize;
    } else {
        // Fallback on earlier versions
    }

}
- (void) showActionSheet
{
    NSLog(@" --- showActionSheet !!");

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"click album action!");
        [self persentImagePicker:1];
    }];

    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"click camera action!");
        [self persentImagePicker:2];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"click cancel action!");
    }];


    [alertController addAction:albumAction];
    [alertController addAction:cameraAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

//调用本地相册
- (void)persentImagePicker:(int)type{
    UIImagePickerController* view =[[UIImagePickerController alloc]init];
    view.delegate = self;

    view.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    view.allowsEditing = YES;
    [self presentViewController:view animated:YES completion:nil];

}

///取消选择图片（拍照）
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

///选择图片完成（从相册或者拍照完成）
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];///原图
    //获取修剪后的图片
    //UIImage *imageUp = [info objectForKey:UIImagePickerControllerEditedImage];
    //[self UpPic:imageUp];
    NSData *imageData = UIImageJPEGRepresentation(image, .6);
    NSLog(@" image url:%@",imageData.description);
    NSString *fun = @"skdmgr.OnLoginCallBack";
    NSString *id = @"111";
    NSString* eval = [NSString stringWithFormat:@"%@('%@')", fun, id];
    const char *c_eval = [eval UTF8String];
    se::ScriptEngine::getInstance()->evalString(c_eval);

    [picker dismissViewControllerAnimated:YES completion:nil];
}

///保存图片到本地相册
-(void)imageTopicSave:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {

    }
    else{
        ///图片未能保存到本地
    }
}

-(void)UpPic:(NSData *)imgdata
{
    NSDictionary *parameters = @{@"uid":@"111"};

    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
}

@end
