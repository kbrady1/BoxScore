//
//  League.swift
//  StatTracker
//
//  Created by Kent Brady on 7/9/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import Foundation
import Combine

class League: ObservableObject {
	
	@Published var seasons: [Season]
	@Published var currentSeason: Season
	
	var cancellable: AnyCancellable?
	
	init(seasons: [Season]) {
		self.seasons = seasons
		self.currentSeason = seasons.first ?? Season(team: Team())
		
		if seasons.isEmpty {
			self.seasons.append(currentSeason)
		}
		
		//Observable objects don't publish changes when nested in another, so manually push up the changes
		cancellable = currentSeason.objectWillChange.sink { (_) in
			self.objectWillChange.send()
		}
	}
	
	var teams: [Team] { seasons.map { $0.team }}
	
	func newTeam() {
		let season = Season(team: Team())
		seasons.append(season)
		
		currentSeason = season
	}
	
	func deleteTeam(_ team: Team) {
		seasons.removeAll { $0.team.name == team.name }
		
		//If the current season was deleted
		if !seasons.contains(where: { $0.team.name == currentSeason.team.name }) {
			currentSeason = seasons.first ?? Season(team: Team())
			
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
}

extension League {
	static var testData: League {
		return League(seasons: [Season.testData])
	}
}
