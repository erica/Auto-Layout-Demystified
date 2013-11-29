/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "CustomTableViewCell.h"
#import "Utility.h"

#define RECTCENTER(_rect_) CGPointMake(CGRectGetMidX(_rect_), CGRectGetMidY(_rect_))

@implementation CustomTableViewCell
{
    UILabel *customLabel;
    UIImageView *customImageView;
    UIImageView *progressImageView;
    
    CGFloat percent;
}

// Override textLabel
- (UILabel *) textLabel
{
    return customLabel;
}

// Override imageView
- (UIImageView *) imageView
{
    return customImageView;
}

#pragma mark - Percentage playback support

// Draw the percent as an arc that fills up
- (UIImage *) percentImage
{
    CGSize size = CGSizeMake(20, 20);
    CGRect rect = (CGRect){.size = size};

    UIBezierPath *path;
    UIGraphicsBeginImageContext(size);

    path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [[UIColor darkGrayColor] set];
    [path fill];
    
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, 8, 8)];
    [[UIColor lightGrayColor] set];
    [path fill];
    
    path = [UIBezierPath bezierPathWithArcCenter:RECTCENTER(rect) radius:6 startAngle:(0 * M_PI) endAngle:(2 * M_PI * percent) clockwise:YES];
    [ORANGE_COLOR set];
    path.lineWidth = 4;
    [path stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void) setPercent:(CGFloat) thePercent
{
    percent = thePercent;
    if (thePercent == 0)
    {
        progressImageView.image = nil;
        return;
    }
    progressImageView.image = [self percentImage];
}

- (CGFloat) percent
{
    return percent;
}

#pragma mark - Creation and Layout

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
    
    HUG(customLabel, 750);
    ALIGN_CENTER(customLabel);
    
    HUG(customImageView, 750);
    ALIGN_CENTERRIGHT(customImageView, 8);
    
    HUG(_buyButton, 750);
    ALIGN_CENTERLEFT(_buyButton, AQUA_SPACE);
    
    LAYOUT_V(progressImageView, 4, _buyButton);
    CONSTRAIN_SIZE(progressImageView, 20, 20);
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return self;
    
    self.contentView.backgroundColor = AQUA_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // Add Label
    customLabel = [[UILabel alloc] init];
    customLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    customLabel.numberOfLines = 0;
    customLabel.textAlignment = NSTextAlignmentCenter;
    customLabel.preferredMaxLayoutWidth = 150;
    customLabel.textColor = [UIColor whiteColor];
    customLabel.backgroundColor = [UIColor clearColor];
    PREPCONSTRAINTS(customLabel);
    [self.contentView addSubview:customLabel];
    
    // Add Image View
    customImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:customImageView];
    PREPCONSTRAINTS(customImageView);
    
    // Add Buy Button
    _buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.contentView addSubview:_buyButton];
    PREPCONSTRAINTS(_buyButton);
    
    // Add Progress Image View
    progressImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:progressImageView];
    PREPCONSTRAINTS(progressImageView);
        
    [self setNeedsUpdateConstraints];
    return self;
}
@end

