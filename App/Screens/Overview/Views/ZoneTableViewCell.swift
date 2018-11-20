//
//  ZoneTableViewCell.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit

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

class ZoneTableViewCell: UITableViewCell {

	@IBOutlet private weak var titleLabel: UILabel?
	@IBOutlet private weak var dateLabel: UILabel?
	@IBOutlet private weak var addressLabel: UILabel?

	@IBOutlet private weak var statusImageView: UIImageView?

	func layout(for zone: Zone) {
		self.titleLabel?.text = zone.reason
		self.dateLabel?.text = zone.time.displayString
		self.addressLabel?.text = zone.address.displayString
		self.statusImageView?.image = zone.signature?.status.image
		self.statusImageView?.tintColor = zone.signature?.status.tint
	}
}

private extension Zone.Address {

	var displayString: String {
		return "\(self.street) \(self.number), \(self.city)"
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

private extension Zone.Signature.Status {

	var image: UIImage? {
		switch self {
		case .APPROVED: return R.image.ic_check()
		case .DENIED: return R.image.ic_decline()
		case .PENDING: return R.image.ic_pending()
		}
	}

	var tint: UIColor {
		switch self {
		case .APPROVED: return #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1)
		case .DENIED: return #colorLiteral(red: 1, green: 0.3098039216, blue: 0.2666666667, alpha: 1)
		case .PENDING: return #colorLiteral(red: 0.6352941176, green: 0.6352941176, blue: 0.6549019608, alpha: 1)
		}
	}
}
