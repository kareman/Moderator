//
// Moderator_swiftTests.swift
// Moderator.swiftTests
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//

import XCTest
import Moderator

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

	func testParsingOption () {
		let m = Moderator()
		let arguments = ["--ignored", "-a", "b", "bravo", "--charlie"]
		let parsedlong = m.add(ArgumentParser<Bool>.option("c", "charlie", description: "dgsf"))
		let parsedshort = m.add(ArgumentParser<Bool>.option("a", "alpha"))
		let unparsed = m.add(ArgumentParser<Bool>.option("b", "bravo"))

		do {
			try m.parse(arguments)
		 	XCTAssertEqual(parsedshort.value, true)
			XCTAssertEqual(unparsed.value, false)
			XCTAssertEqual(parsedlong.value, true)
			XCTAssertEqual(m.remaining, ["--ignored", "b", "bravo"])
		} catch {
			XCTFail(String(error))
		}
	}

	func testParsingOptionWithValue () {
		let m = Moderator()
		let arguments = ["--charlie", "sheen", "ignored", "-a", "alphasvalue"]
		let parsedshort = m.add(ArgumentParser<String>.optionWithValue("a", "alpha"))
		let unparsed = m.add(ArgumentParser<Bool>.option("b", "bravo"))
		let parsedlong = m.add(ArgumentParser<String>.optionWithValue("c", "charlie"))

		do {
			try m.parse(arguments)
			XCTAssertEqual(parsedshort.value, "alphasvalue")
			XCTAssertEqual(parsedlong.value, "sheen")
			XCTAssertEqual(unparsed.value, false)
			XCTAssertEqual(m.remaining, ["ignored"])
		} catch {
			XCTFail(String(error))
		}
	}

	func testParsingOptionWithMissingValueThrows () {
		let m = Moderator()
		let arguments = ["--verbose", "--alpha"]
		let parsed = m.add(ArgumentParser<String>.optionWithValue("a", "alpha"))

		do {
			try m.parse(arguments)
			XCTFail("Should have thrown error about missing value")
		} catch {
			XCTAssertNil(parsed.value)
			XCTAssertTrue(String(error).containsString("Missing value"))
		}
	}

/*
	func testParsingStringArgumentWithEqualSign () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "--alpha=alphasvalue", "string"]
		let parsed = parser.add(StringArgument("a", "alpha"))

		do {
			try parser.parse(arguments)
			XCTAssertEqual(parsed.value, "alphasvalue")
		} catch {
			XCTFail(String(error))
		}
	}

	func testParsingStringArgumentWithFlagValueThrows () {
		let parser = ArgumentParser()
		let arguments = ["--verbose", "-a", "-b"]
		let parsed = parser.add(StringArgument("a", "alpha"))

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
		parser.add(BoolArgument("a", "alpha", helptext: "The leader."))
		parser.add(BoolArgument("b", "bravo", helptext: "Well done!"))

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
		parser.add(BoolArgument("a", "alpha"))
		parser.add(BoolArgument("b", "bravo"))

		do {
			try parser.parse(arguments, strict: true)
		} catch {
			XCTFail("Should not throw error " + String(error))
		}
	}

	func testUsageText () {
		let parser = ArgumentParser()
		parser.add(BoolArgument("a", "alpha", helptext: "The leader."))
		parser.add(StringArgument("b", "bravo", helptext: "Well done!"))
		parser.add(BoolArgument("x", "hasnohelptext"))

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
