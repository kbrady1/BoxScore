//
//  LeagueViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine
import CoreData

class LeagueViewModel: ObservableObject {
	var loadable: Loadable<League> = .loading
	
	init() {
		//Register for remote notifications when store updates via cloudkit
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(fetchChanges),
			name: NSNotification.Name(
				rawValue: "NSPersistentStoreRemoteChangeNotification"),
			object: AppDelegate.instance.persistentContainer.persistentStoreCoordinator
		)
	}
	
	func fetchOnCloudUpdate() {
		loadable = .loading
	}
	
	func fetch() {
		do {
			//Create two teams
			let request = NSFetchRequest<TeamCD>()
			request.entity = TeamCD.entity()
			
			let models = try AppDelegate.context.fetch(request)
			
			if let league = loadable.value {
				try league.applyChanges(models: models)
			} else {
				let seasons = try models.map { try Season(model: $0) }
				
				//This prevents new teams from being created unneccessarily
				if seasons.count > 0 {
					loadable = .success(League(seasons: seasons))
					objectWillChange.send()
				}
			}
		} catch {
			loadable = .error(DisplayableError())
			objectWillChange.send()
		}
	}
	
	@objc func fetchChanges() {
		DispatchQueue.main.async {
			self.fetch()
		}
	}
}
