//
//  LiveGameStatView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/13/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct LiveGameStatView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var game: LiveGame
	@EnvironmentObject var team: Team
	
	@State private var teamTotals = [StatCount]()
	@State private var highlightedPlayer: Player? = nil
	
    var body: some View {
		NavigationView {
			Group {
//				if #available(iOS 14.0, *) {
//					List {
//						sections()
//					}
//					.listStyle(InsetGroupedListStyle())
//				} else {
					List {
						sections()
					}
					.listStyle(GroupedListStyle())
					.environment(\.horizontalSizeClass, .regular)
//				}
			}
			.navigationBarTitle("Game Stats")
			.navigationBarItems(trailing: Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Done")
					.bold()
			})
		}
		.navigationViewStyle(StackNavigationViewStyle())
    }
	
	private func sections() -> some View {
		Group {
			Section(header: Text("Team Totals")) {
				totalScrollView(list: getTeamTotals(dict: game.game.statDictionary))
			}
			
			Section(header: Text("Shot Chart")) {
				ShotStatView(shotsToDisplay: game.game.statDictionary[.shot] ?? [])
					.environmentObject(game.team)
			}
			
			Section(header: Text("Player Stats")) {
				VStack {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack() {
							ForEach(game.team.players) { (player) in
								Button(action: {
									if self.highlightedPlayer == player {
										self.highlightedPlayer = nil
									} else {
										self.highlightedPlayer = player
									}
								}) {
									PlayerView(player: player, shadow: false)
										.if(player.id == self.highlightedPlayer?.id) {
											$0.background(TeamGradientBackground(useBlur: false))
										}
										.if(player.id != self.highlightedPlayer?.id) {
											$0.background(Color(UIColor.systemBackground))
										}
									.clipShape(Circle())
									.padding([.vertical, .trailing])
									.foregroundColor(Color(UIColor.label))
								}
							}
						}
					}
					if highlightedPlayer != nil {
						//Once a player is selected, show their personal stats here
						statView(for: highlightedPlayer!)
							.animation(.easeIn)
					}
				}
			}
		}
	}
	
	private func totals(for player: Player, dict: [StatType: [Stat]]) -> [StatRow] {
		let statDict = dict.mapValues { $0.filter { $0.player.id?.uuidString == player.id } }
		var totals = [StatRow]()
		var tempTotals = [StatCount]()
		statDict.keys.forEach {
			if let stats = statDict[$0]?.filter({ $0.player.id?.uuidString == player.id }) {
				tempTotals.append(StatCount(stat: $0, total: stats.count.asDouble))
			}
		}
		
		let recordedStats = tempTotals.map { $0.stat }
		StatType.all.filter { !recordedStats.contains($0) }.forEach {
			tempTotals.append(StatCount(stat: $0, total: 0))
		}
		
		while !tempTotals.isEmpty {
			let toRemove = tempTotals.prefix(3)
			tempTotals = Array(tempTotals.dropFirst(toRemove.count))
			totals.append(StatRow(cells: Array(toRemove)))
		}
		
		return totals
	}
	
	private func getTeamTotals(dict: [StatType: [Stat]]) -> [StatCount] {
		return StatType.all.map { (type) in
			if type == .shot, let shots = dict[type]?.sumPoints() {
				return StatCount(stat: type, total: shots.asDouble)
			}
			
			return StatCount(stat: type, total: (dict[type]?.count ?? 0).asDouble)
		}
	}

	private func statView(for player: Player) -> some View {
		VStack(spacing: 12) {
			ForEach(totals(for: player, dict: game.game.statDictionary)) { row in
				HStack {
					Spacer()
					ForEach(row.cells) {
						StatBlock(stat: $0, extraPadding: false)
						Spacer()
					}
				}
			}
		}
	}

	private func totalScrollView(list: [StatCount]) -> some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack() {
				ForEach(list) { stat in
					StatBlock(stat: stat)
				}
			}
		}
	}
}
