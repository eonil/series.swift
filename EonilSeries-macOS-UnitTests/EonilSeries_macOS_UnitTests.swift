//
//  EonilSeries_macOS_UnitTests.swift
//  EonilSeries-macOS-UnitTests
//
//  Created by Hoon H. on 2017/10/09.
//

import XCTest
import EonilSeries

class EonilSeries_macOS_UnitTests: XCTestCase {
    func testSeriesAutokeyAppending() {
        typealias S = Series<String>
        var s = S()
        s.append(value: "AAA")
        s.append(value: "BBB")
        s.append(value: "CCC")
        XCTAssertEqual(s.count, 3)
        XCTAssertEqual(s[0].key, S.PointKey.min)
        XCTAssertEqual(s[1].key, S.PointKey.min.next)
        XCTAssertEqual(s[2].key, S.PointKey.min.next.next)
        XCTAssertEqual(s[0].value, "AAA")
        XCTAssertEqual(s[1].value, "BBB")
        XCTAssertEqual(s[2].value, "CCC")
    }
    func testSeriesNewsResolving() {
        typealias S = Series<String>
        var s1 = S()
        s1.append(value: "AAA")
        s1.append(value: "BBB")
        s1.append(value: "CCC")
        var s2 = s1
        s2.append(value: "DDD")
        s2.append(value: "EEE")
        s2.append(value: "FFF")

        let news = s1.news(from: s2)
        XCTAssertEqual(news.count, 3)
        XCTAssertEqual(news.startIndex, 3)
        XCTAssertEqual(news.endIndex, 6)
        XCTAssertEqual(news[news.startIndex + 0].key, s2[3].key)
        XCTAssertEqual(news[news.startIndex + 1].key, s2[4].key)
        XCTAssertEqual(news[news.startIndex + 2].key, s2[5].key)
    }
    func testSeriesAppendNews() {
        typealias S = Series<String>
        var s1 = S()
        s1.append(value: "AAA")
        s1.append(value: "BBB")
        s1.append(value: "CCC")
        var s2 = s1
        s2.append(value: "DDD")
        s2.append(value: "EEE")
        s2.append(value: "FFF")

        s1.append(newsFrom: s2)
        XCTAssertEqual(s1[0].value, "AAA")
        XCTAssertEqual(s1[1].value, "BBB")
        XCTAssertEqual(s1[2].value, "CCC")
        XCTAssertEqual(s1[3].value, "DDD")
        XCTAssertEqual(s1[4].value, "EEE")
        XCTAssertEqual(s1[5].value, "FFF")
    }
    func testSeriesAppendNewsWithMapping() {
        typealias S1 = Series<Int>
        typealias S2 = Series<String>
        var s1 = S1()
        var s2 = S2()
        s1.append(value: 111)
        s1.append(value: 222)
        s1.append(value: 333)
        s2.append(newsFrom: s1, with: { "- \($0)" })
        XCTAssertEqual(s2[0].value, "- 111")
        XCTAssertEqual(s2[1].value, "- 222")
        XCTAssertEqual(s2[2].value, "- 333")
    }
    func testSeriesAppendNewsWithMapping2() {
        typealias S1 = Series<Int>
        typealias S2 = Series<String>
        var s1 = S1()
        var s2 = S2()
        s1.append(value: 111)
        s1.append(value: 222)
        s1.append(value: 333)
        s2.append(newsFrom: s1, with: { "- \($0)" })
        XCTAssertEqual(s2[0].value, "- 111")
        XCTAssertEqual(s2[1].value, "- 222")
        XCTAssertEqual(s2[2].value, "- 333")
        s1.append(value: 444)
        s1.append(value: 555)
        s1.append(value: 666)
        s2.append(newsFrom: s1, with: { "+ \($0)" })
        XCTAssertEqual(s2[0].value, "- 111")
        XCTAssertEqual(s2[1].value, "- 222")
        XCTAssertEqual(s2[2].value, "- 333")
        XCTAssertEqual(s2[3].value, "+ 444")
        XCTAssertEqual(s2[4].value, "+ 555")
        XCTAssertEqual(s2[5].value, "+ 666")
    }
}
