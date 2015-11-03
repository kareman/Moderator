//
// Moderator_swiftTests.swift
// Moderator.swiftTests
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//

import XCTest
@testable import Moderator

extension Array {
	var toStrings: [String] {
		return map {String($0)}
	}
}

extension String.CharacterView: CustomDebugStringConvertible {
	public var debugDescription: String {
		return String(self)
	}
}

class Moderator_Tests: XCTestCase {

	func testPreprocessor () {
		let arguments = ["lskdfj", "--verbose", "--this=that", "-b", "-lkj"]

		let result = ArgumentParser().preprocess(arguments)
		XCTAssertEqual(result.toStrings, ["lskdfj", "--verbose", "--this", "that", "-b", "-lkj"])
	}

	func testParsingBool () {
		_ = ArgumentParser()
		/*
		let arguments = ["lskdfj", "--verbose", "--this=that", "-b", "-lkj"]

		let a = BoolOption (shortname: "b", longname: "brilliant")
		parser.argumenttypes.append( a)
		try parser.parse(arguments)
		a.value
		*/
	}
}
