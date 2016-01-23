//
//  UIKit+Themes.swift
//  SwiftTheme
//
//  Created by Gesen on 16/1/22.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import UIKit

extension UIView {
    
    public typealias ThemePickers = [String: ThemePicker]
    
    public var themePickers: ThemePickers {
        get {
            if let value = objc_getAssociatedObject(self, &themesAssociationKey) as? ThemePickers {
                return value
            }
            let value = ThemePickers()
            objc_setAssociatedObject(self, &themesAssociationKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setupThemeNotification()
            return value
        }
        set {
            objc_setAssociatedObject(self, &themesAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func performThemePicker(selector: String, themePicker: ThemePicker) {
        let sel = Selector(selector)
        guard respondsToSelector(sel)         else { return }
        guard let value = themePicker.value() else { return }
        guard let state = themePicker.state   else {
            performSelector(sel, withObject: themePicker.value())
            return
        }
        
        typealias setValueForControlStateIMP = @convention(c) (UIView, Selector, AnyObject, UIControlState) -> Void
        
        let methodSignature = self.methodForSelector(sel)
        let callback = unsafeBitCast(methodSignature, setValueForControlStateIMP.self)
        
        callback(self, sel, value, state)
    }
    
    private func setupThemeNotification() {
        if #available(iOS 9.0, *) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTheme", name: ThemeUpdateNotification, object: nil)
        } else {
            NSNotificationCenter.defaultCenter().addObserverForName(ThemeUpdateNotification, object: nil, queue: nil, usingBlock: { [weak self] notification in self?.updateTheme() })
        }
    }
    
    @objc private func updateTheme() {
        themePickers.forEach { selector, themePicker in
            UIView.animateWithDuration(ThemeAnimationDuration) {
                self.performThemePicker(selector, themePicker: themePicker)
            }
        }
    }
    
}

private var themesAssociationKey = ""