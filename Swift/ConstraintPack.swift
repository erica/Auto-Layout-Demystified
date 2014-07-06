/*
 
 Erica Sadun, http://ericasadun.com
 Auto Layout Demystified

 Requires CrossPlatformDefines.swift

*/

import Foundation
import ObjectiveC
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

let SkipConstraint = CGRectNull.origin.x
let SkipOptions = NSLayoutFormatOptions.fromMask(0)

// **************************************
// MARK: Superviews / Ancestors
// **************************************

// Return superviews
func Superviews(view : View) -> (View[])
{
    var array : View[] = []
    var currentView = view.superview
    while (currentView != nil)
    {
        array += currentView
        currentView = currentView.superview
    }
    return array
}

// Return nearest common ancestor between two views
func NearestCommonViewAncestor(view1 : View, view2 : View) -> (View?)
{
    if (view1 === view2) {return view1}
    
    var view1Superviews = Superviews(view1)
    var view2Superviews = Superviews(view2)
    
    // Check for superview relationships
    if (view1Superviews as NSArray).containsObject(view2) {return view2}
    if (view2Superviews as NSArray).containsObject(view1) {return view1}
    
    // Check for indirect ancestor
    for eachItem in view1Superviews
    {
        if (view2Superviews as NSArray).containsObject(eachItem) {return eachItem}
    }
    
    return nil
}

extension View {
    func nearestCommonAncestorWithView(view : View) -> (View?)
    {
        return NearestCommonViewAncestor(self, view)
    }
}

// **************************************
// MARK: Self-installing Constraints
// **************************************

// NSLayoutConstraint Extensions
extension NSLayoutConstraint
{
    func install() -> Bool
    {
        if (self.firstItem === nil)
        {
            println("Error: This should never happen. Missing first item")
            return false
        }
        
        let firstView = self.firstItem as View
        if (self.secondItem === nil)
        {
            firstView.addConstraint(self)
            return true
        }

        let secondView = self.secondItem as View
        
        let ncaView = NearestCommonViewAncestor(firstView, secondView)
        if (ncaView === nil)
        {
            println("Error: Constraint cannot be installed. No common ancestor between items")
            return false
        }
        
        ncaView!.addConstraint(self)
        return true
    }
    
    func installWithPriority(priority : Float) -> Bool
    {
#if os(iOS)
        self.priority = UILayoutPriority.abs(priority)
#else
        self.priority = NSLayoutPriority.abs(priority)
#endif
        return self.install()
    }
    
    func remove()
    {
        if (!self.isMemberOfClass(NSLayoutConstraint))
        {
            println("Error: Can only uninstall NSLayoutConstraint.")
            return
        }
        
        if (self.firstItem === nil)
        {
            println("Error: This should never happen. Missing first item")
            return
        }
        
        if (self.secondItem === nil)
        {
            let view : View = self.firstItem as View
            view.removeConstraint(self)
            return
        }
        
        let firstView = self.firstItem as View
        let secondView = self.secondItem as View
        let ncaView = NearestCommonViewAncestor(firstView, secondView)
        
        // This should not happen
        if (!ncaView)
        {
            println("Error: no common ancestor. This should not happen")
            return
        }
        
        ncaView!.removeConstraint(self)
    }
}

func InstallConstraints(constraints : NSLayoutConstraint[], priority : Float)
{
    for constraint in constraints
    {
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        constraint.installWithPriority(priority)
    }
}

func InstallConstraints(constraints : NSLayoutConstraint[])
{
    for constraint in constraints
    {
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        constraint.install()
    }
}

func RemoveConstraints(constraints : NSLayoutConstraint[])
{
    for constraint in constraints
    {
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        constraint.remove()
    }
}

// **************************************
// MARK: Constraint References
// **************************************

extension NSLayoutConstraint {
    
    func refersToView(theView : View) -> Bool
    {
        if (self.firstItem === nil)
        {
            println("Error: This should never happen. Missing first item")
            return false
        }
        
        if (self.secondItem === nil)
        {
            let view = self.firstItem as View
            return (view === theView)
        }
        
        let firstView = self.firstItem as View
        let secondView = self.secondItem as View
        
        if (firstView === theView) {return true}
        if (secondView === theView) {return true}
        return false
    }
}

// External constraint references
func ExternalConstraintsReferencingView(view : View) -> (NSLayoutConstraint[])
{
    var superviews = Superviews(view)
    var constraints : NSLayoutConstraint[] = []
    for superview : View in superviews {
        #if os(iOS)
            let collection = superview.constraints() as NSLayoutConstraint[] // Thanks Josh Weinberg
            #else
            let collection = superview.constraints as NSLayoutConstraint[]
        #endif
        for constraint in collection {
            if (constraint.refersToView(view))
            {
                constraints += constraint
            }
        }
    }
    return constraints
}

// Internal constraint references
func InternalConstraintsReferencingView(view : View) -> (NSLayoutConstraint[])
{
    var constraints : NSLayoutConstraint[] = []
    #if os(iOS)
        let collection = view.constraints() as NSLayoutConstraint[] // Thanks Josh Weinberg
        #else
        let collection = view.constraints as NSLayoutConstraint[]
    #endif
    for constraint in collection
    {
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        if (constraint.refersToView(view))
        {
            constraints += constraint
        }
    }
    return constraints
}

// Internal + External
func ConstraintsReferencingView(view : View) -> (NSLayoutConstraint[])
{
    let internal = InternalConstraintsReferencingView(view)
    let external = ExternalConstraintsReferencingView(view)
    return internal + external
}

extension View
{
    func externalConstraintReferences() -> (NSLayoutConstraint[])
    {
        return ExternalConstraintsReferencingView(self)
    }
    
    func internalConstraintReferences() -> (NSLayoutConstraint[])
    {
        return InternalConstraintsReferencingView(self)
    }
    
    func constraintReferences() -> (NSLayoutConstraint[])
    {
        return ConstraintsReferencingView(self)
    }
}

// **************************************
// MARK: Inspection
// **************************************

extension View {
    func dumpViewsAtIndent(indent : Int)
    {
        for i in 0..(indent * 4) {print("-")}
        print("[\(self.description)]")
        if (self.tag != 0) {print(" (tag:\(self.tag))")}
        #if os(iOS)
            let count = self.constraints().count
            #else
            let count = self.constraints.count
        #endif
        print(" constraints: \(count) stored")
        print(" \(self.constraintReferences().count) references")
        println()
        
        for subview in (self.subviews as View[])
        {
            subview.dumpViewsAtIndent(indent + 1)
        }
    }
    
    func dumpViews()
    {
        dumpViewsAtIndent(0)
    }
}

// **************************************
// MARK: Enabling Auto Layout
// **************************************
#if os(iOS)
    extension View {
    var autoLayoutEnabled : Bool {
    get {return !self.translatesAutoresizingMaskIntoConstraints()}
    set {self.setTranslatesAutoresizingMaskIntoConstraints(!newValue)}
    }
    }
    #else
    extension View {
        var autoLayoutEnabled : Bool {
        get {return self.translatesAutoresizingMaskIntoConstraints == false}
        set {self.translatesAutoresizingMaskIntoConstraints = !newValue}
        }
    }
#endif


// **************************************
// MARK: Format Installation
// **************************************

// Format Installation
func InstallLayoutFormats(formats : NSString[], options : NSLayoutFormatOptions, metrics : NSDictionary, bindings : NSDictionary, priority : Float)
{
    for format in formats
    {
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: bindings) as NSLayoutConstraint[]
        InstallConstraints(constraints, priority)
    }
}

// **************************************
// MARK: Sizing
// **************************************

// Constraining Sizes
func SizeView(view : View, size : CGSize, priority : Float)
{
    let metrics = ["width" : size.width, "height" : size.height]
    let bindings = ["view" : view]
    var formats : String[] = []
    if (size.width != SkipConstraint)
    {
        formats += "H:[view(==width)]"
    }
    if (size.height != SkipConstraint)
    {
        formats += "V:[view(==height)]"
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainMinimumViewSize(view : View, size : CGSize, priority : Float)
{
    let metrics = ["width" : size.width, "height" : size.height]
    let bindings = ["view" : view]
    var formats : String[] = []
    if (size.width != SkipConstraint)
    {
        formats += "H:[view(>=width)]"
    }
    if (size.height != SkipConstraint)
    {
        formats += "V:[view(>=height)]"
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainMaximumViewSize(view : View, size : CGSize, priority : Float)
{
    let metrics = ["width" : size.width, "height" : size.height]
    let bindings = ["view" : view]
    var formats : String[] = []
    if (size.width != SkipConstraint)
    {
        formats += "H:[view(<=width)]"
    }
    if (size.height != SkipConstraint)
    {
        formats += "V:[view(<=height)]"
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

// **************************************
// MARK: Positioning
// **************************************

// Constraining Positions
func PositionView(view : View, point : CGPoint, priority : Float)
{
    if (!view.superview) {return}
    let metrics = ["hLoc" : point.x, "vLoc" : point.y]
    let bindings = ["view" : view]
    var formats : String[] = []
    if (point.x != SkipConstraint)
    {
        formats += "H:|-hLoc-[view]"
    }
    if (point.y != SkipConstraint)
    {
        formats += "V:|-vLoc-[view]"
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainViewToSuperview(view : View, inset : Float, priority : Float)
{
    if (!view.superview) {return}
    let formats = [
        "H:|->=inset-[view]",
        "H:[view]->=inset-|",
        "V:|->=inset-[view]",
        "V:[view]->=inset-|"]
    InstallLayoutFormats(formats, SkipOptions, ["inset":inset], ["view":view], priority)
}

// **************************************
// MARK: Stretching
// **************************************

// Stretching to Superview
func StretchViewHorizontallyToSuperview(view : View, inset : CGFloat, priority : Float)
{
    if (!view.superview) {return}
    let metrics = ["inset" : inset]
    let bindings = ["view" : view]
    let formats = ["H:|-inset-[view]-inset-|"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewVerticallyToSuperview(view : View, inset : CGFloat, priority : Float)
{
    if (!view.superview) {return}
    let metrics = ["inset" : inset]
    let bindings = ["view" : view]
    let formats = ["V:|-inset-[view]-inset-|"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToSuperview(view : View, inset : CGSize, priority : Float)
{
    if (!view.superview) {return}
    if (inset.width != SkipConstraint)
    {
        StretchViewHorizontallyToSuperview(view, inset.width, priority)
    }
    
    if (inset.height != SkipConstraint)
    {
        StretchViewVerticallyToSuperview(view, inset.height, priority)
    }
}

// **************************************
// MARK: Alignment
// **************************************

// Aligning
func AlignViewInSuperview(view : View, attribute : NSLayoutAttribute, inset : CGFloat, priority : Float)
{
    if (!view.superview) {return}
    
    var actualInset : CGFloat
    switch attribute {
    case NSLayoutAttribute.Left, NSLayoutAttribute.Leading, NSLayoutAttribute.Top:
        actualInset = inset * -1.0
    default:
        actualInset = inset
    }
    
    let constraint = NSLayoutConstraint(item:view.superview, attribute:attribute, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: actualInset)
    constraint.installWithPriority(priority)
}

func AlignViews(priority : Float, view1 : View, view2 : View, attribute : NSLayoutAttribute)
{
    let constraint : NSLayoutConstraint = NSLayoutConstraint(item: view1, attribute: attribute, relatedBy: NSLayoutRelation.Equal, toItem: view2, attribute: attribute, multiplier: 1, constant: 0)
    constraint.installWithPriority(priority)
}

// View to View Layout
func CenterViewInSuperview(view : View, horizontal : Bool, vertical : Bool, priority : Float)
{
    if (!view.superview) {return}
    if (horizontal) {AlignViews(priority, view, view.superview, NSLayoutAttribute.CenterX)}
    if (vertical) {AlignViews(priority, view, view.superview, NSLayoutAttribute.CenterY)}
}

func ConstrainView(format : NSString, view : View, priority : Float)
{
    let formats = [format]
    let bindings = ["view" : view]
    let metrics  = NSDictionary()
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainViewPair(format : NSString, view1 : View, view2 : View, priority : Float)
{
    let formats = [format]
    let bindings = ["view1" : view1, "view2" : view2]
    let metrics = NSDictionary()
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainViewArray(priority : Float, format : NSString, viewArray : NSArray)
{
    // Views are named view1, view2, view3...

    let formats = [format]
    let metrics = NSDictionary()
    var bindings = NSMutableDictionary()
    var index : Int = 1 // start at view1
    for eachViewItem : AnyObject in viewArray
    {
        let view = eachViewItem as View
        let key = "view" + "\(index)"
        bindings[key] = view
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainViewsWithBindings(priority : Float, format : NSString, bindings : NSDictionary)
{
    let formats = [format]
    let metrics = NSDictionary()
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

// **************************************
// MARK: iOS Layout Guides
// **************************************

// Working with Layout Guides. iOS Only
#if os(iOS)
func StretchViewToTopLayoutGuide(controller : UIViewController, view : View, inset : NSInteger, priority : Float)
{
    let topGuide = controller.topLayoutGuide
    let metrics = ["vinset":inset]
    let bindings = ["view" : view, "topGuide" : topGuide]
    let formats = ["V:[topGuide]-vinset-[view]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToBottomLayoutGuide(controller : UIViewController, view : View, inset : NSInteger, priority : Float)
{
    let bottomGuide = controller.bottomLayoutGuide
    let metrics = ["vinset":inset]
    let bindings = ["view" : view, "bottomGuide" : bottomGuide]
    let formats = ["V:[view]-vinset-[bottomGuide]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToLeftLayoutGuide(controller : UIViewController, view : View, inset : NSInteger, priority : Float)
{
    let leftGuide = controller.leftLayoutGuide
    let metrics = ["hinset":inset]
    let bindings = ["view" : view, "leftGuide" : leftGuide]
    let formats = ["H:[leftGuide]-hinset-[view]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToRightLayoutGuide(controller : UIViewController, view : View, inset : NSInteger, priority : Float)
{
    let rightGuide = controller.rightLayoutGuide
    let metrics = ["hinset":inset]
    let bindings = ["view" : view, "rightGuide" : rightGuide]
    let formats = ["H:[view]-hinset-[rightGuide]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToController(controller : UIViewController, view : View, inset : CGSize, priority : Float)
{
    StretchViewToTopLayoutGuide(controller, view, NSInteger(inset.height), priority)
    StretchViewToBottomLayoutGuide(controller, view, NSInteger(inset.height), priority)
    StretchViewHorizontallyToSuperview(view, inset.width, priority)
}

// UIViewController extended layout
extension UIViewController {
    func extendLayoutUnderBars(extendLayout : Bool)
    {
        if (extendLayout) {
            self.edgesForExtendedLayout = UIRectEdge.All
        } else {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
    }
}
#endif

// **************************************
// MARK: iOS Quick Layout
// **************************************

#if os(iOS)
    // Quick Layout
    func LayoutThenCleanup(view : View, layout : Void -> Void)
    {
        layout()
        view.layoutIfNeeded()
        if (view.superview) {view.superview.layoutIfNeeded()}
        RemoveConstraints(view.externalConstraintReferences())
    }
#endif


// **************************************
// MARK: iOS Layout Guides
// **************************************

// Hugging and Resistance (iOS)
func SetHuggingPriority(view : View, priority : Float)
{
    #if os(iOS)
        view.setContentHuggingPriority(priority, forAxis: UILayoutConstraintAxis.Horizontal)
        view.setContentHuggingPriority(priority, forAxis: UILayoutConstraintAxis.Vertical)
        #else
        view.setContentHuggingPriority(priority, forOrientation: NSLayoutConstraintOrientation.Horizontal)
        view.setContentHuggingPriority(priority, forOrientation: NSLayoutConstraintOrientation.Vertical)
    #endif
}

func SetResistancePriority(view : View, priority : Float)
{
    #if os(iOS)
        view.setContentCompressionResistancePriority(priority, forAxis: UILayoutConstraintAxis.Horizontal)
        view.setContentCompressionResistancePriority(priority, forAxis: UILayoutConstraintAxis.Vertical)
        #else
        view.setContentCompressionResistancePriority(priority, forOrientation: NSLayoutConstraintOrientation.Horizontal)
        view.setContentCompressionResistancePriority(priority, forOrientation: NSLayoutConstraintOrientation.Vertical)
    #endif
}

// --------------------------------------------------
// MARK: Placement utility
// --------------------------------------------------

func PlaceViewInSuperview(view : View, position: String, inseth : CGFloat, insetv : CGFloat, priority : Float)
{
    if (countElements(position) != 2) {return}
    if (!view.superview) {return}

//    view.autoLayoutEnabled = true
//    view.superview.autoLayoutEnabled = true
    
    let verticalPosition = position.substringToIndex(1)
    let horizontalPosition = position.substringFromIndex(1)
    
    switch verticalPosition {
    case "t":
        AlignViewInSuperview(view, NSLayoutAttribute.Top, insetv, priority)
    case "c":
        AlignViewInSuperview(view, NSLayoutAttribute.CenterY, insetv, priority)
    case "b":
        AlignViewInSuperview(view, NSLayoutAttribute.Bottom, insetv, priority)
    case "x":
        StretchViewVerticallyToSuperview(view, insetv, priority)
    default:
        break
    }
    
    switch horizontalPosition {
        case "l":
            AlignViewInSuperview(view, NSLayoutAttribute.Leading, inseth, priority)
        case "c":
            AlignViewInSuperview(view, NSLayoutAttribute.CenterX, inseth, priority)
        case "r":
            AlignViewInSuperview(view, NSLayoutAttribute.Trailing, inseth, priority)
        case "x":
            StretchViewHorizontallyToSuperview(view, inseth, priority)
    default:
        break
    }
}

#if os(iOS)
func PlaceView(controller : UIViewController, view : UIView, position : String, inseth : CGFloat, insetv : CGFloat, priority : Float)
{
    if (countElements(position) != 2) {return}
    var verticalPosition = position.substringToIndex(1)
    var horizontalPosition = position.substringFromIndex(1)
    
    // Add if needed
    if (!view.superview) {controller.view.addSubview(view)}
    
    // Handle the two stretching cases
    if (position.hasPrefix("x"))
    {
        StretchViewToTopLayoutGuide(controller, view, NSInteger(insetv), priority)
        StretchViewToBottomLayoutGuide(controller, view, NSInteger(insetv), priority)
        verticalPosition = "-"
    }
    
    if (position.hasSuffix("x"))
    {
        StretchViewHorizontallyToSuperview(view, inseth, priority)
        horizontalPosition = "-"
    }
    
    // Otherwise just place in superview
    PlaceViewInSuperview(view, (verticalPosition + horizontalPosition), inseth, insetv, priority)
}
#endif

