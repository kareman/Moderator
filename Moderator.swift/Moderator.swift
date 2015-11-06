//
// File.swift
// Moderator.swift
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//


public protocol ArgumentType: class {
	func parse (arguments: [String.CharacterView]) throws -> [String.CharacterView]
	var usagetext: (title: String, description: String)? {get}
}

extension ArgumentType {
	public var usagetext: (title: String, description: String)? {return nil}
}

public final class ArgumentParser {
	private var argumenttypes: [ArgumentType] = []
	public private(set) var remaining: [String] = []

	public func add <T:ArgumentType> (a: T) -> T {
		argumenttypes.append(a)
		return a
	}

	public func parse (strict strict: Bool = false) throws {
		try parse(Array(Process.arguments.dropFirst()), strict: strict)
	}

	public func parse (arguments: [String], strict: Bool = false) throws {
		do {
			var remainingarguments = preprocess(arguments)
			try argumenttypes.forEach {
				remainingarguments = try $0.parse(remainingarguments)
			}
			self.remaining = remainingarguments.map {String($0)}
			if strict && !remaining.isEmpty {
				throw ArgumentError(errormessage: "Unknown arguments: " + remaining.joinWithSeparator(" "))
			}
		} catch var error as ArgumentError {
			error.usagetext = self.usagetext
			throw error
		}
	}

	func preprocess (arguments: [String]) -> [String.CharacterView] {
		return arguments.flatMap { s -> [String.CharacterView] in
			let c = s.characters
			if c.startsWith("--".characters) {
				return c.split("=" as Character, maxSplit: 2, allowEmptySlices: true)
			} else {
				return [c]
			}
		}
	}

	public var usagetext: String {
		let usagetexts = argumenttypes.flatMap { $0.usagetext }
		return usagetexts.reduce("Usage: \(Process.arguments.first ?? "")\n") { acc, usagetext in
			return acc + "  " + usagetext.title + "\n      " + usagetext.description + "\n"
		}
	}
}


public struct ArgumentError: ErrorType, CustomStringConvertible {
	public let errormessage: String
	public private(set) var usagetext: String? = nil

	public init (errormessage: String, usagetext: String? = nil) {
		self.errormessage = errormessage
		self.usagetext = usagetext
	}

	public var description: String { return errormessage + (usagetext.map { "\n" + $0 } ?? "") }
}

public class TagArgument: ArgumentType {
	let shortname: Character
	let longname: String
	public let helptext: String?

	init (short: Character, long: String, helptext: String? = nil) {
		self.longname = long
		self.shortname = short
		self.helptext = helptext
	}

	public var usagetext: (title: String, description: String)? {
		// must use temporary variable to avoid compiler crash in release builds (Xcode 7.1).
		let result = helptext.map { ("-\(shortname), --\(longname):", $0) }
		return result
	}

	public func parse(var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		if let index = arguments.indexOf({
			let s = String($0)
			return s == "-\(shortname)" || s == "--\(longname)"
		}) {
			arguments = try matchHandler(index, arguments: arguments)
		}
		return arguments
	}

	public func matchHandler(index: Array<String>.Index, arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		return arguments
	}
}

public final class BoolArgument: TagArgument {
	public private(set) var value = false

	override public func matchHandler(index: Array<String>.Index, var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		value = true
		arguments.removeAtIndex(index)
		return arguments
	}
}

public final class StringArgument: TagArgument {
	public private(set) var value: String?

	override public func matchHandler(index: Array<String>.Index, var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		let usedflag = arguments.removeAtIndex(index)
		guard index < arguments.endIndex else {
			throw ArgumentError(errormessage: "Missing value for argument '\(usedflag)'")
		}
		let newvalue = String(arguments.removeAtIndex(index))
		guard !newvalue.hasPrefix("-") else {
			throw ArgumentError(errormessage: "Illegal value '\(newvalue)' for argument '\(usedflag)")
		}
		value = newvalue
		return arguments
	}
}
