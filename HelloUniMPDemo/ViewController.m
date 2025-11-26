//
//  ViewController.m
//  HelloUniMPDemo
//
//  Created by XHY on 2019/12/28.
//  Copyright © 2019 DCloud. All rights reserved.
//

#import "ViewController.h"
#import "DCUniMP.h"

#define k_AppId1 @"__UNI__11E9B73" // uniapp 示例工程，在 HBuilderX 中新建 uniapp 示例项目可获取示例源码
#define k_AppId2 @"__UNI__CBDCE04" // 演示扩展 Module 及 Component 等功能示例小程序，工程 GitHub 地址： https://github.com/dcloudio/UniMPExample

@interface ViewController () <DCUniMPSDKEngineDelegate>

@property (nonatomic, weak) DCUniMPInstance *uniMPInstance; /**< 保存当前打开的小程序应用的引用 注意：请使用 weak 修辞，否则应在关闭小程序时置为 nil */
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask; /**< 下载任务 */
@property (nonatomic, copy) NSString *downloadedAppId; /**< 下载的小程序 AppId */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self checkUniMPResource:k_AppId1];
    [self checkUniMPResource:k_AppId2];
    [self setUniMPMenuItems];
}


/// 检查运行目录是否存在应用资源，不存在将应用资源部署到运行目录
- (void)checkUniMPResource:(NSString *)appid {
#warning 注意：isExistsUniMP: 方法判断的仅是运行路径中是否有对应的应用资源，宿主还需要做好内置wgt版本的管理，如果更新了内置的wgt也应该执行 releaseAppResourceToRunPathWithAppid 方法应用最新的资源
    if (![DCUniMPSDKEngine isExistsUniMP:appid]) {
        // 读取导入到工程中的wgt应用资源
        NSString *appResourcePath = [[NSBundle mainBundle] pathForResource:appid ofType:@"wgt"];
        if (!appResourcePath) {
            NSLog(@"资源路径不正确，请检查");
            return;
        }
        // 将应用资源部署到运行路径中
        NSError *error;
        if ([DCUniMPSDKEngine installUniMPResourceWithAppid:appid resourceFilePath:appResourcePath password:nil error:&error]) {
            NSLog(@"小程序 %@ 应用资源文件部署成功，版本信息：%@",appid,[DCUniMPSDKEngine getUniMPVersionInfoWithAppid:appid]);
        } else {
            NSLog(@"小程序 %@ 应用资源部署失败： %@",appid,error);
        }
    } else {
        NSLog(@"已存在小程序 %@ 应用资源，版本信息：%@",appid,[DCUniMPSDKEngine getUniMPVersionInfoWithAppid:appid]);
    }
}

/// 配置胶囊按钮菜单 ActionSheet 全局项（点击胶囊按钮 ··· ActionSheet弹窗中的项）
- (void)setUniMPMenuItems {
    
    DCUniMPMenuActionSheetItem *item1 = [[DCUniMPMenuActionSheetItem alloc] initWithTitle:@"将小程序隐藏到后台" identifier:@"enterBackground"];
    DCUniMPMenuActionSheetItem *item2 = [[DCUniMPMenuActionSheetItem alloc] initWithTitle:@"关闭小程序" identifier:@"closeUniMP"];
    
//     运行内置的 __UNI__CBDCE04 小程序，点击进去 小程序-原生通讯 页面，打开下面的注释，并将 item3 添加到 MenuItems 中，可以测试原生向小程序发送事件
//    DCUniMPMenuActionSheetItem *item3 = [[DCUniMPMenuActionSheetItem alloc] initWithTitle:@"SendUniMPEvent" identifier:@"SendUniMPEvent"];
    // 添加到全局配置
    [DCUniMPSDKEngine setDefaultMenuItems:@[item1,item2]];
    
    // 设置 delegate
    [DCUniMPSDKEngine setDelegate:self];
}

/// 启动小程序
- (IBAction)openUniMP:(id)sender {
    
    // 获取配置信息
    DCUniMPConfiguration *configuration = [[DCUniMPConfiguration alloc] init];
    
    // 配置启动小程序时传递的数据（目标小程序可在 App.onLaunch，App.onShow 中获取到启动时传递的数据）
    configuration.extraData = @{ @"launchInfo":@"Hello UniMP" };
    
    // 配置小程序启动后直接打开的页面路径 例：@"pages/component/view/view?action=redirect&password=123456"
//    configuration.path = @"pages/component/view/view?action=redirect&password=123456";
    
    // 开启后台运行
    configuration.enableBackground = YES;
    
    // 设置打开方式
    configuration.openMode = DCUniMPOpenModePush;
    
    // 启用侧滑手势关闭小程序
    configuration.enableGestureClose = YES;
    
    __weak __typeof(self)weakSelf = self;
    // 打开小程序
    [DCUniMPSDKEngine openUniMP:k_AppId1 configuration:configuration completed:^(DCUniMPInstance * _Nullable uniMPInstance, NSError * _Nullable error) {
        if (uniMPInstance) {
            weakSelf.uniMPInstance = uniMPInstance;
        } else {
            NSLog(@"打开小程序出错：%@",error);
        }
    }];
}

/// 预加载后打开小程序
- (IBAction)preloadUniMP:(id)sender {
    
    // 获取配置信息
    DCUniMPConfiguration *configuration = [[DCUniMPConfiguration alloc] init];
    
    // 开启后台运行
    configuration.enableBackground = YES;
    
    // 设置打开方式
    configuration.openMode = DCUniMPOpenModePresent;
    
    // 启用侧滑手势关闭小程序
    configuration.enableGestureClose = YES;
    
    
    __weak __typeof(self)weakSelf = self;
    // 预加载小程序
    [DCUniMPSDKEngine preloadUniMP:k_AppId2 configuration:configuration completed:^(DCUniMPInstance * _Nullable uniMPInstance, NSError * _Nullable error) {
        if (uniMPInstance) {
            weakSelf.uniMPInstance = uniMPInstance;
            // 预加载后打开小程序
            [uniMPInstance showWithCompletion:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"show 小程序失败：%@",error);
                }
            }];
        } else {
            NSLog(@"预加载小程序出错：%@",error);
        }
    }];
}

#pragma mark - DCUniMPSDKEngineDelegate
/// 胶囊按钮‘x’关闭按钮点击回调
- (void)closeButtonClicked:(NSString *)appid {
    NSLog(@"点击了 小程序 %@ 的关闭按钮",appid);
}

/// DCUniMPMenuActionSheetItem 点击触发回调方法
- (void)defaultMenuItemClicked:(NSString *)appid identifier:(NSString *)identifier {
    NSLog(@"标识为 %@ 的 item 被点击了", identifier);
    
    // 将小程序隐藏到后台
    if ([identifier isEqualToString:@"enterBackground"]) {
        __weak __typeof(self)weakSelf = self;
        [self.uniMPInstance hideWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"小程序 %@ 进入后台",weakSelf.uniMPInstance.appid);
            } else {
                NSLog(@"hide 小程序出错：%@",error);
            }
        }];
    }
    // 关闭小程序
    else if ([identifier isEqualToString:@"closeUniMP"]) {
        [self.uniMPInstance closeWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"小程序 closed");
            } else {
                NSLog(@"close 小程序出错：%@",error);
            }
        }];
    }
    // 向小程序发送消息
    else if ([identifier isEqualToString:@"SendUniMPEvent"]) {
        [self.uniMPInstance sendUniMPEvent:@"NativeEvent" data:@{@"msg":@"native message"}];
    }
}

/// 返回打开小程序时的自定义闪屏视图
- (UIView *)splashViewForApp:(NSString *)appid {
    UIView *splashView = [[[NSBundle mainBundle] loadNibNamed:@"SplashView" owner:self options:nil] lastObject];
    return splashView;
}

/// 小程序关闭回调方法
- (void)uniMPOnClose:(NSString *)appid {
    NSLog(@"小程序 %@ 被关闭了",appid);
    
    self.uniMPInstance = nil;
    
    // 可以在这个时机再次打开小程序
//    [self openUniMP:nil];
}


/// 小程序向原生发送事件回调方法
/// @param appid 对应小程序的appid
/// @param event 事件名称
/// @param data 数据：NSString 或 NSDictionary 类型
/// @param callback 回调数据给小程序
- (void)onUniMPEventReceive:(NSString *)appid event:(NSString *)event data:(id)data callback:(DCUniMPKeepAliveCallback)callback {
    NSLog(@"Receive UniMP:%@ event:%@ data:%@",appid,event,data);
    
    // 回传数据给小程序
    // DCUniMPKeepAliveCallback 用法请查看定义说明
    if (callback) {
        callback(@"native callback message",NO);
    }
}

#pragma mark - 网络下载小程序
/// 从网络下载并运行小程序
- (IBAction)downloadAndRunUniMP:(id)sender {
    // 默认下载地址（您可以替换为实际的 URL）
    NSString *downloadURL = @"https://example.com/__UNI__11E9B73.wgt";
    
    // 弹出输入框让用户输入下载地址（AppId 将自动从文件名提取）
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"下载小程序" 
                                                                   message:@"请输入小程序 .wgt 文件的下载地址\n(AppId 将自动从文件名中提取)" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"https://example.com/__UNI__11E9B73.wgt";
        textField.text = downloadURL;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" 
                                                           style:UIAlertActionStyleCancel 
                                                         handler:nil];
    
    UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"下载" 
                                                             style:UIAlertActionStyleDefault 
                                                           handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = alert.textFields[0].text;
        
        if (url.length > 0) {
            [self downloadWgtFileFromURL:url];
        } else {
            [self showAlertWithTitle:@"错误" message:@"请输入有效的 URL"];
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:downloadAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/// 下载 .wgt 文件（AppId 自动从 URL 文件名中提取）
- (void)downloadWgtFileFromURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        [self showAlertWithTitle:@"错误" message:@"URL 格式不正确"];
        return;
    }
    
    // 从 URL 中提取文件名作为 AppId（去掉 .wgt 后缀）
    NSString *appId = [url.lastPathComponent stringByDeletingPathExtension];
    if (appId.length == 0) {
        [self showAlertWithTitle:@"错误" message:@"无法从 URL 中提取 AppId，请确保 URL 以 .wgt 文件结尾"];
        return;
    }
    
    NSLog(@"从文件名提取的 AppId: %@", appId);
    
    // 显示加载提示
    UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:@"下载中" 
                                                                          message:[NSString stringWithFormat:@"正在下载小程序 %@\n请稍候...", appId]
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:loadingAlert animated:YES completion:nil];
    
    // 创建下载任务
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    __weak __typeof(self)weakSelf = self;
    self.downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 在 completion 回调中处理后续操作，确保弹窗完全关闭后再执行
            [loadingAlert dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    NSLog(@"下载失败：%@", error);
                    [weakSelf showAlertWithTitle:@"下载失败" message:error.localizedDescription];
                    return;
                }
                
                // 获取下载的临时文件路径
                if (location) {
                    [weakSelf installDownloadedWgt:location appId:appId];
                }
            }];
        });
    }];
    
    [self.downloadTask resume];
}

/// 安装下载的 .wgt 文件
- (void)installDownloadedWgt:(NSURL *)tempFileURL appId:(NSString *)appId {
    // 将临时文件复制到应用的 Documents 目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *destinationPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wgt", appId]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 如果文件已存在，先删除
    if ([fileManager fileExistsAtPath:destinationPath]) {
        [fileManager removeItemAtPath:destinationPath error:nil];
    }
    
    NSError *copyError;
    if ([fileManager copyItemAtURL:tempFileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&copyError]) {
        NSLog(@"文件保存成功：%@", destinationPath);
        
        // 安装小程序资源
        NSError *installError;
        if ([DCUniMPSDKEngine installUniMPResourceWithAppid:appId resourceFilePath:destinationPath password:nil error:&installError]) {
            NSLog(@"小程序 %@ 安装成功", appId);
            self.downloadedAppId = appId;
            
            [self showAlertWithTitle:@"安装成功" 
                             message:[NSString stringWithFormat:@"小程序 %@ 已安装，是否立即运行？", appId] 
                             actions:@[@"取消", @"运行"] 
                             handler:^(NSInteger index) {
                if (index == 1) {
                    [self openDownloadedUniMP:appId];
                }
            }];
        } else {
            NSLog(@"小程序安装失败：%@", installError);
            [self showAlertWithTitle:@"安装失败" message:installError.localizedDescription];
        }
    } else {
        NSLog(@"文件保存失败：%@", copyError);
        [self showAlertWithTitle:@"保存失败" message:copyError.localizedDescription];
    }
}

/// 打开下载的小程序
- (void)openDownloadedUniMP:(NSString *)appId {
    DCUniMPConfiguration *configuration = [[DCUniMPConfiguration alloc] init];
    configuration.enableBackground = YES;
    configuration.openMode = DCUniMPOpenModePush;
    configuration.enableGestureClose = YES;
    
    __weak __typeof(self)weakSelf = self;
    [DCUniMPSDKEngine openUniMP:appId configuration:configuration completed:^(DCUniMPInstance * _Nullable uniMPInstance, NSError * _Nullable error) {
        if (uniMPInstance) {
            weakSelf.uniMPInstance = uniMPInstance;
            NSLog(@"成功打开下载的小程序：%@", appId);
        } else {
            NSLog(@"打开小程序出错：%@", error);
            [weakSelf showAlertWithTitle:@"打开失败" message:error.localizedDescription];
        }
    }];
}

/// 显示简单提示框
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title 
                                                                   message:message 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" 
                                                       style:UIAlertActionStyleDefault 
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 显示带多个按钮的提示框
- (void)showAlertWithTitle:(NSString *)title 
                   message:(NSString *)message 
                   actions:(NSArray<NSString *> *)actionTitles 
                   handler:(void(^)(NSInteger index))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title 
                                                                   message:message 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    for (NSInteger i = 0; i < actionTitles.count; i++) {
        UIAlertActionStyle style = (i == 0) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
        UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitles[i] 
                                                         style:style 
                                                       handler:^(UIAlertAction * _Nonnull action) {
            if (handler) {
                handler(i);
            }
        }];
        [alert addAction:action];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
