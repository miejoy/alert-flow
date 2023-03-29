//
//  AlertModifier.swift
//  
//
//  Created by 黄磊 on 2023/3/9.
//

import Foundation
import DataFlow
import SwiftUI

/// 弹窗修改器（如果使用 present-flow，这个修改器应该在 PresentModifier 之外）
public struct AlertModifier: ViewModifier {
    let level: UInt
    public init(level: UInt = 0) {
        self.level = level
    }
    
    public func body(content: Content) -> some View {
        AlertFlowView(level: level) {
            content
        }
    }
}


