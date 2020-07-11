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

private let SAVED_TEAM_KEY = "currentlySelectedTeamKey"

class League: ObservableObject, Equatable, CloudCreatable {
	
	@Published var seasons: [Season]
	@Published var currentSeason: Season {
		didSet {
			UserDefaults.standard.set(currentSeason.team.id, forKey: SAVED_TEAM_KEY)
		}
	}
	var id = UUID().uuidString
	
	var cancellable: AnyCancellable?
	
	//TODO: Save preferred team in user defaults and look up to populate
	init(seasons: [Season]) {
		self.seasons = seasons
		
		if let currentSeasonId = UserDefaults.standard.string(forKey: SAVED_TEAM_KEY),
			let season = seasons.first(where: { $0.team.id == currentSeasonId }) {
			self.currentSeason = season
		} else {
			self.currentSeason = seasons.first ?? Season(team: Team())
			
			if seasons.isEmpty {
				self.seasons.append(currentSeason)
			}
		}
		
		//Observable objects don't publish changes when nested in another, so manually push up the changes
		cancellable = currentSeason.objectWillChange.sink { (_) in
			self.objectWillChange.send()
		}
	}
	
	required convenience init(records: [CKRecord]) throws {
		self.init(seasons: try records.map { try Team(record: $0) }.map { Season(team: $0) })
	}
	
	var teams: [Team] { seasons.map { $0.team }}
	
	func newTeam() -> Team {
		let team = Team.createNewRecord()
		let season = Season(team: team)
		seasons.append(season)
		currentSeason = season
		
		return team
	}
	
	func deleteTeam(_ team: Team) {
		seasons.removeAll { $0.team.name == team.name }
		
		//If the current season was deleted
		if !seasons.contains(where: { $0.team.name == currentSeason.team.name }) {
			currentSeason = seasons.first ?? Season(team: Team.createNewRecord())
			
			if seasons.isEmpty {
				seasons.append(currentSeason)
			}
		}
	}
	
	func deleteAll() {
		seasons.removeAll()
		
		currentSeason = Season(team: Team())
		seasons.append(currentSeason)
	}
	
	//MARK: Equatable
	
	static func == (lhs: League, rhs: League) -> Bool {
		lhs.id == rhs.id
	}
}

extension League {
	static var testData: League {
		return League(seasons: [Season.testData])
	}
}
