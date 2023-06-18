# AlertFlow

AlertFlow 是基于 ViewFlow 的 弹窗流操作模块，为 SwiftUI 提供方便的弹窗显示和消失控制

AlertFlow 是自定义 RSV(Resource & State & View) 设计模式中 State 层的应用模块，同时也是 View 层的应用模块。负责 View 提供可操作的弹窗流。

[![Swift](https://github.com/miejoy/alert-flow/actions/workflows/test.yml/badge.svg)](https://github.com/miejoy/alert-flow/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/miejoy/alert-flow/branch/main/graph/badge.svg)](https://codecov.io/gh/miejoy/alert-flow)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/swift-5.7-brightgreen.svg)](https://swift.org)

## 依赖

- iOS 15.0+ / macOS 12+
- Xcode 14.0+
- Swift 5.7+

## 简介

### 该模块包含如下内容:

- AlertState: 弹窗核心状态，对应 Store 叫弹窗管理器，外部可通过这个管理器对弹窗流进行各种操作，如果 显示、消失等
- AlertAction: 弹窗管理器操作事件，主要对外提供 显示(show)、消失(dismiss)、中断(interrupt) 三类事件
- AlertFlowView: 弹窗流包装界面，如果需要可操作的弹窗流，必须在最根部使用该界面包装起来，用 AlertModifier 修饰是同样的效果
- AlertModifier: 弹窗流修饰器，使用该修饰器的界面将会被 AlertFlowView 包一层，其中 level 参数用于展示后的界面传入和修饰
- AlertInfo: 弹窗信息，在显示弹窗时使用，包含弹窗的标题、内容、类型、按钮 和 输入框等

### 弹窗类型定义如下：
- strong: 强弹窗，一般用于用户交互弹窗，不可被中断，也不可被其他弹窗覆盖，包括其他强弹窗
- normal: 普通弹窗，一般用于异步提醒或者推广，可被中断，也可被其他弹窗覆盖，包括其他普通弹窗
- weak: 弱弹窗，一般用于推广，可被中断，被中断之后直接销毁，在显示时，如果存在其他弹窗或中断，会直接销毁而不显示

### 为 SwiftUI 提供的如下环境变量:

- alertManager: 弹窗管理器，实际是弹窗状态的存储器，外部可通过这个管理器对弹窗流进行各种操作

## 安装

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

在项目中的 Package.swift 文件添加如下依赖:

```swift
dependencies: [
    .package(url: "https://github.com/miejoy/alert-flow.git", from: "0.1.0"),
]
```

## 使用

### 前置准备工作

- 使用 AlertFlowView 包装需要弹窗流的界面（这里使用弹窗修饰器 AlertModifier() 是一样的效果）

```swift
import SwiftUI
import AlertFlow

@main
struct MainView: View {
    var body: some View {
        // 使用弹窗流包装器
        AlertFlowView {
            AlertRootView()
        }
    }
}
```

- 配合 PresentFlow 在各个展示层使用弹窗

```swift
import SwiftUI
import AlertFlow
import PresentFlow

@main
struct MainView: View {
    var body: some View {
        ContentView()
            .modifier(PresentModifier())    // 使用展示流修饰器
            .modifier(AlertModifier())      // 使用弹窗流修饰器，两个修饰器使用没有先后顺序
            .registerPresentedModifier { content, sceneId, level in
                content.modifier(AlertModifier(level: level))
            }
    }
}
```

### 使用弹窗管理器显示弹窗


```swift
import SwiftUI
import AlertFlow

struct AlertRootView: View {

    // 读取环境中的弹窗管理器
    @Environment(\.alertManager) var alertManager

    var body: some View {
        VStack {
            Button {
                alertManager.showAlert("This is a normal alert")
            } label: {
                Text("Show Normal Alert")
            }
            Button {
                alertManager.showStrongAlert("This is a strong alert")
            } label: {
                Text("Show Strong Alert")
            }
            Button {
                alertManager.showWeakAlert("This is a weak alert")
            } label: {
                Text("Show Weak Alert")
            }
        }
    }
}
```

### 使用代码消失弹窗

注意：SwiftUI 的 alert 使用代码消失存在问题，暂时不公开

```swift
import SwiftUI
import AlertFlow

struct AlertRootView: View {

    @Environment(\.alertManager) var alertManager

    var content: some View {
        VStack {
            Button {
                let alertId = alertManager.showAlert("This alert will auto dismiss")
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                    alertManager.dismissAlert(with: alertId)
                }
            } label: {
                Text("Show Alert Auto Dismiss")
            }
        }
    }
}
```


## 作者

Raymond.huang: raymond0huang@gmail.com

## License

AlertFlow is available under the MIT license. See the LICENSE file for more info.

