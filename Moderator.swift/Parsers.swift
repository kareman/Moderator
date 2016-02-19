//: Playground - noun: a place where people can play


extension ArgumentParser {
	public static func flag(short short: Character, long: String, description: String? = nil) -> ArgumentParser<Bool> {
		let usage: UsageText = description.map { ("-\(short), --\(long):", $0) }
		return ArgumentParser<Bool>(usage: usage) { (var args) in
			guard let index = args.indexOf({
				return $0 == "-\(short)" || $0 == "--\(long)"
			}) else {
				return (false, args)
			}
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
	 public static func flagWithValue (short: Character, long: String, description: String? = nil) -> ArgumentParser<String> {
		return ArgumentParser.flag(short: short, long: long, description: description)
			.next { (flagfound, firstchange, var args) in
				guard flagfound, let firstchange = firstchange else { throw ArgumentError(errormessage: "missing value") }
				let result = args.removeAtIndex(firstchange)
				return (result, args)
		}
	}
}
