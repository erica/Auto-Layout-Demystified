//
//  CrossPlatformDefines.swift
//  SwiftWorld
//
//  Created by Erica Sadun on 6/10/14.
//  Copyright (c) 2014 Erica Sadun. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
    #else
    import Cocoa
    import AppKit
#endif

#if os(iOS)
    typealias View = UIView
    typealias Font = UIFont
    typealias Color = UIColor
    typealias Image = UIImage
    #else
    typealias View = NSView
    typealias Font = NSFont
    typealias Color = NSColor
    typealias Image = NSImage
#endif
