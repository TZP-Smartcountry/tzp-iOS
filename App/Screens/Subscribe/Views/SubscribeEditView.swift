//
//  SubscribeEditView.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

private enum Constants {

	static let minDistance = 100
	static let maxDistance = 1000
	static let defaultValue = 300
}

class SubscribeEditView: UIView {

	@IBOutlet private weak var titleLabel: UILabel?
	@IBOutlet private weak var distanceLabel: UILabel?
	@IBOutlet private weak var slider: UISlider?
	@IBOutlet private weak var proceedButton: UIButton?

	private let disposeBag = DisposeBag()

	// MARK: - Relays

	var diameter: Driver<Int>? {
		return self.slider?.rx.controlEvent(.valueChanged)
			.map { _ -> Int in
				guard let value = self.slider?.value else {
					return Constants.defaultValue
				}

				return Int(value)
			}
			.asDriver(onErrorJustReturn: Constants.defaultValue)
	}

	var proceedTrigger: Driver<Int>? {
		return self.proceedButton?.rx.tap
			.map { _ -> Int in
				guard let value = self.slider?.value else {
					return Constants.defaultValue
				}

				return Int(value)
			}
			.asDriver(onErrorJustReturn: Constants.defaultValue)
	}

	// MARK: - View

	private lazy var formatter: LengthFormatter = {
		let formatter = LengthFormatter()
		formatter.unitStyle = .short
		formatter.numberFormatter.maximumFractionDigits = 0
		return formatter
	}()

	override func awakeFromNib() {
		super.awakeFromNib()

		self.createBinding()
		self.slider?.maximumValue = Float(Constants.maxDistance)
		self.slider?.minimumValue = Float(Constants.minDistance)
		self.slider?.value = Float(Constants.defaultValue)
		self.slider?.sendActions(for: .valueChanged)
		self.proceedButton?.layer.cornerRadius = 5
	}

	private func createBinding() {
		self.titleLabel?.text = R.string.localizable.subscribeEditTitle()

		self.slider?.rx.controlEvent(UIControlEvents.valueChanged)
			.map { _ -> Int in
				guard let value = self.slider?.value else {
					return Constants.defaultValue
				}

				return Int(value)
			}.map { self.formatter.string(fromMeters: Double($0)) }
			.asDriver(onErrorJustReturn: "-")
			.drive(self.distanceLabel?.rx.text)
			.disposed(by: self.disposeBag)
	}
}
