//
//  League.swift
//  StatTracker
//
//  Created by Kent Brady on 7/9/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine
import CloudKit
import CoreData

private let SAVED_TEAM_KEY = "currentlySelectedTeamKey"

class League: ObservableObject, Equatable {
	
	@Published var seasons: [Season]
	@Published var currentSeason: Season {
		didSet {
			UserDefaults.standard.set(currentSeason.team.id, forKey: SAVED_TEAM_KEY)
		}
	}
	var id = UUID().uuidString
	
	var bag: Set<AnyCancellable> = Set<AnyCancellable>()
	
	init(seasons: [Season]) {
		self.seasons = seasons
		
		if let currentSeasonId = UserDefaults.standard.string(forKey: SAVED_TEAM_KEY),
			let season = seasons.first(where: { $0.team.id == currentSeasonId }) {
			self.currentSeason = season
		} else {
			self.currentSeason = seasons.first ?? Season(team: Team.createNewRecord())
			
			if seasons.isEmpty {
				self.seasons.append(currentSeason)
			}
		}
		
		//Observable objects don't publish changes when nested in another, so manually push up the changes
		bag.insert(currentSeason.objectWillChange.sink { (_) in
			self.objectWillChange.send()
		})
		seasons.map { $0.objectWillChange.sink { (_) in
			self.objectWillChange.send()
		} }.forEach {
			bag.insert($0)
		}
		
	}
	
	var teams: [Team] { seasons.map { $0.team }}
	
	func newTeam(setToCurrent: Bool = false) {
		let season = Season(team: Team.createNewRecord())
		
		if seasons.isEmpty || setToCurrent {
			currentSeason = season
		}
		
		seasons.append(season)
		
		AppDelegate.instance.saveContext()
	}
	
	func deleteTeam(_ team: Team) {
		seasons.removeAll { $0.team.id == team.id }
		AppDelegate.context.delete(team.model)
		
		//If the current season was deleted
		if !seasons.contains(where: { $0.team.id == currentSeason.team.id }) {
			if let nextInLine = seasons.first {
				currentSeason = nextInLine
			} else {
				newTeam()
			}
		}
		
		AppDelegate.instance.saveContext()
	}
	
	func deleteAll() {
		seasons.forEach {
			AppDelegate.context.delete($0.team.model)
		}
		seasons.removeAll()
		AppDelegate.context.delete(currentSeason.team.model)
		
		newTeam(setToCurrent: true)
	}
	
	func applyChanges(models: [TeamCD]) throws {
		try models.forEach { (model) in
			if !seasons.contains(where: { $0.team.model.objectID == model.objectID }) {
				//If this is a new season add it
				seasons.append(try Season(model: model))
				self.objectWillChange.send()
			}
		}
	}
	
	//MARK: Equatable
	
	static func == (lhs: League, rhs: League) -> Bool {
		lhs.id == rhs.id
	}
}
