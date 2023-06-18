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

enum InnerAlertAction: Action {
    case none
    case present(AlertInfo)
    case dismiss
    case dismissByView // 暂时不使用
}

/// 弹窗状态
struct InnerAlertState: StorableState, ActionBindable, ReducerLoadableState {
    
    public typealias BindAction = InnerAlertAction
    
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
    
    /// 弹窗信息
    var displayAlertInfo: AlertInfo? = nil
    
    static func loadReducers(on store: Store<InnerAlertState>) {
        store.registerDefault { state, action in
            switch action {
            case .none: break
            case .present(let alertInfo):
                state.alertInfo = alertInfo
                if state.displayAlertInfo == nil {
                    state.displayAlertInfo = alertInfo
                } else {
                    state.displayAlertInfo = nil
                }
            case .dismiss:
                state.alertInfo = nil
                state.displayAlertInfo = nil
            case .dismissByView:
                if let alertInfo = state.alertInfo {
                    if let displayAlertInfo = state.displayAlertInfo {
                        if alertInfo.id != displayAlertInfo.id {
                            // 不相同，需要更新 displayAlertInfo
                            state.displayAlertInfo = alertInfo
                            return
                        }
                    } else {
                        state.displayAlertInfo = alertInfo
                        return
                    }
                }
                // 其他情况相当于 dismiss
                state.alertInfo = nil
                state.displayAlertInfo = nil
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
