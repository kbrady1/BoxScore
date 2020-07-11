//
//  AddPlayerViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit
import Combine

struct AddPlayerRequest: SaveRequest {
	var recordModel: RecordModel
	var database = CKContainer.default().privateCloudDatabase
	var zone: CKRecordZone.ID? = nil
}

struct DeletePlayerRequest: DeleteRequest {
	var database = CKContainer.default().privateCloudDatabase
	var zone: CKRecordZone.ID? = nil
	var recordId: CKRecord.ID
}

class AddPlayerViewModel: NetworkWriteViewModel, ObservableObject {
	typealias CloudResource = CloudUpdateResponse
	
	var loadable: Loadable<CloudResource> = .loading
	var manager: CloudManager = CloudManager()
	var saveRequest: SaveRequest
	var deleteRequest: DeleteRequest
	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
	
	var player: Player
	var record: RecordModel
	
	init(player: Player) {
		self.player = player
		self.record = player
		
		saveRequest = AddPlayerRequest(recordModel: player)
		deleteRequest = DeletePlayerRequest(recordId: CKRecord.ID(recordName: player.id))
	}
	
	func beginSave() {
		save(request: saveRequest)
	}
	
	func beginDelete() {
		delete(request: deleteRequest)
	}
}
