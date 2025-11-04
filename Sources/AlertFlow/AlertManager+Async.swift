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
import Combine

/// 注意：SwiftUI 的 alert 使用代码消失存在问题，消失后不能自动弹出新弹窗，这里使用延时处理
/// 目前弹窗更新功能不能使用
extension Store where State == AlertState {
    
    /// 显示普通弹窗
    ///
    /// - Parameter title: 弹窗标题
    /// - Parameter message: 弹窗消息
    /// - Parameter buttons: 弹窗按钮
    /// - Parameter textFields: 弹窗输入框
    /// - Returns: 返回弹窗唯一标识
    public func showAlert<Result: AlertResult>(
        _ title: String?,
        _ message: String? = nil,
        _ buttons: [AlertResultButtonInfo<Result>] = [],
        _ textFields: [AlertTextFieldInfo] = []
    ) async -> Result {
        return await withCheckedContinuation { continuation in
            let arrButtons = buttons.map { buttonInfo in
                AlertButtonInfo(title: buttonInfo.title, role: buttonInfo.role) {
                    continuation.resume(with: .success(buttonInfo.result))
                }
            }
            let alertInfo = AlertInfo(title: title ?? "", message: message ?? "", alertType: .normal, arrButtons: arrButtons, arrTextFields: textFields)
            dispatch(action: .showAlert(alertInfo))
        }
    }
    
    /// 显示强弹窗
    ///
    /// - Parameter title: 弹窗标题
    /// - Parameter message: 弹窗消息
    /// - Parameter buttons: 弹窗按钮
    /// - Parameter textFields: 弹窗输入框
    /// - Returns: 返回弹窗唯一标识
    public func showStrongAlert<Result: AlertResult>(
        _ title: String?,
        _ message: String? = nil,
        _ buttons: [AlertResultButtonInfo<Result>] = [],
        _ textFields: [AlertTextFieldInfo] = []
    ) async -> Result {
        return await withCheckedContinuation { continuation in
            let arrButtons = buttons.map { buttonInfo in
                AlertButtonInfo(title: buttonInfo.title, role: buttonInfo.role) {
                    continuation.resume(with: .success(buttonInfo.result))
                }
            }
            let alertInfo = AlertInfo(title: title ?? "", message: message ?? "", alertType: .strong, arrButtons: arrButtons, arrTextFields: textFields)
            dispatch(action: .showAlert(alertInfo))
        }
    }
    
    /// 显示弱弹窗
    ///
    /// - Parameter title: 弹窗标题
    /// - Parameter message: 弹窗消息
    /// - Parameter buttons: 弹窗按钮
    /// - Parameter textFields: 弹窗输入框
    /// - Returns: 返回弹窗唯一标识
    public func showWeakAlert<Result: AlertResult>(
        _ title: String?,
        _ message: String? = nil,
        _ buttons: [AlertResultButtonInfo<Result>] = [],
        _ textFields: [AlertTextFieldInfo] = []
    ) async -> Result {
        return await withCheckedContinuation { continuation in
            let arrButtons = buttons.map { buttonInfo in
                AlertButtonInfo(title: buttonInfo.title, role: buttonInfo.role) {
                    continuation.resume(with: .success(buttonInfo.result))
                }
            }
            let alertInfo = AlertInfo(title: title ?? "",
                                      message: message ?? "",
                                      alertType: .weak,
                                      arrButtons: arrButtons,
                                      arrTextFields: textFields) {
                DispatchQueue.main.async {
                    continuation.resume(with: .success(.cancel))
                }
            }
            dispatch(action: .showAlert(alertInfo))
        }
    }    
}
