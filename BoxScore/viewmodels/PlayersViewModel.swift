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
import CoreData

struct TeamPlayersRequest: FetchRequest2 {
	var database = CKContainer.default().privateCloudDatabase
	var query: CKQuery
	var zone: CKRecordZone.ID? = CKRecordZone.default().zoneID
	
	var teamId: String
	
	init(teamId: String) {
		self.teamId = teamId
		let recordToMatch = CKRecord.Reference(recordID: CKRecord.ID(recordName: teamId), action: .deleteSelf)
		query = CKQuery(recordType: PlayerSchema.TYPE,
						predicate: NSPredicate(format: "\(PlayerSchema.TEAM_ID_REF) == %@", recordToMatch))
		query.sortDescriptors?.append(NSSortDescriptor(key: PlayerSchema.LAST_NAME, ascending: false))
	}
}

class TeamPlayers: CloudCreatable {
	var players: [Player]
	
	init(players: [Player]) {
		self.players = players
	}
	
	required init(records: [CKRecord]) throws {
		self.players = []
	}
}

class PlayersViewModel: NetworkReadViewModel, ObservableObject {
	typealias CloudResource = TeamPlayers

	var loadable: Loadable<CloudResource> = .loading
	var manager: CloudManager = CloudManager()
	var request: FetchRequest2
	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
	
	var skipCall = false
	
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

class PlayersViewModel2: ObservableObject {
	var loadable: Loadable<[Player]> = .loading
	
	var team: TeamCD
	init(team: TeamCD) {
		self.team = team
	}
	
	func fetch() {
		do {
			let request = NSFetchRequest<PlayerCD>()
			request.entity = PlayerCD.entity()
			request.predicate = NSPredicate(format: "teamId == %@", team)
			
			let players = try AppDelegate.instance.persistentContainer.viewContext.fetch(request)
				.map { try Player(model: $0) }
			
			loadable = .success(players)
		} catch {
			loadable = .error(DisplayableError())
		}
		objectWillChange.send()
	}
}

class SeasonViewModel2: ObservableObject {
	var loadable: Loadable<Season> = .loading
	
	var team: Team
	
	init(team: Team) {
		self.team = team
	}
	
	func fetch() {
		do {
			let predicate = NSPredicate(format: "team == %@", team.model)
			let playersRequest = NSFetchRequest<PlayerCD>()
			playersRequest.entity = PlayerCD.entity()
			playersRequest.predicate = predicate
			
			//TODO: Test, I think that players will come with the team
//			let players = try AppDelegate.instance.persistentContainer.viewContext.fetch(playersRequest)
//				.map { try Player(player: $0) }
			
//			let gamesRequest = NSFetchRequest<GameCD>()
//			gamesRequest.entity = GameCD.entity()
//			gamesRequest.predicate = predicate
//			
//			let games = try AppDelegate.instance.persistentContainer.viewContext.fetch(gamesRequest)
//				.map { try Game(model: $0) }
//			
//			
//			loadable = .success(Season(team: team, currentGame: currentGame, previousGames: previousGames))
		} catch {
			loadable = .error(DisplayableError())
		}
		objectWillChange.send()
	}
}
