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

struct AllTeamsRequest: FetchRequest {
	var database = CKContainer.default().privateCloudDatabase
	var query = CKQuery(recordType: TeamSchema.TYPE, predicate: NSPredicate(value: true))
	var zone: CKRecordZone.ID? = nil
	
	init() {
		query.sortDescriptors?.append(NSSortDescriptor(key: TeamSchema.NAME, ascending: false))
	}
}

class LeagueViewModel: NetworkReadViewModel, ObservableObject {
	typealias CloudResource = League
	
	var loadable: Loadable<CloudResource> = .loading
	var manager: CloudManager = CloudManager()
	var request: FetchRequest = AllTeamsRequest()
	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
	
	var skipCall: Bool = false
}
