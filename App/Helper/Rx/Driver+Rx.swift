//
//  Driver+Rx.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType where Self.SharingStrategy == RxCocoa.DriverSharingStrategy {

	func drive<O>(_ observer: O?) -> Disposable where O : ObserverType, Self.E == O.E {
		guard let observer = observer else {
			/// Creates a disposable that does nothing on disposal.
			return Disposables.create()
		}

		return self.drive(observer)
	}

	func drive<O>(_ observer: O?) -> Disposable where O : ObserverType, O.E == Self.E? {
		guard let observer = observer else {
			/// Creates a disposable that does nothing on disposal.
			return Disposables.create()
		}

		return self.drive(observer)
	}

	func bind<O>(to observer: O?) -> Disposable where O : ObserverType, Self.E == O.E {
		guard let observer = observer else {
			return Disposables.create()
		}

		return self.bind(to: observer)
	}
}

extension ObservableType {

	func bind(to relay: BehaviorRelay<E?>?) -> Disposable {
		guard let relay = relay else {
			return Disposables.create()
		}

		return self.bind(to: relay)
	}
}

extension Driver where E == Bool {

	/// Will inverse the Bool in a sequence
	///
	/// true -> `.inversed` -> false
	var inversed: SharedSequence {
		return self.map { $0 == false }
	}
}

extension ObservableType {

	func bind(to relay: PublishRelay<Self.E>?) -> Disposable {
		guard let relay = relay else {
			return Disposables.create()
		}

		return self.bind(to: relay)
	}

	func bind(to relay: BehaviorRelay<Self.E>?) -> Disposable {
		guard let relay = relay else {
			return Disposables.create()
		}

		return self.bind(to: relay)
	}
}

