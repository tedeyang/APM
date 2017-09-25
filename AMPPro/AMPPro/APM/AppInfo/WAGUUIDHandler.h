//
//  WAGUUIDHandler.h
//  WAGChat
//
//  Created by yanjing on 2017/9/19.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WAGUUIDHandler : NSObject
/**
 *   存储 UUID
 *
 *     */
+(void)saveUUID:(NSString *)UUID;

/**
 *  读取UUID *
 *
 */
+(NSString *)readUUID;

/**
 *    删除数据
 */
+(void)deleteUUID;


+(NSString *)appleIFV;


@end
