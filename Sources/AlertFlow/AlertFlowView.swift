//
//  AlertFlowView.swift
//  
//
//  Created by 黄磊 on 2023/3/9.
//


import SwiftUI
import DataFlow
import ViewFlow

// 包装弹窗流的界面，可以用这个来包装界面来提供弹窗能力
public struct AlertFlowView<Content: View>: View {
    
    @Environment(\.sceneId) var sceneId
    @ViewBuilder var content: Content
    @InnerAlertWrapper var alertState: InnerAlertState
    
    public init(level: UInt = 0, @ViewBuilder content: () -> Content ) {
        self._alertState = .init(level)
        self.content = content()
    }
    
    public var body: some View {
        content
            .alert(
                alertState.alertInfo?.title ?? "",
                isPresented: $alertState.bindingDefault(of: \.isShow, { ($0 ? .none : .dismiss) })) {
                if let alertInfo = alertState.alertInfo {
                    ForEach(alertInfo.arrTextFields) { textField in
                        TextField(textField.title, text: textField.text)
                    }
                    ForEach(alertInfo.arrButtons) { button in
                        Button(button.title, role: button.role, action: button.action)
                    }
                }
            } message: {
                Text(alertState.alertInfo?.message ?? "")
            }
            .onDisappear {
                Store<AlertState>.shared(on: sceneId).apply(action: .inner(.removeInnerStoreOnLevel(alertState.level)))
            }
    }
}
