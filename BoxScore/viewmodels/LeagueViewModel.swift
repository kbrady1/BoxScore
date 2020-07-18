//
//  LeagueViewModel.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine
import CoreData

class LeagueViewModel: ObservableObject {
	var loadable: Loadable<League> = .loading
	
	func fetch() {
		do {
			//Create two teams
			let request = NSFetchRequest<TeamCD>()
			request.entity = TeamCD.entity()
			
			let seasons: [Season] = try AppDelegate.context.fetch(request)
				.map { try Team(model: $0) }
				.map {
					let games = $0.model.game?.compactMap { $0 as? GameCD }.compactMap { try? Game(model: $0) } ?? []
					var previousGames = games.filter { $0.isComplete }
					let activeGames = games.filter { !$0.isComplete }
					
					var currentGame = activeGames.first
					if activeGames.count > 1 {
						//If somehow extra games were started, take the newest and keep it, and end the other games
						var extraActives = activeGames.sorted { $0.startDate ?? Date() < $1.startDate ?? Date() }
						currentGame = extraActives.popLast()
						
						extraActives.forEach { $0.isComplete = true }
						
						previousGames.append(contentsOf: extraActives)
					}
					
					return Season(team: $0, currentGame: currentGame, previousGames: previousGames)
			}
			
			loadable = .success(League(seasons: seasons))
		} catch {
			print(error)
			loadable = .error(DisplayableError())
		}
		objectWillChange.send()
	}
}
