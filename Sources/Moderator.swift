//: Playground - noun: a place where people can play

public final class Moderator {
	fileprivate var parsers: [ArgumentParser<Void>] = []
	public fileprivate(set) var remaining: [String] = []

	public init () { }

	public func add <Value> (_ p: ArgumentParser<Value>) -> MutableBox<Value> {
		let b = MutableBox<Value>()
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
		return usagetexts.reduce("Usage: \(CommandLine.arguments.first ?? "")\n") { (acc:String, usagetext:UsageText) -> String in
			return acc + "  " + usagetext!.title + ":\n      " + usagetext!.description + "\n"
		} as String
	}
}

// https://github.com/robrix/Box/blob/master/Box/MutableBox.swift

//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// Wraps a type `T` in a mutable reference type.
///
/// While this, like `Box<T>` could be used to work around limitations of value types, it is much more useful for sharing a single mutable value such that mutations are shared.
///
/// As with all mutable state, this should be used carefully, for example as an optimization, rather than a default design choice. Most of the time, `Box<T>` will suffice where any `BoxType` is needed.
public final class MutableBox<T>: CustomStringConvertible {
	/// Initializes a `MutableBox` with the given value.
	public init(_ value: T) {
		self.value = value
	}

	/// Initializes a `MutableBox` with the given value.
	public init () {
		self.value = nil
	}

	/// The (mutable) value wrapped by the receiver.
	public var value: T!

	/// Constructs a new MutableBox by transforming `value` by `f`.
	public func map<U>(_ f: (T) -> U) -> MutableBox<U> {
		return MutableBox<U>(f(value))
	}

	// MARK: Printable

	public var description: String {
		return String(describing: value)
	}
}
