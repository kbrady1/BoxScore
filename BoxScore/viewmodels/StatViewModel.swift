//
//  GameStatViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit
import Combine

struct StatsRequest: FetchRequest {
	var database = CKContainer.default().privateCloudDatabase
	var query: CKQuery
	var zone: CKRecordZone.ID? = nil
	
	var referenceId: String
	
	init(referenceId: String, type: StatViewModelType) {
		var key = ""
		switch type {
		case .game:
			key = StatSchema.GAME_ID
		case .team:
			key = StatSchema.TEAM_ID
		case .player:
			key = StatSchema.PLAYER_ID
		}
		self.referenceId = referenceId
		let recordToMatch = CKRecord.Reference(recordID: CKRecord.ID(recordName: referenceId), action: .deleteSelf)
		self.query = CKQuery(recordType: StatSchema.TYPE,
							 predicate: NSPredicate(format: "\(key) == %@", recordToMatch))
	}
}

class StatGroup: CloudCreatable {
	var stats = [StatType: [Stat]]()
	
	required init(records: [CKRecord]) throws {
		StatType.all.forEach { stats[$0] = [] }
		
		try records.forEach {
			let stat = try Stat(record: $0)
			
			stats[stat.type]?.append(stat)
		}
	}
}

enum StatViewModelType {
	case team, game, player
}

class StatViewModel: NetworkReadViewModel, ObservableObject {
	typealias CloudResource = StatGroup
	
	var loadable: Loadable<CloudResource> = .loading
	var manager: CloudManager = CloudManager()
	var request: FetchRequest
	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
	
	var id: String?
	
	///One of these must not be nil
	init(id: String, type: StatViewModelType) {
		self.id = id
		
		self.request = StatsRequest(referenceId: id, type: type)
	}
}
