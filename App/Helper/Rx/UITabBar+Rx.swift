//
//  UITabBar+Rx.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base == UITabBar {

	/// Animates the Tabbar to hide under the Screen Border
	/// Will be animated with the CoreGraphics API (CGAffineTransform)
	///
	/// - Parameter animationDuration: duration of the animation
	/// - Returns: Binder
	func hideBar(animationDuration: TimeInterval = 0.3) -> Binder<Bool> {
		return Binder(base) { bar, hidden in
			UIView.animate(withDuration: animationDuration) {
				if hidden == true {
					bar.transform = CGAffineTransform(translationX: 0, y: bar.frame.height)
				} else {
					bar.transform = .identity
				}
			}
		}
	}

	/// Will change the `isEnabled` State of every BarItem
	var isEnabled: Binder<Bool> {
		return Binder(base) { bar, isEnabled in
			bar.items?.forEach { $0.isEnabled = isEnabled }
		}
	}
}
