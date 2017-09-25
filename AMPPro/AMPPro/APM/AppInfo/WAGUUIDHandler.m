//
//  WAGUUIDHandler.m
//  WAGChat
//
//  Created by yanjing on 2017/9/19.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import "WAGUUIDHandler.h"
#import <Foundation/Foundation.h>
#import "WAGKeyChain.h"
#import <UIKit/UIDevice.h>

@implementation WAGUUIDHandler

static NSString * const KEY_IN_KEYCHAIN_UUID = @"唯一识别的KEY_UUID";
static NSString * const KEY_UUID = @"唯一识别的key_uuid";

+(void)saveUUID:(NSString *)UUID{
    
    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
    [usernamepasswordKVPairs setObject:UUID forKey:KEY_UUID];
   
    [WAGKeyChain save:KEY_IN_KEYCHAIN_UUID data:usernamepasswordKVPairs];
}

+(NSString *)readUUID{
    
    NSMutableDictionary *usernamepasswordKVPair = (NSMutableDictionary *)[WAGKeyChain load:KEY_IN_KEYCHAIN_UUID];
    
    return [usernamepasswordKVPair objectForKey:KEY_UUID];
    
}

+(void)deleteUUID{
    
    [WAGKeyChain delete:KEY_IN_KEYCHAIN_UUID];
    
}



+ (NSString *)appleIFV {
    if(NSClassFromString(@"UIDevice") && [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
        // only available in iOS >= 6.0
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return nil;
}

//+(NSString *)appleIFA {
//    NSString *ifa = nil;
//    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
//    if (ASIdentifierManagerClass) { // a dynamic way of checking if AdSupport.framework is available
//        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
//        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
//        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
//        NSUUID *advertisingIdentifier = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
//        ifa = [advertisingIdentifier UUIDString];
//    }
//    return ifa;
//}

@end
