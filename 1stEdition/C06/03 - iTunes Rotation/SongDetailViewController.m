/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "SongDetailViewController.h"
#import "Utility.h"

@implementation SongDetailViewController
{
    UIImageView *imageView;
    UILabel *titleLabel;
    UILabel *artistLabel;
    UIButton *buyButton;
    
    UIView *spacerTop, *spacerBottom, *spacerLeft, *spacerRight;
}

+ (instancetype) controllerWithData:(NSDictionary *)record
{
    SongDetailViewController *controller = [[self alloc] init];
    controller.record = record;
    return controller;
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    // check orientation
    BOOL layoutIsPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);

    // Remove constraints
    NSArray *views = @[imageView, titleLabel, artistLabel, buyButton, spacerTop, spacerBottom, spacerLeft, spacerRight];
    for (UIView *view in views)
    {
        for (NSLayoutConstraint *constraint in view.referencingConstraints)
            [constraint remove];
    }
    
    // Up the hug
    HUG(imageView, 750);
    
    if (IS_IPAD || layoutIsPortrait)
    {
        titleLabel.textAlignment = NSTextAlignmentCenter;
        artistLabel.textAlignment = NSTextAlignmentCenter;       
        titleLabel.preferredMaxLayoutWidth = 280;
        artistLabel.preferredMaxLayoutWidth = 280;

        // Align center
        for (UIView *view in @[imageView, titleLabel, artistLabel, buyButton])
            CENTER_H(view);
        
        // Build column
        CONSTRAIN(@"V:|[spacerTop(==spacerBottom)][imageView]-30-[titleLabel]-[artistLabel]-30-[buyButton][spacerBottom]|", imageView, titleLabel, artistLabel, buyButton, spacerTop, spacerBottom);
    }
    else
    {
        titleLabel.textAlignment = NSTextAlignmentRight;
        artistLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.preferredMaxLayoutWidth = 320;
        artistLabel.preferredMaxLayoutWidth = 320;
        
        // Center image view on left
        CENTER_V(imageView);
        
        // Right align title, artist, buy
        ALIGN_PAIR_RIGHT(titleLabel, artistLabel);
        ALIGN_PAIR_RIGHT(titleLabel, buyButton);

        // Build column
        CONSTRAIN(@"V:|[spacerTop(==spacerBottom)][titleLabel]-[artistLabel]-[buyButton][spacerBottom]|", titleLabel, artistLabel, buyButton, spacerTop, spacerBottom);
        
        // Space out horizontal
        CONSTRAIN(@"H:|[spacerLeft(==spacerRight)][imageView]-20-[titleLabel][spacerRight]|", spacerLeft, spacerRight, imageView, titleLabel);
    }
}

- (void) buy
{
    // no op
}

- (void) lazyLoadImage
{
    // Pull out highest artwork quality
    NSString *string100 = _record[@"artworkUrl100"];
    if (!string100)
        return;
    
    // Build request
    NSURL *url = [NSURL URLWithString:string100];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Fetch image data asynchronously
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (!data)
         {
             NSLog(@"Error retrieving image data: %@", error.localizedDescription);
             return;
         }
         
         UIImage *image = [UIImage imageWithData:data];
         if (!image)
         {
             NSLog(@"Error converting image data into image");
             return;
         }
         
         // Update image
         dispatch_async(dispatch_get_main_queue(), ^{imageView.image = image;});
     }];    
}

// Handle rotation animation
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        [self updateViewConstraints];
        [self.view layoutIfNeeded];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewConstraints];
}

// View constraints
- (void) peek
{
    [self.view addConstraintNames];
    [self.view addViewNames];
    [self.view showViewReport:YES];
    NSLog(@"%@", self.view.trace);
}

// Build label
- (UILabel *) labelWithTitle: (NSString *) aTitle
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.text = aTitle;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.nametag = aTitle;
    label.textColor = [UIColor whiteColor];
    return label;
}

// Build spacer
- (UIView *) spacer: (NSString *) name
{
    // Make it, Add it, Name it
    UIView *spacer = [[UIView alloc] init];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:spacer];
    NSString *string = [NSString stringWithFormat:@"SpacerView%@", name];
    spacer.nametag = string;
    return spacer;
}

- (void) buildSpacers
{
    // Build spacers
    spacerTop = [self spacer:@"Top"];
    spacerBottom = [self spacer:@"Bottom"];
    spacerLeft = [self spacer:@"Left"];
    spacerRight = [self spacer:@"Right"];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = AQUA_COLOR;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Peek", @selector(peek));
    self.view.nametag = @"RootView";

    // Reflect the selected track
    self.title = _record[@"trackName"];
    
    // Lazy load image
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self lazyLoadImage];
    
    // Labels
    titleLabel = [self labelWithTitle:_record[@"trackCensoredName"]];
    titleLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20.0f];
    artistLabel = [self labelWithTitle:_record[@"artistName"]];
    artistLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:16.0f];
    
    // Buy Button
    buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSNumber *number = _record[@"trackPrice"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSString *buttonString = [formatter stringFromNumber:number];
    [buyButton setTitle:buttonString forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:16];
    [buyButton addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];

    // Install views
    for (UIView *view in @[imageView, titleLabel, artistLabel, buyButton])
    {
        [self.view addSubview:view];
        PREPCONSTRAINTS(view);
    }
    
    // Add spacers
    [self buildSpacers];
}
@end
