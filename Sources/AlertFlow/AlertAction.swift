//
//  AlertAction.swift
//
//
//  Created by 黄磊 on 2023/3/11.
//

import Foundation
import DataFlow

/// 弹窗事件
public struct AlertAction: Action {
    
    enum InnerAction {
        case none
        case dismissTopAlert
        case addInnerStore(Store<InnerAlertState>)
        case removeInnerStoreOnLevel(UInt)
    }
    
    enum InterruptAction {
        case add(InterruptInfo)
        case remove(UUID)
    }
    
    /// 内部事件
    enum ContentAction {
        case show(AlertInfo)
        case dismiss(UUID)
        case interrupt(InterruptAction)
        case inner(InnerAction)
    }
    
    var action: ContentAction
    
    static func inner(_ action: InnerAction) -> Self {
        .init(action: .inner(action))
    }
    
    /// 生成弹窗显示事件
    ///
    /// - Parameter alertInfo: 对应弹窗弹窗
    /// - Returns: 对于事件
    public static func showAlert(_ alertInfo: AlertInfo) -> Self {
        return .init(action: .show(alertInfo))
    }
    
    /// 生成弹窗消失事件，一般弹窗在用户点击时就会消失，这种代码消失需要自己记录 uuid
    /// 注意：SwiftUI 的 alert 使用代码消失存在问题，暂时不公开
    ///
    /// - Parameter uuid: 需要消失弹框的 uuid
    /// - Returns: 对于事件
    static func dismissAlert(with uuid: UUID) -> Self {
        return .init(action: .dismiss(uuid))
    }
}
