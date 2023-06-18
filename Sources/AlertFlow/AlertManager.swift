//
//  AlertManager.swift
//  
//
//  Created by 黄磊 on 2023/3/30.
//  AlertMonitor = Store<AlertState>

import Foundation
import DataFlow
import ViewFlow
import SwiftUI

/// 注意：SwiftUI 的 alert 使用代码消失存在问题，消失后不能自动弹出新弹窗，
/// 目前消失和更新功能均不能使用，普通弹窗和弱弹窗也不能使用，
/// 只对外公开一个弹窗方法，内部使用强弹窗
extension Store where State == AlertState {
    
    /// 显示普通弹窗
    ///
    /// - Parameter title: 弹窗标题
    /// - Parameter message: 弹窗消息
    /// - Parameter buttons: 弹窗按钮
    /// - Parameter textFields: 弹窗输入框
    /// - Returns: 返回弹窗唯一标识
    @discardableResult
    public func showAlert(
        _ title: String?,
        _ message: String? = nil,
        _ buttons: [ButtonInfo] = [],
        _ textFields: [TextFieldInfo] = []
    ) -> UUID {
        let alertInfo = AlertInfo(title: title ?? "", message: message ?? "", alertType: .strong, arrButtons: buttons, arrTextFields: textFields)
        send(action: .showAlert(alertInfo))
        return alertInfo.id
    }
    
    /// 显示强弹窗
    ///
    /// - Parameter title: 弹窗标题
    /// - Parameter message: 弹窗消息
    /// - Parameter buttons: 弹窗按钮
    /// - Parameter textFields: 弹窗输入框
    /// - Returns: 返回弹窗唯一标识
    @discardableResult
    func showStrongAlert(
        _ title: String?,
        _ message: String? = nil,
        _ buttons: [ButtonInfo] = [],
        _ textFields: [TextFieldInfo] = []
    ) -> UUID {
        let alertInfo = AlertInfo(title: title ?? "", message: message ?? "", alertType: .strong, arrButtons: buttons, arrTextFields: textFields)
        send(action: .showAlert(alertInfo))
        return alertInfo.id
    }
    
    /// 显示强弹窗
    ///
    /// - Parameter title: 弹窗标题
    /// - Parameter message: 弹窗消息
    /// - Parameter buttons: 弹窗按钮
    /// - Parameter textFields: 弹窗输入框
    /// - Returns: 返回弹窗唯一标识
    @discardableResult
    func showWeakAlert(
        _ title: String?,
        _ message: String? = nil,
        _ buttons: [ButtonInfo] = [],
        _ textFields: [TextFieldInfo] = []
    ) -> UUID? {
        let alertInfo = AlertInfo(title: title ?? "", message: message ?? "", alertType: .weak, arrButtons: buttons, arrTextFields: textFields)
        send(action: .showAlert(alertInfo))
        return alertInfo.id
    }
    
    /// 销毁对应 alertId 的弹窗
    ///
    /// - Parameter alertId: 需要销毁弹窗的 id
    /// - Returns: Void
    func dismissAlert(with alertId: UUID) {
        send(action: .dismissAlert(with: alertId))
    }
    
    /// 创建关联中断的绑定属性
    ///
    /// - Parameter binding: 原始绑定属性
    /// - Parameter viewPath: 当前标记的界面路径
    /// - Parameter name: 中断名称
    /// - Returns: 返回关联中断的绑定属性
    func bindingWithInterrupt(_ binding: Binding<Bool>, _ viewPath: ViewPath, _ name: String? = nil) -> Binding<Bool> {
        let interruptInfo = InterruptInfo(viewPath: viewPath, name: name)
        return .init {
            let value = binding.wrappedValue
            if value {
                self.send(action: .init(action: .interrupt(.add(interruptInfo))))
            }
            return value
        } set: { newValue in
            if !newValue {
                self.send(action: .init(action: .interrupt(.remove(interruptInfo.id))))
            }
            binding.wrappedValue = newValue
        }
    }
    
    /// 获取 Inner Present Store
    func innerAlertStoreOnLevel(_ level: UInt) -> Store<InnerAlertState> {
        if level < state.storage.innerAlertStores.count {
            return state.storage.innerAlertStores[Int(level)]
        }
        if level == state.storage.innerAlertStores.count {
            // 创建最顶层 alert
            let newState = InnerAlertState(level: level)
            let newStore = Store<InnerAlertState>.box(newState)
            self.observe(store: newStore) { [weak self] new, old in
                guard let self = self else { return }
                if old.alertInfo != nil && new.alertInfo == nil {
                    // 弹窗消失
                    if new.level == self.storage.innerAlertStores.count - 1 {
                        self.apply(action: .inner(.dismissTopAlert))
                    } else {
                        // 存在错误，只有顶部 alert 才可以消失
                        AlertMonitor.shared.fatalError("Dismiss alert at level '\(new.level)' failed. Not the top level '\(self.storage.innerAlertStores.count)'")
                    }
                }
            }
            self.apply(action: .inner(.addInnerStore(newStore)))
            return newStore
        }
        
        // 这里正常情况不会出现
        AlertMonitor.shared.fatalError("Get inner alert store on level '\(level)' failed. Store not exist")
        let newState = InnerAlertState(level: level)
        return .box(newState)
    }
}
