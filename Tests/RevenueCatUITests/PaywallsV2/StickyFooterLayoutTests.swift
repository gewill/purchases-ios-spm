//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//

import CoreGraphics
@testable import RevenueCatUI
import XCTest

final class StickyFooterLayoutTests: TestCase {

    func testOrdinaryFooterKeepsItsNaturalHeight() {
        let bounds = CGRect(x: 0, y: 0, width: 382, height: 562)
        let frame = StickyFooterLayout.frame(in: bounds, idealHeight: 300,
                                             minimumContentHeight: 120, avoiding: [])
        XCTAssertEqual(frame, CGRect(x: 0, y: 262, width: 382, height: 300))
    }

    func testLargeTextKeepsBothContentAndControlsScrollable() {
        let bounds = CGRect(x: 0, y: 0, width: 382, height: 562)
        let frame = StickyFooterLayout.frame(in: bounds, idealHeight: 800,
                                             minimumContentHeight: 162, avoiding: [])
        XCTAssertGreaterThanOrEqual(frame.minY, 162)
        XCTAssertEqual(frame.maxY, bounds.maxY)
        XCTAssertLessThan(frame.height, 800)
        XCTAssertGreaterThan(frame.height, 0)
    }

    func testBookControlsAvoidMeasuredDivisionAndItsMargins() {
        let bounds = CGRect(x: 0, y: 0, width: 867, height: 553)
        let division = CGRect(x: 435.5, y: -82, width: 80, height: 669)
        let frame = StickyFooterLayout.frame(in: bounds, idealHeight: 800,
                                             minimumContentHeight: 162, avoiding: [division])
        XCTAssertFalse(frame.intersects(division))
        XCTAssertTrue(bounds.contains(frame))
        XCTAssertGreaterThanOrEqual(frame.minY, 162)
        XCTAssertGreaterThan(frame.width, 300)
    }

    func testTabletopFooterStaysBelowHorizontalDivision() {
        let bounds = CGRect(x: 0, y: 0, width: 553, height: 867)
        let division = CGRect(x: -20, y: 360, width: 620, height: 80)
        let frame = StickyFooterLayout.frame(in: bounds, idealHeight: 600,
                                             minimumContentHeight: 162, avoiding: [division])
        XCTAssertGreaterThanOrEqual(frame.minY, division.maxY)
        XCTAssertEqual(frame.maxY, bounds.maxY)
        XCTAssertTrue(bounds.contains(frame))
    }

    func testLeavingFoldRestoresFullWidth() {
        let bounds = CGRect(x: 0, y: 0, width: 867, height: 553)
        let division = CGRect(x: 435.5, y: -82, width: 80, height: 669)
        let folded = StickyFooterLayout.frame(in: bounds, idealHeight: 600,
                                              minimumContentHeight: 162, avoiding: [division])
        let flat = StickyFooterLayout.frame(in: bounds, idealHeight: 600,
                                            minimumContentHeight: 162, avoiding: [])
        XCTAssertLessThan(folded.width, flat.width)
        XCTAssertEqual(flat.width, bounds.width)
    }

    func testShortWindowStillHasNonzeroContentAndControls() {
        let bounds = CGRect(x: 0, y: 0, width: 667, height: 160)
        let frame = StickyFooterLayout.frame(in: bounds, idealHeight: 600,
                                             minimumContentHeight: 162, avoiding: [])
        XCTAssertEqual(frame.minY, 80)
        XCTAssertEqual(frame.height, 80)
    }

    func testRegionsOutsideContainerDoNotShrinkFooter() {
        let bounds = CGRect(x: 0, y: 0, width: 382, height: 562)
        let frame = StickyFooterLayout.frame(in: bounds, idealHeight: 300,
                                             minimumContentHeight: 120,
                                             avoiding: [CGRect(x: 500, y: 0, width: 40, height: 600)])
        XCTAssertEqual(frame.width, bounds.width)
        XCTAssertEqual(frame.height, 300)
    }

    func testEmptyContainerDoesNotCreateNegativeFrame() {
        XCTAssertEqual(StickyFooterLayout.frame(in: .zero, idealHeight: 500,
                                                minimumContentHeight: 120, avoiding: []), .zero)
    }

}
