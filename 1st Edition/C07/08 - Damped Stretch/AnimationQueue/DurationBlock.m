//
//  DurationBlock.m
//  HelloWorld
//
//  Created by Erica Sadun on 11/17/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import "DurationBlock.h"

@implementation DurationBlock
+ (instancetype) block
{
    DurationBlock *block = [[self alloc] init];
    block.duration = 0.15f;
    return block;
}
@end
