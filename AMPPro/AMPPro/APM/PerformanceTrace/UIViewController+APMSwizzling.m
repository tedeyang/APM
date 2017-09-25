//
//  UIViewController+APMSwizzling.m
//  WAGChat
//
//  Created by yanjing on 2017/8/27.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import "UIViewController+APMSwizzling.h"
#import <objc/runtime.h>
#import "WAGAPMCacheIOHandler.h"




@implementation UIViewController (APMSwizzling)

//#ifndef kUsingAPM

+ (void)load
{
    SEL origSel = @selector(viewDidAppear:);
    SEL swizSel = @selector(swiz_viewDidAppear:);
    [UIViewController swizzleMethods:[self class] originalSelector:origSel swizzledSelector:swizSel];
    

  }

//exchange implementation of two methods
+ (void)swizzleMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel
{
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method swizMethod = class_getInstanceMethod(class, swizSel);
    
    //class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        //origMethod and swizMethod already exist
        method_exchangeImplementations(origMethod, swizMethod);
    }
}


- (void)swiz_viewDidAppear:(BOOL)animated
{
//    NSLog(@"I am in - [swiz_viewDidAppear:]");
    //handle viewController transistion counting here, before ViewController instance calls its -[viewDidAppear:] method
    //需要注入的代码写在此处
    [[WAGAPMCacheIOHandler sharedInstance]fetchAPMWtihModelName:NSStringFromClass([self class])];
    [self swiz_viewDidAppear:animated];
}

//#endif


@end
