

#import <Foundation/Foundation.h>
#import "AFNetworkActivityLoggerProtocol.h"


@interface AFNetworkActivityLogger : NSObject

/**
 The set of loggers current managed by the shared activity logger. By default, this includes one `AFNetworkActivityConsoleLogger`
 */
//@property (nonatomic, strong, readonly) NSSet <AFNetworkActivityLoggerProtocol> *loggers;

/**
 Returns the shared logger instance.
 */
+ (instancetype)sharedLogger;

/**
 Start logging requests and responses to all managed loggers.
 */
- (void)startLogging;

/**
 Stop logging requests and responses to all managed loggers.
 */
- (void)stopLogging;


/**
 Adds the given logger to be managed to the `loggers` set.
 */
- (void)addLogger:(id <AFNetworkActivityLoggerProtocol>)logger;

/**
 Removes the given logger from the `loggers` set.
 */
- (void)removeLogger:(id <AFNetworkActivityLoggerProtocol>)logger;

@end
