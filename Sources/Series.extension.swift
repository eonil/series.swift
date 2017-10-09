//
//  Series.extension.swift
//  Series3
//
//  Created by Hoon H. on 2017/10/09.
//Copyright © 2017 Hoon H. All rights reserved.
//

public extension SeriesProtocol {
    ///
    /// Gets a slice which contains points with key which are larger than last
    /// point-key of this series.
    ///
    /// Program crashes if this series is empty therefore key-based comparison
    /// cannot be defined.
    ///
    public func range(after key: PointKey) -> Range<Int> {
        precondition(isEmpty == false)
        var r = Range(endIndex..<endIndex)
        for i in (startIndex..<endIndex).reversed() {
            guard self[i].key > key else { break }
            r = i..<endIndex
        }
        return r
    }
    ///
    /// Gets a slice which contains points with key which are larger than last
    /// point-key of this series.
    ///
    public func news<S>(from: S) -> S.SubSequence where S: SeriesProtocol, S.PointKey == PointKey {
        if isEmpty || from.isEmpty { return from[from.startIndex..<from.endIndex] }
        return from[last!.key...]
    }
    ///
    /// Program crashes if this series is empty therefore key-based comparison
    /// cannot be defined.
    ///
    public subscript(_ r: PartialRangeFrom<PointKey>) -> SubSequence {
        precondition(isEmpty == false)
        let r1 = range(after: r.lowerBound)
        return self[r1]
    }
}

public extension NonEmptySeriesProtocol {
}

public extension MutableSeriesProtocol {
    ///
    /// Append a new value with next point key.
    /// If this series is empty, `.min` key willl be used.
    ///
    public mutating func append(value v: PointValue) {
        let k = last?.key.next ?? .min
        let p = (k, v)
        append(p)
    }
    ///
    /// All points in sequence MUST be ordered by its key.
    ///
    public mutating func append<S>(contentsOf s: S) where S: Sequence, S.Element == Point {
        for p in s { append(p) }
    }
    ///
    /// Appends all newer points from another series.
    ///
    /// - Note:
    ///     Another series doesn't have to be continuous.
    ///
    public mutating func append(newsFrom s: Self) {
        let newsSlice = news(from: s)
        precondition(isEmpty || newsSlice.isEmpty || last!.key < newsSlice.first!.key)
        append(contentsOf: newsSlice)
    }

    ///
    /// Appends all newer points from another series with point value mapping.
    ///
    /// - Note:
    ///     Another series doesn't have to be continuous.
    ///
    public mutating func append<S>(newsFrom s: S, with mapping: (S.PointValue) -> PointValue) where S: SeriesProtocol, S.PointKey == PointKey {
        let newsSlice = news(from: s)
        precondition(isEmpty || newsSlice.isEmpty || last!.key < newsSlice.first!.key)
        for p in newsSlice {
            let (k, v) = p
            let v1 = mapping(v)
            let p1 = (k, v1)
            append(p1)
        }
    }
}











