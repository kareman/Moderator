// Should ideally and eventually be compatible with http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html , with the addition of "--longname".

public typealias UsageText = (title: String, description: String)?

public struct ArgumentParser <Value> {
	public let usage: UsageText
	public let parse: ([String]) throws -> (value: Value, remainder: [String])

	public init (usage: UsageText = nil, p: @escaping ([String]) throws -> (value: Value, remainder: [String])) {
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
	public func map <Outvalue> (_ f: @escaping (Value) throws -> Outvalue) -> ArgumentParser<Outvalue> {
		return ArgumentParser<Outvalue>(usage: self.usage) { args in
			let result = try self.parse(args)
			return (value: try f(result.value), remainder: result.remainder)
		}
	}
}

public struct ArgumentError: Error, CustomStringConvertible {
	public let errormessage: String
	public internal(set) var usagetext: String? = nil

	public init (errormessage: String, usagetext: String? = nil) {
		self.errormessage = errormessage
		self.usagetext = usagetext
	}

	public var description: String { return errormessage + (usagetext.map { "\n" + $0 } ?? "") }
}

extension ArgumentParser {
	static func isOption (index: Array<String>.Index, args: [String]) -> Bool {
		if let i = args.index(of: "--"), i < index { return false }
		let argument = args[index].characters
		if argument.first == "-", let second = argument.dropFirst().first {
			if !("0"..."9" ~= second) { return true }
		}
		return false
	}

	static func option(names: [String], description: String? = nil) -> ArgumentParser<Bool> {
		let names = names.map { $0.characters.count==1 ? "-" + $0 : "--" + $0 }
		let usage = description.map { (names.joined(separator: ","), $0) }
		return ArgumentParser<Bool>(usage: usage) { args in
			var args = args
			guard let index = args.index(where: names.contains), isOption(index: index, args: args) else { return (false, args) }
			args.remove(at: index)
			return (true, args)
		}
	}

	public static func option(_ names: String..., description: String? = nil) -> ArgumentParser<Bool> {
		return option(names: names, description: description)
	}
}


extension Array where Element: Equatable {
	public func indexOfFirstDifference (_ other: Array<Element>) -> Index? {
		for i in self.indices {
			if i >= other.endIndex || self[i] != other[i] { return i }
		}
		return nil
	}
}

extension ArgumentParser {
	public func next <Outvalue> (_ f: @escaping (String, Array<String>.Index?, [String]) throws -> (value: Outvalue, remainder: [String]) ) -> ArgumentParser<Outvalue> {
		return ArgumentParser<Outvalue>(usage: self.usage) { args in
			let result = try self.parse(args)
			let firstchange = result.remainder.indexOfFirstDifference(args)
			return try f(args[firstchange ?? args.endIndex-1], firstchange, result.remainder)
		}
	}

	public static func optionWithValue (_ names: String..., description: String? = nil) -> ArgumentParser<String> {
		return ArgumentParser.option(names: names, description: description)
			.next { (option, firstchange, args) in
				var args = args
				guard let firstchange = firstchange else {
					throw ArgumentError(errormessage: "Expected value for argument '\(option)'.")
				}
				guard !isOption(index: firstchange, args: args) else {
					throw ArgumentError(errormessage: "Expected value for '\(option)', got option '\(args[firstchange])'.")
				}
				let result = args.remove(at: firstchange)
				return (result, args)
		}
	}

	public static func singleArgument (name: String, description: String? = nil) -> ArgumentParser<String> {
		return ArgumentParser<String>(usage: description.map { (name, $0) }) { args in
			guard let arg = args.first else { throw ArgumentError(errormessage: "Expected " + name) }
			guard !isOption(index: 0, args: args) else { throw ArgumentError(errormessage: "Expected \(name), got option '\(arg)'") }
			return (arg, Array(args.dropFirst()))
		}
	}
}
