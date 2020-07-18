//
//  GameViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/16/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit
import Combine

//struct AddGameRequest: SaveRequest {
//	var recordModel: RecordModel
//	var database = CKContainer.default().privateCloudDatabase
//	var zone: CKRecordZone.ID? = nil
//}
//
//struct DeleteGameRequest: DeleteRequest {
//	var database = CKContainer.default().privateCloudDatabase
//	var zone: CKRecordZone.ID? = nil
//	var recordId: CKRecord.ID
//}
//
//class EditGameViewModel: NetworkWriteViewModel {
//	typealias CloudResource = CloudUpdateResponse
//	
//	var loadable: Loadable<CloudResource> = .loading
//	var manager: CloudManager = CloudManager()
//	var saveRequest: SaveRequest
//	var deleteRequest: DeleteRequest
//	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
//	
//	var game: Game
//	var record: RecordModel
//	
//	init(game: Game) {
//		self.game = game
//		
//		saveRequest = AddGameRequest(recordModel: record)
//		deleteRequest = DeleteGameRequest(recordId: record.record.recordID)
//	}
//	
//	func beginSave() {
//		save(request: saveRequest)
//	}
//	
//	func beginDelete() {
//		delete(request: deleteRequest)
//	}
//}

