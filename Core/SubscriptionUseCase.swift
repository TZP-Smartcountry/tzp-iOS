//
//  SubscriptionUseCase.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation

private enum Constants {

	static let url = "https://7f8f3173.ngrok.io/api/subscriptions"
	static let user = "user"
}

class SubscriptionUseCase {

	static let shared = SubscriptionUseCase()
}
