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
	static var shared = CloudManager(batchUpdates: true)
	
	init(batchUpdates: Bool = false) {
		if batchUpdates {
			//Batch send groups of updates every 15 seconds
			//TODO: Make this time a little longer
			//TODO: Build mechanism to finish pushing before exiting app
			timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(processBatch), userInfo: nil, repeats: true)
		}
	}
	
	deinit {
		timer?.invalidate()
	}
	
	//Mark Grouped Operations
	
	private var timer: Timer?
	
	private var db = CKContainer.default().privateCloudDatabase
	private var recordsToSave = [CKRecord]()
	private var recordsToDelete = [CKRecord]()
	
	func addRecordToSave(record: CKRecord, instantSave: Bool = false) {
		recordsToSave.removeAll { $0.recordID == record.recordID }
		
		recordsToSave.append(record)
		
		if instantSave {
			processBatch()
		}
	}
	
	func addRecordToDelete(record: CKRecord, instantDelete: Bool = false) {
		recordsToDelete.append(record)
	}
	
	@objc private func processBatch() {
		if !recordsToDelete.isEmpty || !recordsToSave.isEmpty {
			let _ = process()
		}
	}
	
	private func process() -> CurrentValueSubject<CloudUpdateResponse, Error> {
		let publisher = CurrentValueSubject<CloudUpdateResponse,Error>(CloudUpdateResponse())
		
		let op = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordsToDelete.map { $0.recordID })
		
		//Remove batch of updates
		recordsToDelete.removeAll()
		recordsToSave.removeAll()
		
		op.modifyRecordsCompletionBlock = { (saved, deleted, error) in
			let _ = publisher.send(CloudUpdateResponse(error: error, complete: true, record: nil))
			
			let _ = publisher.send(completion: .finished)
		}
		
		db.add(op)
		
		return publisher
	}
	
	//Single Operations
	
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
		
		//For updates you may need to use fetchRecordWithID before updating
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
