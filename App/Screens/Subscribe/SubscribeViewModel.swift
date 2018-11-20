//
//  SubscribeViewModel.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class SubscribeViewModel {

	enum State {

		case display
		case add
	}

	private let disposeBag = DisposeBag()

	// MARK: - Relay

	private let stateRelay = BehaviorRelay(value: State.display)
	private let subscriptionRelay = PublishRelay<[Subscription]>()
	private let zonesRelay = PublishRelay<[Zone]>()

	// MARK: - Driver

	var state: Driver<State> {
		return self.stateRelay.asDriver()
	}

	var subscriptions: Driver<[Subscription]> {
		return self.subscriptionRelay.asDriver(onErrorJustReturn: [])
	}

	var zones: Driver<[Zone]> {
		return self.zonesRelay.asDriver(onErrorJustReturn: [])
	}

	// MARK: - I/O

	func enterAddMode() {
		self.stateRelay.accept(.add)
	}

	func subscribe(radius: Double, location: CLLocationCoordinate2D) {
		self.stateRelay.accept(.display)

		SubscriptionUseCase.shared
			.subscribe(for: Subscription(location: location, radius: radius))
			.subscribe(onCompleted: { [weak self] in
				self?.refreshSubscriptions()
			})
			.disposed(by: self.disposeBag)
	}

	func refreshSubscriptions() {
		SubscriptionUseCase.shared
			.getAll()
			.subscribe(onSuccess: { [weak self] (subscriptions) in
				self?.subscriptionRelay.accept(subscriptions)
			})
			.disposed(by: self.disposeBag)
	}

	func refreshZones() {
		ZonesUseCase.shared
			.getAll()
			.subscribe(onSuccess: { [weak self] (zones) in
				self?.zonesRelay.accept(zones)
			})
			.disposed(by: self.disposeBag)
	}
}
