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
public struct AlertInfo {
    public let id = UUID()
    /// 标题
    public let title: String
    /// 消息
    public let message: String
    /// 是否是强弹窗
    public let alertType: AlertType
    
    /// 弹窗按钮，可以为空，为空时也会有 OK 按钮
    public var arrButtons: [ButtonInfo]
    public var arrTextFields: [TextFieldInfo]
    
    public init(title: String, message: String, alertType: AlertType, arrButtons: [ButtonInfo], arrTextFields: [TextFieldInfo]) {
        self.title = title
        self.message = message
        self.alertType = alertType
        self.arrButtons = arrButtons
        self.arrTextFields = arrTextFields
    }
}

/// 弹窗按钮信息
public struct ButtonInfo: Identifiable {
    public let id = UUID()
    public let title: String
    public let role: ButtonRole?
    public let action: () -> Void
    
    public init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
}

/// 弹窗输入框信息
public struct TextFieldInfo: Identifiable {
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
    public let id = UUID()
    public let viewPath: ViewPath
    public let name: String?
    
    public init(viewPath: ViewPath, name: String? = nil) {
        self.viewPath = viewPath
        self.name = name
    }
}
