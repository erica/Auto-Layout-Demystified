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
- (IBAction)listConstraints:(id)sender;
- (IBAction)viewConstraints:(id)sender;
- (IBAction)fanViews:(id)sender;
- (IBAction)stackViews:(id)sender;
@end
