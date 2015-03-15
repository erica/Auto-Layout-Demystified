/*

 http://ericasadun.com

*/

import Foundation

// Frameworks
#if os(iOS)
    import UIKit
    #else
    import Cocoa
    import AppKit
#endif

// UIKit/Cocoa Classes
#if os(iOS)
    public typealias View = UIView
    public typealias Font = UIFont
    public typealias Color = UIColor
    public typealias Image = UIImage
    public typealias BezierPath = UIBezierPath
    #else
    public typealias View = NSView
    public typealias Font = NSFont
    public typealias Color = NSColor
    public typealias Image = NSImage
    public typealias BezierPath = NSBezierPath
#endif

// Auto Layout
#if os(iOS)
    public typealias LayoutPriority = UILayoutPriority
    #else
    public typealias LayoutPriority = NSLayoutPriority
#endif
