[![Build Status](https://travis-ci.org/kareman/Moderator.svg?branch=master)](https://travis-ci.org/kareman/Moderator) ![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20WatchOS%20%7C%20Linux-lightgrey.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Moderator

Moderator is a Swift library for parsing commandline arguments.

## Features

- [x] 

## Example

```swift
let arguments = Moderator()
let overwrite = arguments.add(.option("o","overwrite", description: "Replace Tests/LinuxMain.swift if it already exists."))
_ = arguments.add(Argument<String?>
	.singleArgument(name: "directory", description: "The project root directory")
	.default("./")
	.map { (projectpath:String) in
		let projectdir = try Directory(open: projectpath)
		try projectdir.verifyContains("Package.swift")
		if !overwrite.value && projectdir.contains("Tests/LinuxMain.swift") {
			throw ArgumentError(errormessage: (projectpath == "./" ? "" : projectdir.path.string + "/")
				+ "Tests/LinuxMain.swift already exists. Use -o/--overwrite to replace it.")
		}
		Directory.current = projectdir
	})

do {
	try arguments.parse()
	
} catch {

}
```

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add `.Package(url: "https://github.com/kareman/Moderator", "0.4.0-beta")` to your Package.swift:

```swift
import PackageDescription

let package = Package(
	name: "somename",
	dependencies: [
		.Package(url: "https://github.com/kareman/Moderator", "0.4.0-beta")
		 ]
	)
```

and run `swift build`.

### [Carthage](https://github.com/Carthage/Carthage)

Add `github "kareman/Moderator"` to your Cartfile, then run `carthage update` and add the resulting framework to the "Embedded Binaries" section of the application. See [Carthage's README][carthage-installation] for further instructions.

[carthage-installation]: https://github.com/Carthage/Carthage/blob/master/README.md#adding-frameworks-to-an-application

### [CocoaPods](https://cocoapods.org/)

Add `Moderator` to your `Podfile`.

```Ruby
pod "Moderator", git: "https://github.com/kareman/Moderator.git"
```

Then run `pod install` to install it.

## License

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)

