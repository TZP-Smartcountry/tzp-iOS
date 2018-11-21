//
//  CreateZoneSubMapViewController.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class CreateZoneSubMapViewController: UIViewController {

	@IBOutlet fileprivate weak var mapView: MKMapView?
	@IBOutlet fileprivate weak var locateButton: UIButton?
	@IBOutlet fileprivate weak var nextButton: UIButton?
	@IBOutlet fileprivate weak var poiView: UIView?

	let viewModel = CreateZoneSubMapViewModel()
	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.createBinding()
		self.mapView?.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.viewModel.reset()
	}

	var centerLocation: CLLocationCoordinate2D? {
		guard
			let map = self.mapView,
			let poiView = self.poiView else {
				return nil
		}

		let point = CGPoint(x: poiView.bounds.width / 2, y: poiView.bounds.height)
		return map.convert(point, toCoordinateFrom: poiView)
	}

	func createBinding() {

		self.nextButton?.roundView()
		self.nextButton?.setTitleColor(#colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1), for: .normal)
		self.nextButton?.layer.borderColor = #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1)
		self.nextButton?.backgroundColor = .white
		self.nextButton?.layer.borderWidth = 1

		self.viewModel.state.drive(self.rx.updateState).disposed(by: self.disposeBag)
		self.viewModel.firstLocation.drive(self.rx.firstPosition).disposed(by: self.disposeBag)

		self.nextButton?.rx.tap.asDriver().drive(onNext: { [weak self] _ in
			guard let location = self?.centerLocation else {
				return
			}

			guard (self?.viewModel.firstLocation == nil) else {
				self?.viewModel.set(secondLocation: location)
				return
			}

			self?.viewModel.set(firstLocation: location)
		})
		.disposed(by: self.disposeBag)
	}

	@IBAction private func locationButtonTapped(sender: Any) {
		self.mapView?.userTrackingMode = .follow
	}
}

// MARK: - MapView

extension CreateZoneSubMapViewController: MKMapViewDelegate {

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {

		mapView.removeOverlays(mapView.overlays)

		let _annotation = mapView.annotations.first { $0 is MKPointAnnotation }

		guard
			let annotation = _annotation,
			let center = self.centerLocation else {
				return
		}

		let line = MKPolyline(coordinates: [annotation.coordinate, center], count: 2)
		mapView.addOverlay(line)
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
		renderer.strokeColor = UIColor.black.withAlphaComponent(0.5)
		renderer.lineWidth = 2
		renderer.lineDashPhase = 3

		return renderer
	}
}

// MARK: - RX

private extension Reactive where Base == CreateZoneSubMapViewController {

	var updateState: Binder<CreateZoneSubMapViewModel.State> {
		return Binder(base) { controller, state in
			let text = state == .noneSet ? R.string.localizable.createMapNextButton() : R.string.localizable.createMapProceedButton()
			controller.nextButton?.isHidden = state == .twoSet
			controller.nextButton?.setTitle(text, for: .normal)
		}
	}

	var firstPosition: Binder<CLLocationCoordinate2D?> {
		return Binder(base) { controller, location in
			let annotations = controller.mapView?.annotations.filter { $0 is MKPointAnnotation } ?? []
			controller.mapView?.removeAnnotations(annotations)

			guard let location = location else {
				return
			}

			let annotation = MKPointAnnotation()
			annotation.coordinate = location

			controller.mapView?.addAnnotation(annotation)
		}
	}
}
