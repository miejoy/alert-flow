//
//  AlertFlowViewTests.swift
//  alert-flow
//
//  Created by 黄磊 on 2025/10/30.
//

import SwiftUI
import Testing
@testable import DataFlow
@testable import ViewFlow
@testable import AlertFlow
import XCTViewFlow


@MainActor
@Suite("弹窗流界面测试")
struct AlertFlowViewTests {
    
    /// 刷新时间（单位：秒）
    static let refreshDuration: Double = 0.6;
    
    @Test("使用弹窗流测试")
    func testUseAlertFlowView() {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            NormalView()
        }
        
        NormalView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        #expect(NormalView.s_alertManager != nil)
        #expect(NormalView.s_alertManager!.state.storage.innerAlertStores.count == 1)

        ViewTest.releaseHost(host)
    }
    
    @Test("使用弹窗修饰器测试")
    func testUseAlertModifier() {
        let sceneId = SceneId.custom(#function)
        let rootView = NormalView().modifier(AlertModifier())
        
        NormalView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        #expect(NormalView.s_alertManager != nil)
        #expect(NormalView.s_alertManager!.state.storage.innerAlertStores.count == 1)

        ViewTest.releaseHost(host)
    }
    
    @Test("使用弹窗流弹窗测试")
    func testUseAlertFlowViewShowAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showAlert("title", "message", [.init(title: "button", action: {})], [.init(title: "textTitle", text: .constant("textContent"))])
                
        try await checkDisplayedAlert(innerAlertStore, title: "title", message: "message", buttons: [.init(title: "button", action: {})], textFields: [.init(title: "textTitle", text: .constant("textContent"))])
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面显示两个普通弹窗测试")
    func testViewShowTwoNormalAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title2)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面显示两个强弹窗测试")
    func testViewShowTwoStrongAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showStrongAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showStrongAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面显示两个弱弹窗测试")
    func testViewShowTwoWeakAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showWeakAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showWeakAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面在普通弹窗后显示强弹窗测试")
    func testViewShowStrongAlertAfterNormalAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showStrongAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title2)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面在强弹窗后显示普通弹窗测试")
    func testViewShowNormalAlertAfterStrongAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showStrongAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面在普通弹窗后显示弱弹窗测试")
    func testViewShowWeakAlertAfterNormalAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showWeakAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面在弱弹窗后显示普通弹窗测试")
    func testViewShowNormalAlertAfterWeakAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showWeakAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title2)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面在强弹窗后显示弱弹窗测试")
    func testViewShowWeakAlertAfterStrongAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showStrongAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showWeakAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面在弱弹窗后显示强弹窗测试")
    func testViewShowStrongAlertAfterWeakAlert() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            ShowAlertView()
        }
        let title1 = "title1"
        let title2 = "title2"
        
        ShowAlertView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = ShowAlertView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showWeakAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        alertManager.showStrongAlert(title2)
        try await checkDisplayedAlert(innerAlertStore, title: title2)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面弹窗打断测试")
    func testViewInterrupt() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            AlertInterruptView()
        }
        let title1 = "title1"
        
        AlertInterruptView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = AlertInterruptView.s_alertManager!
        let innerAlertStore = alertManager.state.storage.innerAlertStores.last!
        
        alertManager.showAlert(title1)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        ViewTest.refreshHost(host)
        try? await Task.sleep(for: .seconds(0.9)) // checkDisplayedAlert 会 sleep 0.6s
        
        #expect(alertManager.state.getTopAlert() == nil)
        #expect(alertManager.state.storage.arrNormalAlerts.count == 1)
        #expect(innerAlertStore.alertInfo == nil)
       
        try? await Task.sleep(for: .seconds(1))
        #expect(alertManager.state.getTopAlert() != nil)
        try await checkDisplayedAlert(innerAlertStore, title: title1)
        
        ViewTest.releaseHost(host)
    }
    
    @Test("界面结果弹窗测试")
    func testAlertButtonResult() async throws {
        let sceneId = SceneId.custom(#function)
        let rootView = AlertFlowView {
            AlertResultView()
        }
        let title1 = "title1"
        
        AlertResultView.s_alertManager = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let alertManager = AlertResultView.s_alertManager!
        
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            alertManager.showAlert("title")
        }
        
        // 目前因为无法点击 Alert，只能测试 cancel
        let result: AlertResultView.Result = await alertManager.showWeakAlert(title1)
        
        #expect(result == .cancel)
                
        ViewTest.releaseHost(host)
    }
    
    
    // MARK: - private
    
    func checkDisplayedAlert(_ innerAlertStore: Store<InnerAlertState>, title: String = "", message: String = "", buttons: [AlertButtonInfo] = [], textFields: [AlertTextFieldInfo] = []) async throws {
        #expect(innerAlertStore.alertInfo != nil)
        AlertStateTests.checkAlert(innerAlertStore.alertInfo!, title:title, message:message, buttons:buttons, textFields:textFields)
        
        try? await Task.sleep(for: .seconds(Self.refreshDuration))
        
        #expect(innerAlertStore.displayAlertInfo != nil)
        #expect(innerAlertStore.level == 0)
        AlertStateTests.checkAlert(innerAlertStore.displayAlertInfo!, title:title, message:message, buttons:buttons, textFields:textFields)
        
        if case let .displayed(alertInfo) = innerAlertStore.displayState {
            AlertStateTests.checkAlert(alertInfo, title:title, message:message, buttons:buttons, textFields:textFields)
        } else {
            #expect(Bool(false))
        }
    }
}


struct NormalView: View {
    static var s_alertManager: Store<AlertState>? = nil
    @Environment(\.alertManager) var alertManager
    
    var body: some View {
        Text("")
            .onAppear {
                Self.s_alertManager = alertManager
            }
    }
}

struct ShowAlertView: View {
    static var s_alertManager: Store<AlertState>? = nil
    @Environment(\.alertManager) var alertManager
    
    var body: some View {
        Text("")
            .onAppear {
                Self.s_alertManager = alertManager
            }
    }
}


struct AlertInterruptView: View {
    static var s_alertManager: Store<AlertState>? = nil
    @Environment(\.alertManager) var alertManager
    @Environment(\.viewPath) var viewPath
    @State var showOther: Bool = false
    
    var body: some View {
        Text("")
            .onAppear {
                Self.s_alertManager = alertManager
            }
            .dialogSuppressionToggle(isSuppressed: alertManager.bindingWithInterrupt($showOther, viewPath))
            .task {
                try? await Task.sleep(for: .seconds(1))
                
                showOther = true
                
                try? await Task.sleep(for: .seconds(1))
                
                showOther = false
            }
    }
}

struct AlertResultView: View {
    enum Result: AlertResult {
        case cancel
    }
    
    static var s_alertManager: Store<AlertState>? = nil
    @Environment(\.alertManager) var alertManager
    
    var body: some View {
        Text("")
            .onAppear {
                Self.s_alertManager = alertManager
            }
    }
}
