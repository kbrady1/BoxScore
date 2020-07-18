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
import Combine

class Team: ObservableObject {
	init(name: String, primaryColor: Color, secondaryColor: Color, model: TeamCD, id: UUID, players: [Player]) {
		self.name = name
		self.primaryColor = primaryColor
		self.secondaryColor = secondaryColor
		self.model = model
		self.id = id.uuidString
		self.players = players
		
		//Set initial values on model
		self.model.name = self.name
		self.model.primaryColor = primaryColor.stringRepresentation
		self.model.secondaryColor = secondaryColor.stringRepresentation
		self.model.id = id
		self.model.players = NSSet(array: players.map { $0.model })
	}
	
	static func createNewRecord() -> Team {
		let team = Team(name: "",
					primaryColor: .brandBlue,
					secondaryColor: .brandBeige,
					model: TeamCD(context: AppDelegate.context),
					id: UUID(),
					players: []
		)
		
		AppDelegate.instance.saveContext()
		
		return team
	}
	
	convenience init(model: TeamCD) throws {
		guard let name = model.name,
			let primaryColor = model.primaryColor,
			let secondaryColor = model.secondaryColor,
			let id = model.id else {
				throw BoxScoreError.invalidModelError()
			}
		
		self.init(name: name,
				  primaryColor: try Color(primaryColor),
				  secondaryColor: try Color(secondaryColor),
				  model: model,
				  id: id,
				  players: try model.players?.allObjects.compactMap { $0 as? PlayerCD }.map { try Player(model: $0) } ?? []
		)
	}
	
	let model: TeamCD
	let id: String
	
	@Published var name: String {
		didSet {
			model.name = name
			AppDelegate.instance.saveContext()
		}
	}
	@Published var primaryColor: Color {
		didSet {
			model.primaryColor = primaryColor.stringRepresentation
			AppDelegate.instance.saveContext()
		}
	}
	@Published var secondaryColor: Color {
		didSet {
			model.secondaryColor = secondaryColor.stringRepresentation
			AppDelegate.instance.saveContext()
		}
	}
	
	@Published var players: [Player] {
		didSet {
			model.players = NSSet(array: players.map { $0.model })
			AppDelegate.instance.saveContext()
		}
	}
	
	func addPlayer(_ player: Player) {
		if !players.contains(player) {
			players.append(player)
		}
	}
	
	func delete(player: Player) {
		players.removeAll { player == $0 }
		objectWillChange.send()
		
		AppDelegate.context.delete(player.model)
	}
}

extension Color {
	typealias ColorComponents = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
	typealias HueSatBrightAlphaComponents = (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)
	
	static var brandBlue: Color {
		Color(components: (r: 0.50688, g: 0.667794, b: 0.768, a: 1.0))
	}
	
	static var brandBeige: Color {
		Color(components: (r: 0.624, g: 0.639, b: 0.529, a: 1.0))
	}
	
	var stringRepresentation: String {
		self.toRGBList.map { "\($0)" }.joined(separator: "-")
	}
	var toRGBList: [Double] {
		let components = self.components()
		return [components.r, components.g, components.b, components.a].map { Double($0) }
	}
	
	init(_ string: String) throws {
		let list = string.split(separator: "-").compactMap { Double($0) }.map { CGFloat($0) }
		guard list.count == 4 else { throw BoxScoreError.invalidModelError() }
		
		self.init(components: (list[0], list[1], list[2], list[3]))
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
