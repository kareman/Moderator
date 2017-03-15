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

	func testOptionAndArgumentJoinedWithEqualSign () {
		let m = Moderator()
		let arguments = ["lskdfj", "--verbose", "--this=that=", "-b", "--", "--c=1"]

		do {
			try m.parse(arguments, strict: false)
			XCTAssertEqual(m.remaining, ["lskdfj", "--verbose", "--this", "that=", "-b", "--", "--c=1"])
		} catch {
			XCTFail(String(describing: error))
		}
	}

	/*
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
			try m.parse(arguments, strict: false)
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
		let parsedshort = m.add(Argument<String?>.optionWithValue("a", "alpha"))
		let unparsed = m.add(Argument<Bool>.option("b", "bravo"))
		let parsedlong = m.add(Argument<String?>.optionWithValue("c", "charlie"))

		do {
			try m.parse(arguments, strict: false)
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
		_ = m.add(Argument<String>.optionWithValue("a", "alpha"))

		XCTAssertThrowsError( try m.parse(arguments) ) { error in
			XCTAssertTrue(String(describing: error).contains("--alpha"))
		}
	}

	func testParsingMissingOptionWithValue () {
		let m = Moderator()
		let arguments = ["arg1", "arg2", "arg3"]
		let parsed = m.add(Argument<String?>.optionWithValue("a", "alpha").default("default"))

		do {
			try m.parse(arguments, strict: false)
			XCTAssertEqual(parsed.value, "default")
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testParsingStringArgumentWithOptionValueThrows () {
		let m = Moderator()
		let arguments = ["--verbose", "-a", "-b"]
		_ = m.add(Argument<Bool>.optionWithValue("a", "alpha"))

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
			try m.parse(arguments, strict: false)
			XCTAssertEqual(parsedshort.value, true)
			XCTAssertEqual(parsedlong.value, true)
			XCTAssertEqual(single.value, "argument")
			XCTAssertEqual(m.remaining, ["--ignored"])

			try m.parse(["-a", "--charlie", "argument2", "--ignored"], strict: false)
			XCTAssertEqual(single.value, "argument2")

			try m.parse(["-a", "--charlie", "--", "--argument3", "--ignored"], strict: false)
			XCTAssertEqual(single.value, "--argument3")

			try m.parse(["-a", "--charlie", "--"], strict: false)
			XCTAssertEqual(single.value, nil)

			try m.parse(["-a", "--charlie"], strict: false)
			XCTAssertEqual(single.value, nil)
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
			try m.parse(["-a", "-b"], strict: false)
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
			try m.parse(["-a", "-b"], strict: false)
			XCTAssertEqual(defaultsingle.value, "defaultvalue")
			try m.parse(["-a", "notdefaultvalue"], strict: false)
			XCTAssertEqual(defaultsingle.value, "notdefaultvalue")
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

	func testRemoveDoubleDashIfAlone () {
		let m = Moderator()
		let arguments = ["--"]

		do {
			try m.parse(arguments, strict: true)
			try m.parse(arguments, strict: false)
			XCTAssert(m.remaining.isEmpty)
		} catch {
			XCTFail(String(describing: error))
		}
	}

	func testUsageText () {
		let m = Moderator(description: "A very thorough and informative description.")
		_ = m.add(.option("a", "alpha", description: "The leader."))
		_ = m.add(Argument<Bool>.optionWithValue("b", "bravo", description: "Well done!").default("default value"))
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
		("testOptionAndArgumentJoinedWithEqualSign", testOptionAndArgumentJoinedWithEqualSign),
		//("testPreprocessorHandlesJoinedFlags", testPreprocessorHandlesJoinedFlags),
		("testParsingOption", testParsingOption),
		("testParsingOptionWithValue", testParsingOptionWithValue),
		("testParsingOptionWithMissingValueThrows", testParsingOptionWithMissingValueThrows),
		("testParsingMissingOptionWithValue", testParsingMissingOptionWithValue),
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
