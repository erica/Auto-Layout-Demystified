/*
 
 Erica Sadun, http://ericasadun.com
 Auto Layout Demystified

*/

import Foundation
import ObjectiveC
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

#if os(iOS)
// Uncomment this if you do not have the cross-platform material defined elsewhere
//    typealias View = UIView
#else
// This assumes View is not aliased in the Mac Pack
    typealias View = NSView
#endif

#if os(iOS)
#else
    // Utility, normally included with iOS Utility Pack
    extension Array {
        func containsObject(testItem:AnyObject) -> Bool
        {
            return (self as NSArray).containsObject(testItem)
        }
        
        func indexOfObject(object : AnyObject) -> NSInteger
        {
            return (self as NSArray).indexOfObject(object)
        }
        
        mutating func removeObject(object : AnyObject)
        {
            let index = self.indexOfObject(object)
            if (index == NSNotFound) {
                println("Error: object \(object) not found in array")
                return
            }
            
            self.removeAtIndex(index)
        }
        
        func objectAtIndex(index : Int) -> AnyObject?
        {
            if ((index >= 0) && (index < self.count)) {
                return (self as NSArray).objectAtIndex(index)
            }
            
            return nil
        }
    }
#endif

let SkipConstraint = CGRectNull.origin.x
let SkipOptions = NSLayoutFormatOptions.fromMask(0)

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
    if view1Superviews.containsObject(view2) {return view2}
    if view2Superviews.containsObject(view1) {return view1}
    
    // Check for indirect ancestor
    for eachItem in view1Superviews
    {
        if view2Superviews.containsObject(eachItem) {return eachItem}
    }
    
    return nil
}

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
    
    func refersToView(theView : View) -> Bool
    {
        if (self.firstItem === nil)
        {
            println("Error: This should never happen. Missing first item")
            return false
        }

        if (self.secondItem === nil)
        {
            let view : View = self.firstItem as View
            return (view === theView)
        }
        
        let firstView = self.firstItem as View
        let secondView = self.secondItem as View
        
        if (firstView === theView) {return true}
        if (secondView === theView) {return true}
        return false
    }
}

// Installation

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
    
    func nearestCommonAncestorWithView(view : View) -> (View?)
    {
        return NearestCommonViewAncestor(self, view)
    }
    
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

#if os(iOS)
extension View
{
    // Computed property makes Xcode compilation go boom
//    var autoLayoutEnabled: Bool {
//    get {return !self.translatesAutoresizingMaskIntoConstraints()}
//    set {self.setTranslatesAutoresizingMaskIntoConstraints(!newValue)}
//    }
    
    func autoLayoutEnabled() -> Bool
    {
        return !self.translatesAutoresizingMaskIntoConstraints()
    }
    
    func setAutoLayoutEnabled(autoLayoutEnabled : Bool)
    {
        self.setTranslatesAutoresizingMaskIntoConstraints(!autoLayoutEnabled)
    }
}
#elseif os(OSX)
extension View
{
    func autoLayoutEnabled() -> Bool
    {
        return !self.translatesAutoresizingMaskIntoConstraints
    }

    func setAutoLayoutEnabled(autoLayoutEnabled : Bool)
    {
        self.translatesAutoresizingMaskIntoConstraints = !autoLayoutEnabled
    }
}
#endif



// Format Installation

func InstallLayoutFormats(formats : NSString[], options : NSLayoutFormatOptions, metrics : NSDictionary, bindings : NSDictionary, priority : Float)
{
    for format in formats
    {
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: bindings) as NSLayoutConstraint[]
        InstallConstraints(constraints, priority)
    }
}

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

func ConstrainviewPair(format : NSString, view1 : View, view2 : View, priority : Float)
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
    StretchViewToLeftLayoutGuide(controller, view, NSInteger(inset.width), priority)
    StretchViewToRightLayoutGuide(controller, view, NSInteger(inset.width), priority)
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
    
// Quick Layout
func LayoutThenCleanup(view : View, layout : Void -> Void)
{
    layout()
    view.layoutIfNeeded()
    if (view.superview) {view.superview.layoutIfNeeded()}
    RemoveConstraints(view.externalConstraintReferences())
}

// Hugging and Resistance (iOS)
func SetHuggingPriority(view : View, priority : Float)
{
    view.setContentHuggingPriority(priority, forAxis: UILayoutConstraintAxis.Horizontal)
    view.setContentHuggingPriority(priority, forAxis: UILayoutConstraintAxis.Vertical)
}
    
func SetResistancePriority(view : View, priority : Float)
{
    view.setContentCompressionResistancePriority(priority, forAxis: UILayoutConstraintAxis.Horizontal)
    view.setContentCompressionResistancePriority(priority, forAxis: UILayoutConstraintAxis.Vertical)
}

#else
    
// Hugging and Resistance (OS X)
func SetHuggingPriority(view : View, priority : Float)
{
    view.setContentHuggingPriority(priority, forOrientation: NSLayoutConstraintOrientation.Horizontal)
    view.setContentHuggingPriority(priority, forOrientation: NSLayoutConstraintOrientation.Vertical)
}

func SetResistancePriority(view : View, priority : Float)
{
    view.setContentCompressionResistancePriority(priority, forOrientation: NSLayoutConstraintOrientation.Horizontal)
    view.setContentCompressionResistancePriority(priority, forOrientation: NSLayoutConstraintOrientation.Vertical)
}

#endif

