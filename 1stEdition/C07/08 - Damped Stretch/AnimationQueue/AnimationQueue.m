//
//  AnimationQueue.m
//  HelloWorld
//
//  Created by Erica Sadun on 11/17/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import "AnimationQueue.h"
#import "Utility.h"

#define SAFE_PERFORM(THE_OBJECT, THE_SELECTOR, THE_ARG) {if ([THE_OBJECT respondsToSelector:THE_SELECTOR]) {[THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG];}}

@implementation AnimationQueue

// Complete the queue operations
- (void) end
{
    _active = NO;
    _complete = YES;
    
    if (_delegate)
        SAFE_PERFORM(_delegate, @selector(animationQueueDidComplete:), self);
}

// Begin the queue operations
- (BOOL) start
{
    // No ops == success and done
    if (!_queue.count)
    {
        [self end];
        return YES;
    }
    
    _complete = NO;
    _active = YES;

    // Pop
    DurationBlock *current = [_queue lastObject];
    [_queue removeLastObject];
    
    // Preliminary set-up; timing ignored
    if (current.tag == 1)
    {
        // The first block always operates immediately
        // Use it to set up initial conditions
        current.block();
        _completedStages++;
        
        [self start];
        return YES;
    }
    
    // Animate normally
    AnimationQueue __weak *weakself = self;
    [UIView animateWithDuration:current.duration animations:current.block completion:
     ^(BOOL finished)
     {
         if (finished)
             _completedStages++;
         
         [weakself start];
     }];

    return YES;
}

// Store block with timing onto the queue
- (BOOL) enqueue: (DurationBlock *) dBlock
{
    if (!_queue)
        _queue = [NSMutableArray array];
    
    if (!dBlock)
        return NO;
    
    if (![dBlock isKindOfClass:[DurationBlock class]])
    {
        NSLog(@"Error: You can only enqueue duration blocks");
        return NO;
    }
    
    [_queue insertObject:dBlock atIndex:0];
    dBlock.tag = _queue.count;
    
    return YES;
}

// Add animation block with timing request
- (BOOL) enqueue: (AnimationBlock) animationBlock withDuration: (NSTimeInterval) duration
{
    if (_active || _complete)
        return NO;
    
    _numberOfStages += 1;
    
    if (!_queue)
        _queue = [NSMutableArray array];
    
    if (!animationBlock)
        return NO;

    DurationBlock *dBlock = [DurationBlock block];
    dBlock.tag = _queue.count + 1;
    dBlock.duration = duration;
    dBlock.block = animationBlock;
    
    [_queue insertObject:dBlock atIndex:0];
    
    return YES;
}
@end
