//
//  Player.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit

struct SavePlayerRequest: SaveRequest {
	var recordModel: RecordModel
	var database = CKContainer.default().privateCloudDatabase
	var zone: CKRecordZone.ID? = nil
}

class Player: Identifiable, RecordModel, Equatable {
	
	//TODO: Remove defaults
	private init(lastName: String, firstName: String, number: Int, record: CKRecord) {
		self.lastName = lastName
		self.firstName = firstName
		self.number = number
		self.record = record
	}
	
	//This is for creating players in the app
	convenience init(lastName: String, firstName: String, number: Int, teamId: String) {
		let record = CKRecord(recordType: PlayerSchema.TYPE)
		record.setValue(CKRecord.Reference(recordID: CKRecord.ID(recordName: teamId), action: .deleteSelf), forKey: PlayerSchema.TEAM_ID_REF)
		
		self.init(lastName: lastName,
				  firstName: firstName,
				  number: number,
				  record: record)
	}
	
	required convenience init(record: CKRecord) throws {
		guard let firstName = record.value(forKey: PlayerSchema.FIRST_NAME) as? String,
			let lastName = record.value(forKey: PlayerSchema.LAST_NAME) as? String,
			let number = record.value(forKey: PlayerSchema.NUMBER) as? Int else {
				throw BoxScoreError.invalidModelError()
		}
		
		self.init(lastName: lastName,
				  firstName: firstName,
				  number: number,
				  record: record)
	}
	
	var lastName: String
	var firstName: String
	var number: Int
	var record: CKRecord
	
	var nameFirstLast: String { [firstName, lastName].joined(separator: " ") }
	var nameLastFirst: String { [lastName, firstName].joined(separator: ", ") }
	var id: String { record.recordID.recordName }
	
	var draggableReference: DraggablePlayerReference {
		DraggablePlayerReference(id: id)
	}
	
	//MARK: Equatable
	
	static func == (lhs: Player, rhs: Player) -> Bool {
		return lhs.id == rhs.id
	}
	
	//MARK: RecordModel Methods
	
	func recordToSave() -> CKRecord {
		record.setValue(firstName, forKey: PlayerSchema.FIRST_NAME)
		record.setValue(lastName, forKey: PlayerSchema.LAST_NAME)
		record.setValue(number, forKey: PlayerSchema.NUMBER)
		
		return record
	}
	
}

//Use this in the drag and drop view

class DraggablePlayerReference: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
	var id: String
	
	init(id: String) {
		self.id = id
	}
	
	//MARK: Codable Methods
	
	func encode(with coder: NSCoder) {
		coder.encode(id, forKey: "id")
	}
	
	required init?(coder: NSCoder) {
		guard let id = coder.decodeObject(forKey: "id") as? String else { return nil }
		
		self.id = id
	}
	
	//MARK: NSItemProvider Methods
	
	static var writableTypeIdentifiersForItemProvider: [String] = ["player"]
	
	func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
		let progress = Progress(totalUnitCount: 100)
		do {
			let data = try JSONEncoder().encode(self)
			progress.completedUnitCount = 100
			
			completionHandler(data, nil)
		} catch {
			completionHandler(nil, error)
		}
		
		return progress
	}
	
	static var readableTypeIdentifiersForItemProvider: [String] = ["player"]
	
	static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
		return try JSONDecoder().decode(self, from: data)
	}
}
