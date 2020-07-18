//
//  LeagueViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine
import CloudKit
import CoreData

struct AllTeamsRequest: FetchRequest2 {
	var database = CKContainer.default().privateCloudDatabase
	var query = CKQuery(recordType: TeamSchema.TYPE, predicate: NSPredicate(value: true))
	var zone: CKRecordZone.ID? = nil
	
	init() {
		query.sortDescriptors?.append(NSSortDescriptor(key: TeamSchema.NAME, ascending: false))
	}
}

class LeagueViewModel: ObservableObject {
	var loadable: Loadable<League> = .loading
	
	func fetch() {
		do {
			//Create two teams
			let request = NSFetchRequest<TeamCD>()
			request.entity = TeamCD.entity()
			
			let seasons = try AppDelegate.instance.persistentContainer.viewContext.fetch(request)
				.map { try Team(model: $0) }
				.map { Season(team: $0) }
			
			loadable = .success(League(seasons: seasons))
		} catch {
			print(error)
			loadable = .error(DisplayableError())
		}
		objectWillChange.send()
	}
}
