//
//  CreateZoneMapViewController.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class CreateZoneMapViewController: UIViewController {

	@IBOutlet private weak var segmentedControl: UISegmentedControl?

	@IBOutlet private weak var mapContentView: UIView?
	@IBOutlet private weak var arContentView: UIView?

	private let disposeBag = DisposeBag()

	private let geoCoder = CLGeocoder()

	var mapViewController: CreateZoneSubMapViewController? {
		return self.children.first { $0 is CreateZoneSubMapViewController } as? CreateZoneSubMapViewController
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.segmentedControl?.sendActions(for: .valueChanged)
		self.mapViewController?.viewModel
			.canProceed
			.subscribe(onNext: { [weak self] (locations) in
				var zone = Zone([[locations.0.latitude, locations.0.longitude], [locations.1.latitude, locations.1.longitude]], distance: CLLocation.distance(from: locations.0, to: locations.1))
				guard let controller = R.storyboard.createZoneFormViewController.instantiateInitialViewController() else {
					return
				}

				self?.getLocationSnapshot(for: locations.0, complation: { (place) in
					zone.address.city = place?.administrativeArea ?? ""
					zone.address.country = place?.country ?? ""
					zone.address.street = place?.thoroughfare ?? ""
					zone.address.number = place?.subThoroughfare ?? ""
					zone.address.zip = place?.postalCode ?? ""

					controller.zone = zone

					self?.navigationController?.pushViewController(controller, animated: true)
				})
			})
			.disposed(by: self.disposeBag)
	}

	@IBAction private func segmentedControlChanged(control: UISegmentedControl) {
		UIView.animate(withDuration: 0.3) {
			self.mapContentView?.isHidden = control.selectedSegmentIndex != 0
			self.arContentView?.isHidden = control.selectedSegmentIndex == 0
		}
	}

	@IBAction private func dismissTapped(sender: Any) {
		self.dismiss(animated: true)
	}

	func getLocationSnapshot(for location: CLLocationCoordinate2D, complation: @escaping ((CLPlacemark?) -> Void)) {
		self.geoCoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) { (placemarks, error) in
			complation(placemarks?.first)
		}
	}
}

private extension CLLocation {

	class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
		let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
		let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
		return from.distance(from: to)
	}
}
