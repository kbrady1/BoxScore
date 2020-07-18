//
//  TeamStatSummaryView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/14/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct TopPlayer: Identifiable {
	var player: Player
	var title: String
	var total: String
	
	public var id: String { title + player.id }
}

struct StatCount: Identifiable {
	var stat: StatType
	var total: Double
	
	var totalText: String {
		total.formatted(decimal: 1)
	}
	
	public var id = UUID()
}

struct TeamStatSummaryView: View {
	@EnvironmentObject var gameList: GameList
	@EnvironmentObject var team: Team
	
	var viewModel: StatViewModel
	@State private var error: DisplayableError? = nil
	@State var stats: StatGroup = StatGroup(stats: [:])
	
	@State private var statDictionary = [StatType: [Stat]]()
	@State private var topPerformers = [TopPlayer]()
	@State private var teamTotals = [StatCount]()
	@State private var shots = [Stat]()
	@State var showPersonalModal = false
	
    var body: some View {
		//Show shot chart, filter by misses and make
		
		List {
			if gameList.games.count == 1 {
				Section {
					GameTitleView()
						.environmentObject(gameList.games[0])
						.environmentObject(team)
				}
			}
			
			if error != nil {
				Section {
					VStack {
						Text(error!.readableMessage)
					}
					.padding()
				}
			} else {
				self.setup(with: stats)
			}
		}.listStyle(GroupedListStyle())
		.environment(\.horizontalSizeClass, .regular)
		.navigationBarTitle(getText("Game Summary", "Season Summary"))
		.onAppear {
			(self.stats, self.error) = self.viewModel.fetch()
		}
    }
	
	private func setup(with stats: StatGroup) -> some View {
		//Set up stat details here
		self.gameList.statDictionary = stats.stats
		
		return Group {
			Section(header: Text("Shot Chart")) {
				ShotStatView(shotsToDisplay: stats.stats[.shot] ?? [])
			}
			
			Section(header: Text("Top Performers")) {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 12) {
						ForEach(self.getTopPerfomers(dict: stats.stats)) { topPlayer in
							VStack {
								Text(topPlayer.title)
								.font(.headline)
								VStack {
									Text(topPlayer.total)
									.font(.system(size: 40))
									PlayerView(player: topPlayer.player, shadow: true, height: 60)
								}
								.padding()
								.background(BlurView(style: .systemThinMaterial).cornerRadius(8))
									.background(LinearGradient(gradient: Gradient(colors: [self.team.primaryColor, self.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
								.cornerRadius(8)
							}
							.padding(8.0)
						}
					}
				}
			}
			
			Section(header: Text(self.getText("Team Totals", "Team Averages"))) {
				self.totalScrollView(list: self.getTeamTotals(dict: stats.stats))
			}
			
			Section(header: Text("Individual Stats")) {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack() {
						ForEach(self.team.players) { (player) in
							NavigationLink(destination:
								PlayerStatSummaryView(viewModel: StatViewModel(player: player.model), useLoadedStats: true, player: player)
									.environmentObject(self.gameList)
									.environmentObject(self.team)
							) {
								PlayerView(player: player, shadow: false)
									.background(LinearGradient(gradient: Gradient(colors: [self.team.primaryColor, self.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
									.clipShape(Circle())
									.padding([.vertical, .trailing])
							}
							.foregroundColor(Color(UIColor.label))
						}
					}
				}
			}
		}
	}
	
	private func totalScrollView(list: [StatCount]) -> some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack() {
				ForEach(list) { stat in
					VStack {
						Text(stat.stat == .shot ? "PTS" : stat.stat.abbreviation())
							.font(.headline)
						Text(stat.totalText)
							.font(.system(size: 40))
							
					}
					.frame(width: 60)
					.padding()
					.background(BlurView(style: .systemThinMaterial).cornerRadius(4))
					.background(LinearGradient(gradient: Gradient(colors: [self.team.primaryColor, self.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
				.cornerRadius(4)
					.padding(8.0)
				}
			}
		}
	}
	
	private func getTopPerfomers(dict: [StatType: [Stat]]) -> [TopPlayer] {
		var topPerformers = [TopPlayer]()
		StatType.all.forEach { (statType) in
			let byPlayer = Dictionary(grouping: dict[statType] ?? []) { $0.player.id?.uuidString ?? "" }.values
			var sorted = [[Stat]]()
			var description: Int?
			
			//For negative stats, reverse sorting order
			switch statType {
			case .foul, .turnover:
				sorted = byPlayer.sorted { $0.count < $1.count }
				description = sorted.first?.count
			case .assist, .block, .rebound, .steal:
				sorted = byPlayer.sorted { $0.count > $1.count }
				description = sorted.first?.count
			case .shot:
				sorted = byPlayer.sorted { $0.sumPoints() > $1.sumPoints() }
				description = sorted.first?.sumPoints()
			}
			
			guard let playerId = sorted.first?.first?.player.id?.uuidString,
				let desc = description,
				let player = team.players.first(where: { $0.id == playerId }) else { return }
			
			topPerformers.append(
				TopPlayer(player: player, title: statType == .shot ? "PTS" : statType.abbreviation(), total: desc.safeDivide(by: gameList.games.count).formatted(decimal: 1))
			)
		}
		
		return topPerformers
	}
	
	private func getTeamTotals(dict: [StatType: [Stat]]) -> [StatCount] {
		return StatType.all.map { (type) in
			if type == .shot, let shots = dict[type]?.sumPoints() {
				return StatCount(stat: type, total: shots.safeDivide(by: gameList.games.count))
			}
			
			return StatCount(stat: type, total: (dict[type]?.count ?? 0).safeDivide(by: gameList.games.count))
		}
	}
	
	private func getText(_ single: String, _ season: String) -> String {
		gameList.games.count == 1 ? single : season
	}
}
