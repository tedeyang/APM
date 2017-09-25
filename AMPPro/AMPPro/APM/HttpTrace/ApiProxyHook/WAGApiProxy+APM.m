////
////  WAGApiProxy+APM.m
////  WAGChat
////
////  Created by yanjing on 2017/9/19.
////  Copyright © 2017年 wuage. All rights reserved.
////
//
//#import "WAGApiProxy+APM.h"
//#import "AFNetworkReachabilityManager.h"
//#import "WAGUserAgent.h"
//#import "PersistenceInstallation.h"
//
//@implementation WAGApiProxy (APM)
//
//static void * WAGNetworkRequestStartDate = &WAGNetworkRequestStartDate;
//
//+ (void)load
//{
//    SEL origSel = @selector(callApiWithRequest: success: fail:);
//    SEL swizSel = @selector(apm_callApiWithRequest: success: fail:);
//    [WAGApiProxy swizzleMethods:[self class] originalSelector:origSel swizzledSelector:swizSel];
//    
//}
//
////exchange implementation of two methods
//+ (void)swizzleMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel
//{
//    Method origMethod = class_getInstanceMethod(class, origSel);
//    Method swizMethod = class_getInstanceMethod(class, swizSel);
//    
//    //class_addMethod will fail if original method already exists
//    BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
//    if (didAddMethod) {
//        class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
//    } else {
//        //origMethod and swizMethod already exist
//        method_exchangeImplementations(origMethod, swizMethod);
//    }
//}
//
//- (NSNumber *)apm_callApiWithRequest:(NSURLRequest *)request success:(APCallback)success fail:(APCallback)fail
//{
//    
//    objc_setAssociatedObject(request, WAGNetworkRequestStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
//    void (^onSuccess)(id data) = ^(id data) {
//        
//        if (success) {
//            success(data);
//        }
//        
//        NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(request, WAGNetworkRequestStartDate)];
//
//        WAGURLResponse *responeObj = data;
//        NSDictionary *responseDic = responeObj.content;
//        BOOL isError = NO;
//        NSString * errorInfo = @"null";
//        if (responseDic) {
//            
//            for ( NSString * key in responseDic.allKeys) {
//                if ([key isEqualToString:@"code"]) {
//                    
//                    int code = ((NSNumber*)responseDic[key]).intValue;
//                    if (0 != code) {
//                        isError = YES;
//                        errorInfo = responseDic[@"message"];
//                    }
//                    break;
//                }else if([key isEqualToString:@"status"]){
//                    int code = ((NSNumber*)responseDic[key]).intValue;
//                    if (0 != code) {
//                        isError = YES;
//                        errorInfo = responseDic[@"msg"];
//                    }
//                    break;
//                    
//                }
//            }
//            
//        }
//        
//        if (isError) {
//            NSInteger   netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
//            NSInteger   responseStatusCode =  responeObj.status;
//            NSString *  url = request.URL.absoluteString ;
//            
//            NSString * idnum = [NSString stringWithFormat:@"%lu", responeObj.requestId];
//            NSString * errorStr = errorInfo;//[NSString stringWithFormat:@"%lu",(unsigned long)responseStatusCode];
//            NSString * requestSize = [NSString stringWithFormat:@"%lu",(unsigned long)responeObj.responseData.length];
//            
//            NSString * appInformation = [WAGUserAgent appInformation];
//            //    AFNetworkReachabilityStatusUnknown = -1,         未识别的网络
//            //    AFNetworkReachabilityStatusNotReachable = 0,          未连接 NotLink
//            //    AFNetworkReachabilityStatusReachableViaWWAN = 1,  2G,3G,4G mobileNet
//            //    AFNetworkReachabilityStatusReachableViaWiFi = 2,       wifi
//            NSString * logStr = [NSString stringWithFormat:@"**************************[ResponseCode:%ld] [URL:'%@'] [ElapsedTime: %.04f s] [NetStatus:%ld] [error: %@]", (long)responseStatusCode, url, elapsedTime , netStatus ,errorStr];
//            NSLog(@"%@",logStr);
//            
//            NSDictionary * dic = @{@"url":url?url:@"null",
//                                   @"responseCode":@(responseStatusCode).stringValue,
//                                   @"elapsedTime":@(elapsedTime).stringValue,
//                                   @"netStatus":@(netStatus).stringValue,
//                                   @"actionType":@(2).stringValue,
//                                   @"operationId": idnum,
//                                   @"error": errorStr?errorStr:@"null",
//                                   @"appInfo": appInformation?appInformation : @"null",
//                                   @"requestSize":requestSize
//                                   };
//            [[PersistenceInstallation sharedPersistence].ldb putObject:dic Source:@"net" callback:^(id data, int code, NSError *err) {
//                
//            }] ;
//        }
// 
// 
//
//        
// 
//    };
//    
//    void (^onFail)(id data) = ^(id data) {
//        
//        if (fail) {
//            fail(data);
//        }
//        
//        
//        NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(request, WAGNetworkRequestStartDate)];
//        WAGURLResponse *responeObj = data;
//        
//        NSInteger   netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
//        NSInteger   responseStatusCode = responeObj.status;
//        NSString *  url = request.URL.absoluteString ;
//        
//        NSString * idnum = [NSString stringWithFormat:@"%lu", responeObj.requestId];
//        NSString * errorStr = [NSString stringWithFormat:@"%lu",(unsigned long)responseStatusCode];
//        NSString * requestSize = [NSString stringWithFormat:@"%lu",(unsigned long)responeObj.responseData.length];
//        
//        NSString * appInformation = [WAGUserAgent appInformation];
//        NSString * logStr = [NSString stringWithFormat:@"**************************[ResponseCode:%ld] [URL:'%@'] [ElapsedTime: %.04f s] [NetStatus:%ld] [error: %@]", (long)responseStatusCode, url, elapsedTime , netStatus ,errorStr];
//        NSLog(@"%@",logStr);
//        
//        NSDictionary * dic = @{@"url":url?url:@"null",
//                               @"responseCode":@(responseStatusCode).stringValue,
//                               @"elapsedTime":@(elapsedTime).stringValue,
//                               @"netStatus":@(netStatus).stringValue,
//                               @"actionType":@(2).stringValue,
//                               @"operationId": idnum,
//                               @"error": errorStr?errorStr:@"null",
//                               @"appInfo": appInformation?appInformation : @"null",
//                               @"requestSize":requestSize
//                               };
//        
////        [[PersistenceInstallation sharedPersistence].ldb putObject:dic Source:@"net" callback:^(id data, int code, NSError *err) {
////            
////        }] ;
//        
//        [[PersistenceInstallation sharedPersistence].ldpb putSource:@"net" topic:@"chat" content:dic];
//     };
//   return  [self apm_callApiWithRequest:request success:onSuccess fail:onFail];
// }
//
////#endif
//@end

