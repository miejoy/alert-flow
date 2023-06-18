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
    @Environment(\.isPresented) var isPresented
    @Environment(\.presentationMode) var presentationMode
    @ViewBuilder var content: Content
    @InnerAlertWrapper var alertState: InnerAlertState
    
    public init(level: UInt = 0, @ViewBuilder content: () -> Content ) {
        self._alertState = .init(level)
        self.content = content()
    }
    
    public var body: some View {
        content
            .alert(
                alertState.displayAlertInfo?.title ?? "",
                isPresented: $alertState.bindingDefault(of: \.isShow, { ($0 ? .none : .dismiss) }),
                presenting: alertState.displayAlertInfo
            ) { alertInfo in
                ForEach(alertInfo.arrTextFields) { textField in
                    TextField(textField.title, text: textField.text)
                }
                ForEach(alertInfo.arrButtons) { button in
                    Button(button.title, role: button.role, action: button.action)
                }
            } message: { alertInfo in
                Text(alertInfo.message)
            }
            .onDisappear {
                if alertState.level > 0 && !presentationMode.wrappedValue.isPresented {
                    Store<AlertState>.shared(on: sceneId).apply(action: .inner(.removeInnerStoreOnLevel(alertState.level)))
                }
            }
    }
}
