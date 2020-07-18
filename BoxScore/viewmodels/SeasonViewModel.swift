//
//  SeasonViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit
import Combine
import CoreData

struct GamesForTeamRequest: FetchRequest2 {
	var database = CKContainer.default().privateCloudDatabase
	var query: CKQuery
	var zone: CKRecordZone.ID? = nil
	
	var teamId: String
	
	init(teamId: String) {
		self.teamId = teamId
		let recordToMatch = CKRecord.Reference(recordID: CKRecord.ID(recordName: teamId), action: .deleteSelf)
		self.query = CKQuery(recordType: GameSchema.TYPE,
							 predicate: NSPredicate(format: "\(GameSchema.TEAM) == %@", recordToMatch))
		query.sortDescriptors?.append(NSSortDescriptor(key: GameSchema.DATE, ascending: true))
	}
}

class TeamGames: CloudCreatable {
	var games: [Game]
	
	init(games: [Game]) {
		self.games = games
	}
	
	required init(records: [CKRecord]) throws {
		self.games = try records.map { try Game(record: $0) }
	}
}

class SeasonViewModel: NetworkReadViewModel, ObservableObject {
	typealias CloudResource = TeamGames

	var loadable: Loadable<CloudResource> = .loading
	var manager: CloudManager = CloudManager()
	var request: FetchRequest2
	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
	
	var skipCall: Bool = false
	
	var teamId: String
	
	init(teamId: String) {
		self.teamId = teamId
		self.request = GamesForTeamRequest(teamId: teamId)
	}
	
	func update(teamId: String) {
		self.loadable = .loading
		self.teamId = teamId
		self.request = GamesForTeamRequest(teamId: teamId)
		self.objectWillChange.send()
		
		self.fetch(request: request)
	}
}
