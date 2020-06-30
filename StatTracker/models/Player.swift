//
//  Player.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import Foundation

class Player: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable, Identifiable {
	
	init(lastName: String, firstName: String, number: Int) {
		self.lastName = lastName
		self.firstName = firstName
		self.number = number
	}
	
	var lastName: String
	var firstName: String
	var number: Int
	
	var nameFirstLast: String { [firstName, lastName].joined(separator: " ") }
	var nameLastFirst: String { [lastName, firstName].joined(separator: " ") }
	
	//MARK: Codable Methods
	
	func encode(with coder: NSCoder) {
		coder.encode(lastName, forKey: "last")
		coder.encode(firstName, forKey: "first")
		coder.encode(number, forKey: "number")
	}
	
	required init?(coder: NSCoder) {
		guard let num = coder.decodeObject(forKey: "number") as? Int,
			let firstName = coder.decodeObject(forKey: "first") as? String,
			let lastName = coder.decodeObject(forKey: "last") as? String else { return nil }
		
		self.number = num
		self.firstName = firstName
		self.lastName = lastName
	}
	
	//MARK: Equatable
	
	override func isEqual(_ object: Any?) -> Bool {
		guard let object = object as? Player else { return false }
		
		return lastName == object.lastName &&
			firstName == object.firstName &&
			number == object.number
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