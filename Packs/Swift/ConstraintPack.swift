/*
 
 Erica Sadun, http://ericasadun.com
 Auto Layout Demystified

 Requires CrossPlatformDefines.swift
 This version deprecates iOS 7 coverage. For iOS 8 and later only

*/

import Foundation
import ObjectiveC
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public let SkipConstraint = CGRectNull.origin.x
public let SkipOptions = NSLayoutFormatOptions(rawValue: 0)

// **************************************
// MARK: Convenience
// **************************************

public extension UIView {
    public func addSubviews(views : UIView...) {
        for eachView in views {
            addSubview(eachView)
            eachView.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
    }
}

// **************************************
// MARK: Superviews / Ancestors
// **************************************

// Return superviews
public func Superviews(view : View) -> ([View]) {
    var array = [View]()
    var currentView : View? = view.superview
    while (currentView != nil) {
        array += [currentView!]
        currentView = currentView!.superview
    }
    return array
}

// Return nearest common ancestor between two views
public func NearestCommonViewAncestor(view1 : View, view2 : View) -> (View?) {
    if view1 === view2 {return view1}
    
    var view1Superviews = Superviews(view1)
    var view2Superviews = Superviews(view2)
    
    // Check for superview relationships
    if contains(view1Superviews, view2) {return view2}
    if contains(view2Superviews, view1) {return view1}
    
    // Check for indirect ancestor
    for eachItem in view1Superviews {
        if contains(view2Superviews, eachItem) {return eachItem}
    }
    
    return nil
}

public extension View {
    public var superviews : [View] {get {return Superviews(self)}}
    public func nearestCommonAncestorWithView(view : View) -> (View?) {
        return NearestCommonViewAncestor(self, view)
    }
}

// **************************************
// MARK: Constraint References
// **************************************

// NSView uses a constraints property
// UIView uses a constraints function
public extension View {
    var viewConstraints : [NSLayoutConstraint] {
        #if os(iOS)
            return constraints() as! [NSLayoutConstraint]
        #else
            return constraints as! [NSLayoutConstraint]
        #endif
    }
}

public extension NSLayoutConstraint {
    public var firstView : View {return self.firstItem as! View}
    public var secondView : View? {return self.secondItem as? View}
    public func refersToView(theView : View) -> Bool {
        if firstItem as! View == theView {return true}
        if secondItem != nil {
            if secondItem as! View == theView {return true}
        }
        return false
    }
}

public func ExternalConstraintsReferencingView(view : View) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()
    for superview in view.superviews {
        for constraint in superview.viewConstraints {
            if constraint.refersToView(view) {constraints += [constraint]}
        }
    }
    return constraints
}

public func InternalConstraintsReferencingView(view : View) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]() // updated to any object
    for constraint in view.viewConstraints {
        if constraint.refersToView(view) {
            constraints += [constraint]
        }
    }
    return constraints
}

public extension View {
    public var externalConstraintReferences : [NSLayoutConstraint] {
        return ExternalConstraintsReferencingView(self)
    }
    public var internalConstraintReferences : [NSLayoutConstraint] {
        return InternalConstraintsReferencingView(self)
    }
    public var constraintsReferencingView : [NSLayoutConstraint] {
        return internalConstraintReferences + externalConstraintReferences
    }
}

// **************************************
// MARK: Enabling Auto Layout
// **************************************
#if os(iOS)
    public extension View {
        public var autoLayoutEnabled : Bool {
            get {return !translatesAutoresizingMaskIntoConstraints()}
            set {setTranslatesAutoresizingMaskIntoConstraints(!newValue)}
        }
    }
    #else
    public extension View {
        public var autoLayoutEnabled : Bool {
        get {return translatesAutoresizingMaskIntoConstraints == false}
        set {translatesAutoresizingMaskIntoConstraints = !newValue}
        }
    }
#endif




// **************************************
// MARK: Format Installation
// **************************************
public func InstallLayoutFormats(
    formats : [String],
    options : NSLayoutFormatOptions,
    metrics : [NSObject : AnyObject],
    bindings : [NSObject : AnyObject],
    priority : LayoutPriority) {
    for format in formats {
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: bindings) as! [NSLayoutConstraint]
        constraints.map{$0.priority = priority}
        NSLayoutConstraint.activateConstraints(constraints)
    }
}

// **************************************
// MARK: Sizing
// **************************************

// Constraining Sizes
public func SizeView(view : View, size : CGSize, priority : LayoutPriority) {
    let metrics = ["width" : size.width, "height" : size.height]
    let bindings = ["view" : view]
    var formats = [String]()
    if size.width != SkipConstraint { formats += ["H:[view(==width)]"] }
    if size.height != SkipConstraint { formats += ["V:[view(==height)]"] }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

public func ConstrainMinimumViewSize(view : View, size : CGSize, priority : LayoutPriority) {
    let metrics = ["width" : size.width, "height" : size.height]
    let bindings = ["view" : view]
    var formats = [String]()
    if size.width != SkipConstraint { formats += ["H:[view(>=width)]"] }
    if size.height != SkipConstraint { formats += ["V:[view(>=height)]"] }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

public func ConstrainMaximumViewSize(view : View, size : CGSize, priority : LayoutPriority) {
    let metrics = ["width" : size.width, "height" : size.height]
    let bindings = ["view" : view]
    var formats = [String]()
    if size.width != SkipConstraint { formats += ["H:[view(<=width)]"] }
    if size.height != SkipConstraint { formats += ["V:[view(<=height)]"] }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

// **************************************
// MARK: Positioning
// **************************************

// Constraining Positions
public func PositionView(view : View, point : CGPoint, priority : LayoutPriority) {
    if view.superview == nil {return}
    let metrics = ["hLoc" : point.x, "vLoc" : point.y]
    let bindings = ["view" : view]
    var formats = [String]()
    if point.x != SkipConstraint { formats += ["H:|-hLoc-[view]"] }
    if point.y != SkipConstraint { formats += ["V:|-vLoc-[view]"] }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

public func ConstrainViewToSuperview(view : View, inset : Float, priority : LayoutPriority) {
    if view.superview == nil {return}
    let formats = [
        "H:|->=inset-[view]",
        "H:[view]->=inset-|",
        "V:|->=inset-[view]",
        "V:[view]->=inset-|"]
    InstallLayoutFormats(formats, SkipOptions, ["inset" : inset], ["view" : view], priority)
}

// **************************************
// MARK: Stretching
// **************************************

// Stretching to Superview
public func StretchViewHorizontallyToSuperview(view : View, inset : CGFloat, priority : LayoutPriority) {
    if view.superview == nil {return}
    let metrics = ["inset" : inset]
    let bindings = ["view" : view]
    let formats = ["H:|-inset-[view]-inset-|"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

public func StretchViewVerticallyToSuperview(view : View, inset : CGFloat, priority : LayoutPriority) {
    if view.superview == nil {return}
    let metrics = ["inset" : inset]
    let bindings = ["view" : view]
    let formats = ["V:|-inset-[view]-inset-|"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

public func StretchViewToSuperview(view : View, inset : CGSize, priority : LayoutPriority) {
    if view.superview == nil {return}
    if inset.width != SkipConstraint {
        StretchViewHorizontallyToSuperview(view, inset.width, priority)
    }
    if inset.height != SkipConstraint {
        StretchViewVerticallyToSuperview(view, inset.height, priority)
    }
}

// **************************************
// MARK: Alignment
// **************************************

// Aligning
public func AlignViewInSuperview(view : View, attribute : NSLayoutAttribute, inset : CGFloat, priority : LayoutPriority) {
    if view.superview == nil {return}
    var actualInset : CGFloat
    switch attribute {
    case .Left, .Leading, .Top:
        actualInset = inset * -1.0
    default:
        actualInset = inset
    }
    let superview = view.superview!
    let constraint = NSLayoutConstraint(item:superview, attribute:attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: actualInset)
    constraint.priority = priority
    constraint.active = true
}

public func AlignViews(priority : LayoutPriority, view1 : View, view2 : View, attribute : NSLayoutAttribute) {
    let constraint : NSLayoutConstraint = NSLayoutConstraint(item: view1, attribute: attribute, relatedBy: .Equal, toItem: view2, attribute: attribute, multiplier: 1, constant: 0)
    constraint.priority = priority
    constraint.active = true
}

// View to View Layout
public func CenterViewInSuperview(view : View, horizontal : Bool, vertical : Bool, priority : LayoutPriority) {
    if view.superview == nil {return}
    if horizontal {AlignViews(priority, view, view.superview!, .CenterX)}
    if vertical {AlignViews(priority, view, view.superview!, .CenterY)}
}

/// Constrain several views at once. Views are named view1, view2, view3...
public func ConstrainViews(priority : LayoutPriority, format : String, metrics : [String : AnyObject], views : [UIView]) {
    
    // At least one view
    if count(views) == 0 {return}
    
    // Install view names to bindings
    var bindings = [String : UIView]()
    bindings["view"] = views.first
    for (index, view) in enumerate(views) {
        bindings["view\(index+1)"] = view
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    // Generate and install constraints with priority
    InstallLayoutFormats([format], SkipOptions, metrics, bindings, priority)
}

public func ConstrainViews(priority : LayoutPriority, format : String, views : UIView...) {
    ConstrainViews(priority, format, [String : AnyObject](), views)
}

public func ConstrainView(priority : LayoutPriority, format : String, metrics: [String : AnyObject], view : UIView) {
    ConstrainViews(priority, format, metrics, [view])
}

public func ConstrainView(priority : LayoutPriority, format : String, view : UIView) {
    ConstrainView(priority, format, [String : AnyObject](), view)
}

// **************************************
// MARK: iOS Layout Guides
// **************************************

// Working with Layout Guides. iOS Only
#if os(iOS)
public func StretchViewToTopLayoutGuide(controller : UIViewController, view : View, inset : Int, priority : LayoutPriority) {
    let metrics = ["vinset" : inset]
    let bindings = ["view" : view, "topGuide" : controller.topLayoutGuide as AnyObject]
    let formats = ["V:[topGuide]-vinset-[view]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

public func StretchViewToBottomLayoutGuide(controller : UIViewController, view : View, inset : Int, priority : LayoutPriority) {
    let metrics = ["vinset" : inset]
    let bindings = ["view" : view, "bottomGuide" : controller.bottomLayoutGuide as AnyObject]
    let formats = ["V:[view]-vinset-[bottomGuide]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

public func StretchViewToController(controller : UIViewController, view : View, inset : CGSize, priority : LayoutPriority) {
    StretchViewToTopLayoutGuide(controller, view, lrint(Double(inset.height)), priority)
    StretchViewToBottomLayoutGuide(controller, view, lrint(Double(inset.height)), priority)
    StretchViewHorizontallyToSuperview(view, inset.width, priority)
}

// UIViewController extended layout
extension UIViewController {
    public var useExtendedLayout : Bool {
        get {
            return !(edgesForExtendedLayout == .None)
        }
        set {
            edgesForExtendedLayout = newValue ? .All : .None
        }
    }
}
#endif

// **************************************
// MARK: Hug / Resist
// **************************************

#if os(iOS)
public extension View {
    public var horizontalContentHuggingPriority : LayoutPriority {
        get {return contentHuggingPriorityForAxis(.Horizontal)}
        set {setContentHuggingPriority(newValue, forAxis: .Horizontal)}
    }
    public var verticalContentHuggingPriority : LayoutPriority {
        get {return contentHuggingPriorityForAxis(.Vertical)}
        set {setContentHuggingPriority(newValue, forAxis: .Vertical)}
    }
    public var contentHuggingPriority : LayoutPriority {
        get {println("This priority is write-only"); return 250} // meaningless
        set {
            setContentHuggingPriority(newValue, forAxis: .Horizontal)
            setContentHuggingPriority(newValue, forAxis: .Vertical)
        }
    }
    public var horizontalContentCompressionResistancePriority : LayoutPriority {
        get {return contentCompressionResistancePriorityForAxis(.Horizontal)}
        set {setContentCompressionResistancePriority(newValue, forAxis: .Horizontal)}
    }
    public var verticalContentCompressionResistancePriority : LayoutPriority {
        get {return contentCompressionResistancePriorityForAxis(.Vertical)}
        set {setContentCompressionResistancePriority(newValue, forAxis: .Vertical)}
    }
    public var contentCompressionResistancePriority : LayoutPriority {
        get {println("This priority is write-only"); return 750} // meaningless
        set {
            setContentCompressionResistancePriority(newValue, forAxis: .Horizontal)
            setContentCompressionResistancePriority(newValue, forAxis: .Vertical)
        }
    }
}

    #else

// OS X
public extension View {
    public var horizontalContentHuggingPriority : LayoutPriority {
        get {return contentHuggingPriorityForOrientation(.Horizontal)}
        set {setContentHuggingPriority(newValue, forOrientation: .Horizontal)}
    }
    public var verticalContentHuggingPriority : LayoutPriority {
        get {return contentHuggingPriorityForOrientation(.Vertical)}
        set {setContentHuggingPriority(newValue, forOrientation: .Vertical)}
    }
    public var contentHuggingPriority : LayoutPriority {
        get {println("This priority is write-only"); return 250} // meaningless
        set {
            setContentHuggingPriority(newValue, forOrientation: .Horizontal)
            setContentHuggingPriority(newValue, forOrientation: .Vertical)
        }
    }
    public var horizontalContentCompressionResistancePriority : LayoutPriority {
        get {return contentCompressionResistancePriorityForOrientation(.Horizontal)}
        set {setContentCompressionResistancePriority(newValue, forOrientation: .Horizontal)}
    }
    public var verticalContentCompressionResistancePriority : LayoutPriority {
        get {return contentCompressionResistancePriorityForOrientation(.Vertical)}
        set {setContentCompressionResistancePriority(newValue, forOrientation: .Vertical)}
    }
    public var contentCompressionResistancePriority : LayoutPriority {
        get {println("This priority is write-only"); return 750} // meaningless
        set {
            setContentCompressionResistancePriority(newValue, forOrientation: .Horizontal)
            setContentCompressionResistancePriority(newValue, forOrientation: .Vertical)
        }
    }
}
#endif


// --------------------------------------------------
// MARK: Placement utility
// --------------------------------------------------

public func PlaceViewInSuperview(view : View, position: String, inseth : CGFloat, insetv : CGFloat, priority : LayoutPriority) {
    if count(position) != 2 {return}
    if view.superview == nil {return}

    view.autoLayoutEnabled = true

    let verticalPosition = position.substringToIndex(position.startIndex.successor())
    let horizontalPosition = position.substringFromIndex(position.startIndex.successor())

    switch verticalPosition as String {
    case "t":
        AlignViewInSuperview(view, .Top, insetv, priority)
    case "c":
        AlignViewInSuperview(view, .CenterY, insetv, priority)
    case "b":
        AlignViewInSuperview(view, .Bottom, insetv, priority)
    case "x":
        StretchViewVerticallyToSuperview(view, insetv, priority)
    default:
        break
    }

    switch horizontalPosition as String {
    case "l":
        AlignViewInSuperview(view, .Leading, inseth, priority)
    case "c":
        AlignViewInSuperview(view, .CenterX, inseth, priority)
    case "r":
        AlignViewInSuperview(view, .Trailing, inseth, priority)
    case "x":
        StretchViewHorizontallyToSuperview(view, inseth, priority)
    default:
        break
    }
}

#if os(iOS)
public func PlaceView(controller : UIViewController, view : UIView, position : String, inseth : CGFloat, insetv : CGFloat, priority : LayoutPriority) {
    view.autoLayoutEnabled = true
    if view.superview == nil {controller.view .addSubview(view)}

    if count(position) != 2 {return}
    var verticalPosition = position.substringToIndex(position.startIndex.successor())
    var horizontalPosition = position.substringFromIndex(position.startIndex.successor())

    // Handle the two stretching cases
    if position.hasPrefix("x") {
        StretchViewToTopLayoutGuide(controller, view, lrint(Double(insetv)), priority)
        StretchViewToBottomLayoutGuide(controller, view, lrint(Double(insetv)), priority)
        verticalPosition = "-"
    }

    if position.hasSuffix("x") {
        StretchViewHorizontallyToSuperview(view, inseth, priority)
        horizontalPosition = "-"
    }
    
    if position == "xx" {return}

    // Otherwise just place in superview
    PlaceViewInSuperview(view, (verticalPosition + horizontalPosition), inseth, insetv, priority)
}
#endif

// **************************************
// MARK: Inspection
// **************************************

public var ViewNameKey = "ViewNameKey"
public extension NSObject {
    public var className : String {
        return "\(self.dynamicType)"
    }
    public var addressString : String {
        get {return NSString(format: "%p", self) as String}
    }
    public var debugName : String {
        return className + ":" + addressString
    }
}
public extension UIView {
    public var viewName : String? {
        get {return objc_getAssociatedObject(self, &ViewNameKey) as? String}
        set {objc_setAssociatedObject(self, &ViewNameKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))}
    }
    public var debugViewName : String {
        get {
            if className.hasPrefix("_UI") {return className.substringFromIndex(advance(className.startIndex, 3))}
            return className + ":" + (viewName ?? addressString)}
    }
}

public extension NSLayoutConstraint {
    public var descriptionWithViewNames : String {
        var string : NSString = description

        string = string.stringByReplacingOccurrencesOfString(debugName + " ", withString: "")

        if let viewName = firstView.viewName {
            string = string.stringByReplacingOccurrencesOfString(firstView.addressString, withString: "\"" + viewName + "\"")
        }

        if firstView.className.hasPrefix("_UI") {
            let visible = firstView.className.substringFromIndex(advance(className.startIndex, 3))
            string = string.stringByReplacingOccurrencesOfString(firstView.debugName, withString: visible)
        }

        if let secondView = secondView {
            if let viewName = secondView.viewName {
                string = string.stringByReplacingOccurrencesOfString(secondView.addressString, withString: "\"" + viewName + "\"")
            }
            
            if secondView.className.hasPrefix("_UI") {
                let visible = secondView.className.substringFromIndex(advance(className.startIndex, 3))
                string = string.stringByReplacingOccurrencesOfString(secondView.debugName, withString: visible)
            }
        }

        // return className + ": " + (string as String)
        return string as String
    }
}

public extension View {
    public func dumpViewsAtIndent(indent : Int) {
        
        if className.hasPrefix("_UI") {return}
        
        // indent and print view
        for i in 0..<indent {print("----")}
        print("[\(debugViewName) \(frame)")
        if tag != 0 {print(" tag: \(tag)")}
        
        // Hugging and resistance
        // print(" Hug:(\(horizontalContentHuggingPriority), \(verticalContentHuggingPriority))")
        // print(" Res:(\(horizontalContentCompressionResistancePriority), \(verticalContentCompressionResistancePriority))")
        
        // Count and references
        if viewConstraints.count > 0 {print(" constraints: \(viewConstraints.count)")}
        if constraintsReferencingView.count > 0 {print(" references: \(constraintsReferencingView.count)")}

        println("]")

        // Enumerate the constraints
        for (index, constraint) in enumerate(viewConstraints) {
            for i in 0..<indent {print("    ")} // indentation
            println("    \(index + 1). \(constraint.descriptionWithViewNames)")
        }
        
        // Recurse
        for subview in subviews {
            subview.dumpViewsAtIndent(indent + 1)
        }
    }
    
    public func dumpViews() {
        dumpViewsAtIndent(0)
    }
}

