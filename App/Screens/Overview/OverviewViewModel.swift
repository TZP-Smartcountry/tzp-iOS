//
//  OverviewViewModel.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OverviewViewModel {

	private let disposeBag = DisposeBag()

	private let zonesRelay = BehaviorRelay<[Zone]>(value: [])

	var zones: Driver<[Zone]> {
		return self.zonesRelay.asDriver()
	}

	func refreshZones() {
		ZonesUseCase.shared
			.getMine()
			.subscribe(onSuccess: { [weak self] (zones) in
				self?.zonesRelay.accept(zones)
			})
			.disposed(by: self.disposeBag)
	}
}
