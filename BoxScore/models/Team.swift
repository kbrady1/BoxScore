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
