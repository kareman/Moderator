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

class Moderator_Tests: XCTestCase {
/*
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
*/

	func testParsingFlag () {
		let m = Moderator()
		let arguments = ["--verbose", "-a", "b", "bravo", "--charlie"]
		let parsedlong = m.add(ArgumentParser<Bool>.flag(short: "c", long: "charlie"))
		let parsedshort = m.add(ArgumentParser<Bool>.flag(short: "a", long: "alpha"))
		let unparsed = m.add(ArgumentParser<Bool>.flag(short: "b", long: "bravo"))

		do {
			try m.parse(arguments)
		 	XCTAssertEqual(parsedshort.value, true)
			XCTAssertEqual(unparsed.value, false)
			XCTAssertEqual(parsedlong.value, true)
			XCTAssertEqual(m.remaining, ["--verbose", "b", "bravo"])
		} catch {
			XCTFail(String(error))
		}
	}


	func testParsingFlagWithValue () {
		let m = Moderator()
		let arguments = ["--verbose", "-a", "alphasvalue", "string"]
		let parsedshort = m.add(ArgumentParser<String>.flagWithValue("a", long: "alpha"))
		let unparsed = m.add(ArgumentParser<Bool>.flag(short: "b", long: "bravo"))

		do {
			try m.parse(arguments)
			XCTAssertEqual(parsedshort.value, "alphasvalue")
			XCTAssertEqual(unparsed.value, false)
			XCTAssertEqual(m.remaining, ["--verbose", "string"])
		} catch {
			XCTFail(String(error))
		}
	}
	

/*

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
			XCTFail(String(error))
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
			XCTFail(String(error))
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
			XCTFail(String(error))
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
			XCTAssertTrue(String(error).containsString("Missing value"))
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
			XCTAssertTrue(String(error).containsString("Illegal value"))
		}
	}

	func testStrictParsingThrowsErrorOnUnknownArguments () {
		let parser = ArgumentParser()
		let arguments = ["--alpha", "-c"]
		parser.add(BoolArgument(short: "a", long: "alpha", helptext: "The leader."))
		parser.add(BoolArgument(short: "b", long: "bravo", helptext: "Well done!"))

		do {
			try parser.parse(arguments, strict: true)
			XCTFail("Should have thrown error about incorrect value")
		} catch {
			XCTAssertTrue(String(error).containsString("Unknown arguments"))
			XCTAssertTrue(String(error).containsString("The leader."), "Error should have contained usage text.")
			XCTAssertTrue(String(error).containsString("Well done!"), "Error should have contained usage text.")
		}
	}

	func testStrictParsing () {
		let parser = ArgumentParser()
		let arguments = ["--alpha", "-b"]
		parser.add(BoolArgument(short: "a", long: "alpha"))
		parser.add(BoolArgument(short: "b", long: "bravo"))

		do {
			try parser.parse(arguments, strict: true)
		} catch {
			XCTFail("Should not throw error " + String(error))
		}
	}

	func testUsageText () {
		let parser = ArgumentParser()
		parser.add(BoolArgument(short: "a", long: "alpha", helptext: "The leader."))
		parser.add(StringArgument(short: "b", long: "bravo", helptext: "Well done!"))
		parser.add(BoolArgument(short: "x", long: "hasnohelptext"))

		let usagetext = parser.usagetext
		XCTAssert(usagetext.containsString("alpha"))
		XCTAssert(usagetext.containsString("The leader"))
		XCTAssert(usagetext.containsString("bravo"))
		XCTAssert(usagetext.containsString("Well done"))

		XCTAssertFalse(parser.usagetext.containsString("hasnohelptext"))
	}
}

class AnyArgument_Tests: XCTestCase {

	func testLastArgumentParser () {
		let parser = ArgumentParser()
		let lastOption = parser.add { (var args) -> (String, [String.CharacterView]) in
			guard let last = args.popLast() else { throw ArgumentError(errormessage: "No argument was found") }
			return (String(last), args)
		}

		do {
			try parser.parse(["first","last"])
			XCTAssertEqual(lastOption.value, "last")
			XCTAssertEqual(parser.remaining, ["first"])
		} catch {
			XCTFail("Should not throw error " + String(error))
		}
	}

	func testLastArgumentParserThrows () {
		let parser = ArgumentParser()
		let lastOption = parser.add { (var args) -> (String, [String.CharacterView]) in
			guard let last = args.popLast() else { throw ArgumentError(errormessage: "No argument was found") }
			return (String(last), args)
		}

		do {
			try parser.parse([])
			XCTFail("Should have thrown error about no argument")
		} catch {
			XCTAssertNil(lastOption.value)
			XCTAssertTrue(parser.remaining.isEmpty)
		}
	}
*/
}
