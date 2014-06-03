/*
 
 Erica Sadun, http://ericasadun.com
 iOS Auto Layout Demystified

 For now this is iOS only until I can figure out how to properly expand cross platform

 */

import Foundation
import UIKit

let SkipConstraint : Float = CGRectNull.origin.x
let SkipOptions : NSLayoutFormatOptions = NSLayoutFormatOptions.fromMask(0)

// Return nearest common ancestor between two views
func NearestCommonViewAncestor(view1 : UIView, view2 : UIView) -> (UIView?)
{
    if (view1 === view2) {return view1}
    
    // Collect superviews
    
    var array1 : NSMutableArray = NSMutableArray()
    array1.addObject(view1)
    var view : UIView? = nil
    
    view = view1.superview
    while (view != nil)
    {
        array1.addObject(view)
        view = (view as UIView).superview
    }
    
    var array2 : NSMutableArray = NSMutableArray()
    array2.addObject(view2)

    view = view2.superview
    while (view != nil)
    {
        array2.addObject(view)
        view = (view as UIView).superview
    }
    
    // Check for superview relationships
    if (array1.containsObject(view2)) {return view2}
    if (array2.containsObject(view1)) {return view1}
    
    // Check for indirect ancestor
    for eachItem : AnyObject in array1
    {
        let eachView : UIView = eachItem as UIView
        if (array2.containsObject(eachView)) {return eachView}
    }
    
    return nil
}

// NSLayoutConstraint Extensions
extension NSLayoutConstraint
{
    func install() -> (Bool)
    {
        let firstView : UIView = self.firstItem as UIView
        let secondView : UIView = self.secondItem as UIView
        
        if (secondView === nil)
        {
            firstView.addConstraint(self)
            return true
        }
        
        let ncaView : UIView? = NearestCommonViewAncestor(firstView, secondView)
        if (ncaView === nil)
        {
            println("Error: Constraint cannot be installed. No common ancestor between items")
            return false
        }
        
        (ncaView as UIView).addConstraint(self)
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
        
        if (self.secondItem === nil)
        {
            let view : UIView = self.firstItem as UIView
            view.removeConstraint(self)
            return
        }
        
        let firstView : UIView = self.firstItem as UIView
        let secondView : UIView = self.secondItem as UIView

        let ncaView : UIView? = NearestCommonViewAncestor(firstView, secondView)
        
        // This should not happen
        if (!ncaView)
        {
            println("Error: no common ancestor. This should not happen")
            return
        }
        
        (ncaView as UIView).removeConstraint(self)
    }
    
    func refersToView(theView : UIView) -> (Bool)
    {
        if (self.secondItem === nil)
        {
            let view : UIView = self.firstItem as UIView
            return (view === theView)
        }
        
        let firstView : UIView = self.firstItem as UIView
        let secondView : UIView = self.secondItem as UIView
        
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
        let constraint : NSLayoutConstraint = item as NSLayoutConstraint
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        constraint.installWithPriority(priority)
    }
}

func InstallConstraints(constraints : NSArray)
{
    for item : AnyObject in constraints
    {
        let constraint : NSLayoutConstraint = item as NSLayoutConstraint
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

// References

// External constraints
func ExternalConstraintsReferencingView(view : UIView) -> (NSArray)
{
    var superviews : NSMutableArray = NSMutableArray()
    var aView : UIView? = view.superview
    while (aView != nil)
    {
        superviews.addObject(view)
        aView = (aView as UIView).superview
    }
    
    var constraints : NSMutableArray = NSMutableArray()
    for eachSuperview : AnyObject in superviews
    {
        let superview = eachSuperview as UIView
        for eachConstraint : AnyObject in superview.constraints()
        {
            let constraint : NSLayoutConstraint = eachConstraint as NSLayoutConstraint
            if (constraint.refersToView(view))
            {
                constraints.addObject(constraint)
            }
        }
    }
    
    return constraints
}

// Return sizing constraints
func InternalConstraintsReferencingView(view : UIView) -> (NSArray)
{
    var constraints : NSMutableArray = NSMutableArray()
    for eachConstraint : AnyObject in view.constraints()
    {
        let constraint : NSLayoutConstraint = eachConstraint as NSLayoutConstraint
        if (!constraint.isMemberOfClass(NSLayoutConstraint)) {continue}
        if (constraint.refersToView(view))
        {
            constraints.addObject(constraint)
        }
    }
    return constraints
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

func ConstrainMinimumViewSize(view : UIView, size : CGSize, priority : Float)
{
    let metrics : NSDictionary = ["width" : size.width, "height" : size.height]
    let bindings : NSDictionary = ["view" : view]
    let formats : NSMutableArray = [] as NSMutableArray
    if (size.width != SkipConstraint)
    {
        formats.addObject("H:[view(>=width)]")
    }
    if (size.height != SkipConstraint)
    {
        formats.addObject("V:[view(>=height)]")
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainMaximumViewSize(view : UIView, size : CGSize, priority : Float)
{
    let metrics : NSDictionary = ["width" : size.width, "height" : size.height]
    let bindings : NSDictionary = ["view" : view]
    let formats : NSMutableArray = [] as NSMutableArray
    if (size.width != SkipConstraint)
    {
        formats.addObject("H:[view(<=width)]")
    }
    if (size.height != SkipConstraint)
    {
        formats.addObject("V:[view(<=height)]")
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func SizeView(view : UIView, size : CGSize, priority : Float)
{
    if (!view.superview) {return}
    let metrics : NSDictionary = ["width" : size.width, "height" : size.height]
    let bindings : NSDictionary = ["view" : view]
    let formats : NSMutableArray = [] as NSMutableArray
    if (size.width != SkipConstraint)
    {
        formats.addObject("H:[view(==width)]")
    }
    if (size.height != SkipConstraint)
    {
        formats.addObject("V:[view(==height)]")
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

// Constraining Positions

func PositionView(view : UIView, point : CGPoint, priority : Float)
{
    if (!view.superview) {return}
    let metrics : NSDictionary = ["hLoc" : point.x, "vLoc" : point.y]
    let bindings : NSDictionary = ["view" : view]
    let formats : NSMutableArray = [] as NSMutableArray
    if (point.x != SkipConstraint)
    {
        formats.addObject("H:|-hLoc-[view]")
    }
    if (point.y != SkipConstraint)
    {
        formats.addObject("V:|-vLoc-[view]")
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainViewToSuperview(view : UIView, inset : Float, priority : Float)
{
    if (!view.superview) {return}
    let formats : NSArray = [
        "H:|->=inset-[view]",
        "H:[view]->=inset-|",
        "V:|->=inset-[view]",
        "V:[view]->=inset-|"]
    InstallLayoutFormats(formats, SkipOptions, ["inset":inset], ["view":view], priority)
}

// Stretching

func StretchViewHorizontallyToSuperview(view : UIView, inset : Float, priority : Float)
{
    if (!view.superview) {return}
    let metrics : NSDictionary = ["inset" : inset]
    let bindings : NSDictionary = ["view" : view]
    let formats : NSArray = ["H:|-inset-[view]-inset-|"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewVerticallyToSuperview(view : UIView, inset : Float, priority : Float)
{
    if (!view.superview) {return}
    let metrics : NSDictionary = ["inset" : inset]
    let bindings : NSDictionary = ["view" : view]
    let formats : NSArray = ["V:|-inset-[view]-inset-|"]
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

func AlignViewInSuperview(view : UIView, attribute : NSLayoutAttribute, inset : Float, priority : Float)
{
    var actualInset : Float = inset
    
    if (!view.superview) {return}
    switch attribute {
    case NSLayoutAttribute.Baseline, NSLayoutAttribute.CenterX, NSLayoutAttribute.CenterY, NSLayoutAttribute.Width, NSLayoutAttribute.Height:
        println("Error: Unsupported alignment attribute")
        return
    case NSLayoutAttribute.Left, NSLayoutAttribute.Leading, NSLayoutAttribute.Top:
        actualInset = actualInset * -1
    default:
        return
    }

    let constraint : NSLayoutConstraint = NSLayoutConstraint(item:view.superview, attribute:attribute, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: attribute, multiplier: 1, constant: actualInset)
    constraint.installWithPriority(priority)
}

func AlignViews(priority : Float, view1 : UIView, view2 : UIView, attribute : NSLayoutAttribute)
{
    let constraint : NSLayoutConstraint = NSLayoutConstraint(item: view1, attribute: attribute, relatedBy: NSLayoutRelation.Equal, toItem: view2, attribute: attribute, multiplier: 1, constant: 0)
    constraint.installWithPriority(priority)
}

// View to View layout
func CenterViewInSuperview(view : UIView, horizontal : Bool, vertical : Bool, priority : Float)
{
    if (!view.superview) {return}
    if (horizontal) {AlignViews(priority, view, view.superview, NSLayoutAttribute.CenterX)}
    if (vertical) {AlignViews(priority, view, view.superview, NSLayoutAttribute.CenterY)}
}

func ConstrainView(format : NSString, view : UIView, priority : Float)
{
    let formats : NSArray = [format] as NSArray
    let bindings : NSDictionary = ["view" : view] as NSDictionary
    let metrics : NSDictionary = NSDictionary()
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainviewPair(format : NSString, view1 : UIView, view2 : UIView, priority : Float)
{
    let formats : NSArray = [format] as NSArray
    let bindings : NSDictionary = ["view1" : view1, "view2" : view2] as NSDictionary
    let metrics : NSDictionary = NSDictionary()
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

// Views are named view1, view2, view3...
func ConstrainViewArray(priority : Float, format : NSString, viewArray : NSArray)
{
    let formats : NSArray = [format] as NSArray
    let metrics : NSDictionary = NSDictionary()
    let bindings : NSMutableDictionary = NSMutableDictionary()
    var index : Int = 1
    for eachViewItem : AnyObject in viewArray
    {
        let view : UIView = eachViewItem as UIView
        let key : NSString = "view" + "\(index)"
        bindings[key] = view
    }
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func ConstrainViewsWithBindings(priority : Float, format : NSString, bindings : NSDictionary)
{
    let formats : NSArray = [format] as NSArray
    let metrics : NSDictionary = NSDictionary()
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

// Layout Guides
func StretchViewToTopLayoutGuide(controller : UIViewController, view : UIView, inset : NSInteger, priority : Float)
{
    let topGuide : AnyObject = controller.topLayoutGuide
    let metrics : NSDictionary = ["vinset":inset]
    let bindings : NSDictionary = ["view" : view, "topGuide" : topGuide]
    let formats : NSArray = ["V:[topGuide]-vinset-[view]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToBottomLayoutGuide(controller : UIViewController, view : UIView, inset : NSInteger, priority : Float)
{
    let bottomGuide : AnyObject = controller.bottomLayoutGuide
    let metrics : NSDictionary = ["vinset":inset]
    let bindings : NSDictionary = ["view" : view, "bottomGuide" : bottomGuide]
    let formats : NSArray = ["V:[view]-vinset-[bottomGuide]"]
    InstallLayoutFormats(formats, SkipOptions, metrics, bindings, priority)
}

func StretchViewToController(controller : UIViewController, view : UIView, inset : CGSize, priority : Float)
{
    let topGuide : AnyObject = controller.topLayoutGuide
    let bottomGuide : AnyObject = controller.bottomLayoutGuide
    
    let metrics : NSDictionary = ["hinset":inset.width, "vinset":inset.height]
    let bindings : NSDictionary = ["view" : view, "topGuide" : topGuide, "bottomGuide" : bottomGuide]
    let formats : NSArray = ["V:[topGuide]-vinset-[view]-vinset-[bottomGuide]", "H:|-hinset-[view]-hinset-|"]
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

// UIViewController

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

