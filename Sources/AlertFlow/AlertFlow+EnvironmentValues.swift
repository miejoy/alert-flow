//
//  AlertFlow+EnvironmentValues.swift
//  
//
//  Created by 黄磊 on 2023/3/9.
//

import SwiftUI
import DataFlow
import ViewFlow

extension EnvironmentValues {
    /// 弹窗管理器
    public var alertManager: Store<AlertState> {
        get { self[AlertStoreKey.self] ?? Store<AlertState>.shared(on: self.sceneId) }
        set { self[AlertStoreKey.self] = newValue }
    }
}

/// 弹窗存储器对应的 key
struct AlertStoreKey: EnvironmentKey {
    static var defaultValue: Store<AlertState>? {
        return nil
    }
}

