//
//  ZonesUseCase.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {

	static let allURL = "https://1e31fd74.ngrok.io/api/zones"
	static let mineURL = "https://1e31fd74.ngrok.io/api/zones/mine"
	static let user = "user"
	static let contentType = "Content-Type"
	static let jsonContentType = "application/json"
	static let email = "larschi"
}

class ZonesUseCase {

	enum ApiError: Error {

		case error
	}

	static let shared = ZonesUseCase()

	func getAll() -> Single<[Zone]> {
		guard let url = URL(string: Constants.allURL) else {
			return Single.error(ApiError.error)
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"

		return Single.create { (single) in

			URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

				guard
					let data = data,
					let objects = try? JSONDecoder().decode([Zone].self, from: data) else {
						single(.error(ApiError.error))
						return
				}

				single(.success(objects))
			}.resume()

			return Disposables.create()
		}
	}

	func create(_ zone: Zone) -> Completable {
		guard
			let url = URL(string: Constants.allURL),
			let json = try? JSONEncoder().encode(zone) else {
				return Completable.error(ApiError.error)
		}

		var request = URLRequest(url: url)
		request.addValue(Constants.email, forHTTPHeaderField: Constants.user)
		request.setValue(Constants.jsonContentType, forHTTPHeaderField: Constants.contentType)
		request.httpMethod = "POST"

		request.httpBody = json

		return Completable.create { (completable) in

			URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
				completable(.completed)
			}.resume()

			return Disposables.create()
		}
	}

	func getMine() -> Single<[Zone]> {
		guard let url = URL(string: Constants.mineURL) else {
			return Single.error(ApiError.error)
		}

		var request = URLRequest(url: url)
		request.addValue(Constants.email, forHTTPHeaderField: Constants.user)
		request.httpMethod = "GET"

		return Single.create { (single) in

			URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

				guard
					let data = data,
					let objects = try? JSONDecoder().decode([Zone].self, from: data) else {
						single(.error(ApiError.error))
						return
				}

				single(.success(objects))
			}.resume()

			return Disposables.create()
		}
	}
}
