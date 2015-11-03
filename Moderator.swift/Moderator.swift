//
// File.swift
// Moderator.swift
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//


public protocol ArgumentType: class {
	func parse (arguments: [String.CharacterView]) throws -> [String.CharacterView]
}

public final class ArgumentParser {
	private var argumenttypes: [ArgumentType] = []

	public func add <T:ArgumentType> (a: T) -> T {
		argumenttypes.append(a)
		return a
	}

	func parse () throws {
		try parse(Array(Process.arguments.dropFirst()))
	}

	public func parse (arguments: [String]) throws {
		var remainingarguments = preprocess(arguments)
		try argumenttypes.forEach {
			remainingarguments = try $0.parse(remainingarguments)
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


public final class BoolArgument: ArgumentType {
	let shortname: Character
	let longname: String
	var value = false

	init (shortname: Character, longname: String) {
		self.longname = longname
		self.shortname = shortname
	}

	public func parse(var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		if let index = arguments.indexOf({String ($0) == "-\(shortname)"}) {
			value = true
			arguments.removeAtIndex(index)
		}
		return arguments
	}
}

