//
//  AlertMonitor.swift
//  
//
//  Created by 黄磊 on 2023/3/9.
//

import Foundation
import Combine
import ViewFlow
import DataFlow

/// 弹窗存储器变化事件
public enum AlertEvent: MonitorEvent {
    case showAlert(AlertInfo)
    case showAlertFailedWithInterrupt(AlertInfo, [String:InterruptInfo])
    case showAlertFailedWithStrongExist(AlertInfo, [AlertInfo])
    case showAlertFailedWithNormalExist(AlertInfo, [AlertInfo])
    case showAlertFailedWithWeakExist(AlertInfo, AlertInfo)
    case fatalError(String)
}

public protocol AlertMonitorObserver: MonitorObserver {
    @MainActor
    func receiveAlertEvent(_ event: AlertEvent)
}

/// 弹窗存储器监听器
public final class AlertMonitor: BaseMonitor<AlertEvent> {
    public nonisolated(unsafe) static let shared: AlertMonitor = {
        AlertMonitor { event, observer in
            DispatchQueue.executeOnMain {
                (observer as? AlertMonitorObserver)?.receiveAlertEvent(event)
            }
        }
    }()

    public func addObserver(_ observer: AlertMonitorObserver) -> AnyCancellable {
        super.addObserver(observer)
    }
    
    public override func addObserver(_ observer: MonitorObserver) -> AnyCancellable {
        Swift.fatalError("Only AlertMonitorObserver can observe this monitor")
    }
}
