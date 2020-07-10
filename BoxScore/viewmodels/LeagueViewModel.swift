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

struct AllTeamsRequest: Request {
	var database = CKContainer.default().privateCloudDatabase
	var query = CKQuery(recordType: "Team", predicate: NSPredicate(value: true))
	var zone: CKRecordZone.ID? = nil
}

class LeagueViewModel: NetworkViewModel, ObservableObject {
	typealias CloudResource = League
	
	var loadable: Loadable<CloudResource> = .loading
	var manager: CloudManager = CloudManager()
	var request: Request = AllTeamsRequest()
	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
}
