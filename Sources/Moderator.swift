//
// Moderator.swift
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//


public protocol ArgumentType: class {
	func parse (_ arguments: [String.CharacterView]) throws -> [String.CharacterView]
	var usagetext: (title: String, description: String)? {get}
}

public typealias UsageText = (title: String, description: String)?

extension ArgumentType {
	public var usagetext: UsageText {return nil}
}

public final class ArgumentParser {
	fileprivate var argumenttypes: [ArgumentType] = []
	public fileprivate(set) var remaining: [String] = []

	public func add <T:ArgumentType> (_ a: T) -> T {
		argumenttypes.append(a)
		return a
	}

	public func parse (strict: Bool = false) throws {
		try parse(Array(CommandLine.arguments.dropFirst()), strict: strict)
	}

	public func parse (_ arguments: [String], strict: Bool = false) throws {
		do {
			var remainingarguments = preprocess(arguments)
			try argumenttypes.forEach {
				remainingarguments = try $0.parse(remainingarguments)
			}
			self.remaining = remainingarguments.map {String($0)}
			if strict && !remaining.isEmpty {
				throw ArgumentError(errormessage: "Unknown arguments: " + remaining.joined(separator: " "))
			}
		} catch var error as ArgumentError {
			error.usagetext = self.usagetext
			throw error
		}
	}

	func preprocess (_ arguments: [String]) -> [String.CharacterView] {
		return arguments.flatMap { s -> [String.CharacterView] in
			let c = s.characters
			if c.starts(with: "--".characters) {
				return c.split(separator: "=" as Character, maxSplits: 1, omittingEmptySubsequences: false)
			} else if c.starts(with: "-".characters) && c.count > 2 {
				return c.dropFirst().map { "-\($0)".characters }
			} else {
				return [c]
			}
		}
	}

	public var usagetext: String {
		let usagetexts = argumenttypes.flatMap { $0.usagetext }
		return usagetexts.reduce("Usage: \(CommandLine.arguments.first ?? "")\n") { (acc:String, usagetext: UsageText) -> String in
			return acc + "  " + usagetext!.title + "\n      " + usagetext!.description + "\n"
		}
	}
}


public struct ArgumentError: Error, CustomStringConvertible {
	public let errormessage: String
	public fileprivate(set) var usagetext: String? = nil

	public init (errormessage: String, usagetext: String? = nil) {
		self.errormessage = errormessage
		self.usagetext = usagetext
	}

	public var description: String { return errormessage + (usagetext.map { "\n" + $0 } ?? "") }
}

open class TagArgument: ArgumentType {
	let shortname: Character
	let longname: String
	open let helptext: String?

	init (short: Character, long: String, helptext: String? = nil) {
		self.longname = long
		self.shortname = short
		self.helptext = helptext
	}

	open var usagetext: (title: String, description: String)? {
		return helptext.map { ("-\(shortname), --\(longname):", $0) }
	}

	open func parse(_ arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		if let index = arguments.index(where: {
			let s = String($0)
			return s == "-\(shortname)" || s == "--\(longname)"
		}) {
			return try matchHandler(index, arguments: arguments)
		} else {
			return arguments
		}
	}

	open func matchHandler(_ index: Array<String>.Index, arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		return arguments
	}
}

public final class BoolArgument: TagArgument {
	public fileprivate(set) var value = false

	override public func matchHandler(_ index: Array<String>.Index, arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		var arguments = arguments
		value = true
		arguments.remove(at: index)
		return arguments
	}
}

public final class StringArgument: TagArgument {
	public fileprivate(set) var value: String?

	override public func matchHandler(_ index: Array<String>.Index, arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		var arguments = arguments
		let usedflag = arguments.remove(at: index)
		guard index < arguments.endIndex else {
			throw ArgumentError(errormessage: "Missing value for argument '\(usedflag)'")
		}
		let newvalue = String(arguments.remove(at: index))
		guard !newvalue.hasPrefix("-") else {
			throw ArgumentError(errormessage: "Illegal value '\(newvalue)' for argument '\(usedflag)")
		}
		value = newvalue
		return arguments
	}
}
