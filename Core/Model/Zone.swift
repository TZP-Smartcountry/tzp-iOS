//
//  Zone.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation

struct Zone: Codable {

	let address: Address
	let doubleSided: Bool
	let location: Location
	let reason: String
	let signature: Signature?
	let time: Time

	struct Address: Codable {

		let city: String
		let country: String
		let number: String
		let street: String
	}

	struct Location: Codable {

		let coordinates: [[Double]]
	}

	struct Signature: Codable {

		let assignee: String
		let details: String
		let status: Status

		enum Status: String, Codable {

			case APPROVED
			case PENDING
			case DENIED
		}
	}

	struct Time: Codable {

		let endDate: String
		let endTime: String
		let startDate: String
		let startTime: String
	}
}
