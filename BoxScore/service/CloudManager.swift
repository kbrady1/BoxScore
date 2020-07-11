//
//  CloudManager.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit
import Combine

protocol RecordModel {
	init(record: CKRecord) throws
	var record: CKRecord { get set }
	func recordToSave() -> CKRecord
}

protocol GenericCloudType {}

protocol CloudCreatable: GenericCloudType {
	init(records: [CKRecord]) throws
}

protocol CloudUpdated: GenericCloudType {
	var error: Error? { get set }
	var complete: Bool { get set }
	var record: CKRecord? { get set }
	
	init(error: Error?, complete: Bool, record: CKRecord?)
}

struct CloudUpdateResponse: CloudUpdated {
	var error: Error?
	var complete: Bool
	var record: CKRecord?
	
	init(error: Error? = nil, complete: Bool = false, record: CKRecord? = nil) {
		self.error = error
		self.complete = complete
		self.record = record
	}
}

struct CloudResponse {
	var records: [CKRecord]?
	var error: Error?
}

class CloudManager {
	func fetch(request: FetchRequest) -> CurrentValueSubject<CloudResponse, Error> {
		let publisher = CurrentValueSubject<CloudResponse,Error>(CloudResponse(records: nil, error: nil))
		
		request.database.perform(request.query, inZoneWith: request.zone) { (records, error) in
			let _ = publisher.send(CloudResponse(records: records, error: error))
			
			let _ = publisher.send(completion: .finished)
		}
		
		return publisher
	}
	
	func save(request: SaveRequest) -> CurrentValueSubject<CloudUpdateResponse, Error> {
		let publisher = CurrentValueSubject<CloudUpdateResponse,Error>(CloudUpdateResponse())
		
		//For updates you need to use fetchRecordWithID before updating
		
//		let op = CKModifyRecordsOperation(recordsToSave: [request.recordModel.recordToSave()])
//		op.savePolicy = .changedKeys
//		op.perRecordCompletionBlock = { (record, error) in
//			let _ = publisher.send(CloudUpdateResponse(error: error, complete: true, record: record))
//			
//			let _ = publisher.send(completion: .finished)
//		}
//		
//		request.database.add(op)
		
		request.database.save(request.recordModel.recordToSave()) { (record, error) in
			let _ = publisher.send(CloudUpdateResponse(error: error, complete: true, record: record))

			let _ = publisher.send(completion: .finished)
		}
		
		return publisher
	}
	
	func delete(request: DeleteRequest) -> CurrentValueSubject<CloudUpdateResponse, Error> {
		let publisher = CurrentValueSubject<CloudUpdateResponse,Error>(CloudUpdateResponse())
		
		request.database.delete(withRecordID: request.recordId) { (id, error) in
			let _ = publisher.send(CloudUpdateResponse(error: error, complete: true))
			
			let _ = publisher.send(completion: .finished)
		}
		
		return publisher
	}
}

struct DisplayableError {
	var error: Error?
	var title: String = "🏀 Shoot! 🏀"
	var readableMessage: String = "That wasn't supposed to happen... Please try again."
}

enum BoxScoreError: Error {
	case invalidModelError(message: String = "Server returned invalid information. Please try again")
	case requestFailed(error: Error, message: String = "That wasn't supposed to happen... Please try again.")
}
