//
// File.swift
// Moderator.swift
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//


protocol ArgumentType {

	mutating func parse (arguments: [String.CharacterView]) throws -> [String.CharacterView]

}

public final class ArgumentParser {
	var argumenttypes: [ArgumentType] = []

	func parse () throws {
		try parse (Array(Process.arguments.dropFirst()))
	}

	func parse (arguments: [String]) throws {
		var remainingarguments = preprocess(arguments)
		argumenttypes = try argumenttypes.map {
			var at = $0
			remainingarguments = try at.parse(remainingarguments)
			return at
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


public final class BoolOption: ArgumentType {
	let shortname: Character
	let longname: String
	var value = false

	init (shortname: Character, longname: String) {
		self.longname = longname
		self.shortname = shortname
	}

	func parse(var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		if let index = arguments.indexOf({String ($0) == "-\(shortname)"}) {
			value = true
			arguments.removeAtIndex(index)
		}
		return arguments
	}
}

