//
//  Player.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

struct SavePlayerRequest: SaveRequest {
	var recordModel: RecordModel
	var database = CKContainer.default().privateCloudDatabase
	var zone: CKRecordZone.ID? = nil
}

class Player: Identifiable, Equatable, ObservableObject {
	
	private init(lastName: String, firstName: String, number: Int, model: PlayerCD, id: String) {
		self.lastName = lastName
		self.firstName = firstName
		self.number = number
		self.model = model
		self.id = id
	}
	
	//This is for creating players in the app
	convenience init(lastName: String, firstName: String, number: Int, team: Team) {
		let id = UUID()
		let model = PlayerCD(context: AppDelegate.context)
		model.firstName = firstName
		model.lastName = lastName
		model.team = team.model
		model.number = Int16(number)
		model.id = id
		
		AppDelegate.instance.saveContext()
		
		self.init(lastName: lastName,
				  firstName: firstName,
				  number: number,
				  model: model,
				  id: id.uuidString
		)
	}
	
	convenience init(model: PlayerCD) throws {
		guard let firstName = model.firstName,
			let lastName = model.lastName,
			let id = model.id else {
				throw BoxScoreError.invalidModelError()
		}
		
		self.init(lastName: lastName, firstName: firstName, number: Int(model.number), model: model, id: id.uuidString)
	}
	
	let model: PlayerCD
	let id: String
	
	@Published var lastName: String {
		didSet {
			model.lastName = lastName
			AppDelegate.instance.saveContext()
		}
	}
	
	@Published var firstName: String {
		didSet {
			model.firstName = firstName
			AppDelegate.instance.saveContext()
		}
	}
	@Published var number: Int {
		didSet {
			model.number = Int16(number)
			AppDelegate.instance.saveContext()
		}
	}
	
	var nameFirstLast: String { [firstName, lastName].joined(separator: " ") }
	var nameLastFirst: String { [lastName, firstName].joined(separator: ", ") }
	
	var draggableReference: DraggablePlayerReference {
		DraggablePlayerReference(id: id)
	}
	
	//MARK: Equatable
	
	static func == (lhs: Player, rhs: Player) -> Bool {
		return lhs.id == rhs.id
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
