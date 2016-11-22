//
// Moderator_Tests
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//

import XCTest
import Moderator

extension Array {
	var toStrings: [String] {
		return map {String(describing: $0)}
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
			XCTFail(String(describing: error))
		}
	}

	func testParsingOptionWithValue () {
		let m = Moderator()
		let arguments = ["--charlie", "sheen", "ignored", "-a", "alphasvalue"]
		let parsedshort = m.add(ArgumentParser<String>.optionWithValue("a", "alpha", default: ""))
		let unparsed = m.add(ArgumentParser<Bool>.option("b", "bravo"))
		let parsedlong = m.add(ArgumentParser<String>.optionWithValue("c", "charlie", default: ""))

		do {
			try m.parse(arguments)
			XCTAssertEqual(parsedshort.value, "alphasvalue")
			XCTAssertEqual(parsedlong.value, "sheen")
			XCTAssertEqual(unparsed.value, false)
			XCTAssertEqual(m.remaining, ["ignored"])
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testParsingOptionWithMissingValueThrows () {
		let m = Moderator()
		let arguments = ["--verbose", "--alpha"]
		let parsed = m.add(ArgumentParser<String>.optionWithValue("a", "alpha", default: ""))

		do {
			try m.parse(arguments)
			XCTFail("Should have thrown error about missing value")
		} catch {
			XCTAssertNil(parsed.value)
			XCTAssertTrue(String(describing: error).contains("--alpha"))
		}
	}

	func testParsingMissingOptionWithValue () {
		let m = Moderator()
		let arguments = ["arg1", "arg2", "arg3"]
		let parsed = m.add(ArgumentParser<String>.optionWithValue("a", "alpha", default: "default"))

		do {
			try m.parse(arguments)
			XCTAssertEqual(parsed.value, "default")
		} catch {
			XCTFail("Error should not have been thrown: \(error)")
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
*/
	func testParsingStringArgumentWithOptionValueThrows () {
		let m = Moderator()
		let arguments = ["--verbose", "-a", "-b"]
		let parsed = m.add(ArgumentParser<Bool>.optionWithValue("a", "alpha", default: ""))

		do {
			try m.parse(arguments)
			XCTFail("Should have thrown error about incorrect value")
		} catch {
			XCTAssertNil(parsed.value)
		}
	}

	func testSingleArgument () {
		let m = Moderator()
		let arguments = ["-a", "argument", "--ignored", "--charlie"]
		let parsedlong = m.add(ArgumentParser<Bool>.option("c", "charlie", description: "dgsf"))
		let parsedshort = m.add(ArgumentParser<Bool>.option("a", "alpha"))
		let single = m.add(ArgumentParser<String>.singleArgument(name: "argumentname"))

		do {
			try m.parse(arguments)
			XCTAssertEqual(parsedshort.value, true)
			XCTAssertEqual(parsedlong.value, true)
			XCTAssertEqual(single.value, "argument")
			XCTAssertEqual(m.remaining, ["--ignored"])
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testThrowsOnMissingSingleArgument() {
		let m = Moderator()
		_ = m.add(ArgumentParser<Bool>.option("c", "charlie", description: "dgsf"))
		_ = m.add(ArgumentParser<Bool>.option("a", "alpha"))
		let single = m.add(ArgumentParser<String>.singleArgument(name: "argumentname"))

		do {
			try m.parse(["-a", "-b"])
			XCTFail("Should have thrown error")
		} catch {
			XCTAssertNil(single.value)
			XCTAssert(String(describing: error).contains("-b"))
		}
	}

	func testStrictParsingThrowsErrorOnUnknownArguments () {
		let m = Moderator()
		let arguments = ["--alpha", "-c"]
		_ = m.add(ArgumentParser<Bool>.option("a", "alpha", description: "The leader."))
		_ = m.add(ArgumentParser<Bool>.option("b", "bravo", description: "Well done!"))

		do {
			try m.parse(arguments, strict: true)
			XCTFail("Should have thrown error about incorrect value")
		} catch {
			XCTAssertTrue(String(describing: error).contains("Unknown arguments"))
			XCTAssertTrue(String(describing: error).contains("The leader."), "Error should have contained usage text.")
			XCTAssertTrue(String(describing: error).contains("Well done!"), "Error should have contained usage text.")
		}
	}

	func testStrictParsing () {
		let m = Moderator()
		let arguments = ["--alpha", "-b"]
		_ = m.add(ArgumentParser<Bool>.option("a", "alpha", description: "The leader."))
		_ = m.add(ArgumentParser<Bool>.option("b", "bravo", description: "Well done!"))

		do {
			try m.parse(arguments, strict: true)
		} catch {
			XCTFail("Should not throw error " + String(describing: error))
		}
	}

	func testUsageText () {
		let m = Moderator()
		_ = m.add(ArgumentParser<Bool>.option("a", "alpha", description: "The leader."))
		_ = m.add(ArgumentParser<Bool>.optionWithValue("b", "bravo", default: "default value", description: "Well done!"))
		_ = m.add(ArgumentParser<Bool>.option("x", "hasnohelptext"))

		let usagetext = m.usagetext
		print(usagetext)
		XCTAssert(usagetext.contains("alpha"))
		XCTAssert(usagetext.contains("The leader"))
		XCTAssert(usagetext.contains("bravo"))
		XCTAssert(usagetext.contains("Well done"))
		XCTAssert(usagetext.contains("default value"))

		XCTAssertFalse(m.usagetext.contains("hasnohelptext"))
	}
}

/*
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
