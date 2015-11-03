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
		let parser = ArgumentParser()
		let arguments = ["--verbose", "-a", "-lkj", "string"]
		let parsed = parser.add(BoolArgument(shortname: "a", longname: ""))
		let unparsed = parser.add(BoolArgument(shortname: "b", longname: ""))

		do {
			try parser.parse(arguments)
			XCTAssertEqual(parsed.value, true)
			XCTAssertEqual(unparsed.value, false)
		} catch {
			XCTFail(String(error))
		}
	}
}
