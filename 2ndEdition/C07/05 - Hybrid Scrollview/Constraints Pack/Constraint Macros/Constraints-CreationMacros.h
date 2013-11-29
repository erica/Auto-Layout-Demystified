/*
 *
 *
 CREATING CONSTRAINTS
 *
 *
 */

#pragma mark - Position X & Y (not leading & Y)
#define CONSTRAINT_POSITIONING_X(VIEW, X) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeLeft relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeLeft multiplier: 1.0f constant: X]
#define CONSTRAINT_POSITIONING_LEADING(VIEW, X) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeLeading multiplier: 1.0f constant: X]
#define CONSTRAINT_POSITIONING_Y(VIEW, Y) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeTop relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeTop multiplier: 1.0f constant: Y]
#define CONSTRAINTS_POSITION(VIEW, X, Y) @[CONSTRAINT_POSITIONING_X(VIEW, X), CONSTRAINT_POSITIONING_Y(VIEW, Y)]

#pragma mark - Size
// Width and Height
#define CONSTRAINT_SETTING_WIDTH(VIEW, WIDTH) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationEqual toItem:nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1.0f constant: WIDTH]
#define CONSTRAINT_SETTING_HEIGHT(VIEW, HEIGHT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeHeight relatedBy: NSLayoutRelationEqual toItem:nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1.0f constant: HEIGHT]

// Min Width and Height
#define CONSTRAINT_SETTING_MIN_WIDTH(VIEW, WIDTH) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationGreaterThanOrEqual toItem:nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1.0f constant: WIDTH]
#define CONSTRAINT_SETTING_MIN_HEIGHT(VIEW, HEIGHT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeHeight relatedBy: NSLayoutRelationGreaterThanOrEqual toItem:nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1.0f constant: HEIGHT]

// Max Width and Height
#define CONSTRAINT_SETTING_MAX_WIDTH(VIEW, WIDTH) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationLessThanOrEqual toItem:nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1.0f constant: WIDTH]
#define CONSTRAINT_SETTING_MAX_HEIGHT(VIEW, HEIGHT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeHeight relatedBy: NSLayoutRelationLessThanOrEqual toItem:nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1.0f constant: HEIGHT]

// Size
#define CONSTRAINTS_SETTING_SIZE(VIEW, WIDTH, HEIGHT) @[CONSTRAINT_SETTING_WIDTH(VIEW, WIDTH), CONSTRAINT_SETTING_HEIGHT(VIEW, HEIGHT)]
#define CONSTRAINTS_SETTING_MIN_SIZE(VIEW, WIDTH, HEIGHT) @[CONSTRAINT_SETTING_MIN_WIDTH(VIEW, WIDTH), CONSTRAINT_SETTING_MIN_HEIGHT(VIEW, HEIGHT)]
#define CONSTRAINTS_SETTING_MAX_SIZE(VIEW, WIDTH, HEIGHT) @[CONSTRAINT_SETTING_MAX_WIDTH(VIEW, WIDTH), CONSTRAINT_SETTING_MAX_HEIGHT(VIEW, HEIGHT)]

#pragma mark - Stretching
#define CONSTRAINT_STRETCHING_H(VIEW, INDENT) ^NSArray *(){VIEW_CLASS *_stretchview = VIEW; NSString *format = [NSString stringWithFormat:@"H:|-%d-[_stretchview]-%d-|", INDENT, INDENT]; NSArray *_tmparray = CONSTRAINTS(format, _stretchview); return _tmparray;}()
#define CONSTRAINT_STRETCHING_V(VIEW, INDENT) ^NSArray *(){VIEW_CLASS *_stretchview = VIEW; NSString *format = [NSString stringWithFormat:@"V:|-%d-[_stretchview]-%d-|", INDENT, INDENT]; NSArray *_tmparray = CONSTRAINTS(format, _stretchview); return _tmparray;}()
#define STRETCH_CONSTRAINTS(VIEW, INDENT) \
[CONSTRAINT_STRETCHING_H(VIEW, INDENT) arrayByAddingObjectsFromArray:CONSTRAINT_STRETCHING_V(VIEW, INDENT)]

#define CONSTRAINT_STRETCHING_PARTIAL_H(VIEW, PERCENT) [NSLayoutConstraint constraintWithItem:VIEW attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[VIEW superview] attribute:NSLayoutAttributeWidth multiplier:(PERCENT) constant:0]
#define CONSTRAINT_STRETCHING_PARTIAL_V(VIEW, PERCENT) [NSLayoutConstraint constraintWithItem:VIEW attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:[VIEW superview] attribute:NSLayoutAttributeHeight multiplier:(PERCENT) constant:0]


#pragma mark - Matching
#define CONSTRAINT_MATCHING_WIDTH(VIEW, TOVIEW) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationEqual toItem:TOVIEW attribute: NSLayoutAttributeWidth multiplier: 1.0f constant:0]
#define CONSTRAINT_MATCHING_HEIGHT(VIEW, TOVIEW) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeHeight relatedBy: NSLayoutRelationEqual toItem:TOVIEW attribute: NSLayoutAttributeHeight multiplier: 1.0f constant:0]
#define CONSTRAINTS_MATCHING_SIZE(VIEW, TOVIEW) \
@[CONSTRAINT_MATCHING_WIDTH(VIEW, TOVIEW), CONSTRAINT_MATCHING_HEIGHT(VIEW, TOVIEW)]

#pragma mark - Centering
#define CONSTRAINT_CENTERING_H(VIEW) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeCenterX relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeCenterX multiplier: 1.0f constant: 0.0f]
#define CONSTRAINT_CENTERING_V(VIEW) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeCenterY relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeCenterY multiplier: 1.0f constant: 0.0f]
#define CONSTRAINTS_CENTERING(VIEW) \
@[CONSTRAINT_CENTERING_H(VIEW), CONSTRAINT_CENTERING_V(VIEW)]

#pragma mark - Alignment
// Left and Top, Leading
#define CONSTRAINT_ALIGNING_LEFT(VIEW, INDENT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeLeft relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeLeft multiplier: 1.0f constant: INDENT]
#define CONSTRAINT_ALIGNING_TOP(VIEW, INDENT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeTop relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeTop multiplier: 1.0f constant: INDENT]
#define CONSTRAINT_ALIGNING_LEADING(VIEW, INDENT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeLeading multiplier: 1.0f constant: INDENT]

// Right, Bottom, Trailing -- indentation is adjusted backwards
#define CONSTRAINT_ALIGNING_RIGHT(VIEW, INDENT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeRight relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeRight multiplier: 1.0f constant: (-INDENT)]
#define CONSTRAINT_ALIGNING_BOTTOM(VIEW, INDENT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeBottom relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeBottom multiplier: 1.0f constant: (-INDENT)]
#define CONSTRAINT_ALIGNING_TRAILING(VIEW, INDENT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeTrailing relatedBy: NSLayoutRelationEqual toItem: [VIEW superview] attribute: NSLayoutAttributeTrailing multiplier: 1.0f constant: (-INDENT)]

#pragma mark - Aligning Pairs
// Left and Top, Leading
#define CONSTRAINT_ALIGNING_PAIR_LEFT(VIEW1, VIEW2, INDENT) [NSLayoutConstraint constraintWithItem: VIEW2 attribute: NSLayoutAttributeLeft relatedBy: NSLayoutRelationEqual toItem:VIEW1 attribute: NSLayoutAttributeLeft multiplier: 1.0f constant: INDENT]
#define CONSTRAINT_ALIGNING_PAIR_TOP(VIEW1, VIEW2, INDENT) [NSLayoutConstraint constraintWithItem: VIEW2 attribute: NSLayoutAttributeTop relatedBy: NSLayoutRelationEqual toItem:VIEW1 attribute: NSLayoutAttributeTop multiplier: 1.0f constant: INDENT]
#define CONSTRAINT_ALIGNING_PAIR_LEADING(VIEW1, VIEW2, OFFSET) [NSLayoutConstraint constraintWithItem: VIEW1 attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem:VIEW2 attribute: NSLayoutAttributeLeading multiplier: 1.0f constant: OFFSET]

// Right and Bottom, Trailing -- indentation is adjusted backwards
#define CONSTRAINT_ALIGNING_PAIR_RIGHT(VIEW1, VIEW2, INDENT) [NSLayoutConstraint constraintWithItem: VIEW2 attribute: NSLayoutAttributeRight relatedBy: NSLayoutRelationEqual toItem:VIEW1 attribute: NSLayoutAttributeRight multiplier: 1.0f constant: (-INDENT)]
#define CONSTRAINT_ALIGNING_PAIR_BOTTOM(VIEW1, VIEW2, INDENT) [NSLayoutConstraint constraintWithItem: VIEW2 attribute: NSLayoutAttributeBottom relatedBy: NSLayoutRelationEqual toItem:VIEW1 attribute: NSLayoutAttributeBottom multiplier: 1.0f constant: (-INDENT)]
#define CONSTRAINT_ALIGNING_PAIR_TRAILING(VIEW1, VIEW2, OFFSET) [NSLayoutConstraint constraintWithItem: VIEW1 attribute: NSLayoutAttributeTrailing relatedBy: NSLayoutRelationEqual toItem:VIEW2 attribute: NSLayoutAttributeTrailing multiplier: 1.0f constant: (-OFFSET)]

// Centering -- No adjustments
#define CONSTRAINT_ALIGNING_PAIR_CENTERX(VIEW1, VIEW2, OFFSET) [NSLayoutConstraint constraintWithItem: VIEW2 attribute: NSLayoutAttributeCenterX relatedBy: NSLayoutRelationEqual toItem:VIEW1 attribute: NSLayoutAttributeCenterX multiplier: 1.0f constant: OFFSET]
#define CONSTRAINT_ALIGNING_PAIR_CENTERY(VIEW1, VIEW2, OFFSET) [NSLayoutConstraint constraintWithItem: VIEW2 attribute: NSLayoutAttributeCenterY relatedBy: NSLayoutRelationEqual toItem:VIEW1 attribute: NSLayoutAttributeCenterY multiplier: 1.0f constant: OFFSET]
#define CONSTRAINTS_ALIGNING_PAIR_CENTER(VIEW1, VIEW2, OFFSET) \
    @[CONSTRAINT_ALIGNING_PAIR_CENTERX(VIEW1, VIEW2, OFFSET), \
    CONSTRAINT_ALIGNING_PAIR_CENTERY(VIEW1, VIEW2, OFFSET)]

#pragma mark - Stacking
// Rows and Columns
#define CONSTRAINT_STACKING_H(VIEW1, VIEW2, BUFFERPOINTS) [NSLayoutConstraint constraintWithItem: VIEW2 attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem:VIEW1 attribute:NSLayoutAttributeTrailing multiplier: 1.0f constant:(BUFFERPOINTS)]
#define CONSTRAINT_STACKING_V(VIEW1, VIEW2, BUFFERPOINTS) [NSLayoutConstraint constraintWithItem: VIEW2 attribute: NSLayoutAttributeTop relatedBy: NSLayoutRelationEqual toItem:VIEW1 attribute:NSLayoutAttributeBottom multiplier: 1.0f constant:(BUFFERPOINTS)]

#pragma mark - Aspect
#define CONSTRAINT_SETTING_ASPECT(VIEW, ASPECT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationEqual toItem:VIEW attribute: NSLayoutAttributeHeight multiplier:(ASPECT) constant: 0.0f]
#define CONSTRAINT_SETTING_MIN_ASPECT(VIEW, ASPECT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationGreaterThanOrEqual toItem:VIEW attribute: NSLayoutAttributeHeight multiplier:(ASPECT) constant: 0.0f]
#define CONSTRAINT_SETTING_MAX_ASPECT(VIEW, ASPECT) [NSLayoutConstraint constraintWithItem: VIEW attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationLessThanOrEqual toItem:VIEW attribute: NSLayoutAttributeHeight multiplier:(ASPECT) constant: 0.0f]

/*
 *
 *
 PRACTICAL CONSTRAINTS
 Will grow this as needed. I've vastly trimmed it back for simplicity.
 These are commonly used items that don't often need priority tweaking,
 so priority is mostly hard-coded to a common value (DEFAULT_LAYOUT_PRIORITY)
 *
 *
 */

// Centering
#pragma mark - Centering
#define CENTER_H(VIEW) INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Center View", CONSTRAINT_CENTERING_H(VIEW))
#define CENTER_V(VIEW) INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Center View", CONSTRAINT_CENTERING_V(VIEW))
#define CENTER(VIEW)   {CENTER_H(VIEW); CENTER_V(VIEW);}

// Courtesy equivs
#define ALIGN_CENTER_H(VIEW)    CENTER_H(VIEW)
#define ALIGN_CENTER_V(VIEW)    CENTER_V(VIEW)

// Stretching
#pragma mark - Stretching
#define STRETCH_H(VIEW, INSET) INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Stretch View", CONSTRAINT_STRETCHING_H(VIEW, INSET))
#define STRETCH_V(VIEW, INSET) INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Stretch View", CONSTRAINT_STRETCHING_V(VIEW, INSET))
#define STRETCH(VIEW, INSET)   {STRETCH_H(VIEW, INSET); STRETCH_V(VIEW, INSET);}

// Exact Sizing
#pragma mark - Sizing Exact
#define CONSTRAIN_WIDTH(VIEW, WIDTH)        INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Constrain View Size", CONSTRAINT_SETTING_WIDTH(VIEW, WIDTH))
#define CONSTRAIN_HEIGHT(VIEW, HEIGHT)      INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Constrain View Size", CONSTRAINT_SETTING_HEIGHT(VIEW, HEIGHT))
#define CONSTRAIN_SIZE(VIEW, WIDTH, HEIGHT) {CONSTRAIN_WIDTH(VIEW, WIDTH); CONSTRAIN_HEIGHT(VIEW, HEIGHT);}

// Min and Max Sizing -- These almost always need priority tweaking so
// these macros include non-default priority
#pragma mark - Sizing Min and Max

#define CONSTRAIN_MIN_WIDTH(VIEW, WIDTH, PRIORITY) \
    INSTALL_CONSTRAINTS(PRIORITY, @"Constrain View Size", CONSTRAINT_SETTING_MIN_WIDTH(VIEW, WIDTH))
#define CONSTRAIN_MIN_HEIGHT(VIEW, HEIGHT, PRIORITY) \
    INSTALL_CONSTRAINTS(PRIORITY, @"Constrain View Size", CONSTRAINT_SETTING_MIN_HEIGHT(VIEW, HEIGHT))
#define CONSTRAIN__MIN_SIZE(VIEW, WIDTH, HEIGHT, PRIORITY) \
    {CONSTRAIN_MIN_WIDTH(VIEW, WIDTH, PRIORITY); \
    CONSTRAIN_MIN_HEIGHT(VIEW, HEIGHT, PRIORITY);}

#define CONSTRAIN_MAX_WIDTH(VIEW, WIDTH, PRIORITY) \
    INSTALL_CONSTRAINTS(PRIORITY, @"Constrain View Size", CONSTRAINT_SETTING_MAX_WIDTH(VIEW, WIDTH))
#define CONSTRAIN_MAX_HEIGHT(VIEW, HEIGHT, PRIORITY) \
    INSTALL_CONSTRAINTS(PRIORITY, @"Constrain View Size", CONSTRAINT_SETTING_MAX_HEIGHT(VIEW, HEIGHT))
#define CONSTRAIN__MAX_SIZE(VIEW, WIDTH, HEIGHT, PRIORITY) \
    {CONSTRAIN_MAX_WIDTH(VIEW, WIDTH, PRIORITY); \
    CONSTRAIN_MAX_HEIGHT(VIEW, HEIGHT, PRIORITY);}

// Matching
#pragma mark - Matching
#define MATCH_WIDTH(FROMVIEW, TOVIEW)  INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Match View Size", CONSTRAINT_MATCHING_WIDTH(FROMVIEW, TOVIEW))
#define MATCH_HEIGHT(FROMVIEW, TOVIEW) INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Match View Size", CONSTRAINT_MATCHING_HEIGHT(FROMVIEW, TOVIEW))
#define MATCH_SIZE(FROMVIEW, TOVIEW)   INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Match View Size", CONSTRAINTS_MATCHING_SIZE(FROMVIEW, TOVIEW))

#define MATCH_CENTERS(FROMVIEW, TOVIEW) INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Match Center", CONSTRAINTS_ALIGNING_PAIR_CENTER(FROMVIEW, TOVIEW))
#define MATCH_CENTERH(FROMVIEW, TOVIEW) INSTALL_CONSTRAINT(DEFAULT_LAYOUT_PRIORITY, @"Match Center", CONSTRAINT_ALIGNING_PAIR_CENTERX(FROMVIEW, TOVIEW, 0))
#define MATCH_CENTERV(FROMVIEW, TOVIEW) INSTALL_CONSTRAINT(DEFAULT_LAYOUT_PRIORITY, @"Match Center", CONSTRAINT_ALIGNING_PAIR_CENTERY(FROMVIEW, TOVIEW, 0))

// Aligning
#pragma mark - Aligning
#define ALIGN_LEFT(VIEW, INDENT)      INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align View", CONSTRAINT_ALIGNING_LEFT(VIEW, INDENT))
#define ALIGN_RIGHT(VIEW, INDENT)     INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align View", CONSTRAINT_ALIGNING_RIGHT(VIEW, INDENT))
#define ALIGN_TOP(VIEW, INDENT)       INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align View", CONSTRAINT_ALIGNING_TOP(VIEW, INDENT))
#define ALIGN_BOTTOM(VIEW, INDENT)    INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align View", CONSTRAINT_ALIGNING_BOTTOM(VIEW, INDENT))
#define ALIGN_LEADING(VIEW, INDENT)   INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align View", CONSTRAINT_ALIGNING_LEADING(VIEW, INDENT))
#define ALIGN_TRAILING(VIEW, INDENT)  INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align View", CONSTRAINT_ALIGNING_TRAILING(VIEW, INDENT))

// Alignment to the 9 cardinal points
#pragma mark - Cardinal Alignment
#define ALIGN_BOTTOMLEFT(VIEW, INDENT)    {ALIGN_BOTTOM(VIEW, INDENT); ALIGN_LEFT(VIEW, INDENT);}
#define ALIGN_BOTTOMRIGHT(VIEW, INDENT)   {ALIGN_BOTTOM(VIEW, INDENT); ALIGN_RIGHT(VIEW, INDENT);}
#define ALIGN_TOPLEFT(VIEW, INDENT)       {ALIGN_TOP(VIEW, INDENT); ALIGN_LEFT(VIEW, INDENT);}
#define ALIGN_TOPRIGHT(VIEW, INDENT)      {ALIGN_TOP(VIEW, INDENT); ALIGN_RIGHT(VIEW, INDENT);}
#define ALIGN_CENTER(VIEW)                {CENTER_H(VIEW); CENTER_V(VIEW);}
#define ALIGN_CENTERBOTTOM(VIEW, INDENT)  {ALIGN_BOTTOM(VIEW, INDENT); CENTER_H(VIEW);}
#define ALIGN_CENTERTOP(VIEW, INDENT)     {ALIGN_TOP(VIEW, INDENT); CENTER_H(VIEW);}
#define ALIGN_CENTERRIGHT(VIEW, INDENT)   {ALIGN_RIGHT(VIEW, INDENT); CENTER_V(VIEW);}
#define ALIGN_CENTERLEFT(VIEW, INDENT)    {ALIGN_LEFT(VIEW, INDENT); CENTER_V(VIEW);}

// Pair alignment
#pragma mark - Pair Alignment
#define ALIGN_PAIR_LEFT(VIEW1, VIEW2)       INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align Pair", CONSTRAINT_ALIGNING_PAIR_LEFT(VIEW1, VIEW2, 0))
#define ALIGN_PAIR_LEADING(VIEW1, VIEW2)    INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align Pair", CONSTRAINT_ALIGNING_PAIR_LEADING(VIEW1, VIEW2, 0))
#define ALIGN_PAIR_RIGHT(VIEW1, VIEW2)      INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align Pair", CONSTRAINT_ALIGNING_PAIR_RIGHT(VIEW1, VIEW2, 0))
#define ALIGN_PAIR_CENTERX(VIEW1, VIEW2)    INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align Pair", CONSTRAINT_ALIGNING_PAIR_CENTERX(VIEW1, VIEW2, 0))
#define ALIGN_PAIR_TRAILING(VIEW1, VIEW2)   INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align Pair", CONSTRAINT_ALIGNING_PAIR_TRAILING(VIEW1, VIEW2, 0))
#define ALIGN_PAIR_TOP(VIEW1, VIEW2)        INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align Pair", CONSTRAINT_ALIGNING_PAIR_TOP(VIEW1, VIEW2, 0))
#define ALIGN_PAIR_CENTERY(VIEW1, VIEW2)    INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align Pair", CONSTRAINT_ALIGNING_PAIR_CENTERY(VIEW1, VIEW2, 0))
#define ALIGN_PAIR_BOTTOM(VIEW1, VIEW2)     INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Align Pair", CONSTRAINT_ALIGNING_PAIR_BOTTOM(VIEW1, VIEW2, 0))


// Place In Row or Column
#pragma mark - Rows and Columns
#define LAYOUT_H(VIEW1, OFFSET, VIEW2) INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Create Row", CONSTRAINT_STACKING_H(VIEW1, VIEW2, OFFSET), CONSTRAINT_ALIGNING_PAIR_CENTERY(VIEW1, VIEW2, 0))
#define LAYOUT_V(VIEW1, OFFSET, VIEW2) INSTALL_CONSTRAINTS(DEFAULT_LAYOUT_PRIORITY, @"Create Column", CONSTRAINT_STACKING_V(VIEW1, VIEW2, OFFSET), CONSTRAINT_ALIGNING_PAIR_CENTERX(VIEW1, VIEW2, 0))

// Set ImageView Aspect
#if TARGET_OS_IPHONE
#define CONSTRAIN_IMAGEVIEW_ASPECT(IMAGEVIEW, PRIORITY)  InstallConstraint(CONSTRAINT_SETTING_ASPECT(IMAGEVIEW, (IMAGEVIEW.image.size.width / IMAGEVIEW.image.size.height)), PRIORITY, @"Image View Aspect");
#endif

#pragma mark - Content Size Layout

#if TARGET_OS_IPHONE

#pragma mark iOS

// Content Hugging
#define HUG_H(VIEW, PRIORITY) [VIEW setContentHuggingPriority:(PRIORITY) forAxis:UILayoutConstraintAxisHorizontal]
#define HUG_V(VIEW, PRIORITY) [VIEW setContentHuggingPriority:(PRIORITY) forAxis:UILayoutConstraintAxisVertical]
#define HUG(VIEW, PRIORITY) {HUG_H(VIEW, PRIORITY); HUG_V(VIEW, PRIORITY);}

// Compression Resistance
#define RESIST_H(VIEW, PRIORITY) [VIEW setContentCompressionResistancePriority:(PRIORITY) forAxis:UILayoutConstraintAxisHorizontal]
#define RESIST_V(VIEW, PRIORITY) [VIEW setContentCompressionResistancePriority:(PRIORITY) forAxis:UILayoutConstraintAxisVertical]
#define RESIST(VIEW, PRIORITY) {RESIST_H(VIEW, PRIORITY); RESIST_V(VIEW, PRIORITY);}

#elif TARGET_OS_MAC

#pragma mark OS X

// Content Hugging
#define HUG_H(VIEW, PRIORITY) [VIEW setContentHuggingPriority:(PRIORITY) forOrientation:NSLayoutConstraintOrientationHorizontal]
#define HUG_V(VIEW, PRIORITY) [VIEW setContentHuggingPriority:(PRIORITY) forOrientation:NSLayoutConstraintOrientationVertical]
#define HUG(VIEW, PRIORITY) {HUG_H(VIEW, PRIORITY); HUG_V(VIEW, PRIORITY);}

// Compression Resistance
#define RESIST_H(VIEW, PRIORITY) [VIEW setContentCompressionResistancePriority:(PRIORITY) forOrientation:NSLayoutConstraintOrientationHorizontal]
#define RESIST_V(VIEW, PRIORITY) [VIEW setContentCompressionResistancePriority:(PRIORITY) forOrientation:NSLayoutConstraintOrientationVertical]
#define RESIST(VIEW, PRIORITY) {RESIST_H(VIEW, PRIORITY); RESIST_V(VIEW, PRIORITY);}
#endif
