//
//  SubscribeViewController.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class SubscribeViewController: UIViewController {

	@IBOutlet private weak var mapView: MKMapView?

	@IBOutlet fileprivate weak var poiImageView: UIImageView?
	@IBOutlet fileprivate weak var poiDiameterView: UIView?
	@IBOutlet fileprivate weak var editView: SubscribeEditView?

	@IBOutlet fileprivate var poiDiameterViewHeightConstraint: NSLayoutConstraint?
	@IBOutlet fileprivate var poiDiameterViewWidthConstraint: NSLayoutConstraint?

	private let viewModel = SubscribeViewModel()
	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.createBinding()

		self.mapView?.delegate = self
	}

	private func createBinding() {

		self.poiDiameterView?.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.5568627451, blue: 1, alpha: 1).withAlphaComponent(0.4)
		self.poiDiameterView?.layer.borderColor = #colorLiteral(red: 0.07843137255, green: 0.5568627451, blue: 1, alpha: 1)
		self.poiDiameterView?.layer.borderWidth = 1

		self.viewModel.state.drive(self.rx.stateChanged).disposed(by: self.disposeBag)
		self.viewModel.state.map { $0 == .add }.drive(self.tabBarController?.tabBar.rx.hideBar()).disposed(by: self.disposeBag)

		self.editView?.diameter?
			.map { [weak self] in CGFloat((self?.pixelPerMeter ?? 0) * Double($0)) }
			.drive(self.rx.updateDiameterView)
			.disposed(by: self.disposeBag)
	}

	func addBarButton() -> UIBarButtonItem? {
		return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped(sender:)))
	}

	@IBAction func addTapped(sender: Any) {
		self.viewModel.enterAddMode()
	}

	@IBAction private func locateMeTapped(sender: Any) {
		self.mapView?.userTrackingMode = .follow
	}
}

// MARK: - MapView

extension SubscribeViewController: MKMapViewDelegate {

	fileprivate var pixelPerMeter: Double {
		guard
			let location = self.mapView?.centerCoordinate,
			let rect = self.mapView?.visibleMapRect,
			let mapWidth = self.mapView?.frame.width else {
				return 0
		}

		let pointsPerMeter = MKMetersPerMapPointAtLatitude(location.latitude)
		return (1 / pointsPerMeter) * (Double(mapWidth) / rect.width)
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		return MKPolygonRenderer(overlay: overlay)
	}
}

// MARK: - Rx

extension Reactive where Base == SubscribeViewController {

	var stateChanged: Binder<SubscribeViewModel.State> {
		return Binder(base) { controller, state in
			controller.navigationItem.rightBarButtonItem = state == .add ? nil : controller.addBarButton()
			controller.poiImageView?.isHidden = state == .display
			controller.editView?.isHidden = state == .display
			controller.poiDiameterView?.isHidden = state == .display
		}
	}

	var updateDiameterView: Binder<CGFloat> {
		return Binder(base) { controller, diameter in
			controller.poiDiameterViewHeightConstraint?.constant = diameter
			controller.poiDiameterViewWidthConstraint?.constant = diameter
			controller.poiDiameterView?.layer.cornerRadius = diameter / 2
			controller.poiDiameterView?.layoutIfNeeded()
		}
	}
}
