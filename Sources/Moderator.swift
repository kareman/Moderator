//
//  Moderator.swift
//
//  Created by Kåre Morstøl.
//  Copyright (c) 2016 NotTooBad Software. All rights reserved.
//

public final class Moderator {
	fileprivate var parsers: [ArgumentParser<Void>] = []
	public fileprivate(set) var remaining: [String] = []

	public init () { }

	public func add <Value> (_ p: ArgumentParser<Value>) -> FutureValue<Value> {
		let b = FutureValue<Value>()
		parsers.append(p.map {b.value = $0})
		return b
	}

	public func parse (_ args: [String], strict: Bool = false) throws {
		do {
			remaining = try parsers.reduce(args) { (args, parser) in try parser.parse(args).remainder }
			if strict && !remaining.isEmpty {
				throw ArgumentError(errormessage: "Unknown arguments: " + self.remaining.joined(separator: " "))
			}
		} catch var error as ArgumentError {
			error.usagetext = self.usagetext
			throw error
		}
	}

	public func parse (strict: Bool = false) throws {
		try parse(Array(CommandLine.arguments.dropFirst()), strict: strict)
	}

	public var usagetext: String {
		let usagetexts = parsers.flatMap { $0.usage }
		guard !usagetexts.isEmpty else {return ""}
		return usagetexts.reduce("Usage: \(CommandLine.arguments.first ?? "")\n") {
			(acc:String, usagetext:UsageText) -> String in
			return acc + "  " + usagetext!.title + ":\n      " + usagetext!.description + "\n"
		}
	}
}

//  https://github.com/robrix/Box
//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A value that will be set sometime in the future.
public final class FutureValue<T>: CustomStringConvertible {
	/// Initializes a `FutureValue` with the given value.
	public init(_ value: T) {
		self.value = value
	}

	/// Initializes an empty `FutureValue`.
	public init() {
		self.value = nil
	}

	private var _value: T!

	/// The (mutable) value.
	public var value: T! {
		get {
			precondition(_value != nil, "Remember to call ArgumentParser.parse() before accessing value of arguments.")
			return _value
		}
		set {
			_value = newValue
		}
	}

	/// Constructs a new FutureValue by transforming `value` by `f`.
	public func map<U>(_ f: (T) -> U) -> FutureValue<U> {
		return FutureValue<U>(f(value))
	}

	// MARK: Printable

	public var description: String {
		return String(describing: value)
	}
}
