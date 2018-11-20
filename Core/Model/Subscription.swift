//
//  Subscription.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation
import CoreLocation

struct Subscription: Codable {

	let id: String?
	let author: String?

	let location: GeoJsonCircle

	init(location: CLLocationCoordinate2D, radius: Double) {
		self.location = GeoJsonCircle(radius: radius, coordinates: [location.latitude, location.longitude])
		self.id = nil
		self.author = nil
	}
}

struct GeoJsonCircle: Codable {

	let type = "Circle"
	let properties = ["radius_units": "m"]
	let radius: Double
	let coordinates: [Double]
}
