//
//  Team.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import UIKit.UIColor
import SwiftUI
import CloudKit

class Team: ObservableObject, RecordModel {
	init(name: String, primaryColor: Color, secondaryColor: Color, record: CKRecord = CKRecord(recordType: TeamSchema.TYPE)) {
		self.name = name
		self.primaryColor = primaryColor
		self.secondaryColor = secondaryColor
		self.record = record
	}
	
	static func createNewRecord() -> Team {
		let team = Team()
		CloudManager.shared.addRecordToSave(record: team.record, instantSave: true)
		
		return team
	}
	
	convenience init() {
		self.init(name: "",
				  primaryColor: .blue,
				  secondaryColor: .red)
	}
	
	required convenience init(record: CKRecord) throws {
		guard let name = record.value(forKey: TeamSchema.NAME) as? String,
			let primaryColorList = record.value(forKey: TeamSchema.PRIMARY_COLOR) as? [Double],
			let secondaryColorList = record.value(forKey: TeamSchema.SECONDARY_COLOR) as? [Double],
			primaryColorList.count == 4,
			secondaryColorList.count == 4 else {
			throw BoxScoreError.invalidModelError()
		}
		
		self.init(name: name,
				  primaryColor: try Color(doubleList: primaryColorList),
				  secondaryColor: try Color(doubleList: secondaryColorList),
				  record: record)
	}
	
	var id: String { record.recordID.recordName }
	var record: CKRecord
	@Published var name: String {
		didSet {
			CloudManager.shared.addRecordToSave(record: recordToSave())
		}
	}
	@Published var primaryColor: Color {
		didSet {
			CloudManager.shared.addRecordToSave(record: recordToSave())
		}
	}
	@Published var secondaryColor: Color {
		didSet {
			CloudManager.shared.addRecordToSave(record: recordToSave())
		}
	}
	
	@Published var players = [Player]()
	
	func addPlayer(_ player: Player) {
		if !players.contains(player) {
			players.append(player)
		}
	}
	
	//MARK: RecordModel
	
	func recordToSave() -> CKRecord {
		record.setValue(name, forKey: TeamSchema.NAME)
		record.setValue(primaryColor.toRGBList, forKey: TeamSchema.PRIMARY_COLOR)
		record.setValue(secondaryColor.toRGBList, forKey: TeamSchema.SECONDARY_COLOR)
		
		return record
	}
}

extension Color {
	typealias ColorComponents = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
	typealias HueSatBrightAlphaComponents = (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)
	
	var toRGBList: [Double] {
		let components = self.components()
		return [components.r, components.g, components.b, components.a].map { Double($0) }
	}
	
	init(doubleList: [Double]) throws {
		let list = doubleList.map { CGFloat($0) }
		guard list.count == 4 else { throw BoxScoreError.invalidModelError() }
		
		self.init(components: (list[0], list[1], list[2], list[3]))
	}
	
	init(components: ColorComponents) {
		self.init(UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a))
	}
	
	func withSaturation(_ saturation: CGFloat) -> Color {
		let components = self.hueSatBrightAlpha()
		return Color(hue: Double(components.h),
					 saturation: Double(saturation),
					 brightness: Double(components.b),
					 opacity: Double(components.a))
	}
	
	private var uiColor: UIColor {
		let components = self.components()
		return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
	}
	
	func hueSatBrightAlpha() -> HueSatBrightAlphaComponents {
		let color = self.uiColor
		var hue: CGFloat = 0.0
		var saturation: CGFloat = 0.0
		var brightness: CGFloat = 0.0
		var alpha: CGFloat = 0.0
		
		color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		
		return HueSatBrightAlphaComponents(h: hue, s: saturation, b: brightness, a: alpha)
	}
	
	private func components() -> ColorComponents {
		let numbers = self.description
			.split(separator: " ")
			.compactMap { Double($0) }
			.compactMap { CGFloat($0) }
		
		var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
		numbers.enumerated().forEach {
			switch $0.offset {
			case 0:
				r = $0.element
			case 1:
				g = $0.element
			case 2:
				b = $0.element
			case 3:
				a = $0.element
			default:
				break
			}
		}
		
        return (r, g, b, a)
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
	static var testData: Team {
		let team = Team(name: "Chicago Bulls", primaryColor: .bullsRed, secondaryColor:.bullsGray )
		team.addPlayer(Player(lastName: "Kukoc", firstName: "Toni", number: 7, teamId: "1"))
		team.addPlayer(Player(lastName: "Pippen", firstName: "Scottie", number: 33, teamId: "1"))
		team.addPlayer(Player(lastName: "Longley", firstName: "Luc", number: 13, teamId: "1"))
		team.addPlayer(Player(lastName: "Jordan", firstName: "Michael", number: 23, teamId: "1"))
		team.addPlayer(Player(lastName: "Harper", firstName: "Ron", number: 9, teamId: "1"))
		team.addPlayer(Player(lastName: "Rodman", firstName: "Dennis", number: 91, teamId: "1"))
		team.addPlayer(Player(lastName: "Kerr", firstName: "Steve", number: 25, teamId: "1"))
		team.addPlayer(Player(lastName: "Burrell", firstName: "Scott", number: 24, teamId: "1"))
		team.addPlayer(Player(lastName: "Buechler", firstName: "Jud", number: 30, teamId: "1"))
		team.addPlayer(Player(lastName: "Wennington", firstName: "Bill", number: 34, teamId: "1"))
		team.addPlayer(Player(lastName: "Brown", firstName: "Randy", number: 1, teamId: "1"))
		team.addPlayer(Player(lastName: "Simpkins", firstName: "Dickey", number: 8, teamId: "1"))

		return team
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
