//
//  ARViewController.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 21.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController {

	@IBOutlet private weak var arView: ARSCNView?
	@IBOutlet private weak var nextButton: UIButton?
	@IBOutlet private weak var hintLabel: UILabel?
	@IBOutlet private weak var hinView: UIView?

	private var placedNodes = 0 {
		didSet {
			self.nextButton?.isHidden = self.placedNodes != 2

			if (self.placedNodes == 0) {
				self.hintLabel?.text = R.string.localizable.arHint()
			}
		}
	}

	private var panGesture: UIPanGestureRecognizer?
	private var selectedNode: ZoneNode?

	lazy var wood: SCNMaterial = {
		let material = SCNMaterial()
		material.diffuse.contents = R.image.wood()
		material.locksAmbientWithDiffuse = true
		return material
	}()

	lazy var metal: SCNMaterial = {
		let material = SCNMaterial()
		material.diffuse.contents = R.image.metal()
		material.locksAmbientWithDiffuse = true
		return material
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizer(gesture:)))
		self.arView?.addGestureRecognizer(self.panGesture!)

		self.nextButton?.roundView()
		self.nextButton?.setTitleColor(#colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1), for: .normal)
		self.nextButton?.layer.borderColor = #colorLiteral(red: 0, green: 0.6665554643, blue: 0.2045508027, alpha: 1)
		self.nextButton?.backgroundColor = .white
		self.nextButton?.layer.borderWidth = 1
		self.nextButton?.setTitle("Halteverbot beantragen ...", for: .normal)
		self.nextButton?.isHidden = true

		self.hintLabel?.text = R.string.localizable.arHint()
		self.hinView?.layoutIfNeeded()
		self.hinView?.layer.cornerRadius = 5
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let config = ARWorldTrackingConfiguration()
		config.planeDetection = .horizontal

		self.arView?.session.run(config, options: [.removeExistingAnchors, .resetTracking])
		self.arView?.debugOptions = [.showWorldOrigin, .showFeaturePoints]
	}

	@IBAction func panGestureRecognizer(gesture: UIPanGestureRecognizer) {
		let location = gesture.location(in: self.arView)
		let hitTest = self.arView?.hitTest(location, types: .estimatedHorizontalPlane)
		let nodeHitTest = self.arView?.hitTest(location, options: [.backFaceCulling: false])
		let zoneNode = nodeHitTest?.first { $0.node.parent is ZoneNode }?.node.parent as? ZoneNode

		defer {
			self.calculateDistance()
		}

		guard let result = hitTest?.first else {
			return
		}

		var translation = result.worldTransform.translation

		switch gesture.state {
		case .began:
			defer {
				self.selectedNode?.position = SCNVector3(translation.x, translation.y, translation.z)
				self.placedNodes = self.arView?.scene.rootNode.childNodes.filter { $0 is ZoneNode }.count ?? 0
			}

			if let selectedNode = zoneNode {
				self.selectedNode = selectedNode
				return
			}

			let numberOfZoneNodes = self.arView?.scene.rootNode.childNodes.filter { $0 is ZoneNode }.count

			guard ((numberOfZoneNodes ?? 0) < 2) else {
				self.selectedNode = self.arView?.scene.rootNode.childNodes.first { $0 is ZoneNode } as? ZoneNode
				return
			}

			let node = self.shape(for: translation)
			self.arView?.scene.rootNode.addChildNode(node)
			self.selectedNode = node
		case .changed:
			self.selectedNode?.position = SCNVector3(translation.x, translation.y, translation.z)
		case .ended:
			self.selectedNode = nil
		case .possible,
			 .cancelled,
			 .failed : return
		}
	}

	func calculateDistance() {
		let zones = self.arView?.scene.rootNode.childNodes.compactMap { $0 as? ZoneNode } ?? []

		guard (zones.count == 2) else {
			return
		}

		self.hintLabel?.text = Int(zones[0].position.distance(to: zones[1].position)).description + " m"
	}

	@IBAction private func nextButtonTapped(sender: Any) {
		// TODO
	}
}

// MARK: - Display AR

extension ARViewController {

	func shape(for translation: float3) -> ZoneNode {
		let node = ZoneNode()

		let geometryCylinder = SCNCylinder(radius: 0.05, height: 1.2)
		geometryCylinder.materials = [self.metal]
		let cylinder = SCNNode(geometry: geometryCylinder)
		node.addChildNode(cylinder)

		let geometryBox1 = SCNBox(width: 0.1, height: 0.05, length: 0.4, chamferRadius: 0.05)
		geometryBox1.materials = [wood]
		let box1 = SCNNode(geometry: geometryBox1)
		box1.position = SCNVector3(0, -0.6, 0)
		node.addChildNode(box1)

		let geometryBox2 = SCNBox(width: 0.4, height: 0.05, length: 0.1, chamferRadius: 0.05)
		geometryBox2.materials = [wood]
		let box2 = SCNNode(geometry: geometryBox2)
		box2.position = SCNVector3(0, -0.6, 0)
		node.addChildNode(box2)

		let boundingBox = node.boundingBox
		node.pivot = SCNMatrix4MakeTranslation(0, (boundingBox.min.y - boundingBox.max.y) / 2, 0)
		node.position = SCNVector3(translation.x, translation.y, translation.z)

		return node
	}
}

private extension simd_float4x4 {

	var translation: float3 {
		let translation = self.columns.3
		return float3(translation.x, translation.y, translation.z)
	}
}

private extension SCNVector3 {

	func distance(to vector: SCNVector3) -> Float {
		let distance = SCNVector3(self.x - vector.x, self.y - vector.y, self.z - vector.z)
		return sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
	}
}
