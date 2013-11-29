//
//  AppDelegate.h
//  TestProject
//
//  Created by Erica Sadun on 12/24/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) NSView *view;
@property (weak) IBOutlet NSLayoutConstraint *spacingConstraint;

@end
