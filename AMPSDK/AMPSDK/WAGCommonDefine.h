//
//  WAGCommonDefine.h
//  WuAGeRoadTrain
//
//  Created by cg_wuage on 16/9/20.
//  Copyright © 2016年 wuage. All rights reserved.
//

#ifndef WAGCommonDefine_h
#define WAGCommonDefine_h

// Domain
// #define WAGDOMAIN_TEST          // 测试环境
// #define WAGDOMAIN_PRERELEASE    // 预发环境

// Frame
#define kiPhone6ScreenWidth     (750.0 / 2)
#define kiPhone6ScreenHeight    (1334.0 / 2)
#define kScaleWFor6 ([UIScreen mainScreen].bounds.size.width / kiPhone6ScreenWidth)
#define kScaleHFor6 ([UIScreen mainScreen].bounds.size.height / kiPhone6ScreenHeight)

// Control Define.
#define StatusBar_HEIGHT 20
#define NavigationBar_HEIGHT 44
#define NavigationBarIcon 20
#define TabBar_HEIGHT 49
#define TabBarIcon 30
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//
//替换NSLog来使用，debug模式下可以打印很多方法名，行信息。
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// System Define.
//获取版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]

//获取当前语言
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Memory Define.
//使用ARC和不使用ARC
#if __has_feature(objc_arc)
//compiling with ARC
#else
// compiling without ARC
#endif

#pragma mark - common functions
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

//释放一个对象
#define SAFE_DELETE(P) if(P) { [P release], P = nil; }

#define SAFE_RELEASE(x) [x release];x=nil


// Image Define.
//读取本地图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

//定义UIImage对象
//#define ImageNamed(_pointer) [UIImage imageNamed:[UIUtil imageName:_pointer]]

//前两种宏性能高，省内存
//第三个没有必要使用，因为我们可以使用Xcode的插件

// Color Define.
// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

//带有RGBA的颜色设置
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

//背景色
#define BACKGROUND_COLOR [UIColor colorWithRed:242.0/255.0 green:236.0/255.0 blue:231.0/255.0 alpha:1.0]

//清除背景色
#define CLEARCOLOR [UIColor clearColor]

#pragma mark - color functions
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]



// ARC解循环引用
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

//Block helper

#define WEAK_REF(obj) \
__weak typeof(obj) weak_##obj = obj; \

#define STRONG_REF(obj) \
__strong typeof(weak_##obj) obj = weak_##obj; \

#define PREP_BLOCK WEAK_REF(self);

#define BEGIN_BLOCK \
STRONG_REF(self); \
if(self != nil){ \

#define END_BLOCK \
} \

//根据屏幕尺寸判断机型

#define iPhone4 ((int)[UIScreen mainScreen].bounds.size.height == 480)
#define iPhone5 ((int)[UIScreen mainScreen].bounds.size.height == 568)
#define iPhone6 ((int)[UIScreen mainScreen].bounds.size.height == 667)
#define iPhone6p ((int)[UIScreen mainScreen].bounds.size.height == 736)

// LineWidth
#define kMinLineWidth (1.0f / [UIScreen mainScreen].scale)

//屏幕适配因子  根据iPhone尺寸
//#define kScaleW ([UIScreen mainScreen].bounds.size.width/375.0)
//#define kScaleH ([UIScreen mainScreen].bounds.size.height/667.0)
//Font
#define FontForHFor6(numf) [UIFont systemFontOfSize:numf * kScaleWFor6]
#define FontForBFor6(numf) [UIFont boldSystemFontOfSize:numf * kScaleWFor6]

//iPhone6
#define WidthForScale6(flout) (flout * kScaleWFor6)
#define HeightForScale6(flout) (flout * kScaleHFor6)

#endif /* WAGCommonDefine_h */



