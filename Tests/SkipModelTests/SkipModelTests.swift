// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Combine
import XCTest

@available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 8, *)
final class SkipModelTests: XCTestCase {
    var published = -1

    func testObjectWillChange() {
        let model = Model()
        var observed = -1
        let cancellable = model.objectWillChange.sink {
            observed = model.value
        }
        XCTAssertEqual(observed, -1)
        model.value = 5
        XCTAssertEqual(observed, 0)
        model.value = 100
        XCTAssertEqual(observed, 5)
        XCTAssertEqual(model.value, 100)

        cancellable.cancel()
        model.value = 200
        XCTAssertEqual(observed, 5)
        XCTAssertEqual(model.value, 200)
    }

    func testPropertyPublisher() {
        let model = Model()
        var published = -1
        var observed = -1
        let cancellable = model.$value.sink {
            published = $0
            observed = model.value
        }
        XCTAssertEqual(published, 0)
        XCTAssertEqual(observed, 0)
        model.value = 5
        XCTAssertEqual(published, 5)
        XCTAssertEqual(observed, 0)
        model.value = 100
        XCTAssertEqual(published, 100)
        XCTAssertEqual(observed, 5)
        XCTAssertEqual(model.value, 100)

        cancellable.cancel()
        model.value = 200
        XCTAssertEqual(published, 100)
        XCTAssertEqual(observed, 5)
        XCTAssertEqual(model.value, 200)
    }

    func testAssignTo() {
        let model = Model()
        published = -1
        let cancellable = model.$value.assign(to: \.published, on: self)
        XCTAssertEqual(published, 0)
        model.value = 5
        XCTAssertEqual(published, 5)
        model.value = 100
        XCTAssertEqual(published, 100)
        XCTAssertEqual(model.value, 100)

        cancellable.cancel()
        model.value = 200
        XCTAssertEqual(published, 100)
    }

    func testPassthroughSubject() {
        let subject = PassthroughSubject<Int, Never>()
        subject.send(1)
        subject.send(2)
        subject.send(3)

        var published = -1
        let cancellable = subject.sink {
            published = $0
        }
        XCTAssertEqual(published, -1)

        subject.send(4)
        XCTAssertEqual(published, 4)

        cancellable.cancel()
        subject.send(5)
        XCTAssertEqual(published, 4)
    }

    func testMap() {
        let model = Model()
        var published = ""
        let cancellable = model.$value.map {
            String(describing: $0)
        }.sink {
            published = $0
        }
        XCTAssertEqual(published, "0")
        model.value = 5
        XCTAssertEqual(published, "5")

        cancellable.cancel()
        model.value = 100
        XCTAssertEqual(published, "5")
    }

    func testStoreIn() {
        let model = Model()
        var cancellables: Set<AnyCancellable> = []
        model.$value.sink { _ in  }.store(in: &cancellables)
        XCTAssertEqual(cancellables.count, 1)
    }
}

class Model: ObservableObject {
    @Published var value = 0
}
