//
//  CreateZoneFormViewController.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 21.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

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

class CreateZoneFormViewController: UIViewController {

	@IBOutlet private weak var moveButton: UIButton?
	@IBOutlet private weak var videoButton: UIButton?
	@IBOutlet private weak var otherButton: UIButton?

	@IBOutlet private weak var addressLabel: UILabel?
	@IBOutlet private weak var lengthLabel: UILabel?
	@IBOutlet private weak var dateLabel: UILabel?
	@IBOutlet private weak var timeLabel: UILabel?
	@IBOutlet private weak var slider: UISlider?

	var zone: Zone!

	var disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.addressLabel?.text = zone.address.displayString
		self.lengthLabel?.text = zone.length.description + " m"
		self.slider?.value = Float(zone.length)
		self.slider?.isEnabled = false
		self.dateLabel?.text = zone.time.dateDisplayString
		self.timeLabel?.text = zone.time.timeDisplayString

		self.moveButton?.setTitleColor(.white, for: .selected)
		self.moveButton?.setTitleColor(#colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1), for: .normal)
		self.videoButton?.setTitleColor(.white, for: .selected)
		self.videoButton?.setTitleColor(#colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1), for: .normal)
		self.otherButton?.setTitleColor(.white, for: .selected)
		self.otherButton?.setTitleColor(#colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1), for: .normal)

		self.moveButton?.layer.cornerRadius = 5
		self.moveButton?.layer.borderColor = #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1)
		self.moveButton?.layer.borderWidth = 1
		self.videoButton?.layer.cornerRadius = 5
		self.videoButton?.layer.borderColor = #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1)
		self.videoButton?.layer.borderWidth = 1
		self.otherButton?.layer.cornerRadius = 5
		self.otherButton?.layer.borderColor = #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1)
		self.otherButton?.layer.borderWidth = 1

		self.moveButton?.isSelected = true
		self.moveButton?.backgroundColor = #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1)
	}

	@IBAction private func doneTapped(sender: Any) {
		ZonesUseCase.shared.create(self.zone).subscribe(onCompleted: { [weak self] in
			self?.dismiss(animated: true)
		}).disposed(by: self.disposeBag)
	}

	@IBAction private func buttonTapped(sender: UIButton) {
		self.moveButton?.backgroundColor = sender == self.moveButton ? #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1) : .white
		self.videoButton?.backgroundColor = sender == self.videoButton ? #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1) : .white
		self.otherButton?.backgroundColor = sender == self.otherButton ? #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1) : .white

		self.moveButton?.isSelected = sender == self.moveButton
		self.videoButton?.isSelected = sender == self.videoButton
		self.otherButton?.isSelected = sender == self.otherButton

		if sender == self.moveButton {
			zone.reason = "Umzug"
		} else if sender == self.videoButton {
			zone.reason = "Filmdreh"
		} else if sender == self.otherButton {
			zone.reason = "Andere"
		}
	}
}

private extension Zone.Address {

	var displayString: String {
		return "\(self.street) \(self.number)\n\(self.zip) \(self.city)"
	}
}

private extension Zone.Time {

	var dateDisplayString: String {
		guard
			let startDate = Constants.dateFormatter.date(from: self.startDate),
			let endDate = Constants.dateFormatter.date(from: self.endDate) else {
				return "-"
		}

		return Constants.dateDisplayFormatter.string(from: startDate) + " - " + Constants.dateDisplayFormatter.string(from: endDate)
	}

	var timeDisplayString: String {
		guard
			let startTime = Constants.timeFormatter.date(from: self.startTime),
			let endTime = Constants.timeFormatter.date(from: self.endTime) else {
				return "-"
		}

		return Constants.timeDisplayFormatter.string(from: startTime) + " - " + Constants.timeDisplayFormatter.string(from: endTime)
	}
}
