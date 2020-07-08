//
//  TeamStatSummaryView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/14/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

struct TopPlayer {
	var player: Player
	var title: String
	var total: String
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
	//TODO: Differentiate data if showing multiple games (averages)
	@EnvironmentObject var gameList: GameList
	@EnvironmentObject var team: Team
	
	@State private var topPerformers = [TopPlayer]()
	@State private var teamTotals = [StatCount]()
	@State private var shots = [Stat]()
	@State var showPersonalModal = false
	
    var body: some View {
		//Show shot chart, filter by misses and make
		
		List {
			if gameList.games.count == 1 {
				Section {
					GameTitleView(game: gameList.games[0])
				}
			}

			Section(header: Text("Shot Chart")) {
				ShotStatView(shotsToDisplay: shots)
			}
			
			Section(header: Text("Top Performers")) {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 12) {
						ForEach(topPerformers) { topPlayer in
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
			
			Section(header: Text("Team Totals")) {
				totalScrollView(list: teamTotals)
			}
			
			Section(header: Text("Individual Stats")) {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack() {
						ForEach(team.players) { (player) in
							NavigationLink(destination:
								PlayerStatSummaryView(player: player)
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
		}.listStyle(GroupedListStyle())
		.environment(\.horizontalSizeClass, .regular)
		.navigationBarTitle(getText("Game Summary", "Season Summary"))
		.onAppear {
			self.setup()
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
	
	private func setup() {
		getShots()
		getTopPerfomers()
		getTeamTotals()
	}
	
	private func getShots() {
		self.shots = gameList.games.compactMap { $0.statDictionary[.shot] }.flatMap { $0 }
	}
	
	private func getTopPerfomers() {
		StatType.all.forEach { (statType) in
			//TODO: Fix this with multiple games. Same Players have different ids.
			let byPlayer = Dictionary(grouping: gameList.games
				.compactMap { $0.statDictionary[statType] }
				.flatMap { $0 }
			) { $0.player }.values
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
			
			guard let player = sorted.first?.first?.player, let desc = description else { return }
			
			self.topPerformers.append(
				TopPlayer(player: player, title: statType == .shot ? "PTS" : statType.abbreviation(), total: String(desc))
			)
		}
	}
	
	private func getTeamTotals() {
		teamTotals = StatType.all.map { (type) in
			var statDict = [StatType: [Stat]]()
			gameList.games.forEach {
				statDict.merge($0.statDictionary) { $0 + $1 }
			}
			
			if type == .shot, let shots = statDict[type]?.sumPoints() {
				return StatCount(stat: type, total: shots.asDouble / gameList.games.count.asDouble)
			}
			
			return StatCount(stat: type, total: (statDict[type]?.count ?? 0).asDouble / gameList.games.count.asDouble)
		}
	}
	
	private func getText(_ single: String, _ season: String) -> String {
		gameList.games.count == 1 ? single : season
	}
}

struct TeamStatSummaryView_Previews: PreviewProvider {
    static var previews: some View {
		let view = TeamStatSummaryView().environmentObject(Game.statTestData)
		return view
    }
}

struct ShotView: View {
	var make: Bool
	
	var body: some View {
		DefaultCircleView(color: make ? .green : .red, shadow: false)
			.frame(width: 16, height: 16)
	}
}


extension Array where Element: Stat {
	func sumPoints() -> Int {
		return self.reduce(into: 0) { $0 += ($1.shotWasMake ? $1.pointsOfShot ?? 0 : 0) }
	}
}

extension TopPlayer: Identifiable {
	public var id: String {
		return self.title
	}
}
