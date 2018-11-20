//
//  TabBarController.swift
//  tzp-Demo
//
//  Created by Konstantin Deichmann on 20.11.18.
//  Copyright © 2018 kondeichmann. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

	override func viewDidLoad() {
		super.viewDidLoad()

		self.viewControllers?[0].tabBarItem.image = R.image.ic_map()
		self.viewControllers?[1].tabBarItem.image = R.image.ic_pencil()
	}
}
