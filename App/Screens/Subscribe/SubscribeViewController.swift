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

	@IBOutlet fileprivate weak var mapView: MKMapView?

	@IBOutlet fileprivate weak var poiImageView: UIImageView?
	@IBOutlet fileprivate weak var poiDiameterView: UIView?
	@IBOutlet fileprivate weak var editView: SubscribeEditView?

	@IBOutlet fileprivate var poiDiameterViewHeightConstraint: NSLayoutConstraint?
	@IBOutlet fileprivate var poiDiameterViewWidthConstraint: NSLayoutConstraint?

	private let viewModel = SubscribeViewModel()
	private let disposeBag = DisposeBag()
	private let manager = CLLocationManager()

	private let mapRectChangedRelay = PublishRelay<Void>()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.mapView?.delegate = self

		manager.delegate = self
		manager.requestWhenInUseAuthorization()

		self.createBinding()
	}

	private func createBinding() {

		self.poiDiameterView?.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.5568627451, blue: 1, alpha: 1).withAlphaComponent(0.4)
		self.poiDiameterView?.layer.borderColor = #colorLiteral(red: 0.07843137255, green: 0.5568627451, blue: 1, alpha: 1)
		self.poiDiameterView?.layer.borderWidth = 1

		self.viewModel.state.drive(self.rx.stateChanged).disposed(by: self.disposeBag)
		self.viewModel.subscriptions.drive(self.rx.subscriptions).disposed(by: self.disposeBag)
		self.viewModel.zones.drive(self.rx.zones).disposed(by: self.disposeBag)

		self.editView?.proceedTrigger?.drive(onNext: { [weak self] (diameter) in
			guard let location = self?.mapView?.centerCoordinate else {
				return
			}

			self?.viewModel.subscribe(radius: Double(diameter) / 2, location: location)
		}).disposed(by: self.disposeBag)

		self.observeDiameter()
		self.viewModel.refreshSubscriptions()
		self.viewModel.refreshZones()
	}

	private func observeDiameter() {
		guard let diameter = self.editView?.diameter else {
			return
		}

		Driver.combineLatest(diameter, self.mapRectChangedRelay.asDriver(onErrorJustReturn: ()), resultSelector: { diameter, _ in return diameter })
			.map { [weak self] in CGFloat((self?.pixelPerMeter ?? 0) * Double($0)) }
			.drive(self.rx.updateDiameterView)
			.disposed(by: self.disposeBag)
	}

	func addBarButton() -> UIBarButtonItem? {
		return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped(sender:)))
	}

	func cancelButton() -> UIBarButtonItem? {
		return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped(sender:)))
	}

	@IBAction func addTapped(sender: Any) {
		self.viewModel.enterAddMode()
	}

	@IBAction func cancelTapped(sender: Any) {
		self.viewModel.exitAddMode()
	}

	@IBAction private func locateMeTapped(sender: Any) {
		self.mapView?.userTrackingMode = .follow
	}

	@IBAction private func refreshTapped(sender: Any) {
		self.viewModel.refreshZones()
	}
}

// MARK: - MapView

extension SubscribeViewController: MKMapViewDelegate, CLLocationManagerDelegate {

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
		let renderer = MKCircleRenderer(overlay: overlay)
		renderer.fillColor = #colorLiteral(red: 1, green: 0.662745098, blue: 0.07843137255, alpha: 1).withAlphaComponent(0.4)
		return renderer
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		self.mapRectChangedRelay.accept(())
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		self.mapView?.userTrackingMode = .follow
	}
}

// MARK: - Rx

extension Reactive where Base == SubscribeViewController {

	var stateChanged: Binder<SubscribeViewModel.State> {
		return Binder(base) { controller, state in
			controller.navigationItem.rightBarButtonItem = state == .add ? controller.cancelButton() : controller.addBarButton()
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

	var subscriptions: Binder<[Subscription]> {
		return Binder(base) { controller, subscriptions in
			let circles = controller.mapView?.overlays.filter { $0 is MKCircle } ?? []
			controller.mapView?.removeOverlays(circles)
			controller.mapView?.addOverlays(subscriptions.map { $0.circle })
		}
	}

	var zones: Binder<[Zone]> {
		return Binder(base) { controller, zones in
			let annotations = controller.mapView?.annotations.filter { $0 is ZoneAnnotation } ?? []
			controller.mapView?.removeAnnotations(annotations)
			controller.mapView?.addAnnotations(zones.map { ZoneAnnotation($0) })
		}
	}
}

private extension Subscription {

	var circle: MKCircle {
		return MKCircle(center: self.location.location, radius: self.location.radius)
	}
}

private extension GeoJsonCircle {

	var location: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.coordinates[0], longitude: self.coordinates[1])
	}
}
