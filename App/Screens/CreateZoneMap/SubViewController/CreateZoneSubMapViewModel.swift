//
//  CreateZoneSubMapViewModel.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 21.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class CreateZoneSubMapViewModel {

	enum State {

		case noneSet
		case oneSet
		case twoSet
	}

	private var firstLocationRelay = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)

	private let stateRelay = BehaviorRelay(value: State.noneSet)
	private let proceedRelay = PublishRelay<(CLLocationCoordinate2D, CLLocationCoordinate2D)>()

	var state: Driver<State> {
		return self.stateRelay.asDriver()
	}

	var canProceed: Observable<(CLLocationCoordinate2D, CLLocationCoordinate2D)> {
		return self.proceedRelay.asObservable()
	}

	var firstLocation: Driver<CLLocationCoordinate2D?> {
		return self.firstLocationRelay.asDriver(onErrorJustReturn: nil)
	}

	func set(firstLocation: CLLocationCoordinate2D) {
		self.firstLocationRelay.accept(firstLocation)
		self.stateRelay.accept(.oneSet)
	}

	func reset() {
		self.firstLocationRelay.accept(nil)
		self.stateRelay.accept(.noneSet)
	}

	func set(secondLocation: CLLocationCoordinate2D) {
		guard let firstLocation = self.firstLocationRelay.value else {
			self.stateRelay.accept(.oneSet)
			self.firstLocationRelay.accept(secondLocation)
			return
		}

		self.proceedRelay.accept((firstLocation, secondLocation))
		self.stateRelay.accept(.twoSet)
	}
}
