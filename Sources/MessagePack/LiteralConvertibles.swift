extension MessagePackValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MessagePackValue...) {
        self = .Array(elements)
    }
}

extension MessagePackValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Swift.Bool) {
        self = .Bool(value)
    }
}

extension MessagePackValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (MessagePackValue, MessagePackValue)...) {
        var dict = [MessagePackValue : MessagePackValue](minimumCapacity: elements.count)
        for (key, value) in elements {
            dict[key] = value
        }

        self = .Map(dict)
    }
}

extension MessagePackValue: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: Swift.String) {
        self = .String(value)
    }
}

extension MessagePackValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Swift.Double) {
        self = .Double(value)
    }
}

extension MessagePackValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self = .Int(value)
    }
}

extension MessagePackValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .Nil
    }
}

extension MessagePackValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: Swift.String) {
        self = .String(value)
    }
}

extension MessagePackValue: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: Swift.String) {
        self = .String(value)
    }
}
