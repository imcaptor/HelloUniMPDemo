# HelloUniMPDemo

iOS 原生应用集成 UniMP SDK（小程序 SDK）的示例项目，演示如何在原生 App 中运行 UniApp 开发的小程序。

## 功能特性

- ✅ 打开本地内置小程序
- ✅ 预加载后打开小程序（提升秒开体验）
- ✅ 从网络下载并运行小程序
- ✅ 原生与小程序双向通信
- ✅ 自定义原生 Module 扩展
- ✅ 自定义原生 Component 组件
- ✅ 胶囊按钮菜单自定义
- ✅ 小程序后台运行支持

## 项目结构

```
HelloUniMPDemo/
├── AppDelegate.m          # SDK 初始化、生命周期管理
├── ViewController.m       # 小程序启动、下载、通信逻辑
├── CustomNavigationController.m  # 自定义导航控制器
├── SplashView.xib         # 自定义启动页
├── UniMP/
│   ├── Apps/              # 小程序 .wgt 资源包
│   │   ├── __UNI__11E9B73.wgt   # 示例小程序1
│   │   └── __UNI__CBDCE04.wgt   # 示例小程序2（扩展功能演示）
│   ├── Core/              # UniMP SDK 核心库
│   └── Extension/         # 原生扩展
│       ├── TestModule.m   # 自定义 Module 示例
│       └── TestMapComponent.m  # 自定义 Component 示例
└── Base.lproj/
    └── Main.storyboard    # 主界面
```

## 快速开始

### 1. 环境要求

- Xcode 12.0+
- iOS 11.0+
- UniMP SDK 4.75

### 2. 运行项目

1. 克隆仓库
```bash
git clone https://github.com/imcaptor/HelloUniMPDemo.git
```

2. 打开 Xcode 项目
```bash
cd HelloUniMPDemo
open HelloUniMPDemo.xcodeproj
```

3. 选择模拟器或真机，点击运行

### 3. 功能演示

运行后，主界面有三个按钮：

| 按钮 | 功能 |
|------|------|
| **打开小程序1** | 直接打开内置的示例小程序 |
| **预加载后打开小程序2** | 先预加载再显示，体验更流畅 |
| **网络下载运行小程序** | 输入 URL 下载并运行远程小程序 |

## 核心代码说明

### SDK 初始化

```objc
// AppDelegate.m
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化 SDK
    [DCUniMPSDKEngine initSDKEnvironmentWithLaunchOptions:options];
    
    // 注册自定义 Module
    [WXSDKEngine registerModule:@"TestModule" withClass:NSClassFromString(@"TestModule")];
    
    // 注册自定义 Component
    [WXSDKEngine registerComponent:@"testmap" withClass:NSClassFromString(@"TestMapComponent")];
    
    return YES;
}
```

### 打开小程序

```objc
// ViewController.m
DCUniMPConfiguration *configuration = [[DCUniMPConfiguration alloc] init];
configuration.enableBackground = YES;           // 支持后台运行
configuration.openMode = DCUniMPOpenModePush;   // 打开方式
configuration.enableGestureClose = YES;         // 手势关闭

[DCUniMPSDKEngine openUniMP:@"__UNI__11E9B73" configuration:configuration completed:^(DCUniMPInstance *instance, NSError *error) {
    // 处理结果
}];
```

### 网络下载小程序

```objc
// 从 URL 下载 .wgt 文件
// AppId 自动从文件名提取，例如：https://example.com/__UNI__11E9B73.wgt
[self downloadWgtFileFromURL:@"https://your-server.com/__UNI__XXXXX.wgt"];
```

### 原生与小程序通信

**小程序 → 原生：**
```objc
// ViewController.m
- (void)onUniMPEventReceive:(NSString *)appid event:(NSString *)event data:(id)data callback:(DCUniMPKeepAliveCallback)callback {
    NSLog(@"收到小程序事件: %@, 数据: %@", event, data);
    if (callback) {
        callback(@"原生返回的数据", NO);
    }
}
```

**原生 → 小程序：**
```objc
[self.uniMPInstance sendUniMPEvent:@"NativeEvent" data:@{@"msg": @"Hello from native"}];
```

### 自定义 Module

```objc
// TestModule.m
@implementation TestModule

// 暴露异步方法给 JS
WX_EXPORT_METHOD(@selector(testAsyncFunc:callback:))

- (void)testAsyncFunc:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback {
    // 实现原生功能
    if (callback) {
        callback(@"success", NO);
    }
}

// 暴露同步方法给 JS
WX_EXPORT_METHOD_SYNC(@selector(testSyncFunc:))

- (NSString *)testSyncFunc:(NSDictionary *)options {
    return @"success";
}

@end
```

## 小程序资源

### 内置小程序

- `__UNI__11E9B73.wgt` - UniApp 官方示例
- `__UNI__CBDCE04.wgt` - 扩展功能演示（[源码](https://github.com/dcloudio/UniMPExample)）

### 制作自己的小程序

1. 使用 HBuilderX 创建 UniApp 项目
2. 发行 → 原生 App-本地打包 → 生成本地打包 App 资源
3. 将生成的 `.wgt` 文件放入 `UniMP/Apps/` 目录
4. 或上传到服务器，通过"网络下载运行小程序"功能加载

## 相关链接

- [UniMP SDK 官方文档](https://nativesupport.dcloud.net.cn/UniMPDocs/)
- [UniApp 官网](https://uniapp.dcloud.net.cn/)
- [HBuilderX 下载](https://www.dcloud.io/hbuilderx.html)

## License

MIT License

