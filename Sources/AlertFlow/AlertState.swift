//
//  AlertState.swift
//  
//
//  Created by 黄磊 on 2023/3/9.
//

import Foundation
import DataFlow
import ViewFlow
import SwiftUI

/// 弹窗状态
public struct AlertState: FullSceneSharableState {
    
    public typealias BindAction = AlertAction
    
    /// 弹窗数据存储器
    var storage: AlertStorage = .init()
    
    public init() {
    }
    
    public static func loadReducers(on store: DataFlow.Store<AlertState>) {
        store.registerDefault { state, action in
            let oldAlertInfo: AlertInfo? = state.storage.innerAlertStores.last?.alertInfo
            var newAlertInfo = oldAlertInfo
            var topStoreChange: Bool = false
            switch action.action {
            case .show(let alertInfo):
                newAlertInfo = state.storage.getTopAlertAfterPush(alertInfo)
            case .dismiss(let alertId):
                newAlertInfo = state.storage.getTopAlertAfterRemoveAlert(with: alertId)
            case .interrupt(let interruptAction):
                switch interruptAction {
                case .add(let interruptInfo):
                    newAlertInfo = state.storage.getTopAlertAfterInsert(interruptInfo)
                case .remove(let interruptId):
                    newAlertInfo = state.storage.getTopAlertAfterRemoveInterrupt(interruptId)
                }
            case .inner(let innerAction):
                switch innerAction {
                case .none: break
                case .dismissTopAlert:
                    newAlertInfo = state.storage.getTopAlertAfterRemoveTopAlert()
                case .addInnerStore(let newStore):
                    if state.storage.innerAlertStores.last?.alertInfo != nil {
                        // 这里在展示 alert 的时候又 present 一个新的界面，需要避免
                        state.storage.innerAlertStores.last?.alertInfo = nil
                    }
                    state.storage.innerAlertStores.append(newStore)
                    newAlertInfo = state.storage.getTopAlert()
                    topStoreChange = true
                case .removeInnerStoreOnLevel(let level):
                    guard state.storage.innerAlertStores.count - 1 == level else  {
                        AlertMonitor.shared.fatalError("Remove alert store at level '\(level)' failed. Not the top level '\(state.storage.innerAlertStores.count)'")
                        return
                    }
                    _ = state.storage.innerAlertStores.popLast()
                    newAlertInfo = state.storage.getTopAlert()
                    topStoreChange = true
                }
            }
            if topStoreChange || newAlertInfo?.id != oldAlertInfo?.id {
                let topInnerStore = state.storage.innerAlertStores.last
                if let newAlertInfo = newAlertInfo {
                    topInnerStore?.apply(action: .present(newAlertInfo))
                    AlertMonitor.shared.record(event: .showAlert(newAlertInfo))
                } else {
                    topInnerStore?.apply(action: .dismiss)
                }
            }
        }
    }
}

/// 弹窗数据存储器
class AlertStorage {
    
    var mapAlerts: [UUID:AlertInfo] = [:]
    /// 强弹窗，不可被中断，也不可被其他弹窗覆盖，包括其他强弹窗
    var arrStrongAlerts: [UUID] = []
    /// 中断列表
    var mapInterrupt: [UUID:InterruptInfo] = [:]
    /// 普通弹窗，可被中断，也可被其他弹窗覆盖，包括其他普通弹窗
    var arrNormalAlerts: [UUID] = []
    /// 弱弹窗 ID
    var weakAlertId: UUID?
    
    /// 内部弹窗状态存储器列表
    var innerAlertStores: [Store<InnerAlertState>] = []
    
    func getTopAlertAfterPush(_ alertInfo: AlertInfo) -> AlertInfo? {
        switch alertInfo.alertType {
        case .strong:
            mapAlerts[alertInfo.id] = alertInfo
            // 强弹窗不能中断其他强弹窗，所以插在最底部
            arrStrongAlerts.insert(alertInfo.id, at: 0)
        case .normal:
            mapAlerts[alertInfo.id] = alertInfo
            // 普通弹窗插在最后面，可以覆盖其他普通弹窗
            arrNormalAlerts.append(alertInfo.id)
            // 判断一下是否有中断，有的话记录一下
            if !mapInterrupt.isEmpty {
                AlertMonitor.shared.record(event: .showAlertFailedWithInterrupt(alertInfo, mapInterrupt))
            }
        case .weak:
            if !arrStrongAlerts.isEmpty {
                AlertMonitor.shared.record(event: .showAlertFailedWithStrongExist(alertInfo, arrStrongAlerts.compactMap({ mapAlerts[$0] })))
            } else if !mapInterrupt.isEmpty {
                AlertMonitor.shared.record(event: .showAlertFailedWithInterrupt(alertInfo, mapInterrupt))
            } else if !arrNormalAlerts.isEmpty {
                AlertMonitor.shared.record(event: .showAlertFailedWithNormalExist(alertInfo, arrNormalAlerts.compactMap({ mapAlerts[$0] })))
            } else if let weakAlertId = weakAlertId, let weakAlert = mapAlerts[weakAlertId] {
                AlertMonitor.shared.record(event: .showAlertFailedWithWeakExist(alertInfo, weakAlert))
            } else {
                mapAlerts[alertInfo.id] = alertInfo
                weakAlertId = alertInfo.id
            }
        }
                
        return getTopAlert()
    }
    
    func getTopAlertAfterRemoveAlert(with alertId: UUID) -> AlertInfo? {
        mapAlerts.removeValue(forKey: alertId)
        return getTopAlert()
    }
    
    func getTopAlertAfterInsert(_ interruptInfo: InterruptInfo) -> AlertInfo? {
        mapInterrupt[interruptInfo.id] = interruptInfo
        return getTopAlert()
    }
    
    func getTopAlertAfterRemoveInterrupt(_ interruptId: UUID) -> AlertInfo? {
        mapInterrupt.removeValue(forKey: interruptId)
        return getTopAlert()
    }
    
    func getTopAlertAfterRemoveTopAlert() -> AlertInfo? {
        var topAlertId: UUID? = nil
        if let last = arrStrongAlerts.last {
            topAlertId = last
            _ = arrStrongAlerts.popLast()
        } else if let last = arrNormalAlerts.last {
            topAlertId = last
            _ = arrNormalAlerts.popLast()
        } else if let theWeakAlertId = weakAlertId {
            topAlertId = theWeakAlertId
            weakAlertId = nil
        }
        if let topAlertId = topAlertId {
            mapAlerts.removeValue(forKey: topAlertId)
        }
        
        return getTopAlert()
    }
    
    func getTopAlert() -> AlertInfo? {
        if let alertId = arrStrongAlerts.last {
            if let alertInfo = mapAlerts[alertId] {
                return alertInfo
            }
            arrStrongAlerts.removeLast()
            return getTopAlert()
        } else if !mapInterrupt.isEmpty {
            return nil
        } else if let alertId = arrNormalAlerts.last {
            if let alertInfo = mapAlerts[alertId] {
                return alertInfo
            }
            arrNormalAlerts.removeLast()
            return getTopAlert()
        } else if let alertId = weakAlertId {
            if let alertInfo = mapAlerts[alertId] {
                return alertInfo
            }
            weakAlertId = nil
        }
        return nil
    }
}
