//
//  SeasonView.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct SeasonView: View {
	@EnvironmentObject var settings: StatSettings
	
	@State var season: Season
	@State var currentGame: Game?
	
    var body: some View {
		List {
			if currentGame != nil {
				Section(header:
					Text("Current Game")
						.font(.largeTitle)
						.fontWeight(.bold)
				) {
					EmptyView()
				}
				Section {
					NavigationLink(destination:
						LiveGameView()
							.environmentObject(LiveGame(team: season.team, game: currentGame!))
							.environmentObject(settings)
							.environmentObject(season)
					) {
						GameTitleView(showDate: false)
							.environmentObject(season.currentGame!)
							.environmentObject(season.team)
					}
				}
			}
			
			Section(header:
				Text("Past Games")
					.font(.largeTitle)
					.fontWeight(.bold)
			) {
				if season.previousGames.isEmpty {
					Text("No completed games")
					.padding()
				} else {
					EmptyView()
				}
			}
			
			ForEach(season.previousGames, id: \.id) { (game) in
				Section (header: Text(game.dateText ?? "")) {
					NavigationLink(destination: TeamStatSummaryView(viewModel: StatViewModel(id: game.id, type: .game))
						.environmentObject(GameList(game))
						.environmentObject(self.season.team)
					) {
						GameTitleView(showDate: false)
							.environmentObject(game)
							.environmentObject(self.season.team)
					}
				}
			}
		}
		.environment(\.horizontalSizeClass, .regular)
		.listStyle(GroupedListStyle())
		.navigationBarTitle("Season")
		.navigationBarItems(trailing:
			NavigationLink(destination:
				TeamStatSummaryView(viewModel: StatViewModel(id: season.team.id, type: .team))
					.environmentObject(GameList(season.previousGames))
					.environmentObject(season.team)
			) {
			Text("Stats")
		})
		.onAppear {
			self.currentGame = self.season.currentGame
		}
    }
}

struct SeasonView_Previews: PreviewProvider {
	static let team = Team(name: "BYU Cougars",
					primaryColor: Color.blue,
					secondaryColor: Color.black)
	static let game = Game(team: team)
	static let pastGame = Game(team: team)
	static let pastGame2 = Game(team: team)
	
    static var previews: some View {
        return SeasonView(season: Season(team: team,
										 currentGame: game,
										 previousGames: [pastGame, pastGame2]))
    }
}
