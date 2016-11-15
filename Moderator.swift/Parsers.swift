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
	public static func option(_ names: String..., description: String? = nil) -> ArgumentParser<Bool> {
		let names = names.map { $0.characters.count==1 ? "-" + $0 : "--" + $0 }
		let usage = description.map { (names.joined(separator: ","), $0) }
		return ArgumentParser<Bool>(usage: usage) { args in
			var args = args
			guard let index = args.index(where: names.contains) else { return (false, args) }
			args.remove(at: index)
			return (true, args)
		}
	}
/*
	public static func option(names: String..., description: String? = nil) -> ArgumentParser<Bool> {
		 return option(names, description: description)
	}
*/
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
	public func next <Outvalue> (_ f: @escaping (Value, Array<String>.Index?, [String]) throws -> (value: Outvalue, remainder: [String]) ) -> ArgumentParser<Outvalue> {
		return ArgumentParser<Outvalue>(usage: self.usage) { args in
			let result = try self.parse(args)
			let firstchange = result.remainder.indexOfFirstDifference(args)
			return try f(result.value, firstchange, result.remainder)
		}
	}
}

extension ArgumentParser {
	public static func optionWithValue (_ names: String..., description: String? = nil) -> ArgumentParser<String> {
		return ArgumentParser.option(names[0], description: description)
			.next { (optionfound, firstchange, args) in
				var args = args
				guard optionfound, let firstchange = firstchange else {
					throw ArgumentError(errormessage: "Missing value after argument '\(names.joined(separator: "|"))'.")
				}
				let result = args.remove(at: firstchange)
				return (result, args)
		}
	}
}

