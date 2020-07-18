//
//  InstructionCardView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/18/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct InstructionCardView<Content: View>: View {
	var title: String
	var image: Image? = nil
	let content: Content
	var details: String
	
	var width: CGFloat
	var height: CGFloat
	
    var body: some View {
		VStack(spacing: 16) {
			Text(title)
				.font(.largeTitle)
				.bold()
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
			
			Spacer()
			VStack {
				if image != nil {
					image!
						.resizable()
						.frame(width: width * 0.6, height: width * 0.6)
						.cornerRadius(16)
						.shadow(color: Color.black.opacity(0.1), radius: 6)
				}
				content
					.disabled(true)
			}
			Spacer()
			Text(details)
				.font(.headline)
			.foregroundColor(Color(UIColor.secondaryLabel))
			Spacer()
		}
		.frame(width: width, height: height)
		.padding()
		.background(BlurView(style: .systemMaterial))
		.cornerRadius(36)
		.shadow(color: Color.black.opacity(0.15), radius: 12)
		.padding()
    }
}

struct InstructionCardView_Previews: PreviewProvider {
    static var previews: some View {
		InstructionCardView(title: "Step One",
							image: nil,
							content: Text("Person"),
							details: "Get it done!",
							width: 200,
							height: 300)
    }
}
