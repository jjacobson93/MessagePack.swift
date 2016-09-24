import Foundation

/// Packs an integer into a byte array.
///
/// - parameter value: The integer to split.
/// - parameter parts: The number of bytes into which to split.
///
/// - returns: An byte array representation.
func packInteger(_ value: UInt64, parts: Int) -> Data {
    precondition(parts > 0)
    return Data(bytes: stride(from: (8 * (parts - 1)), through: 0, by: -8).map { shift in
        return Byte(truncatingBitPattern: value >> numericCast(shift))
    })
}

/// Packs an unsigned integer into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
func packPositiveInteger(_ value: UInt64) -> Data {
    switch value {
    case let value where value <= 0x7f:
        return Data(bytes: [Byte(truncatingBitPattern: value)])
    case let value where value <= 0xff:
        return Data(bytes: [0xcc, Byte(truncatingBitPattern: value)])
    case let value where value <= 0xffff:
        return Data(bytes: [0xcd] + packInteger(value, parts: 2))
    case let value where value <= 0xffff_ffff:
        return Data(bytes: [0xce] + packInteger(value, parts: 4))
    default:
        return Data(bytes: [0xcf] + packInteger(value, parts: 8))
    }
}

/// Packs a signed integer into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
func packNegativeInteger(_ value: Int64) -> Data {
    precondition(value < 0)

    switch value {
    case let value where value >= -0x20:
        return Data(bytes: [0xe0 + 0x1f & Byte(truncatingBitPattern: value)])
    case let value where value >= -0x7f:
        return Data(bytes: [0xd0, Byte(bitPattern: numericCast(value))])
    case let value where value >= -0x7fff:
        let truncated = UInt16(bitPattern: numericCast(value))
        return Data(bytes: [0xd1] + packInteger(numericCast(truncated), parts: 2))
    case let value where value >= -0x7fff_ffff:
        let truncated = UInt32(bitPattern: numericCast(value))
        return Data(bytes: [0xd2] + packInteger(numericCast(truncated), parts: 4))
    default:
        let truncated = UInt64(bitPattern: value)
        return Data(bytes: [0xd3] + packInteger(truncated, parts: 8))
    }
}

/// Packs a MessagePackValue into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
public func pack(_ value: MessagePackValue) -> Data {
    switch value {
    case .Nil:
        return Data(bytes: [0xc0])

    case let .Bool(value):
        return Data(bytes: [value ? 0xc3 : 0xc2])

    case let .Int(value):
        if value >= 0 {
            return packPositiveInteger(numericCast(value))
        } else {
            return packNegativeInteger(value)
        }

    case let .UInt(value):
        return packPositiveInteger(value)

    case let .Float(value):
        let integerValue = unsafeBitCast(value, to: UInt32.self)
        return Data(bytes: [0xca] + packInteger(numericCast(integerValue), parts: 4))

    case let .Double(value):
        let integerValue = unsafeBitCast(value, to: UInt64.self)
        return Data(bytes: [0xcb] + packInteger(integerValue, parts: 8))

    case let .String(string):
        let utf8 = string.utf8
        let count = UInt32(utf8.count)
        precondition(count <= 0xffff_ffff)

        let prefix: Data
        switch count {
        case let count where count <= 0x19:
            prefix = Data(bytes: [0xa0 | numericCast(count)])
        case let count where count <= 0xff:
            prefix = Data(bytes: [0xd9, numericCast(count)])
        case let count where count <= 0xffff:
            prefix = Data(bytes: [0xda] + packInteger(numericCast(count), parts: 2))
        default:
            prefix = Data(bytes: [0xdb] + packInteger(numericCast(count), parts: 4))
        }

        return prefix + utf8

    case let .Binary(data):
        let count = UInt32(data.count)
        precondition(count <= 0xffff_ffff)

        let prefix: Data
        switch count {
        case let count where count <= 0xff:
            prefix = Data(bytes: [0xc4, numericCast(count)])
        case let count where count <= 0xffff:
            prefix = Data(bytes: [0xc5] + packInteger(numericCast(count), parts: 2))
        default:
            prefix = Data(bytes: [0xc6] + packInteger(numericCast(count), parts: 4))
        }

        return prefix + data

    case let .Array(array):
        let count = UInt32(array.count)
        precondition(count <= 0xffff_ffff)

        let prefix: Data
        switch count {
        case let count where count <= 0xe:
            prefix = Data(bytes: [0x90 | numericCast(count)])
        case let count where count <= 0xffff:
            prefix = Data(bytes: [0xdc] + packInteger(numericCast(count), parts: 2))
        default:
            prefix = Data(bytes: [0xdd] + packInteger(numericCast(count), parts: 4))
        }

        return prefix + array.flatMap(pack)

    case let .Map(dict):
        let count = UInt32(dict.count)
        precondition(count < 0xffff_ffff)

        var prefix: Data
        switch count {
        case let count where count <= 0xe:
            prefix = Data(bytes: [0x80 | numericCast(count)])
        case let count where count <= 0xffff:
            prefix = Data(bytes: [0xde] + packInteger(numericCast(count), parts: 2))
        default:
            prefix = Data(bytes: [0xdf] + packInteger(numericCast(count), parts: 4))
        }

        return prefix + dict.flatMap { [$0, $1] }.flatMap(pack)

    case let .Extended(type, data):
        let count = UInt32(data.count)
        precondition(count <= 0xffff_ffff)

        let unsignedType = UInt8(bitPattern: type)
        var prefix: Data
        switch count {
        case 1:
            prefix = Data(bytes: [0xd4, unsignedType])
        case 2:
            prefix = Data(bytes: [0xd5, unsignedType])
        case 4:
            prefix = Data(bytes: [0xd6, unsignedType])
        case 8:
            prefix = Data(bytes: [0xd7, unsignedType])
        case 16:
            prefix = Data(bytes: [0xd8, unsignedType])
        case let count where count <= 0xff:
            prefix = Data(bytes: [0xc7, numericCast(count), unsignedType])
        case let count where count <= 0xffff:
            prefix = Data(bytes: [0xc8] + packInteger(numericCast(count), parts: 2) + [unsignedType])
        default:
            prefix = Data(bytes: [0xc9] + packInteger(numericCast(count), parts: 4) + [unsignedType])
        }

        return prefix + data
    }
}
