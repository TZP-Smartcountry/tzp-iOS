//
//  SubscriptionUseCase.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {

	static let url = "https://1e31fd74.ngrok.io/api/subscriptions"
	static let user = "user"
	static let contentType = "Content-Type"
	static let jsonContentType = "application/json"
	static let email = "k.deichmann@mac.com"
}

class SubscriptionUseCase {

	enum ApiError: Error {

		case error
	}

	static let shared = SubscriptionUseCase()

	func subscribe(for subscription: Subscription) -> Completable {

		guard
			let url = URL(string: Constants.url),
			let json = try? JSONEncoder().encode(subscription) else {
				return Completable.error(ApiError.error)
		}

		var request = URLRequest(url: url)
		request.setValue(Constants.email, forHTTPHeaderField: Constants.user)
		request.setValue(Constants.jsonContentType, forHTTPHeaderField: Constants.contentType)
		request.httpMethod = "POST"

		request.httpBody = json

		return Completable.create { (completable) in

			URLSession.shared.dataTask(with: request) { _, response, _ in
				completable(.completed)
			}.resume()

			return Disposables.create()
		}
	}

	func getAll() -> Single<[Subscription]> {

		guard let url = URL(string: Constants.url) else {
			return Single.error(ApiError.error)
		}

		var request = URLRequest(url: url)
		request.setValue(Constants.email, forHTTPHeaderField: Constants.user)
		request.httpMethod = "GET"

		return Single.create { (single) in

			URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

				guard
					let data = data,
					let objects = try? JSONDecoder().decode([Subscription].self, from: data) else {
						single(.error(ApiError.error))
						return
				}

				single(.success(objects))
			}.resume()

			return Disposables.create()
		}
	}
}
