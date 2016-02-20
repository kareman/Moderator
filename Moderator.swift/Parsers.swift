
public typealias UsageText = (title: String, description: String)?

public struct ArgumentParser <Value> {
	public let usage: UsageText
	public let parse: ([String]) throws -> (value: Value, remainder: [String])

	public init (usage: UsageText = nil, p: ([String]) throws -> (value: Value, remainder: [String])) {
		self.parse = p
		self.usage = usage
	}

	public init (usage: UsageText = nil, value: Value) {
		self.parse = { args in
			 return (value, args)
		}
		self.usage = usage
	}
}

extension ArgumentParser {
	public func map <Outvalue> (f: Value throws -> Outvalue) -> ArgumentParser<Outvalue> {
		return ArgumentParser<Outvalue>(usage: self.usage) { args in
			let result = try self.parse(args)
			return (value: try f(result.value), remainder: result.remainder)
		}
	}
}

public struct ArgumentError: ErrorType, CustomStringConvertible {
	public let errormessage: String
	public internal(set) var usagetext: String? = nil

	public init (errormessage: String, usagetext: String? = nil) {
		self.errormessage = errormessage
		self.usagetext = usagetext
	}

	public var description: String { return errormessage + (usagetext.map { "\n" + $0 } ?? "") }
}

extension ArgumentParser {
	public static func option(short short: Character, long: String, description: String? = nil) -> ArgumentParser<Bool> {
		let usage = description.map { ("-\(short), --\(long)", $0) }
		return ArgumentParser<Bool>(usage: usage) { (var args) in
			let options = Set(["-\(short)","--\(long)"])
			guard let index = args.indexOf(options.contains) else { return (false, args) }
			args.removeAtIndex(index)
			return (true, args)
		}
	}
}


extension ArgumentParser {
	public func next <Outvalue> (f: (Value, Array<String>.Index?, [String]) throws -> (value: Outvalue, remainder: [String]) ) -> ArgumentParser<Outvalue> {
		return ArgumentParser<Outvalue>(usage: self.usage) { args in
			let result = try self.parse(args)
			let firstchange = result.remainder.indexOfFirstDifference(args)
			return try f(result.value, firstchange, result.remainder)
		}
	}
}

extension Array where Element: Equatable {
	public func indexOfFirstDifference (other: Array<Element>) -> Index? {
		for i in self.indices {
			if i >= other.endIndex || self[i] != other[i] { return i }
		}
		return nil
	}
}

extension ArgumentParser {
	public static func optionWithValue (short short: Character, long: String, description: String? = nil) -> ArgumentParser<String> {
		return ArgumentParser.option(short: short, long: long, description: description)
			.next { (optionfound, firstchange, var args) in
				guard optionfound, let firstchange = firstchange else { throw ArgumentError(errormessage: "Missing value after argument '-\(short)|--\(long)'.") }
				let result = args.removeAtIndex(firstchange)
				return (result, args)
		}
	}
}

