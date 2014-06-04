/*
 
 Erica Sadun, http://ericasadun.com
 iOS Auto Layout Demystified

 For now this is iOS only until I can figure out how to properly expand cross platform

 */

import Foundation
import UIKit

let SkipConstraint = CGRectNull.origin.x
let SkipOptions = NSLayoutFormatOptions.fromMask(0)

// Return superviews
func Superviews(view : UIView) -> (UIView[])
{
    var array : UIView[] = []
    var currentView = view.superview
    
    while (currentView != nil)
    {
        array += currentView
        currentView = currentView.superview
    }
    return array
}

// Return nearest common ancestor between two views
func NearestCommonViewAncestor(view1 : UIView, view2 : UIView) -> (UIView?)
{
    if (view1 === view2) {return view1}
    
    var view1Superviews = Superviews(view1)
    var view2Superviews = Superviews(view2)
    
    // Check for superview relationships
    if ContainsObject(view1Superviews, view2) {return view2}
    if ContainsObject(view2Superviews, view1) {return view1}
    
    // Check for indirect ancestor
    for eachItem in view1Superviews
    {
        if ContainsObject(view2Superviews, eachItem) {return eachItem}
    }
    
    return nil
}

// NSLayoutConstraint Extensions
extension NSLayoutConstraint
{
    func install() -> (Bool)
    {
        if (self.firstItem === nil)
        {
            println("Error: This should never happen. Missing first item")
            return false
        }
        
        let firstView = self.firstItem as UIView

        if (self.secondItem === nil)
        {
            firstView.addConstraint(self)
            return true
        }
        
        let secondView = self.secondItem as UIView
        
        let ncaView = NearestCommonViewAncestor(firstView, secondView)
        if (ncaView === nil)
        {
            println("Error: Constraint cannot be installed. No common ancestor between items")
            return false
        }
        
        ncaView!.addConstraint(self)
        return true
    }
    
    func installWithPriority(priority : Float) -> (Bool)
    {
        self.priority = UILayoutPriority.abs(priority)
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
            let view : UIView = self.firstItem as UIView
            view.removeConstraint(self)
            return
        }
        
        let firstView = self.firstItem as UIView
        let secondView = self.secondItem as UIView
        let ncaView = NearestCommonViewAncestor(firstView, secondView)
        
        // This should not happen
        if (!ncaView)
        {
            println("Error: no common ancestor. This should not happen")
            return
        }
        
        ncaView!.removeConstraint(self)
    }
    
    func refersToView(theView : UIView) -> (Bool)
    {
        if (self.firstItem === nil)
        {
            println("Error: This should never happen. Missing first item")
            return false
        }

        if (self.secondItem === nil)
        {
            let view : UIView = self.firstItem as UIView
            return (view === theView)
        }
        
        let firstView = self.firstItem as UIView
        let secondView = self.secondItem as UIView
        
        if (firstView === theView) {return true}
        if (secondView === theView) {return true}
        return false
    }
}

// Installation

func InstallConstraints(constraints : NSArray, priority : Float)
{
    for item : AnyObject in constraints
    {
        let constraint = item as NSLayoutConstraint
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        constraint.installWithPriority(priority)
    }
}

func InstallConstraints(constraints : NSArray)
{
    for item : AnyObject in constraints
    {
        let constraint = item as NSLayoutConstraint
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        constraint.install()
    }
}

func RemoveConstraints(constraints : NSArray)
{
    for item : AnyObject in constraints
    {
        let constraint : NSLayoutConstraint = item as NSLayoutConstraint
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        constraint.remove()
    }
}

// The following items currently work in NSArray to stay in Foundation

// External constraint references
func ExternalConstraintsReferencingView(view : UIView) -> (NSArray)
{
    var superviews = Superviews(view)
    var constraints : NSLayoutConstraint[] = []
    for superview : UIView in superviews
    {
        for eachConstraint : AnyObject in superview.constraints()
        {
            let constraint = eachConstraint as NSLayoutConstraint
            if (constraint.refersToView(view))
            {
                constraints += constraint
            }
        }
    }    
    return constraints as NSArray
}

// Internal constraint references
func InternalConstraintsReferencingView(view : UIView) -> (NSArray)
{
    var constraints : NSLayoutConstraint[] = []
    for eachConstraint : AnyObject in view.constraints()
    {
        let constraint = eachConstraint as NSLayoutConstraint
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        if (constraint.refersToView(view))
        {
            constraints += constraint
        }
    }
    return constraints as NSArray
}

func ConstraintsReferencingView(view : UIView) -> (NSArray)
{
    let internal : NSArray = InternalConstraintsReferencingView(view)
    let external : NSArray = ExternalConstraintsReferencingView(view)
    return internal.arrayByAddingObjectsFromArray(external)
}

extension UIView
{
    func externalConstraintReferences() -> (NSArray)
    {
        return ExternalConstraintsReferencingView(self)
    }
    
    func internalConstraintReferences() -> (NSArray)
    {
        return InternalConstraintsReferencingView(self)
    }
    
    func nearestCommonAncestorWithView(view : UIView) -> (UIView?)
    {
        return NearestCommonViewAncestor(self, view)
    }
    
    func autoLayoutEnabled() -> (Bool)
    {
        return !self.translatesAutoresizingMaskIntoConstraints()
    }
    
    func setAutoLayoutEnabled(autoLayoutEnabled : Bool)
    {
        self.setTranslatesAutoresizingMaskIntoConstraints(!autoLayoutEnabled)
    }
}

// Format Installation

func InstallLayoutFormats(formats : NSArray, options : NSLayoutFormatOptions, metrics : NSDictionary, bindings : NSDictionary, priority : Float)
{
    for eachFormat : AnyObject in formats
    {
        let format : NSString = eachFormat as NSString
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: bindings)
        InstallConstraints(constraints, priority)
    }
}

// Constraining Sizes

func SizeView(view : UIView, size : CGSize, priority : Float)
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

func ConstrainMinimumViewSize(view : UIView, size : CGSize, priority : Float)
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

func ConstrainMaximumViewSize(view : UIView, size : CGSize, priority : Float)
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

func PositionView(view : UIView, point : CGPoint, priority : Float)
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

func ConstrainViewToSuperview(view : UIView, inset : Float, priority : Float)
{
    if (!view.superview) {return}
    let formats = [
        "H:|->=inset-[view]",
        "H:[view]->=inset-|",
        "V:|->=inset-[view]",
        "V:[view]->=inset-|"]
    InstallLayoutFormats(formats, SkipOptions, ["inset":inset], ["view":view], priority)
}

// Stretching

func StretchViewHorizontallyToSuperview(view : UIView, inset : CGFloat, priority : Float)
{
    if (!view.superview) {return}
    let metrics = ["inset" : inset]
    let bindings = ["view" : view]
    let formats = ["H:|-inset-[view]-inset-|"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewVerticallyToSuperview(view : UIView, inset : CGFloat, priority : Float)
{
    if (!view.superview) {return}
    let metrics = ["inset" : inset]
    let bindings = ["view" : view]
    let formats = ["V:|-inset-[view]-inset-|"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToSuperview(view : UIView, inset : CGSize, priority : Float)
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

func AlignViewInSuperview(view : UIView, attribute : NSLayoutAttribute, inset : CGFloat, priority : Float)
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

func AlignViews(priority : Float, view1 : UIView, view2 : UIView, attribute : NSLayoutAttribute)
{
    let constraint : NSLayoutConstraint = NSLayoutConstraint(item: view1, attribute: attribute, relatedBy: NSLayoutRelation.Equal, toItem: view2, attribute: attribute, multiplier: 1, constant: 0)
    constraint.installWithPriority(priority)
}

// View to View Layout

func CenterViewInSuperview(view : UIView, horizontal : Bool, vertical : Bool, priority : Float)
{
    if (!view.superview) {return}
    if (horizontal) {AlignViews(priority, view, view.superview, NSLayoutAttribute.CenterX)}
    if (vertical) {AlignViews(priority, view, view.superview, NSLayoutAttribute.CenterY)}
}

func ConstrainView(format : NSString, view : UIView, priority : Float)
{
    let formats = [format]
    let bindings = ["view" : view]
    let metrics  = NSDictionary()
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainviewPair(format : NSString, view1 : UIView, view2 : UIView, priority : Float)
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
        let view = eachViewItem as UIView
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

// Working with Layout Guides

func StretchViewToTopLayoutGuide(controller : UIViewController, view : UIView, inset : NSInteger, priority : Float)
{
    let topGuide = controller.topLayoutGuide
    let metrics = ["vinset":inset]
    let bindings = ["view" : view, "topGuide" : topGuide]
    let formats = ["V:[topGuide]-vinset-[view]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToBottomLayoutGuide(controller : UIViewController, view : UIView, inset : NSInteger, priority : Float)
{
    let bottomGuide = controller.bottomLayoutGuide
    let metrics = ["vinset":inset]
    let bindings = ["view" : view, "bottomGuide" : bottomGuide]
    let formats = ["V:[view]-vinset-[bottomGuide]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToController(controller : UIViewController, view : UIView, inset : CGSize, priority : Float)
{
    let topGuide = controller.topLayoutGuide
    let bottomGuide = controller.bottomLayoutGuide
    let metrics = ["hinset":inset.width, "vinset":inset.height]
    let bindings = ["view" : view, "topGuide" : topGuide, "bottomGuide" : bottomGuide]
    let formats = ["V:[topGuide]-vinset-[view]-vinset-[bottomGuide]", "H:|-hinset-[view]-hinset-|"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

// Integration

func LayoutThenCleanup(view : UIView, layout : Void -> Void)
{
    layout()
    view.layoutIfNeeded()
    if (view.superview) {view.superview.layoutIfNeeded()}
    RemoveConstraints(view.externalConstraintReferences())
}

// UIViewController extended layout

extension UIViewController
{
    func extendLayoutUnderBars(extendLayout : Bool)
    {
        if (extendLayout)
        {
            self.edgesForExtendedLayout = UIRectEdge.All
        }
        else
        {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
    }    
}

// UIView

func SetHuggingPriority(view : UIView, priority : Float)
{
    view.setContentHuggingPriority(priority, forAxis: UILayoutConstraintAxis.Horizontal)
    view.setContentHuggingPriority(priority, forAxis: UILayoutConstraintAxis.Vertical)
}

func SetResistancePriority(view : UIView, priority : Float)
{
    view.setContentCompressionResistancePriority(priority, forAxis: UILayoutConstraintAxis.Horizontal)
    view.setContentCompressionResistancePriority(priority, forAxis: UILayoutConstraintAxis.Vertical)
}

