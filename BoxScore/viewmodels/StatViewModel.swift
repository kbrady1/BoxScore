//
//  GameStatViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit
import Combine
import CoreData

//TODO: Move stat processing here for improved efficiency
class StatGroup {
	var stats = [StatType: [Stat]]()
	
	init(stats: [StatType: [Stat]]) {
		self.stats = stats
	}
	
	required init(models: [StatCD]) throws {
		StatType.all.forEach { stats[$0] = [] }
		
		try models.forEach {
			let stat = try Stat(model: $0)
			
			stats[stat.type]?.append(stat)
		}
	}
}

class StatViewModel {
	var team: TeamCD?
	var game: GameCD?
	var player: PlayerCD?
	
	init(team: TeamCD? = nil, game: GameCD? = nil, player: PlayerCD? = nil) {
		self.team = team
		self.game = game
		self.player = player
	}
	
	func fetch() -> (StatGroup, DisplayableError?) {
		do {
			var stats = [StatCD]()
			if let team = team,
				let newCD = try AppDelegate.context.existingObject(with: team.objectID) as? TeamCD {
				
				stats = newCD.stats?.compactMap { $0 as? StatCD } ?? []
				
			} else if let game = game,
				let newCD = try AppDelegate.context.existingObject(with: game.objectID) as? GameCD {
				stats = newCD.stats?.compactMap { $0 as? StatCD } ?? []
			} else if let player = player,
				let newCD = try AppDelegate.context.existingObject(with: player.objectID) as? PlayerCD {
				stats = newCD.stats?.compactMap { $0 as? StatCD } ?? []
			} else {
				return (StatGroup(stats: [:]), DisplayableError())
			}
			
			return (try StatGroup(models: stats), nil)
		} catch {
			return (StatGroup(stats: [:]), DisplayableError())
		}
	}
}
