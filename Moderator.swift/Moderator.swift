//
// File.swift
// Moderator.swift
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//


public protocol ArgumentType: class {
	func parse (arguments: [String.CharacterView]) throws -> [String.CharacterView]
	var helptext: String {get}
}

public final class ArgumentParser {
	private var argumenttypes: [ArgumentType] = []
	public private(set) var remaining: [String] = []

	public func add <T:ArgumentType> (a: T) -> T {
		argumenttypes.append(a)
		return a
	}

	func parse (strict strict: Bool = false) throws {
		try parse(Array(Process.arguments.dropFirst()), strict: strict)
	}

	public func parse (arguments: [String], strict: Bool = false) throws {
		var remainingarguments = preprocess(arguments)
		try argumenttypes.forEach {
			remainingarguments = try $0.parse(remainingarguments)
		}
		self.remaining = remainingarguments.map {String($0)}
		if strict && !remaining.isEmpty {
			throw ArgumentError(errormessage: "Unknown arguments: " + remaining.joinWithSeparator(" "))
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
}

public struct ArgumentError: ErrorType, CustomStringConvertible {
	let errormessage: String

	public var description: String { return errormessage }
}

public final class BoolArgument: ArgumentType {
	let shortname: Character
	let longname: String
	public let helptext: String
	public private(set) var value = false

	init (short: Character, long: String, helptext: String = "") {
		self.longname = long
		self.shortname = short
		self.helptext = helptext
	}

	public func parse(var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		if let index = arguments.indexOf({
			let s = String($0)
			return s == "-\(shortname)" || s == "--\(longname)"
		}) {
			value = true
			arguments.removeAtIndex(index)
		}
		return arguments
	}
}

public final class StringArgument: ArgumentType {
	let shortname: Character
	let longname: String
	public let helptext: String
	public private(set) var value: String?

	init (short: Character, long: String, helptext: String = "") {
		self.longname = long
		self.shortname = short
		self.helptext = helptext
	}

	public func parse(var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		if let index = arguments.indexOf({
			let s = String($0)
			return s == "-\(shortname)" || s == "--\(longname)"
		}) {
			let usedflag = arguments.removeAtIndex(index)
			guard index < arguments.endIndex else {
				throw ArgumentError(errormessage: "Missing value for argument '\(usedflag)'")
			}
			let newvalue = String(arguments.removeAtIndex(index))
			guard !newvalue.hasPrefix("-") else {
				throw ArgumentError(errormessage: "Illegal value '\(newvalue)' for argument '\(usedflag)")
			}
			value = newvalue
		}
		return arguments
	}
}

