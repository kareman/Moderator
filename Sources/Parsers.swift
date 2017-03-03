//
//  Moderator.swift
//
//  Created by Kåre Morstøl.
//  Copyright (c) 2016 NotTooBad Software. All rights reserved.
//

// Should ideally and eventually be compatible with http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html ,
// with the addition of "--longname". For more, see http://blog.nottoobadsoftware.com/uncategorized/cross-platform-command-line-arguments-syntax/ .

public typealias UsageText = (title: String, description: String)?

public struct Argument <Value> {
	public let usage: UsageText
	public let parse: ([String]) throws -> (value: Value, remainder: [String])

	public init (usage: UsageText = nil, p: @escaping ([String]) throws -> (value: Value, remainder: [String])) {
		self.parse = p
		self.usage = usage
	}

	public init (usage: UsageText = nil, value: Value) {
		self.parse = { args in (value, args) }
		self.usage = usage
	}
}

extension Argument {
	public func map <Outvalue> (_ f: @escaping (Value) throws -> Outvalue) -> Argument<Outvalue> {
		return Argument<Outvalue>(usage: self.usage) { args in
			let result = try self.parse(args)
			return (value: try f(result.value), remainder: result.remainder)
		}
	}
}

public struct ArgumentError: Error, CustomStringConvertible {
	public let errormessage: String
	public internal(set) var usagetext: String? = nil

	public init (errormessage: String, usagetext: String? = nil) {
		self.errormessage = errormessage
		self.usagetext = usagetext
	}

	public var description: String { return errormessage + (usagetext.map { "\n" + $0 } ?? "") }
}

extension Argument {
	static func isOption (index: Array<String>.Index, args: [String]) -> Bool {
		if let i = args.index(of: "--"), i < index { return false }
		let argument = args[index].characters
		if argument.first == "-", let second = argument.dropFirst().first {
			if !("0"..."9" ~= second) { return true }
		}
		return false
	}

	static func option(names: [String], description: String? = nil) -> Argument<Bool> {
		let names = names.map { $0.characters.count==1 ? "-" + $0 : "--" + $0 }
		let usage = description.map { (names.joined(separator: ","), $0) }
		return Argument<Bool>(usage: usage) { args in
			var args = args
			guard let index = args.index(where: names.contains), isOption(index: index, args: args) else {
				return (false, args)
			}
			args.remove(at: index)
			return (true, args)
		}
	}

	public static func option(_ names: String..., description: String? = nil) -> Argument<Bool> {
		return option(names: names, description: description)
	}
}


extension Array where Element: Equatable {
	public func indexOfFirstDifference (_ other: Array<Element>) -> Index? {
		for i in self.indices {
			if i >= other.endIndex || self[i] != other[i] { return i }
		}
		return nil
	}
}

extension Argument {
	public static func optionWithValue
		(_ names: String..., name valuename: String? = nil, description: String? = nil)
		-> Argument<String?> {

			let option = Argument.option(names: names, description: description)
			let usage = option.usage.map { usage in
				return (usage.title + " <\(valuename ?? "arg")>", usage.description)
			}

			return Argument<String?>(usage: usage) { args in
				var optionresult = try option.parse(args)
				guard optionresult.value else {
					return (nil, args)
				}
				guard let firstchange = optionresult.remainder.indexOfFirstDifference(args) else {
					throw ArgumentError(errormessage: "Expected value for argument '\(args.last!)'.")
				}
				guard !isOption(index: firstchange, args: optionresult.remainder) else {
					throw ArgumentError(errormessage:
						"Expected value for '\(args[firstchange])', got option '\(optionresult.remainder[firstchange])'.")
				}
				let value = optionresult.remainder.remove(at: firstchange)
				return (value, optionresult.remainder)
			}
	}

	public static func singleArgument (name: String, description: String? = nil) -> Argument<String?> {
		return Argument<String?>(usage: description.map { ("<"+name+">", $0) }) { args in
			if let arg = args.first, !isOption(index: args.startIndex, args: args) {
				return (arg, Array(args.dropFirst()))
			}
			return (nil, args)
		}
	}
}


public protocol OptionalType {
	associatedtype Wrapped
	func toOptional() -> Wrapped?
}

extension Optional: OptionalType {
	public func toOptional() -> Optional {
		return self
	}
}

extension Argument where Value: OptionalType {
	public func `default`(_ defaultvalue: Value.Wrapped) -> Argument<Value.Wrapped> {
		let newusage = self.usage.map { ($0.title, $0.description + " Default = '\(defaultvalue)'.") }
		return Argument<Value.Wrapped>(usage: newusage) { args in
			let result = try self.parse(args)
			return (result.value.toOptional() ?? defaultvalue, result.remainder)
		}
	}

	public func required() -> Argument<Value.Wrapped> {
		return Argument<Value.Wrapped>(usage: self.usage) { args in
			let result = try self.parse(args)
			guard let value = result.value.toOptional() else {
				throw ArgumentError(errormessage: "Expected value, got " + (result.remainder.first ?? "nothing"))
			}
			return (value, result.remainder)
		}
	}
}
