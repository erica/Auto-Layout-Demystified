/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "Utility.h"

@interface CustomTableViewCell : UITableViewCell
@property (nonatomic) CGPoint cellSize;
@property (nonatomic) UILabel *customLabel;
@end

@implementation CustomTableViewCell
+ (BOOL) requiresConstraintBasedLayout
{
    return YES;
}

- (void) updateConstraints
{
    [super updateConstraints];
    
    for (UIView *view in self.contentView.subviews)
    {
        NSArray *constraints = [self.contentView constraintsReferencingView:view];
        for (NSLayoutConstraint *constraint in constraints)
            [constraint remove];
    }
    
    CONSTRAIN(@"V:|-[_customLabel]-|", _customLabel);
    CONSTRAIN(@"H:|-[_customLabel]-|", _customLabel);
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return self;
    
    _customLabel = [[UILabel alloc] init];
    _customLabel.numberOfLines = 0;
    PREPCONSTRAINTS(_customLabel);
    [self.contentView addSubview:_customLabel];
    
    [self setNeedsUpdateConstraints];
    return self;
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

+ (UIFont *) bodyFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}
@end

@interface TestBedViewController : UITableViewController
@end

@implementation TestBedViewController
{
    NSMutableArray *array;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    for (NSAttributedString *string in array)
        string.nametag = nil;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString *aString = array[indexPath.row];
    if (aString.nametag)
        return [aString.nametag floatValue];
    
    CGRect r = [aString boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 4 * AQUA_INDENT, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    r.size.height += 4 * AQUA_INDENT;
    aString.nametag = @(r.size.height).stringValue;
    return r.size.height;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.customLabel.attributedText = [array objectAtIndex:indexPath.row];
    return cell;
}

- (void) updateContentSize
{
    for (NSAttributedString *s in array) s.nametag = nil;
    [self.tableView reloadData];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @
    [
    ];
    
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
    pstyle.lineBreakMode = NSLineBreakByWordWrapping;
    pstyle.alignment = NSTextAlignmentJustified;
    
    int numberOfItems = 50;
    NSArray *paras = [[NSString lorem:numberOfItems] componentsSeparatedByString:@"\n\n"];
    array = [NSMutableArray array];
    for (int i = 0; i < numberOfItems; i++)
    {
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc]  initWithString:TRIMSTRING(paras[i])];
        NSRange fullRange = NSMakeRange(0, s.length);
        [s addAttribute:NSParagraphStyleAttributeName value:pstyle range:fullRange];
        [s addAttribute:NSFontAttributeName value:[NSString bodyFont] range:fullRange];
        [s addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:fullRange];
        [array addObject:s];
    }
    
    [self.tableView reloadData];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic) UIWindow *window;
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    srandom(time(0));

	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    tbvc.edgesForExtendedLayout = UIRectEdgeNone;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    _window.rootViewController = nav;
    _window.tintColor = [UIColor blackColor];
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