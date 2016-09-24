import Foundation
@testable import MessagePack
import XCTest

class FloatTests: XCTestCase {
    let packed = Data(bytes: [0xca, 0x40, 0x48, 0xf5, 0xc3])

    static var allTests : [(String, (FloatTests) -> () throws -> Void)] {
        return [
            ("testPack", testPack),
            ("testUnpack", testUnpack),
        ]
    }

    func testPack() {
        XCTAssertEqual(pack(.Float(3.14)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Float(3.14))
    }
}
