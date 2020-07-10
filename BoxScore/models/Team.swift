//
//  Team.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import Foundation
import UIKit.UIColor
import SwiftUI
import CloudKit

class Team: ObservableObject {
	init(id: String = UUID().uuidString, name: String, primaryColor: Color, secondaryColor: Color) {
		self.id = id
		self.name = name
		self.primaryColor = primaryColor
		self.secondaryColor = secondaryColor
	}
	
	convenience init() {
		self.init(id: UUID().uuidString,
				  name: "",
				  primaryColor: .blue,
				  secondaryColor: .red)
	}
	
	convenience init(record: CKRecord) throws {
		guard let name = record.value(forKey: "name") as? String else {
			throw BoxScoreError.invalidModelError()
		}
		
		//TODO: Add colors
		self.init(id: record.recordID.recordName,
				  name: name,
				  primaryColor: .blue,
				  secondaryColor: .red)
	}
	
	let id: String
	@Published var name: String
	@Published var primaryColor: Color
	@Published var secondaryColor: Color
	
	var players = [Player]()
	
	func addPlayer(_ player: Player) {
		players.append(player)
	}
	
	static var testData: Team {
		let team = Team(name: "Chicago Bulls", primaryColor: .bullsRed, secondaryColor:.bullsGray )
		team.addPlayer(Player(lastName: "Kukoc", firstName: "Toni", number: 7))
		team.addPlayer(Player(lastName: "Pippen", firstName: "Scottie", number: 33))
		team.addPlayer(Player(lastName: "Longley", firstName: "Luc", number: 13))
		team.addPlayer(Player(lastName: "Jordan", firstName: "Michael", number: 23))
		team.addPlayer(Player(lastName: "Harper", firstName: "Ron", number: 9))
		team.addPlayer(Player(lastName: "Rodman", firstName: "Dennis", number: 91))
		team.addPlayer(Player(lastName: "Kerr", firstName: "Steve", number: 25))
		team.addPlayer(Player(lastName: "Burrell", firstName: "Scott", number: 24))
		team.addPlayer(Player(lastName: "Buechler", firstName: "Jud", number: 30))
		team.addPlayer(Player(lastName: "Wennington", firstName: "Bill", number: 34))
		team.addPlayer(Player(lastName: "Brown", firstName: "Randy", number: 1))
		team.addPlayer(Player(lastName: "Simpkins", firstName: "Dickey", number: 8))
		
		return team
	}
}

extension Color {
	static var bullsRed: Color {
		Color(UIColor(red: 150/255.0, green: 30/255.0, blue: 51/255.0, alpha: 1.0))
	}
	
	static var bullsGray: Color {
		Color(UIColor(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1.0))
	}
}

extension Team {
	var kukoc: [Stat] {
		[
			Stat.nShots(for: self.players[0], n: 6, make: true, points: 2),
			Stat.nShots(for: self.players[0], n: 6, make: false, points: 2),
			Stat.nShots(for: self.players[0], n: 1, make: true, points: 3),
			Stat.nShots(for: self.players[0], n: 1, make: false, points: 3),
			Stat.nRebounds(for: self.players[0], n: 3, offensive: false),
			Stat.nStats(for: self.players[0], n: 4, ofType: .assist),
			Stat.nStats(for: self.players[0], n: 3, ofType: .foul)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}

	var pippen: [Stat] {
		[
			Stat.nShots(for: self.players[1], n: 4, make: true, points: 2),
			Stat.nShots(for: self.players[1], n: 3, make: false, points: 2),
			Stat.nRebounds(for: self.players[1], n: 3, offensive: false),
			Stat.nStats(for: self.players[1], n: 4, ofType: .assist),
			Stat.nStats(for: self.players[1], n: 2, ofType: .foul),
			Stat.nStats(for: self.players[1], n: 2, ofType: .steal),
			Stat.nStats(for: self.players[1], n: 1, ofType: .block),
			Stat.nStats(for: self.players[1], n: 2, ofType: .turnover)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}

	var longley: [Stat] {
		[
			Stat.nShots(for: self.players[2], n: 1, make: false, points: 2),
			Stat.nRebounds(for: self.players[2], n: 2, offensive: false),
			Stat.nStats(for: self.players[2], n: 4, ofType: .foul),
			Stat.nStats(for: self.players[2], n: 1, ofType: .steal)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}
	
	var jordan: [Stat] {
		[
			Stat.nShots(for: self.players[3], n: 12, make: true, points: 2),
			Stat.nShots(for: self.players[3], n: 16, make: false, points: 2),
			Stat.nShots(for: self.players[3], n: 3, make: true, points: 3),
			Stat.nShots(for: self.players[3], n: 4, make: false, points: 3),
			Stat.nShots(for: self.players[3], n: 12, make: true, points: 1),
			Stat.nShots(for: self.players[3], n: 3, make: false, points: 1),
			Stat.nRebounds(for: self.players[3], n: 1, offensive: false),
			Stat.nStats(for: self.players[3], n: 1, ofType: .assist),
			Stat.nStats(for: self.players[3], n: 2, ofType: .foul),
			Stat.nStats(for: self.players[3], n: 4, ofType: .steal),
			Stat.nStats(for: self.players[3], n: 1, ofType: .turnover)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}
	
	var harper: [Stat] {
		[
			Stat.nShots(for: self.players[4], n: 3, make: true, points: 2),
			Stat.nShots(for: self.players[4], n: 1, make: false, points: 3),
			Stat.nShots(for: self.players[4], n: 2, make: true, points: 1),
			Stat.nRebounds(for: self.players[4], n: 3, offensive: false),
			Stat.nStats(for: self.players[4], n: 3, ofType: .assist),
			Stat.nStats(for: self.players[4], n: 2, ofType: .foul),
			Stat.nStats(for: self.players[4], n: 1, ofType: .steal),
			Stat.nStats(for: self.players[4], n: 2, ofType: .block),
			Stat.nStats(for: self.players[4], n: 1, ofType: .turnover)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}
	
	var rodman: [Stat] {
		[
			Stat.nShots(for: self.players[5], n: 3, make: true, points: 2),
			Stat.nShots(for: self.players[5], n: 1, make: true, points: 1),
			Stat.nShots(for: self.players[5], n: 0, make: false, points: 1),
			Stat.nRebounds(for: self.players[5], n: 4, offensive: false),
			Stat.nRebounds(for: self.players[5], n: 4, offensive: true),
			Stat.nStats(for: self.players[5], n: 1, ofType: .assist),
			Stat.nStats(for: self.players[5], n: 5, ofType: .foul),
			Stat.nStats(for: self.players[5], n: 2, ofType: .steal),
			Stat.nStats(for: self.players[5], n: 1, ofType: .block),
			Stat.nStats(for: self.players[5], n: 2, ofType: .turnover)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}
	
	var kerr: [Stat] {
		[
			Stat.nStats(for: self.players[6], n: 3, ofType: .assist),
			Stat.nStats(for: self.players[6], n: 3, ofType: .foul),
			Stat.nStats(for: self.players[6], n: 1, ofType: .steal),
			Stat.nStats(for: self.players[6], n: 1, ofType: .turnover)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}

	var burrell: [Stat] {
		[
			Stat.nShots(for: self.players[7], n: 1, make: false, points: 2)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}
	
	var buechler: [Stat] {
		[
			Stat.nShots(for: self.players[8], n: 1, make: true, points: 2),
			Stat.nStats(for: self.players[8], n: 1, ofType: .foul),
			Stat.nRebounds(for: self.players[8], n: 1, offensive: true),
			Stat.nRebounds(for: self.players[8], n: 1, offensive: false),
			Stat.nStats(for: self.players[8], n: 1, ofType: .assist),
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}
	
	var wennington: [Stat] {
		[
			Stat.nShots(for: self.players[9], n: 1, make: true, points: 2),
			Stat.nStats(for: self.players[9], n: 1, ofType: .foul),
			Stat.nStats(for: self.players[9], n: 2, ofType: .turnover)
		].reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
	}
}
