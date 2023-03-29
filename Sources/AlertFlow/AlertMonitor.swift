//
//  AlertMonitor.swift
//  
//
//  Created by 黄磊 on 2023/3/9.
//

import Foundation
import Combine
import ViewFlow

/// 弹窗存储器变化事件
public enum AlertEvent {
    case showAlert(AlertInfo)
    case showAlertFailedWithInterrupt(AlertInfo, [UUID:InterruptInfo])
    case showAlertFailedWithStrongExist(AlertInfo, [AlertInfo])
    case showAlertFailedWithNormalExist(AlertInfo, [AlertInfo])
    case showAlertFailedWithWeakExist(AlertInfo, AlertInfo)
    case fatalError(String)
}

public protocol AlertMonitorOberver: AnyObject {
    func receivePresentEvent(_ event: AlertEvent)
}

/// 弹窗存储器监听器
public final class AlertMonitor {
        
    struct Observer {
        let observerId: Int
        weak var observer: AlertMonitorOberver?
    }
    
    /// 监听器共享单例
    public static var shared: AlertMonitor = .init()
    
    /// 所有观察者
    var arrObservers: [Observer] = []
    var generateObserverId: Int = 0
    
    required init() {
    }
    
    /// 添加观察者
    public func addObserver(_ observer: AlertMonitorOberver) -> AnyCancellable {
        generateObserverId += 1
        let observerId = generateObserverId
        arrObservers.append(.init(observerId: generateObserverId, observer: observer))
        return AnyCancellable { [weak self] in
            if let index = self?.arrObservers.firstIndex(where: { $0.observerId == observerId}) {
                self?.arrObservers.remove(at: index)
            }
        }
    }
    
    /// 记录对应事件，这里只负责将所有事件传递给观察者
    @usableFromInline
    func record(event: AlertEvent) {
        guard !arrObservers.isEmpty else { return }
        arrObservers.forEach { $0.observer?.receivePresentEvent(event) }
    }
    
    @usableFromInline
    func fatalError(_ message: String) {
        guard !arrObservers.isEmpty else {
            #if DEBUG
            Swift.fatalError(message)
            #else
            return
            #endif
        }
        arrObservers.forEach { $0.observer?.receivePresentEvent(.fatalError(message)) }
    }
}

