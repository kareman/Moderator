[![Build Status](https://travis-ci.org/kareman/Moderator.svg?branch=master)](https://travis-ci.org/kareman/Moderator) ![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20WatchOS%20%7C%20Linux-lightgrey.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Moderator

Moderator is a simple Swift library for parsing commandline arguments.

## Features

- [x] Modular, easy to extend.
- [x] Handles arguments of the type '--option=value'.
- [x] Optional strict parsing, where an error is thrown if there are any unrecognised arguments.
- [x] Any arguments after an "\--" argument are taken literally, they are not parsed as options and any '=' are left untouched.

## Example

```swift
let arguments = Moderator(description: "Automatically add code to Swift Package Manager projects to run unit tests on Linux.")
let overwrite = arguments.add(.option("o","overwrite", description: "Replace <test directory>/LinuxMain.swift if it already exists."))
let testdirarg = arguments.add(Argument<String>
	.optionWithValue("testdir", name: "test directory", description: "The path to the directory with the unit tests.")
	.default("Tests"))
_ = arguments.add(Argument<String?>
	.singleArgument(name: "directory", description: "The project root directory.")
	.default("./")
	.map { (projectpath: String) in
		let projectdir = try Directory(open: projectpath)
		try projectdir.verifyContains("Package.swift")
		Directory.current = projectdir
	})

do {
	try arguments.parse()

	let testdir = try Directory(open: testdirarg.value)
	if !overwrite.value && testdir.contains("LinuxMain.swift") {
		throw ArgumentError(errormessage: "\(testdir.path)/LinuxMain.swift already exists. Use -o/--overwrite to replace it.")
	}
	...
} catch {
	WritableFile.stderror.print(error)
	exit(Int32(error._code))
}
```

Automatically generated help text: 

```text
Automatically add code to Swift Package Manager projects to run unit tests on Linux.

Usage: linuxmain-generator
  -o,--overwrite:
      Replace <test directory>/LinuxMain.swift if it already exists.
  --testdir <test directory>:
      The path to the directory with the unit tests. Default = 'Tests'.
  <directory>:
      The project root directory. Default = './'.
```


## Built-in parsers

To do

## Add new parsers 

To do

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

