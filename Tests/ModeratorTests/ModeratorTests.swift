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
		return map {String(describing: $0)}
	}
}

extension String.CharacterView: CustomDebugStringConvertible {
	public var debugDescription: String {
		return String(self)
	}
}

class Moderator_Tests: XCTestCase {

	func testPreprocessorHandlesEqualSign () {
		let arguments = ["lskdfj", "--verbose", "--this=that=", "-b"]

		let result = ArgumentParser().preprocess(arguments)
		XCTAssertEqual(result.toStrings, ["lskdfj", "--verbose", "--this", "that=", "-b"])
	}

	func testPreprocessorHandlesJoinedFlags () {
		let arguments = ["-abc", "delta", "--echo", "-f"]

		let result = ArgumentParser().preprocess(arguments)
		XCTAssertEqual(result.toStrings, ["-a", "-b", "-c", "delta", "--echo", "-f"])
	}


	func testParsingBoolShortName () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "-a", "-lkj", "string"]
		let parsed = parser.add(BoolArgument(short: "a", long: "alpha"))
		let unparsed = parser.add(BoolArgument(short: "b", long: "bravo"))

		do {
			try parser.parse(arguments)
			XCTAssertEqual(parsed.value, true)
			XCTAssertEqual(unparsed.value, false)
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testParsingBoolLongName () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "--alpha", "-lkj", "string"]
		let parsed = parser.add(BoolArgument(short: "a", long: "alpha"))
		let unparsed = parser.add(BoolArgument(short: "b", long: "bravo"))

		do {
			try parser.parse(arguments)
			XCTAssertEqual(parsed.value, true)
			XCTAssertEqual(unparsed.value, false)
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testParsingStringArgumentShortName () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "-a", "alphasvalue", "string"]
		let parsed = parser.add(StringArgument(short: "a", long: "alpha"))
		let unparsed = parser.add(StringArgument(short: "b", long: "bravo"))

		do {
			try parser.parse(arguments)
			XCTAssertEqual(parsed.value, "alphasvalue")
			XCTAssertNil(unparsed.value)
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testParsingStringArgumentLongName () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "--alpha", "alphasvalue", "string"]
		let parsed = parser.add(StringArgument(short: "a", long: "alpha"))
		let unparsed = parser.add(StringArgument(short: "b", long: "bravo"))

		do {
			try parser.parse(arguments)
			XCTAssertEqual(parsed.value, "alphasvalue")
			XCTAssertNil(unparsed.value)
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testParsingStringArgumentWithEqualSign () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "--alpha=alphasvalue", "string"]
		let parsed = parser.add(StringArgument(short: "a", long: "alpha"))

		do {
			try parser.parse(arguments)
			XCTAssertEqual(parsed.value, "alphasvalue")
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testParsingStringArgumentWithMissingValueThrows () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "--alpha"]
		let parsed = parser.add(StringArgument(short: "a", long: "alpha"))

		do {
			try parser.parse(arguments)
			XCTFail("Should have thrown error about missing value")
		} catch {
			XCTAssertNil(parsed.value)
			XCTAssertTrue(String(describing: error).contains("Missing value"))
		}
	}

	func testParsingStringArgumentWithFlagValueThrows () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "-a", "-b"]
		let parsed = parser.add(StringArgument(short: "a", long: "alpha"))

		do {
			try parser.parse(arguments)
			XCTFail("Should have thrown error about incorrect value")
		} catch {
			XCTAssertNil(parsed.value)
			XCTAssertTrue(String(describing: error).contains("Illegal value"))
		}
	}

	func testStrictParsingThrowsErrorOnUnknownArguments () {
		let parser = ArgumentParser()
		let arguments = ["--alpha", "-c"]
		_ = parser.add(BoolArgument(short: "a", long: "alpha", helptext: "The leader."))
		_ = parser.add(BoolArgument(short: "b", long: "bravo", helptext: "Well done!"))

		do {
			try parser.parse(arguments, strict: true)
			XCTFail("Should have thrown error about incorrect value")
		} catch {
			XCTAssertTrue(String(describing: error).contains("Unknown arguments"))
			XCTAssertTrue(String(describing: error).contains("The leader."), "Error should have contained usage text.")
			XCTAssertTrue(String(describing: error).contains("Well done!"), "Error should have contained usage text.")
		}
	}

	func testStrictParsing () {
		let parser = ArgumentParser()
		let arguments = ["--alpha", "-b"]
		_ = parser.add(BoolArgument(short: "a", long: "alpha"))
		_ = parser.add(BoolArgument(short: "b", long: "bravo"))

		do {
			try parser.parse(arguments, strict: true)
		} catch {
			XCTFail("Should not throw error " + String(describing: error))
		}
	}

	func testUsageText () {
		let parser = ArgumentParser()
		_ = parser.add(BoolArgument(short: "a", long: "alpha", helptext: "The leader."))
		_ = parser.add(StringArgument(short: "b", long: "bravo", helptext: "Well done!"))
		_ = parser.add(BoolArgument(short: "x", long: "hasnohelptext"))

		let usagetext = parser.usagetext
		XCTAssert(usagetext.contains("alpha"))
		XCTAssert(usagetext.contains("The leader"))
		XCTAssert(usagetext.contains("bravo"))
		XCTAssert(usagetext.contains("Well done"))

		XCTAssertFalse(parser.usagetext.contains("hasnohelptext"))
	}
}
