//
//  PlayerView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct PlayerInGameView: View {
	@ObservedObject var game: LiveGame
	@ObservedObject var player: Player
	var shadow: Bool = true
	var color: Color = .clear
	var height: CGFloat = 80
	
	var body: some View {
		PlayerView(player: player, shadow: shadow, color: color, height: height)
			.if(game.playersOnBench.contains(player)) {
				$0.onDrag {
					return NSItemProvider(object: self.player.draggableReference)
				}
			}
	}
}

struct PlayerView: View {
	@ObservedObject var player: Player
	var shadow: Bool = true
	var color: Color = .clear
	var height: CGFloat = 80
	
    var body: some View {
		return ZStack {
			VStack {
				Text(String(player.number))
					.font(.largeTitle)
				Text(player.lastName)
					.font(.caption)
			}
			.background(Color.clear)
		}
		.frame(width: height, height: height, alignment: .center)
		.background(DefaultCircleView(color: color, shadow: shadow))
	}
}

struct DefaultCircleView: View {
	@State var color = Color(UIColor.systemBackground)
	var shadow: Bool = true
	var style: UIBlurEffect.Style = .prominent
	
	var body: some View {
		CircleView(color: $color, shadow: shadow, style: style)
	}
}

struct CircleView: View {
	@Binding var color: Color
	var shadow: Bool = true
	var style: UIBlurEffect.Style = .prominent
	
	var body: some View {
		BlurView(style: style)
			.background(color)
			.clipShape(Circle())
			.shadow(color: Color.black.opacity(0.15), radius: shadow ? 6 : 0)
	}
}
