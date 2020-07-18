//
//  SettingsView.swift
//  StatTracker
//
//  Created by Kent Brady on 6/29/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

//TODO: Add options here to disable iCloud backup?
struct SettingsView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	@ObservedObject var league: League
	
	@State var settings: StatSettings
	@State var leftGesture: StatType
	@State var rightGesture: StatType
	@State var upGesture: StatType
	@State var downGesture: StatType
	
	@State private var teamToDelete: Team? = nil
	@State private var deleteTeamConfirmation: Bool = false
	@State private var deleteAllDataConfirmation: Bool = false
	
	var body: some View {
		NavigationView {
			List {
				Section(header:
					Text("Teams")
						.font(Font.system(size: 32))
						.bold()
				) {
					ForEach(league.seasons, id: \.team.id) { (season) in
						Button(action: {
							self.league.currentSeason = season
						}) {
							HStack {
								Text(season.team.name)
									.bold()
									.foregroundColor(season.team.name == self.league.currentSeason.team.name ? season.team.primaryColor : Color.gray)
								Spacer()
								if season.team.name == self.league.currentSeason.team.name {
									Image(systemName: "checkmark.circle.fill")
										.foregroundColor(season.team.secondaryColor)
								}
							}
						}
					}
					.onDelete(perform: self.deleteRow)
					.actionSheet(isPresented: $deleteTeamConfirmation) {
						ActionSheet(title: Text("Confirm Delete Team?"), message: Text("Deleting this team will delete all players, games and stats associated with the team. This action cannot be undone."), buttons: [
							ActionSheet.Button.cancel(),
							ActionSheet.Button.destructive(Text("Delete Team"), action: {
								if let team = self.teamToDelete {
									self.league.deleteTeam(team)
								}
							})
						])
					}
					Button(action: {
						self.league.newTeam(setToCurrent: true)
						self.presentationMode.wrappedValue.dismiss()
					}) {
						Text("Add Team")
					}
				}
				Section(header:
					Text("Stat Gestures")
						.font(Font.system(size: 32))
						.bold()
				) {
					gestureButton(for: .up, selection: $settings.upGesture)
					gestureButton(for: .left, selection: $leftGesture)
					gestureButton(for: .right, selection: $settings.rightGesture)
					gestureButton(for: .down, selection: $settings.downGesture)
				}
				
				Button(action: {
					self.deleteAllDataConfirmation.toggle()
					self.league.deleteAll()
				}) {
					Text("Delete Data")
						.foregroundColor(.red)
				}
				.actionSheet(isPresented: $deleteTeamConfirmation) {
					ActionSheet(title: Text("Confirm Delete All Data?"), message: Text("All teams, games, players and stats will be deleted. This action cannot be undone."), buttons: [
						ActionSheet.Button.cancel(),
						ActionSheet.Button.destructive(Text("Delete Team"), action: {
							self.league.deleteAll()
						})
					])
				}
			}
			.listStyle(GroupedListStyle())
			.environment(\.horizontalSizeClass, .regular)
			.navigationBarTitle("Settings")
			.navigationBarItems(trailing: Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Done")
					.bold()
			})
		}
	}
	
	private func deleteRow(at indexSet: IndexSet) {
		if let first = indexSet.first {
			teamToDelete = league.seasons[first].team
			deleteTeamConfirmation.toggle()
		}
    }
	
	private func gestureButton(for direction: MoveDirection, selection: Binding<StatType>) -> some View {
		VStack(spacing: 8) {
			Text("\(direction.rawValue.capitalized)")
				.bold()
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 16) {
					ForEach(StatType.all, id: \.hashValue) { (stat) in
						Text(stat.abbreviation())
							.if(selection.wrappedValue.id == stat.id) { $0.bold() }
							.frame(width: 60, height: 60)
							.if(selection.wrappedValue.id == stat.id) {
								$0.background(CircleView(color: Binding.constant(self.league.currentSeason.team.primaryColor), shadow: false))
							}
							.if(selection.wrappedValue.id != stat.id) {
								$0.background(CircleView(color: Binding.constant(Color.white), shadow: false))
							}
							.onTapGesture {
								selection.wrappedValue = stat
								switch direction {
								case .left:
									self.settings.leftGesture = stat
								case .right:
									self.settings.rightGesture = stat
								case .down:
									self.settings.downGesture = stat
								case.up:
									self.settings.upGesture = stat
								}
							}
					}
				}
				.padding(.vertical)
			}
			.frame(height: 60)
		}
	}
}
