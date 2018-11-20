//
//  ZoneAnnotation.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import Foundation
import MapKit

private enum Constants {

	static var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()

	static var dateDisplayFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeStyle = .none
		formatter.dateStyle = .short
		return formatter
	}()

	static var timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm:ss"
		return formatter
	}()

	static var timeDisplayFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		formatter.dateStyle = .none
		return formatter
	}()
}

class ZoneAnnotation: NSObject, MKAnnotation {

	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?

	init(_ zone: Zone) {
		self.coordinate = zone.location.pointCoordinate
		self.title = zone.reason
		self.subtitle = zone.time.displayString
	}
}

private extension Zone.Location {

	var pointCoordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.coordinates[0][0] , longitude: self.coordinates[0][1])
		return CLLocationCoordinate2D(latitude: (self.coordinates[0][0] + self.coordinates[1][0]) / 2 , longitude: (self.coordinates[0][1] + self.coordinates[1][1]) / 2)
	}
}

private extension Zone.Time {

	var displayString: String {
		guard
			let startDate = Constants.dateFormatter.date(from: self.startDate),
			let endDate = Constants.dateFormatter.date(from: self.endDate),
			let startTime = Constants.timeFormatter.date(from: self.startTime),
			let endTime = Constants.timeFormatter.date(from: self.endTime) else {
				return "-"
		}

		return Constants.dateDisplayFormatter.string(from: startDate) + " - " + Constants.dateDisplayFormatter.string(from: endDate) + " (" + Constants.timeDisplayFormatter.string(from: startTime) + " - " + Constants.timeDisplayFormatter.string(from: endTime) + ")"
	}
}
