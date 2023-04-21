//
//  UIView+DebugBorder.swift
//
//  Helper class to quickly throw a border around a view when
//  troubleshooting layouts.  Cycles between colors
//

import UIKit

private struct BorderColors {
    let colors: [UIColor] = [.red, .green, .blue, .purple, .orange, .yellow]
    var idx = 0

    mutating func nextColor() -> CGColor {
        let result = colors[idx].cgColor
        idx += 1
        if idx == colors.count {
            idx = 0
        }
        return result
    }
}

extension UIView {
    fileprivate static var borderColors = BorderColors()

    @MainActor
    func debugBorder() {
        layer.borderColor = Self.borderColors.nextColor()
        layer.borderWidth = 1
    }
}
