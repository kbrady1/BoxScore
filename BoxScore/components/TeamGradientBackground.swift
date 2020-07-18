//
//  TeamGradientBackground.swift
//  BoxScore
//
//  Created by Kent Brady on 7/18/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct TeamGradientBackground: View {
	@EnvironmentObject var team: Team
	
	var useBlur: Bool = true
	var blur: UIBlurEffect.Style  = .prominent
	var cornerRadius: CGFloat = 4.0
	
    var body: some View {
		VStack {
			if useBlur {
				BlurView(style: blur)
				.cornerRadius(cornerRadius)
				.background(gradient)
			} else {
				gradient
			}
		}
    }
	
	var gradient: some View {
		LinearGradient(gradient: Gradient(colors: [self.team.primaryColor, self.team.secondaryColor]), startPoint: .bottomLeading, endPoint: .topTrailing)
		.cornerRadius(cornerRadius)
	}
}

