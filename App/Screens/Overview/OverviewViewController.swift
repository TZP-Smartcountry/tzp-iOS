//
//  OverviewViewController.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OverviewViewController: UITableViewController {

	private let viewModel = OverviewViewModel()
	private let disposeBag = DisposeBag()

	private var zones = [Zone]()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.createBinding()

		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(self.refreshZones), for: .valueChanged)
		self.refreshControl = refreshControl
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.viewModel.refreshZones()
	}

	func createBinding() {
		self.viewModel.zones.drive(onNext: { [weak self] (zones) in
			self?.zones = zones
			self?.refreshControl?.endRefreshing()
			self?.tableView.reloadData()
		})
		.disposed(by: self.disposeBag)
	}

	@IBAction private func refreshZones() {
		self.viewModel.refreshZones()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.zones.isEmpty ? 0 : 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.zones.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.zoneCell.identifier, for: indexPath) as? ZoneTableViewCell else {
			return UITableViewCell()
		}

		cell.layout(for: self.zones[indexPath.row])
		return cell
	}
}
