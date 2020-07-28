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
	
	@ObservedObject var season: Season
	
	@State private var deleteGameConfirmation: Bool = false
	@State private var gameToDelete: Game? = nil
	@State private var showDeleteGameLoadingView: Bool = false
	
    var body: some View {
		ZStack {
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
		}
		.navigationBarTitle("Season")
		.navigationBarItems(trailing:
			NavigationLink(destination:
				TeamStatSummaryView(viewModel: StatViewModel(team: season.team.model))
					.environmentObject(GameList(season.previousGames))
					.environmentObject(season.team)
			) {
			Text("Stats")
		})
    }
	
	private func sections() -> some View {
		Group {
			if season.currentGame != nil {
				Section(header:
							VStack {
//								if #available(iOS 14.0, *) {
//									Text("Current Game")
//										.font(.title)
//										.fontWeight(.bold)
//										.textCase(.none)
//								} else {
									Text("Current Game")
										.font(.title)
										.fontWeight(.bold)
//								}
							}
				) {
					EmptyView()
				}
				Section {
					NavigationLink(destination:
						LiveGameView()
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
						VStack {
//							if #available(iOS 14.0, *) {
//								Text("Past Games")
//									.font(.title)
//									.fontWeight(.bold)
//									.textCase(.none)
//							} else {
								Text("Past Games")
									.font(.title)
									.fontWeight(.bold)
//							}
						}
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
					NavigationLink(destination: TeamStatSummaryView(viewModel: StatViewModel(game: game.model))
						.environmentObject(GameList(game))
						.environmentObject(self.season.team)
					) {
						GameTitleView(showDate: false)
							.environmentObject(game)
							.environmentObject(self.season.team)
					}
				}
			}
			.onDelete(perform: deleteRow)
			.actionSheet(isPresented: $deleteGameConfirmation) {
				ActionSheet(title: Text("Confirm Delete Game?"), message: Text("Deleting this game will delete all stats associated with the game. This action cannot be undone."), buttons: [
					ActionSheet.Button.cancel(),
					ActionSheet.Button.destructive(Text("Delete Team"), action: {
						if let game = self.gameToDelete {
							self.season.delete(game: game)
						}
					})
				])
			}
		}
	}
	
	private func deleteRow(at indexSet: IndexSet) {
		if let first = indexSet.first {
			self.gameToDelete = self.season.previousGames[first]
			deleteGameConfirmation.toggle()
		}
    }
}
