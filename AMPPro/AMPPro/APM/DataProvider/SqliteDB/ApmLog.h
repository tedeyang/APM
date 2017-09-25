//
//  ApmLog.h
//  WAGChat
//
//  Created by yanjing on 2017/9/20.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApmLog : NSObject
@property(nonatomic,strong)  NSString *  source  ;
@property(nonatomic,strong)  NSString *  topic  ;
@property(nonatomic,strong)  NSDictionary *  content;

@end
