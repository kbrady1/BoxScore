//
//  PlayersViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine
import CloudKit

struct TeamPlayersRequest: FetchRequest {
	var database = CKContainer.default().privateCloudDatabase
	var query: CKQuery
	var zone: CKRecordZone.ID? = CKRecordZone.default().zoneID
	
	var teamId: String
	
	init(teamId: String) {
		self.teamId = teamId
		let recordToMatch = CKRecord.Reference(recordID: CKRecord.ID(recordName: teamId), action: .deleteSelf)
		query = CKQuery(recordType: "Player",
		predicate: NSPredicate(format: "teamId == %@", recordToMatch))
	}
}

class TeamPlayers: CloudCreatable {
	var players = [Player]()
	
	init(players: [Player]) {
		self.players = players
	}
	
	required init(records: [CKRecord]) throws {
		self.players = try records.map { try Player(record: $0) }
	}
}

class PlayersViewModel: NetworkReadViewModel, ObservableObject {
	typealias CloudResource = TeamPlayers

	var loadable: Loadable<CloudResource> = .loading
	var manager: CloudManager = CloudManager()
	var request: FetchRequest
	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
	
	init(teamId: String) {
		self.request = TeamPlayersRequest(teamId: teamId)
	}
	
	//Investigate the latency of new records showing up
	func update(team: Team) {
		if let request = request as? TeamPlayersRequest,
			team.id == request.teamId {
			//If updating on the same team, just get the new players
			loadable = .success(TeamPlayers(players: team.players))
		} else {
			//If this update is with a new team, go get players for that new team
			loadable = .loading
			request = TeamPlayersRequest(teamId: team.id)
			fetch(request: request)
		}
		self.objectWillChange.send()
	}
}
