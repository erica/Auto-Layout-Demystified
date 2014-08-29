/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <Foundation/Foundation.h>

@interface NSObject (DebuggingExtensions)
@property (nonatomic, readonly) NSString *objectIdentifier;
@property (nonatomic, readonly) NSString *objectName;
@property (nonatomic, readonly) NSString *consoleDescription;
@end

