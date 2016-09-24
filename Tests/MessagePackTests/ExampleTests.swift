import Foundation
import Dispatch
@testable import MessagePack
import XCTest

class ExampleTests: XCTestCase {
    static var allTests : [(String, (ExampleTests) -> () throws -> Void)] {
        return [
            ("testPack", testPack),
            ("testUnpack", testUnpack),
            ("testUnpackInvalidData", testUnpackInvalidData),
            ("testUnpackInsufficientData", testUnpackInsufficientData),
            ("testUnpackNSData", testUnpackNSData),
            ("testUnpackInsufficientNSData", testUnpackInsufficientNSData),
            ("testUnpackDispatchData", testUnpackDispatchData),
            ("testUnpackDiscontinuousDispatchData", testUnpackDiscontinuousDispatchData),
            ("testUnpackInsufficientDispatchData", testUnpackInsufficientDispatchData),
        ]
    }

    let example: MessagePackValue = ["compact": true, "schema": 0]

    // Two possible "correct" values because dictionaries are unordered
    let correctA = Data(bytes: [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00])
    let correctB = Data(bytes: [0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3])

    func testPack() {
        let packed = pack(example)
        XCTAssertTrue(packed == correctA || packed == correctB)
    }

    func testUnpack() {
        let unpacked1 = try? unpack(correctA)
        XCTAssertEqual(unpacked1, example)

        let unpacked2 = try? unpack(correctB)
        XCTAssertEqual(unpacked2, example)
    }

    func testUnpackInvalidData() {
        do {
            _ = try unpack([0xc1])
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .InvalidData)
        }
    }

    func testUnpackInsufficientData() {
        do {
            _ = try unpack([0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61])
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .InsufficientData)
        }
    }

    func testUnpackNSData() {
        let unpacked = try? unpack(correctA)
        XCTAssertEqual(unpacked, example)
    }

    func testUnpackInsufficientNSData() {
        let data = Data(bytes: [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d])

        do {
            _ = try unpack(data)
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .InsufficientData)
        }
    }

    func testUnpackDispatchData() {
        let data = correctA.withUnsafeBytes { bytes in
            return DispatchData(bytes: UnsafeBufferPointer(start: bytes, count: correctA.count))
        }

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, example)
    }

    func testUnpackDiscontinuousDispatchData() {
        let bytesA = Data(bytes: [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63])
        let dataA = bytesA.withUnsafeBytes { bytes in
            return DispatchData(bytes: UnsafeBufferPointer(start: bytes, count: bytesA.count))
        }

        let bytesB = Data(bytes: [0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00])
        let dataB = bytesB.withUnsafeBytes { bytes in
            return DispatchData(bytes: UnsafeBufferPointer(start: bytes, count: bytesB.count))
        }

        var data = DispatchData.empty
        data.append(dataA)
        data.append(dataB)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, example)
    }

    func testUnpackInsufficientDispatchData() {
        let bytesA = Data(bytes: [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d])
        let data = bytesA.withUnsafeBytes { bytes in
            return DispatchData(bytes: UnsafeBufferPointer(start: bytes, count: bytesA.count))
        }

        do {
            _ = try unpack(data)
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .InsufficientData)
        }
    }
}
