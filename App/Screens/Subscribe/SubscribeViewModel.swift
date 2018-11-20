//
//  SubscribeViewModel.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SubscribeViewModel {

	enum State {

		case display
		case add
	}

	// MARK: - Relay

	private let stateRelay = BehaviorRelay(value: State.display)

	// MARK: - Driver

	var state: Driver<State> {
		return self.stateRelay.asDriver()
	}

	// MARK: - I/O

	func enterAddMode() {
		self.stateRelay.accept(.add)
	}
}
