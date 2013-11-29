/*
 
 Erica Sadun, http://ericasadun.com
 
 */

@import UIKit;
@import QuartzCore;
#import "ConstraintPack.h"


// Inspired by Steven Hepting
// https://gist.github.com/shepting/6025439

@interface KeyboardSpacingView : UIView
+ (instancetype) installToView: (UIView *) parent;
@end

@implementation KeyboardSpacingView
{
    NSLayoutConstraint *heightConstraint;
}

// Listen for keyboard
- (void) establishNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        // Fetch keyboard frame
        NSDictionary *userInfo = note.userInfo;
        CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGRect keyboardEndFrame = [self.superview convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.window];
        
        // Compare frame to window
        CGRect windowFrame = [self.superview convertRect:self.window.frame fromView:self.window];
        CGFloat heightOffset = (windowFrame.size.height - keyboardEndFrame.origin.y) - self.superview.frame.origin.y; // to be fixed in later betas

#define TEST_FOR_HARDWARE_KEYBOARD 0
#if TEST_FOR_HARDWARE_KEYBOARD
        // Using hardware?
        CGFloat keyboardHeight = keyboardEndFrame.size.height;
        BOOL isUsingHardwareKeyboard = (heightOffset < keyboardHeight);
        NSLog(@"Hardware: %@", isUsingHardwareKeyboard ? @"YES" : @"NO");
#endif
#undef TEST_FOR_HARDWARE_KEYBOARD

        heightConstraint.constant = heightOffset;
        [UIView animateWithDuration:duration animations:^{[self.superview layoutIfNeeded];}];

    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
     {
         // Reset to zero
         NSDictionary *userInfo = note.userInfo;
         CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
         heightConstraint.constant = 0;
         [UIView animateWithDuration:duration animations:^{[self.superview layoutIfNeeded];}];
     }];
}

// Stretch sides and bottom to superview
- (void) layoutView
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (!self.superview) return;
    
    for (NSString *constraintString in @[@"H:|[view]|", @"V:[view]|"])
    {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:@{@"view":self}];
        [self.superview addConstraints:constraints];
    }
    
    heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0.0f];
    [self addConstraint:heightConstraint];
}

// Preferred entry point for class, e.g.:
// KeyboardSpacingView *spacer = [KeyboardSpacingView installToView:self.view];
// STRETCH_H(textView);
// CONSTRAIN(@"V:|[textView][spacer]|", textView, spacer);

// keyboardSpacingViewForSuperview:
+ (instancetype) installToView: (UIView *) parent
{
    if (!parent) return nil;
    KeyboardSpacingView *view = [[self alloc] init];
    [parent addSubview:view];
    [view layoutView];
    [view establishNotificationHandlers];
    return view;
}
@end

#define TRIMSTRING(STRING)              ([STRING stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])

@interface NSString (Utility)
@end

@implementation NSString (Utility)
+ (NSString *) lorem:(NSUInteger) numberOfParagraphs
{
    NSString *urlString = [NSString stringWithFormat:@"http://loripsum.net/api/%0d/short/prude/plaintext", numberOfParagraphs];
    
    NSError *error;
    NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
    if (!string)
    {
        NSLog(@"Error: %@", error.localizedDescription);
        return nil;
    }
    return string;
}

+ (UIFont *) headlineFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UITextView *textView;
}

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR]

- (UIView *) accessoryView
{
    if (IS_IPAD) return nil;
    
    UIToolbar *t = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    UIBarButtonItem *spacer = SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil);
    UIBarButtonItem *bbi = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(endEditing));
    t.items = @[spacer, bbi];
    return t;
}

- (void) endEditing
{
    [textView resignFirstResponder];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];

    // Create text view
    textView = [[UITextView alloc] init];
    textView.editable = YES;
    textView.text = TRIMSTRING([NSString lorem:10]);
    if (IS_IPAD) textView.font = [NSString headlineFont];
    textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0); // To be fixed with top guide
    textView.inputAccessoryView = [self accessoryView];
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_H(textView, 0);
    
    // Add keyboard spacer
    KeyboardSpacingView *spacer = [KeyboardSpacingView installToView:self.view];
    spacer.backgroundColor = [UIColor lightGrayColor];
    CONSTRAIN(@"V:|[textView][spacer]|", textView, spacer);
    
    // Move to selection after keyboard appears
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {[textView scrollRangeToVisible:textView.selectedRange];}];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    tbvc.edgesForExtendedLayout = UIRectEdgeNone;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}