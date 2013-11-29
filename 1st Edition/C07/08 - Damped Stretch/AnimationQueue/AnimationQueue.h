//
//  AnimationQueue.h
//  HelloWorld
//
//  Created by Erica Sadun on 11/17/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DurationBlock.h"

@interface AnimationQueue : NSObject
@property (nonatomic, readonly) int numberOfStages;
@property (nonatomic, readonly) int completedStages;

@property (nonatomic, readonly) BOOL active;
@property (nonatomic, readonly) BOOL complete;

@property (nonatomic, readonly) NSMutableArray *queue;
@property (nonatomic, weak) id delegate;

- (BOOL) start;
- (BOOL) enqueue: (AnimationBlock) animationBlock withDuration: (NSTimeInterval) duration;
@end
