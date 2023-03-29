//
//  File.swift
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
}

/// 弹窗状态
struct InnerAlertState: StorableState, ActionBindable, ReducerLoadableState {
    
    public typealias BindAction = InnerAlertAction
    
    /// 是否显示弹窗
    var isShow: Bool {
        get {
            alertInfo != nil
        }
    }
    
    var level: UInt
    
    /// 弹窗信息
    var alertInfo: AlertInfo? = nil
    
    static func loadReducers(on store: Store<InnerAlertState>) {
        store.registerDefault { state, action in
            switch action {
            case .none: break
            case .present(let alertInfo):
                state.alertInfo = alertInfo
            case .dismiss:
                state.alertInfo = nil
            }
        }
    }
}

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
