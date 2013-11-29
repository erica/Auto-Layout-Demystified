/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import Foundation;

// If you use in production code, please make sure to add
// namespace indicators to class category methods

@interface NSObject (DebuggingExtensions)
@property (nonatomic, readonly) NSString *objectIdentifier;
@property (nonatomic, readonly) NSString *objectName;
@property (nonatomic, readonly) NSString *consoleDescription;
@end

