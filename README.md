[Run shell commands](https://github.com/kareman/SwiftShell)    |    Parse command line arguments | [Handle files and directories](https://github.com/kareman/FileSmith)

---

[![Build Status](https://travis-ci.org/kareman/Moderator.svg?branch=master)](https://travis-ci.org/kareman/Moderator) ![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux-lightgrey.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Moderator

Moderator is a simple Swift library for parsing commandline arguments.

## Features

- [x] Modular, easy to extend.
- [x] Generates help text automatically.
- [x] Handles arguments of the type '--option=value'.
- [x] Optional strict parsing, where an error is thrown if there are any unrecognised arguments.
- [x] Any arguments after an "\--" argument are taken literally, they are not parsed as options and any '=' are left untouched.

## Example

from [linuxmain-generator](https://github.com/kareman/linuxmain-generator):

```Swift
import Moderator
import FileSmith

let arguments = Moderator(description: "Automatically add code to Swift Package Manager projects to run unit tests on Linux.")
let overwrite = arguments.add(.option("o","overwrite", description: "Replace <test directory>/LinuxMain.swift if it already exists."))
let testdirarg = arguments.add(Argument<String?>
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

## Introduction

Moderator works by having a single Moderator object which you add individual argument parsers to. When you start parsing it goes through each argument parser _in the order they were added_. Each parser takes the array of string arguments from the command line, finds the arguments it is responsible for, processes them and throws any errors if anything is wrong, _removes the arguments from the array_, returns its output (which for some parsers may be nil if the argument was not found) and passes the modified array to the next parser.

This keeps the code simple and each parser only has to take care of its own arguments. The built-in parsers can easily be customised, and you can create your own parsers from scratch.

## Built-in parsers

### Option

```swift
func option(_ names: String..., description: String? = nil) -> Argument<Bool>
```

Handles option arguments like `-h` and `--help`. Returns true if the argument is present and false otherwise.

### Option with value

```swift
func optionWithValue(_ names: String..., name valuename: String? = nil, description: String? = nil)
-> Argument<String?>
```

Handles option arguments with a following value, like `--help <topic>`. It returns the value as a String, or nil if the option is not present.

### Single argument

```swift
func singleArgument(name: String, description: String? = nil) -> Argument<String?>
```

Returns the next argument, or nil if there are no more arguments or the next argument is an option. Must be added after any option parsers.

## Customise

### `default`

Can be used on parsers returning optionals, to replace nil with a default value.

### `required`

Can be used on parsers returning optionals, to throw an error on nil.

### `map`

Takes the output of any argument parser and converts it to something else.

## Add new parsers 

If the built in parsers and customisations are not enough, you can easily create your own parsers. As an example here is the implementation of the singleArgument parser:

```swift
extension Argument {
	public static func singleArgument (name: String, description: String? = nil) -> Argument<String?> {
		return Argument<String?>(usage: description.map { ("<"+name+">", $0) }) { args in
			let index = args.first == "--" ? args.index(after: args.startIndex) : args.startIndex
			guard index != args.endIndex, !isOption(index: index, args: args) else { return (nil, args) }
			var args = args
			return (args.remove(at: index), args)
		}
	}
}
```

In the Argument initialiser you return a tuple with the output of the parser and the arguments array without the processed argument(s).

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add `.Package(url: "https://github.com/kareman/Moderator", "0.4.0")` to your Package.swift:

```swift
import PackageDescription

let package = Package(
	name: "somename",
	dependencies: [
		.Package(url: "https://github.com/kareman/Moderator", "0.4.0")
		 ]
	)
```

and run `swift build`.

### [Carthage](https://github.com/Carthage/Carthage)

Add `github "kareman/Moderator"` to your Cartfile, then run `carthage update` and add the resulting framework to the "Embedded Binaries" section of the application. See [Carthage's README][carthage-installation] for further instructions.

[carthage-installation]: https://github.com/Carthage/Carthage/blob/master/README.md#adding-frameworks-to-an-application

### [CocoaPods](https://cocoapods.org/)

Add `Moderator` to your `Podfile`.

```ruby
pod "Moderator", git: "https://github.com/kareman/Moderator.git"
```

Then run `pod install` to install it.

## License

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)

