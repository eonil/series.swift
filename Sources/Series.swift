//
//  Series.swift
//  Series3
//
//  Created by Hoon H. on 2017/10/09.
//Copyright © 2017 Hoon H. All rights reserved.
//

///
/// Ordered key-value random access collection.
///
public protocol SeriesProtocol: RandomAccessCollection where Index == Int, Element == Point {
    associatedtype PointKey: SeriesPointKeyProtocol
    associatedtype PointValue
    typealias Point = (key: PointKey, value: PointValue)
    init(_ initialPoint: Point)
    subscript(_: Int) -> Point { get }
    subscript(_: Range<Int>) -> SeriesSlice<Self> { get }
}
public protocol NonEmptySeriesProtocol: SeriesProtocol {
    var earliest: Point { get }
    var latest: Point { get }
}
public protocol AutoclippingNonEmptySeriesProtocol: NonEmptySeriesProtocol {
    init(_ initialPoint: Point, capacity: Int)
    var capacity: Int { get }
}

///
/// Ordered key-value queue.
///
public protocol MutableSeriesProtocol: SeriesProtocol {
    mutating func append(_ p: Point)
    mutating func removeFirst(_ n: Int)
}

///
/// Keys must be sequential.
/// A `Series` consume keys from `.min` to `.max`.
///
public protocol SeriesPointKeyProtocol: Comparable {
    static var min: Self { get }
    static var max: Self { get }
    var previous: Self { get }
    var next: Self { get }
}

///
/// Limited, finite, ordered and sequential unique key.
///
public struct SeriesPointKey: SeriesPointKeyProtocol, Hashable {
    private static let minN = 1
    private static let maxN = Int.max - 1
    private var n: Int
    private init(number: Int) {
        precondition(number >= SeriesPointKey.minN)
        precondition(number <= SeriesPointKey.maxN)
        n = number
    }
    public static let min = SeriesPointKey(number: minN)
    public static let max = SeriesPointKey(number: maxN)
    public var previous: SeriesPointKey { return SeriesPointKey(number: n - 1) }
    public var next: SeriesPointKey { return SeriesPointKey(number: n + 1) }
    public var hashValue: Int { return n.hashValue }
    public static func == (_ a: SeriesPointKey, _ b: SeriesPointKey) -> Bool { return a.n == b.n }
    public static func < (_ a: SeriesPointKey, _ b: SeriesPointKey) -> Bool { return a.n < b.n }
}

public struct Series<T>: SeriesProtocol, MutableSeriesProtocol {
    public typealias PointKey = SeriesPointKey
    public typealias PointValue = T
    public typealias Point = (key: PointKey, value: PointValue)
    public typealias SubSequence = SeriesSlice<Series<T>>
    private var raw = [Point]()
    public init() {}
    public init(_ initialPoint: Point) { append(initialPoint) }
    public init<S>(_ s: S) where S: NonEmptySeriesProtocol, S.Point == Point { raw = Array(s) }
    public var startIndex: Int { return raw.startIndex }
    public var endIndex: Int { return raw.endIndex }
    public subscript(_ i: Int) -> Point { return raw[i] }
    public subscript(_ range: Range<Int>) -> SubSequence { return SubSequence(base: self, bounds: range) }
    public mutating func append(_ p: Point) {
        precondition(raw.isEmpty || raw.last!.key < p.key, "Supplied point has too old key to be added to this series.")
        raw.append(p)
    }
    ///
    /// This series must be empty or first point key in new sequence must be
    /// newer than last point key of this series.
    ///
    public mutating func append<S>(contentsOf s: S) where S: SeriesProtocol, S.Point == Point {
        guard s.isEmpty == false else { return } // No-op.
        precondition(isEmpty || first!.key < s.first!.key, "Supplied sequence has too old point at first to be added to this series.")
        raw.append(contentsOf: s)
    }
    public mutating func removeFirst(_ n: Int) { raw.removeFirst(n) }
}

public struct NonEmptySeries<T>: NonEmptySeriesProtocol, MutableSeriesProtocol {
    public typealias PointKey = SeriesPointKey
    public typealias PointValue = T
    public typealias Point = (key: PointKey, value: PointValue)
    public typealias SubSequence = SeriesSlice<NonEmptySeries<T>>
    private var raw: Series<T>
    public init(_ initialPoint: Point) { raw = Series(initialPoint) }
    public init<S>(_ s: S) where S: NonEmptySeriesProtocol, S.Point == Point { raw = Series(s) }
    public var startIndex: Int { return raw.startIndex }
    public var endIndex: Int { return raw.endIndex }
    public subscript(_ i: Int) -> Point { return raw[i] }
    public subscript(_ range: Range<Int>) -> SubSequence { return SubSequence(base: self, bounds: range) }
    public mutating func append(_ p: Point) { raw.append(p) }
    public mutating func removeFirst(_ n: Int) {
        precondition(n < raw.count, "You cannot all points in this series. At least one point must alive.")
        raw.removeFirst(n)
    }
    public var earliest: Point { return raw.first! }
    public var latest: Point { return raw.last! }
}

public struct AutoclippingNonEmptySeries<T>: AutoclippingNonEmptySeriesProtocol, MutableSeriesProtocol {
    public typealias PointKey = SeriesPointKey
    public typealias PointValue = T
    public typealias Point = (key: PointKey, value: PointValue)
    public typealias SubSequence = SeriesSlice<AutoclippingNonEmptySeries<T>>
    private var raw: NonEmptySeries<T>
    public let capacity: Int
    public init(_ initialPoint: Point) { self = AutoclippingNonEmptySeries(initialPoint, capacity: 2) }
    public init(_ initialPoint: Point, capacity: Int) {
        raw = NonEmptySeries(initialPoint)
        self.capacity = capacity
    }
    public var startIndex: Int { return raw.startIndex }
    public var endIndex: Int { return raw.endIndex }
    public subscript(_ i: Int) -> Point { return raw[i] }
    public subscript(_ range: Range<Int>) -> SubSequence { return SubSequence(base: self, bounds: range) }
    public mutating func append(_ p: Point) {
        raw.append(p)
        clip()
    }
    ///
    /// All points in sequence MUST be ordered by its key.
    ///
    public mutating func append<S>(contentsOf s: S) where S: Collection, S.Element == Point, S.IndexDistance == Int {
        raw.append(contentsOf: s)
        clip()
    }
    public mutating func removeFirst(_ n: Int) { raw.removeFirst(n) }
    public var earliest: Point { return raw.earliest }
    public var latest: Point { return raw.latest }
    private mutating func clip() {
        removeFirst(Swift.max(0, raw.count - capacity))
    }
}

public struct OnePointSeries<T>: NonEmptySeriesProtocol {
    public typealias PointKey = SeriesPointKey
    public typealias PointValue = T
    public typealias Point = (key: PointKey, value: PointValue)
    public typealias SubSequence = SeriesSlice<OnePointSeries<T>>
    private var thePoint: Point
    public init(_ initialPoint: Point) { thePoint = initialPoint }
    public let startIndex = 0
    public let endIndex = 1
    public subscript(_ i: Int) -> Point {
        precondition(i == 0)
        return thePoint
    }
    public subscript(_ range: Range<Int>) -> SubSequence {
        precondition(range == 0..<1)
        return SubSequence(base: self, bounds: range)
    }
    public var earliest: Point { return thePoint }
    public var latest: Point { return thePoint }
}

public typealias SeriesSlice<S> = RandomAccessSlice<S> where S: SeriesProtocol
