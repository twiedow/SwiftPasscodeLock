//
//  PasscodeLockPresenter.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

open class PasscodeLockPresenter {
    
    private var mainWindow: UIWindow?
    
    private lazy var passcodeLockWindow = UIWindow(frame: UIScreen.main.bounds)
        
    private let passcodeConfiguration: PasscodeLockConfigurationType
    open var isPasscodePresented = false
    open let passcodeLockVC: PasscodeLockViewController
    
    public init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType, viewController: PasscodeLockViewController) {
        mainWindow = window
        passcodeConfiguration = configuration
        
        passcodeLockVC = viewController
    }

    public convenience init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType) {
        let passcodeLockVC = PasscodeLockViewController(state: .enter, configuration: configuration)
        self.init(mainWindow: window, configuration: configuration, viewController: passcodeLockVC)
    }
    
    open func present() {
        guard passcodeConfiguration.repository.hasPasscode && !isPasscodePresented else { return }
        
        isPasscodePresented = true

        mainWindow?.endEditing(true)
        moveWindowsToFront()
        passcodeLockWindow.isHidden = false

        let userDismissCompletionCallback = passcodeLockVC.dismissCompletionCallback
        
        passcodeLockVC.dismissCompletionCallback = { [weak self] in
            userDismissCompletionCallback?()
            self?.dismiss()
        }
        
        passcodeLockWindow.rootViewController = passcodeLockVC
    }

    open func dismiss(animated: Bool = true) {
        isPasscodePresented = false

        if animated {
            animatePasscodeLockDismissal()
            
        } else {
            passcodeLockWindow.isHidden = true
            passcodeLockWindow.rootViewController = nil
        }
    }
    
    internal func animatePasscodeLockDismissal() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: UIViewAnimationOptions(),
            animations: { [weak self] in
                self?.passcodeLockWindow.alpha = 0
            },
            completion: { [weak self] _ in
                self?.passcodeLockWindow.isHidden = true
                self?.passcodeLockWindow.rootViewController = nil
                self?.passcodeLockWindow.alpha = 1
            }
        )
    }

    private func moveWindowsToFront() {
        let windowLevel = UIApplication.shared.windows.last?.windowLevel ?? UIWindowLevelNormal
        let maxWinLevel = max(windowLevel, UIWindowLevelNormal)
        passcodeLockWindow.windowLevel =  maxWinLevel + 1
    }
}
