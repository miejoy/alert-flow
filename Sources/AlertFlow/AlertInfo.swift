//
//  AlertInfo.swift
//  
//
//  Created by 黄磊 on 2023/3/9.
//

import SwiftUI
import ViewFlow

/// 弹窗类型
public enum AlertType {
    /// 强弹窗，一般用于用户交互弹窗，不可被中断，也不可被其他弹窗覆盖，包括其他强弹窗
    case strong
    /// 普通弹窗，一般用于异步提醒或者推广，可被中断，也可被其他弹窗覆盖，包括其他普通弹窗
    case normal
    /// 弱弹窗，一般用于推广，可被中断，被中断之后直接销毁，在显示时，如果存在其他弹窗或中断，会直接销毁而不显示
    case weak
}

/// 弹窗信息
public struct AlertInfo: Identifiable {
    /// 弹窗唯一标识
    public let id = UUID()
    /// 标题
    public var title: String
    /// 消息
    public var message: String
    /// 弹窗类型
    public let alertType: AlertType
    
    /// 弹窗按钮，可以为空，为空时也会有 OK 按钮
    public var arrButtons: [AlertButtonInfo]
    public var arrTextFields: [AlertTextFieldInfo]
    
    /// 取消回调
    public var cancelCallback: () -> Void
    
    var contentMaker: (AlertInfo) -> AnyView
    
    init(
        title: String,
        message: String,
        alertType: AlertType = .normal,
        arrButtons: [AlertButtonInfo] = [],
        arrTextFields: [AlertTextFieldInfo] = [],
        cancelCallback: @escaping () -> Void = { },
        contentMaker: ((AlertInfo) -> AnyView)? = nil
    ) {
        self.title = title
        self.message = message
        self.alertType = alertType
        self.arrButtons = arrButtons
        self.arrTextFields = arrTextFields
        self.cancelCallback = cancelCallback
        if let contentMaker = contentMaker {
            self.contentMaker = contentMaker
        } else {
            self.contentMaker = { alertInfo in
                AnyView(
                    Group {
                        ForEach(alertInfo.arrTextFields) { textField in
                            TextField(textField.title, text: textField.text)
                        }
                        ForEach(alertInfo.arrButtons) { button in
                            Button(button.title, role: button.role, action: button.action)
                        }
                    }
                )
            }
        }
    }
    
    public init(
        title: String,
        message: String = "",
        alertType: AlertType = .normal,
        arrButtons: [AlertButtonInfo] = [],
        arrTextFields: [AlertTextFieldInfo] = [],
        cancelCallback: @escaping () -> Void = { }
    ) {
        self.init(title: title,
                  message: message,
                  alertType: alertType,
                  arrButtons: arrButtons,
                  arrTextFields: arrTextFields,
                  cancelCallback: cancelCallback,
                  contentMaker: nil
        )
    }
    
    public init<Content: View>(
        title: String,
        message: String,
        @ViewBuilder contentMaker: @escaping (AlertInfo) -> Content,
        alertType: AlertType = .normal,
        cancelCallback: @escaping () -> Void = { }
    ) {
        self.init(title: title,
                  message: message,
                  alertType: alertType,
                  arrButtons: [],
                  arrTextFields: [],
                  cancelCallback: cancelCallback,
                  contentMaker: { AnyView(contentMaker($0))}
        )
    }
}

/// 弹窗按钮信息
public struct AlertButtonInfo: Identifiable {
    public let id = UUID()
    public let title: String
    public let role: ButtonRole?
    public let action: () -> Void
    
    public init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    public static func cancelButton(with title: String) -> Self {
        .init(title: title, role: .cancel) { }
    }
}

public protocol AlertResult {
    static var cancel: Self { get }
}

enum TestResult: AlertResult {
    case cancel
}

/// 带结果弹窗按钮信息
public struct AlertResultButtonInfo<Result:AlertResult>: Identifiable {
    public let id = UUID()
    public let title: String
    public let role: ButtonRole?
    public let result: Result
    
    public init(title: String, result: Result = .cancel, role: ButtonRole? = nil) {
        self.title = title
        self.role = role
        self.result = result
    }
    
    public static func cancelButton(with title: String) -> Self {
        .init(title: title, result: .cancel, role: .cancel)
    }
}

/// 弹窗输入框信息
public struct AlertTextFieldInfo: Identifiable {
    public let id = UUID()
    public let title: String
    public let text: Binding<String>
    
    public init(title: String, text: Binding<String>) {
        self.title = title
        self.text = text
    }
}

/// 弹窗打断信息
public struct InterruptInfo: Identifiable {
    public let id: String
    public let viewPath: ViewPath
    public let name: String?
    
    public init(viewPath: ViewPath, name: String? = nil) {
        self.viewPath = viewPath
        self.name = name
        self.id = "\(viewPath.description):\(name ?? "")"
    }
}

// MARK: - Unuse

// SwiftUI alert 不支持动态更新弹窗，这里暂时不使用
struct AlertUpdateInfo {
    /// 弹窗唯一标识
    let id: UUID
    /// 标题
    let title: String?
    /// 消息
    let message: String?
    
    /// 弹窗按钮，可以为空，为空时也会有 OK 按钮
    var arrButtons: [AlertButtonInfo]?
    var arrTextFields: [AlertTextFieldInfo]?
    
    init(id: UUID, title: String?, message: String? = nil, arrButtons: [AlertButtonInfo]? = nil, arrTextFields: [AlertTextFieldInfo]? = nil) {
        self.id = id
        self.title = title
        self.message = message
        self.arrButtons = arrButtons
        self.arrTextFields = arrTextFields
    }
}

extension AlertInfo {
    mutating func update(with updateInfo: AlertUpdateInfo) {
        if let title = updateInfo.title {
            self.title = title
        }
        if let message = updateInfo.message {
            self.message = message
        }
        if let arrButtons = updateInfo.arrButtons {
            self.arrButtons = arrButtons
        }
        if let arrTextFields = updateInfo.arrTextFields {
            self.arrTextFields = arrTextFields
        }
    }
}
