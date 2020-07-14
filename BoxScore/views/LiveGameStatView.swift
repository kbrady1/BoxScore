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
	
	@State private var shots = [Stat]()
	@State private var teamTotals = [StatCount]()
	@State private var highlightedPlayer: Player? = nil
	
    var body: some View {
		List {
			Section(header: Text("Team Totals")) {
				totalScrollView(list: teamTotals)
			}
			
			Section(header: Text("Shot Chart")) {
				ShotStatView(shotsToDisplay: shots)
					.environmentObject(game.team)
			}
			
			Section(header: Text("Player Stats")) {
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
										$0.background(LinearGradient(gradient: Gradient(colors: [self.game.team.primaryColor, self.game.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
									}
									.if(player.id != self.highlightedPlayer?.id) {
										$0.background(Color.white)
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
				}
			}
		}
		.environment(\.horizontalSizeClass, .regular)
		.listStyle(GroupedListStyle())
		.navigationBarTitle("Game Stats")
		.navigationBarItems(trailing: Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}) {
			Text("Done")
				.bold()
		})
    }
	
	private func totals(for player: Player) -> [StatRow] {
		return []
	}

	private func statView(for player: Player) -> some View {
		VStack(spacing: 12) {
			ForEach(totals(for: player)) { row in
				HStack {
					Spacer()
					ForEach(row.cells) {
						self.cell(stat: $0)
						Spacer()
					}
				}
			}
		}
	}

	private func cell(stat: StatCount) -> some View {
		VStack {
			Text(stat.stat.abbreviation())
				.font(.headline)
				.padding([.top])
			Text(stat.totalText)
				.font(.system(size: 40))
		}
		.frame(minWidth: 55, maxWidth: .infinity)
		.background(BlurView(style: .systemThinMaterial).cornerRadius(4))
		.background(LinearGradient(gradient: Gradient(colors: [game.team.primaryColor, game.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
		.cornerRadius(4)
		.padding(8.0)
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
					.background(LinearGradient(gradient: Gradient(colors: [self.game.team.primaryColor, self.game.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing))
					.cornerRadius(4)
					.padding(8.0)
				}
			}
		}
	}
}

struct LiveGameStatView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			LiveGameStatView()
				.environmentObject(Game.previewData)
		}
    }
}
