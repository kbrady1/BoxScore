//
//  AddPlayerView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/13/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct AddPlayerView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var team: Team
	
	var editView: Bool = false
	@ObservedObject var player: ObservablePlayer = ObservablePlayer()
	
	@State var firstName: String = ""
	@State var lastName: String = ""
	@State var number: Int = 0
		
	//Get unused numbers
	@State private var listOfNumbers = [Int]()
	@State private var listOfCollectionRows = [CollectionRow]()
	
	var body: some View {
		ZStack {
			ZStack(alignment: .bottom) {
				ScrollView(.vertical, showsIndicators: true) {
					VStack(alignment: .center) {
						Text(String(number))
							.font(.largeTitle)
							.multilineTextAlignment(.center)
							.frame(width: 120, height: 120)
							.background(DefaultCircleView(color: Color(UIColor.tertiarySystemBackground)))
						
						HStack {
							Text("First: ")
								.padding()
							TextField("First Name", text: $firstName)
								.font(.largeTitle)
						}
						.background(BlurView(style: .systemMaterial))
						.cornerRadius(8)
						.padding(.horizontal)
						
						HStack {
							Text("Last: ")
							.padding()
							TextField("Last Name", text: $lastName)
								.font(.largeTitle)
						}
						.background(BlurView(style: .systemMaterial))
						.cornerRadius(8)
						.padding(.horizontal)
						VStack(spacing: 16) {
							ForEach(self.listOfCollectionRows) {
								self.rowForIndex($0)
							}
						}
						.padding()
						Spacer()
					}
					.padding(.top)
				}
				Button(action: {
					if self.editView {
						self.player.player?.firstName = self.firstName
						self.player.player?.lastName = self.lastName
						self.player.player?.number = self.number
						
						self.team.objectWillChange.send()
					} else {
						self.team.addPlayer(Player(lastName: self.lastName, firstName: self.firstName, number: self.number, team: self.team))
					}
					self.presentationMode.wrappedValue.dismiss()
				}) {
					Text(editView ? "Update Player" : "Add Player")
						.bold()
						.font(.system(size: 28))
						.frame(minWidth: 0, maxWidth: .infinity)
						.padding(.vertical, 6.0)
						.background(firstName.isEmpty || lastName.isEmpty ? Color.gray : team.primaryColor)
						.foregroundColor(Color.white)
						.cornerRadius(8.0)
						.shadow(radius: 4.0)
						.animation(.default)
				}
				.disabled(firstName.isEmpty || lastName.isEmpty)
				.padding([.horizontal, .bottom])
			}
		}
		.onAppear {
			if self.editView, let player = self.player.player {
				self.number = player.number
				self.firstName = player.firstName
				self.lastName = player.lastName
			}
			self.setUpCollection()
		}
		
	}
	
	private func rowForIndex(_ row: CollectionRow) -> some View {
		HStack() {
			Spacer()
			ForEach(row.elements) { (num) in
				Text(String(num))
					.font(.largeTitle)
					.multilineTextAlignment(.center)
					.frame(width: 60, height: 60)
					.if(num == self.number) {
						$0.background(CircleView(color: self.$team.secondaryColor))
					}
					.if(num != self.number) {
						$0.background(DefaultCircleView(color: Color(UIColor.tertiarySystemBackground), shadow: false))
					}
					.onTapGesture {
						UISelectionFeedbackGenerator().selectionChanged()
						self.number = num
				}
				Spacer()
			}
		}
	}
	
	private func setUpCollection() {
		var numbers = Array(0...99).filter { (num) in
			//Only use available numbers (and current player number)
			return !self.team.players.contains { $0.number == num } || self.player.player?.number == num
		}
		var rows = [CollectionRow]()
		while !numbers.isEmpty {
			let toRemove = numbers.prefix(4)
			numbers = Array(numbers.dropFirst(toRemove.count))
			rows.append(CollectionRow(elements: Array(toRemove)))
		}
		self.listOfCollectionRows = rows
		self.number = editView ? number : rows.first?.elements.first ?? 99
	}
}

//This is for unique numbers 1 - 100
extension Int: Identifiable {
	public var id: String {
		return self.description
	}
}

struct CollectionRow: Identifiable {
	var elements: [Int]
	
	public var id: String {
		return String(elements.hashValue)
	}
}
