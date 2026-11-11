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

/// Places the controls together while keeping a usable viewport for the main scrollable content.
enum StickyFooterLayout {

    static func frame(
        in bounds: CGRect,
        idealHeight: CGFloat,
        minimumContentHeight: CGFloat,
        avoiding divisions: [CGRect]
    ) -> CGRect {
        guard bounds.width > 0, bounds.height > 0 else { return .zero }

        var regions = [bounds]
        for division in divisions where !division.isEmpty {
            regions = regions.flatMap { region -> [CGRect] in
                let intersection = region.intersection(division)
                guard !intersection.isNull, !intersection.isEmpty else { return [region] }

                if division.height >= division.width {
                    return [
                        CGRect(x: region.minX, y: region.minY,
                               width: intersection.minX - region.minX, height: region.height),
                        CGRect(x: intersection.maxX, y: region.minY,
                               width: region.maxX - intersection.maxX, height: region.height)
                    ].filter { !$0.isEmpty }
                }
                return [
                    CGRect(x: region.minX, y: region.minY,
                           width: region.width, height: intersection.minY - region.minY),
                    CGRect(x: region.minX, y: intersection.maxY,
                           width: region.width, height: region.maxY - intersection.maxY)
                ].filter { !$0.isEmpty }
            }
        }

        let contentHeight = min(max(0, minimumContentHeight), bounds.height / 2)
        let frames = regions.map { region -> CGRect in
            let maximumHeight = max(0, region.maxY - bounds.minY - contentHeight)
            let height = min(idealHeight > 0 ? idealHeight : maximumHeight, maximumHeight, region.height)
            return CGRect(x: region.minX, y: region.maxY - height, width: region.width, height: height)
        }
        return frames.max { lhs, rhs in
            let lhsArea = lhs.width * lhs.height
            let rhsArea = rhs.width * rhs.height
            if lhsArea != rhsArea { return lhsArea < rhsArea }
            if lhs.maxY != rhs.maxY { return lhs.maxY < rhs.maxY }
            return lhs.minX > rhs.minX
        } ?? .zero
    }

}
