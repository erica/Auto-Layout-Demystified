/*

 Erica Sadun, http://ericasadun.com
 
 Constraints
 
 */

/*
 *
 *
 CONVENIENCE
 *
 *
 */


#pragma mark - Utility


/*
 *
 *
 TESTING CONSTRAINT ELEMENTS
 *
 *
 */

#define IS_VALID_RELATION(RELATION) [@[@(NSLayoutFormatAlignAllTop), @(NSLayoutRelationEqual), @(NSLayoutRelationGreaterThanOrEqual)] containsObject:@(RELATION)]
#define IS_VALID_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight), @(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY), @(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]


/*
 *
 *
 BASIC FORMAT-BASED CONSTRAINTS
 *
 *
 */

#pragma mark - Simple Visual Constraints
#define CONSTRAINTS(FORMAT, ...) ^NSArray *(){NSDictionary *_bindings = NSDictionaryOfVariableBindings(__VA_ARGS__); return [NSLayoutConstraint constraintsWithVisualFormat:(FORMAT) options:0 metrics:nil views:_bindings];}()
#define CONSTRAINTS_WITH_OPTIONS(FORMAT, OPTIONS, ...) ^NSArray *(){NSDictionary *_bindings = NSDictionaryOfVariableBindings(__VA_ARGS__); return [NSLayoutConstraint constraintsWithVisualFormat:(FORMAT) options:OPTIONS metrics:nil views:_bindings];}()

/*
 *
 *
 INSTALLING CONSTRAINTS. Ugly. Sorry.
 *
 *
 */

#pragma mark - Installing Visual Constraints

// Apply format-based constraints
#define CONSTRAIN_VIEWS(PRIORITY, NAME, FORMAT, ...) \
{\
    NSArray *_tmpArray = CONSTRAINTS(FORMAT, __VA_ARGS__); \
    for (NSLayoutConstraint *_tmpConstraint in _tmpArray) \
    { \
        _tmpConstraint.nametag = NAME; \
        [_tmpConstraint install:PRIORITY]; \
    } \
}

// Common constraint install entry point using no naming and default layout priority
#define DEFAULT_LAYOUT_PRIORITY LayoutPriorityRequired

#define CONSTRAIN(FORMAT, ...) CONSTRAIN_VIEWS(DEFAULT_LAYOUT_PRIORITY, nil, FORMAT, __VA_ARGS__)

#pragma mark - Installing single and array constraints

// Install a single constraint
#define _INSTALL_CONSTRAINT(PRIORITY, NAME, CONSTRAINT) {[CONSTRAINT setNametag:NAME]; [CONSTRAINT install:PRIORITY];}

// Install an array of constraints
#define _INSTALL_CONSTRAINT_ARRAY(PRIORITY, NAME, ARRAY) {for (NSLayoutConstraint *_tmpConstraint in ARRAY) {_INSTALL_CONSTRAINT(PRIORITY, NAME, _tmpConstraint);}}

// Install a list of mixed single and array constraints
#define _INSTALL_CONSTRAINTS(PRIORITY, NAME, ...) {\
    NSArray *_tmpArray = [NSArray arrayWithObjects: __VA_ARGS__]; \
    for (NSObject *_eachItem in _tmpArray){ \
        if ([(_eachItem) isKindOfClass:[NSArray class]]) \
            {_INSTALL_CONSTRAINT_ARRAY(PRIORITY, NAME, (NSArray *) _eachItem);} \
        else \
            {_INSTALL_CONSTRAINT(PRIORITY, NAME, (NSLayoutConstraint *) _eachItem);}\
    }\
}

#define REMOVE_CONSTRAINTS(ARRAY) do {for (NSLayoutConstraint *_tmpConstraint in ARRAY) [_tmpConstraint remove];} while (0)

// Convenience entry point to avoid forcing semaphore at the end
#define INSTALL_CONSTRAINTS(PRIORITY, NAME, ...) _INSTALL_CONSTRAINTS(PRIORITY, NAME, __VA_ARGS__, nil)
