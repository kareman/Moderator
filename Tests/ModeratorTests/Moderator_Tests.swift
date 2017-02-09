//
// Moderator_Tests
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright 2015 NotTooBad Software. All rights reserved.
//

import XCTest
import Moderator
import Foundation

extension Array {
	var toStrings: [String] {
		return map {String(describing: $0)}
	}
}

public class Moderator_Tests: XCTestCase {

	/*
	func testPreprocessorHandlesEqualSign () {
		let arguments = ["lskdfj", "--verbose", "--this=that=", "-b"]

		let result = Argument().preprocess(arguments)
		XCTAssertEqual(result.toStrings, ["lskdfj", "--verbose", "--this", "that=", "-b"])
	}

	func testPreprocessorHandlesJoinedFlags () {
		let arguments = ["-abc", "delta", "--echo", "-f"]

		let result = Argument().preprocess(arguments)
		XCTAssertEqual(result.toStrings, ["-a", "-b", "-c", "delta", "--echo", "-f"])
	}
	*/

	func testParsingOption () {
		let m = Moderator()
		let arguments = ["--ignored", "-a", "b", "bravo", "--charlie"]
		let parsedlong = m.add(Argument<Bool>.option("c", "charlie"))
		let parsedshort = m.add(Argument<Bool>.option("a", "alpha"))
		let unparsed = m.add(Argument<Bool>.option("b", "bravo"))

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
		let parsedshort = m.add(Argument<String>.optionWithValue("a", "alpha", default: ""))
		let unparsed = m.add(Argument<Bool>.option("b", "bravo"))
		let parsedlong = m.add(Argument<String>.optionWithValue("c", "charlie", default: ""))

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
		_ = m.add(Argument<String>.optionWithValue("a", "alpha", default: ""))

		XCTAssertThrowsError( try m.parse(arguments) ) { error in
			XCTAssertTrue(String(describing: error).contains("--alpha"))
		}
	}

	func testParsingMissingOptionWithValue () {
		let m = Moderator()
		let arguments = ["arg1", "arg2", "arg3"]
		let parsed = m.add(Argument<String>.optionWithValue("a", "alpha", default: "default"))

		do {
			try m.parse(arguments)
			XCTAssertEqual(parsed.value, "default")
		} catch {
			XCTFail(String(describing: error))
		}
	}
/*
	func testParsingStringArgumentWithEqualSign () {
		let parser = Argument()
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
		_ = m.add(Argument<Bool>.optionWithValue("a", "alpha", default: ""))

		XCTAssertThrowsError( try m.parse(arguments) ) { error in
			XCTAssert(String(describing: error).contains("-a"))
		}
	}

	func testSingleArgument () {
		let m = Moderator()
		let arguments = ["-a", "argument", "--ignored", "--charlie"]
		let parsedlong = m.add(Argument<Bool>.option("c", "charlie"))
		let parsedshort = m.add(Argument<Bool>.option("a", "alpha"))
		let single = m.add(Argument<String?>.singleArgument(name: "argumentname"))

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

	func testMissingSingleArgument() {
		let m = Moderator()
		_ = m.add(Argument<Bool>.option("c", "charlie"))
		_ = m.add(Argument<Bool>.option("a", "alpha"))
		let single = m.add(Argument<String?>.singleArgument(name: "argumentname"))

		do {
			try m.parse(["-a", "-b"])
			XCTAssertNil(single.value)
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testDefaultValue() {
		let m = Moderator()
		_ = m.add(Argument<Bool>.option("c", "charlie"))
		_ = m.add(Argument<Bool>.option("a", "alpha"))
		let defaultsingle = m.add(Argument<String?>.singleArgument(name: "argumentname").default("defaultvalue"))

		do {
			try m.parse(["-a", "-b"])
			XCTAssertEqual(defaultsingle.value, "defaultvalue")
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testMissingRequiredValueThrows() {
		let m = Moderator()
		_ = m.add(Argument<Bool>.option("c", "charlie"))
		_ = m.add(Argument<Bool>.option("a", "alpha"))
		_ = m.add(Argument<String?>.singleArgument(name: "argumentname").required())

		XCTAssertThrowsError( try m.parse(["-a", "-b"]) )
	}
	
	func testStrictParsingThrowsErrorOnUnknownArguments () {
		let m = Moderator()
		let arguments = ["--alpha", "-c"]
		_ = m.add(Argument<Bool>.option("a", "alpha", description: "The leader."))
		_ = m.add(Argument<Bool>.option("b", "bravo", description: "Well done!"))

		XCTAssertThrowsError( try m.parse(arguments, strict: true) ) { error in
			XCTAssertTrue(String(describing: error).contains("Unknown arguments"))
			XCTAssertTrue(String(describing: error).contains("The leader."), "Error should have contained usage text.")
			XCTAssertTrue(String(describing: error).contains("Well done!"), "Error should have contained usage text.")
		}
	}

	func testStrictParsing () {
		let m = Moderator()
		let arguments = ["--alpha", "-b"]
		_ = m.add(Argument<Bool>.option("a", "alpha", description: "The leader."))
		_ = m.add(Argument<Bool>.option("b", "bravo", description: "Well done!"))

		do {
			try m.parse(arguments, strict: true)
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testUsageText () {
		let m = Moderator()
		_ = m.add(Argument<Bool>.option("a", "alpha", description: "The leader."))
		_ = m.add(Argument<Bool>.optionWithValue("b", "bravo", default: "default value", description: "Well done!"))
		_ = m.add(Argument<Bool>.option("x", "hasnohelptext"))

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

extension Moderator_Tests {
	public static var allTests = [
		//("testPreprocessorHandlesEqualSign", testPreprocessorHandlesEqualSign),
		//("testPreprocessorHandlesJoinedFlags", testPreprocessorHandlesJoinedFlags),
		("testParsingOption", testParsingOption),
		("testParsingOptionWithValue", testParsingOptionWithValue),
		("testParsingOptionWithMissingValueThrows", testParsingOptionWithMissingValueThrows),
		("testParsingMissingOptionWithValue", testParsingMissingOptionWithValue),
		//("testParsingStringArgumentWithEqualSign", testParsingStringArgumentWithEqualSign),
		("testParsingStringArgumentWithOptionValueThrows", testParsingStringArgumentWithOptionValueThrows),
		("testSingleArgument", testSingleArgument),
		("testMissingSingleArgument", testMissingSingleArgument),
		("testDefaultValue", testDefaultValue),
		("testMissingRequiredValueThrows", testMissingRequiredValueThrows),
		("testStrictParsingThrowsErrorOnUnknownArguments", testStrictParsingThrowsErrorOnUnknownArguments),
		("testStrictParsing", testStrictParsing),
		("testUsageText", testUsageText),
		]
}
