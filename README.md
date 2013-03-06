Auto-Layout-Demystified
=======================

Welcome to the source code repository for Auto Layout Demystified. 

Sample code is never a fixed target. It continues to evolve as Apple updates its SDK and the CocoaTouch libraries. 

Get involved. You can pitch in by suggesting bug fixes and corrections as well as by expanding the code that's on offer. 

Github allows you to fork repositories and grow them with your own tweaks and features, and share those back to the main repository. If you come up with a new idea or approach, let us know. We'd be happy to include great suggestions both at the repository and in the next edition of this cookbook.

<h3>About the Book</h3>
Auto Layout Demystified is written for experienced developers who want to build constraint-based interfaces. It helps to be already be familiar with Objective-C, the Cocoa frameworks, and the Xcode Tools. 

<h3>What's the deal with main.m?</h3>
For the sake of pedagogy, this book's sample code usually centers around a single main.m file. This is not how people normally develop iOS or Cocoa applications, or *should* be developing them, but it provides a great way of presenting a single big idea. 

It's hard to tell a story when readers must look through many individual files at once. Offering a single file starting point concentrates that story, allowing access to that idea in a single chunk.

<h3>How to build these projects</h3>
You should be able to build these projects for the simulator or use your team provision to build and deploy to devices. Before compiling, make sure you select a deployment target using the pop-up menu at the top-left of the Xcode window. 

The samples for this book use a single application identifier, com.sadun.helloworld. This book avoids clogging up your iOS device with dozens of samples at once. Each sample replaces the previous one, ensuring that SpringBoard remains relatively uncluttered. 

If you want to install several samples at once, simply edit the identifier, adding a unique suffix, such as com.sadun.helloworld.table-edits. You'll want to edit the display name so you can tell instantly which project is which. Samples use the same icons and launch images as well.

<h3>"Some feature does not work on OS X"</h3>
As the book title says, this is an iOS-specific work. I've included OS X support wherever possible. I do know that I caught one big bug in the later chapters that hasn't propagated back to the early ones. If you deploy to OS X and encounter an error with UIViewNoIntrinsicMetric, please add the following:

<pre>#ifndef UIViewNoIntrinsicMetric
#define UIViewNoIntrinsicMetric -1
#endif</pre>

If you find any stray UIKit includes (I tried to smite those I found), please let me know and I'll try to update as well.
