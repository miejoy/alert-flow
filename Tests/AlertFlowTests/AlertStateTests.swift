//
//  AlertStateTests.swift
//
//
//  Created by 黄磊 on 2023/6/11.
//

import SwiftUI
import Testing
@testable import DataFlow
@testable import ViewFlow
@testable import AlertFlow

@MainActor
@Suite("弹窗状态测试")
struct AlertStateTests {
    // MARK: - show
    @Test("显示弹窗测试")
    func testShowAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title = "title"
        let message = "message"
        let button = "button"
        let textTitle = "textTitle"
        let textContent = "textContent"
        alertManager.showAlert(title, message, [.init(title: button, action: {})], [.init(title: textTitle, text: .constant(textContent))])
        #expect(alertManager.state.storage.arrStrongAlerts.count == 0)
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        #expect(alertManager.state.storage.weakAlertId == nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertUUID = alertManager.state.storage.arrNormalAlerts[0]
        let alertInfo = alertManager.state.storage.mapAlerts[alertUUID]
        
        #expect(alertInfo != nil)
        Self.checkAlert(alertInfo!, title: title, message: message, buttons: [.init(title: button, action: {})], textFields: [.init(title: textTitle, text: .constant(textContent))])
    }

    // MARK: normal
    @Test("显示普通弹窗测试")
    func testShowNormalAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title = "title"
        let message = "message"
        alertManager.showAlert(title, message)
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 0)
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        #expect(alertManager.state.storage.weakAlertId == nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertUUID = alertManager.state.storage.arrNormalAlerts[0]
        let alertInfo = alertManager.state.storage.mapAlerts[alertUUID]
        
        #expect(alertInfo != nil)
        #expect(alertInfo?.alertType == .normal)
        Self.checkAlert(alertInfo!, title: title, message: message)
    }

    // MARK: strong
    @Test("显示强弹窗测试")
    func testShowStrongAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title = "title"
        let message = "message"
        alertManager.showStrongAlert(title, message)
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        #expect(alertManager.state.storage.arrNormalAlerts.count == 0)
        #expect(alertManager.state.storage.weakAlertId == nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertUUID = alertManager.state.storage.arrStrongAlerts[0]
        let alertInfo = alertManager.state.storage.mapAlerts[alertUUID]
        
        #expect(alertInfo != nil)
        #expect(alertInfo?.alertType == .strong)
        Self.checkAlert(alertInfo!, title: title, message: message)
    }

    // MARK: weak
    @Test("显示弱弹窗测试")
    func testShowWeakAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title = "title"
        let message = "message"
        alertManager.showWeakAlert(title, message)
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 0)
        #expect(alertManager.state.storage.arrNormalAlerts.count == 0)
        #expect(alertManager.state.storage.weakAlertId != nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo = alertManager.state.storage.mapAlerts[alertManager.state.storage.weakAlertId!]
        
        #expect(alertInfo != nil)
        #expect(alertInfo?.alertType == .weak)
        Self.checkAlert(alertInfo!, title: title, message: message)
    }

    // MARK: - dismiss
    @Test("隐藏普通弹窗测试")
    func testDismissNormalAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title = "title"
        
        #expect(alertManager.state.storage.arrNormalAlerts.count == 0)
        
        let alertId = alertManager.showAlert(title)
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        
        alertManager.dismissAlert(with: alertId)
        #expect(alertManager.state.storage.arrNormalAlerts.count == 0)
    }
    
    @Test("隐藏强弹窗测试")
    func testDismissStrongAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title = "title"
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 0)
        
        let alertId = alertManager.showStrongAlert(title)
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        
        alertManager.dismissAlert(with: alertId)
        #expect(alertManager.state.storage.arrStrongAlerts.count == 0)
    }
    
    @Test("隐藏弱弹窗测试")
    func testDismissWeakAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title = "title"
        
        #expect(alertManager.state.storage.weakAlertId == nil)
        
        let alertId = alertManager.showWeakAlert(title)
        #expect(alertId != nil)
        #expect(alertManager.state.storage.weakAlertId == alertId)
        
        alertManager.dismissAlert(with: alertId!)
        #expect(alertManager.state.storage.weakAlertId == nil)
    }
    
    
    // MARK: - shwo two alert
    
    @Test("显示两个普通弹窗测试")
    func testShowTwoNormalAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showAlert(title1)
        
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertUUID1 = alertManager.state.storage.arrNormalAlerts[0]
        let alertInfo1 = alertManager.state.storage.mapAlerts[alertUUID1]
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        alertManager.showAlert(title2)
        
        #expect(alertManager.state.storage.arrNormalAlerts.count == 2)
        #expect(alertManager.state.storage.mapAlerts.count == 2)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是后显示的
        Self.checkAlert(alertInfo2!, title: title2)
    }
    
    @Test("显示两个强弹窗测试")
    func testShowTwoStrongAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showStrongAlert(title1)
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertUUID1 = alertManager.state.storage.arrStrongAlerts[0]
        let alertInfo1 = alertManager.state.storage.mapAlerts[alertUUID1]
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        alertManager.showStrongAlert(title2)
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 2)
        #expect(alertManager.state.storage.mapAlerts.count == 2)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是先显示的
        Self.checkAlert(alertInfo2!, title: title1)
    }
    
    @Test("显示两个弱弹窗测试")
    func testShowTwoWeakAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showWeakAlert(title1)
        
        #expect(alertManager.state.storage.weakAlertId != nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertUUID1 = alertManager.state.storage.weakAlertId!
        let alertInfo1 = alertManager.state.storage.mapAlerts[alertUUID1]
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        alertManager.showWeakAlert(title2)
        
        #expect(alertManager.state.storage.weakAlertId != nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是先显示的
        Self.checkAlert(alertInfo2!, title: title1)
    }
    
    @Test("在普通弹窗后显示强弹窗测试")
    func testShowStrongAlertAfterNormalAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showAlert(title1)
        
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo1 = alertManager.state.getTopAlert()
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        alertManager.showStrongAlert(title2)
        
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        #expect(alertManager.state.storage.mapAlerts.count == 2)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是强弹窗
        Self.checkAlert(alertInfo2!, title: title2)
    }
    
    @Test("在强弹窗后显示普通弹窗测试")
    func testShowNormalAlertAfterStrongAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showStrongAlert(title1)
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo1 = alertManager.state.getTopAlert()
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        alertManager.showAlert(title2)
        
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        #expect(alertManager.state.storage.mapAlerts.count == 2)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是强弹窗
        Self.checkAlert(alertInfo2!, title: title1)
    }
    
    @Test("在普通弹窗后显示弱弹窗测试")
    func testShowWeakAlertAfterNormalAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showAlert(title1)
        
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo1 = alertManager.state.getTopAlert()
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        let weakAlertId = alertManager.showWeakAlert(title2)
        
        #expect(weakAlertId == nil)
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        // 弱弹窗不会弹出
        #expect(alertManager.state.storage.weakAlertId == nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是强弹窗
        Self.checkAlert(alertInfo2!, title: title1)
    }
    
    @Test("在弱弹窗后显示普通弹窗测试")
    func testShowNormalAlertAfterWeakAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showWeakAlert(title1)
        
        #expect(alertManager.state.storage.weakAlertId != nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo1 = alertManager.state.getTopAlert()
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        alertManager.showAlert(title2)
        
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        // 弱弹窗会被消失
        #expect(alertManager.state.storage.weakAlertId == nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是强弹窗
        Self.checkAlert(alertInfo2!, title: title2)
    }
    
    @Test("在强弹窗后显示弱弹窗测试")
    func testShowWeakAlertAfterStrongAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showStrongAlert(title1)
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo1 = alertManager.state.getTopAlert()
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        let weakAlertId = alertManager.showWeakAlert(title2)
        
        #expect(weakAlertId == nil)
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        // 弱弹窗不会弹出
        #expect(alertManager.state.storage.weakAlertId == nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是强弹窗
        Self.checkAlert(alertInfo2!, title: title1)
    }
    
    @Test("在弱弹窗后显示强弹窗测试")
    func testShowStrongAlertAfterWeakAlert() {
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
                
        alertManager.showWeakAlert(title1)
        
        #expect(alertManager.state.storage.weakAlertId != nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo1 = alertManager.state.getTopAlert()
        
        #expect(alertInfo1 != nil)
        Self.checkAlert(alertInfo1!, title: title1)
        
        alertManager.showStrongAlert(title2)
        
        #expect(alertManager.state.storage.arrStrongAlerts.count == 1)
        // 弱弹窗会被消失
        #expect(alertManager.state.storage.weakAlertId == nil)
        #expect(alertManager.state.storage.mapAlerts.count == 1)
        
        let alertInfo2 = alertManager.state.getTopAlert()
        
        #expect(alertInfo2 != nil)
        // 当前顶部应该是强弹窗
        Self.checkAlert(alertInfo2!, title: title2)
    }
    
    // MARK: - cancel callback
    
    static var s_alertCancelCall = false
    @Test("取消弹窗测试测试")
    func testAlertCancelCallback() {
        // 只有弱弹窗才可以被取消
        let alertManager = Store<AlertState>.shared(on: .custom(#function))
        let title1 = "title1"
        let title2 = "title2"
        
        
        let alertInfo = AlertInfo(title: title1, alertType: .weak) {
            Self.s_alertCancelCall = true
        }
        
        Self.s_alertCancelCall = false
        alertManager.send(action: .showAlert(alertInfo))
        #expect(!Self.s_alertCancelCall)
        
        alertManager.showAlert(title2)
        #expect(Self.s_alertCancelCall)
    }
    
    // MARK: - private
    
    static func checkAlert(_ alertInfo: AlertInfo, title: String = "", message: String = "", buttons: [AlertButtonInfo] = [], textFields: [AlertTextFieldInfo] = []) {
        #expect(alertInfo.title == title)
        #expect(alertInfo.message == message)
        
        #expect(alertInfo.arrButtons.count == buttons.count)
        if alertInfo.arrButtons.count == buttons.count {
            for (index, lertButton) in alertInfo.arrButtons.enumerated() {
                let rightButton = buttons[index]
                #expect(lertButton.title == rightButton.title)
            }
        }
        
        #expect(alertInfo.arrTextFields.count == textFields.count)
        if alertInfo.arrTextFields.count == textFields.count {
            for (index, lertTextField) in alertInfo.arrTextFields.enumerated() {
                let rightTextField = textFields[index]
                #expect(lertTextField.title == rightTextField.title)
                #expect(lertTextField.text.wrappedValue == rightTextField.text.wrappedValue)
            }
        }
    }
}
