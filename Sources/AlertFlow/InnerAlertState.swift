//
//  InnerAlertState.swift
//  
//
//  Created by 黄磊 on 2023/3/27.
//

import Foundation
import DataFlow
import ViewFlow
import SwiftUI
import Combine

/// 弹窗消失时间（单位：秒）
#if os(macOS)
let disappearingDuration: Double = 0.1
#else
let disappearingDuration: Double = 0.5
#endif

enum InnerAlertAction: Action {
    case none
    case present(AlertInfo)
    case dismiss
    case dismissByCode(AlertInfo)
}

/// 弹窗状态，仅内部使用
struct InnerAlertState: StorableState, ActionBindable, ReducerLoadableState {
    
    public typealias BindAction = InnerAlertAction
    
    enum AlertDisplayState {
        case none
        case displayed(AlertInfo)
        case disappearing
    }
    
    enum AlertDisplayAction: Action {
        case displayIfNeeded
        case dismissIfNeeded
        case dismissPrevAlert
        case displayed(AlertInfo)
    }
    
    /// 是否显示弹窗
    var isShow: Bool {
        get {
            displayAlertInfo != nil
        }
    }
    
    /// 当前展示 level
    var level: UInt
    
    /// 弹窗信息
    var alertInfo: AlertInfo? = nil
        
    /// 弹出显示状态
    var displayState: AlertDisplayState = .none
    /// 弹窗信息
    var displayAlertInfo: AlertInfo? = nil
    
    static func loadReducers(on store: Store<InnerAlertState>) {
        store.registerDefault { [weak store] state, action in
            guard let store = store else { return }
            switch action {
            case .none: break
            case .present(let alertInfo):
                state.alertInfo = alertInfo
                store.dispatch(action: AlertDisplayAction.displayIfNeeded)
            case .dismiss:
                if case .displayed(_) = state.displayState {
                    state.alertInfo = nil
                    state.displayAlertInfo = nil
                    state.displayState = .none
                }
            case .dismissByCode(let alertInfo):
                if alertInfo.id == state.alertInfo?.id {
                    state.alertInfo = nil
                    store.dispatch(action: AlertDisplayAction.dismissIfNeeded)
                }
            }
        }
      
        store.register { [weak store] (state, action: AlertDisplayAction) in
            guard let store = store else { return }
            switch action {
            case .displayIfNeeded:
                guard let alertInfo = state.alertInfo else { return }
                switch state.displayState {
                case .none:
                    // 未显示，直接显示
                    state.displayState = .displayed(alertInfo)
                    state.displayAlertInfo = alertInfo
                case .displayed(let displayedAlertInfo):
                    if displayedAlertInfo.id == alertInfo.id {
                        // 当前正在显示的就是需要显示的
                        return
                    }
                    // 已显示，需要先小护士
                    state.displayState = .disappearing
                    // 有真正显示的，需要消失
                    DispatchQueue.main.async {
                        Task {
                            var transaction = Transaction(animation: nil)
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                store.apply(action: AlertDisplayAction.dismissPrevAlert)
                            }
                            
                            try? await Task.sleep(for: .seconds(disappearingDuration))
                            
                            // 这里重新读取一下，主要是可能出现 alertInfo 已经 为空的问题
                            if let newAlertInfo = store.alertInfo {
                                store.apply(action: AlertDisplayAction.displayed(newAlertInfo))
                            }
                        }
                    }
                case .disappearing:
                    // 有正在消失的，不需要处理
                    break
                }
            case .dismissIfNeeded:
                guard state.alertInfo == nil else { return }
                switch state.displayState {
                case .none:
                    // 不处理
                    break
                case .displayed(_):
                    state.displayAlertInfo = nil
                    state.displayState = .none
                case .disappearing:
                    // 不处理
                    break
                }
            case .dismissPrevAlert:
                state.displayAlertInfo = nil
            case .displayed(let alertInfo):
                state.displayAlertInfo = alertInfo
                state.displayState = .displayed(alertInfo)
            }
        }
    }
}

/// 内部弹窗状态包装器，只在内部使用
@propertyWrapper
struct InnerAlertWrapper : DynamicProperty {
    
    @ObservedObject
    var storage: InnerAlertWrapperStorage
    @Environment(\.sceneId)
    var sceneId
    
    init(_ level: UInt) {
        self._storage = .init(wrappedValue: .init(level: level))
    }
    
    var wrappedValue: InnerAlertState {
        get {
            storage.store!.state
        }
        
        nonmutating set {
            storage.store!.state = newValue
        }
    }
    
    var projectedValue: Store<InnerAlertState> {
        storage.store!
    }
    
    func update() {
        if storage.store == nil {
            storage.configIfNeed(sceneId)
        }
    }
}

/// 内部弹窗状态包装器使用的存储器
final class InnerAlertWrapperStorage: ObservableObject {
    let level: UInt
    @Published
    var refreshTrigger: Bool = false
    var store: Store<InnerAlertState>? = nil
    var cancellable: AnyCancellable? = nil
    
    init(level: UInt) {
        self.level = level
    }
    
    func configIfNeed(_ sceneId: SceneId) {
        if store == nil {
            let newStore = Store<AlertState>.shared(on: sceneId).innerAlertStoreOnLevel(level)
            self.cancellable = newStore.addObserver { [weak self] new, old in
                self?.refreshTrigger.toggle()
            }
            self.store = newStore
        }
    }
}
