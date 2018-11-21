//
//  Zone.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation

struct Zone: Codable {

	var address: Address
	var doubleSided: Bool
	var location: Location
	var reason: String
	var signature: Signature?
	var time: Time
	var length: Double

	init(_ coordinates: [[Double]], distance: Double) {
		self.address = Address(city: "", country: "", number: "", street: "", zip: "")
		self.doubleSided = false
		self.location = Location(coordinates: coordinates)
		self.reason = "Umzug"
		self.signature = nil
		self.time = Time(endDate: "2018-11-29", endTime: "17:00:00", startDate: "2018-11-27", startTime: "10:00:00")
		self.length = Double(Int(distance))
	}

	struct Address: Codable {

		var city: String
		var country: String
		var number: String
		var street: String
		var zip: String
	}

	struct Location: Codable {

		let type = "LineString"
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
