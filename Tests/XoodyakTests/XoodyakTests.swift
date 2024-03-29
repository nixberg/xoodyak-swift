import HexString
import XCTest
import Xoodyak

final class XoodyakTests: XCTestCase {
    func testHash() throws {
        struct Vector: Decodable {
            @HexString var message: [UInt8]
            @HexString var digest:  [UInt8]
            
            private enum CodingKeys: String, CodingKey {
                case message = "msg"
                case digest  = "md"
            }
        }
        
        let url = Bundle.module.url(forResource: "hash", withExtension: "json")
        let vectors = try JSONDecoder().decode([Vector].self, from: try Data(contentsOf: url!))
        
        for vector in vectors {
            var xoodyak = Xoodyak()
            
            xoodyak.absorb(contentsOf: vector.message)
            
            var newDigest: [UInt8] = .init(0..<32)
            xoodyak.squeeze(to: &newDigest, outputByteCount: vector.digest.count)
            
            XCTAssert(newDigest.dropFirst(32).elementsEqual(vector.digest))
        }
    }
}
