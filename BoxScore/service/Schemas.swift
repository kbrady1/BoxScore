//
//  Schemas.swift
//  BoxScore
//
//  Created by Kent Brady on 7/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CloudKit

protocol Schema {
	static var TYPE: CKRecord.RecordType { get }
}

class PlayerSchema: Schema {
	static var TYPE = CKRecord.RecordType("Player")
	
	static var FIRST_NAME = "firstName"
	static var LAST_NAME = "lastName"
	static var NUMBER = "number"
	static var TEAM_ID_REF = "teamId"
}

class TeamSchema: Schema {
	static var TYPE = CKRecord.RecordType("Team")
	
	static var NAME = "name"
	static var PRIMARY_COLOR = "primaryColor"
	static var SECONDARY_COLOR = "secondaryColor"
}

class GameSchema: Schema {
	static var TYPE = CKRecord.RecordType("Game")
	
	static var DATE = "endDate"
	static var HAS_ENDED = "hasEnded"
	static var OPPONENT = "opponentName"
	static var OPPONENT_SCORE = "opponentScore"
	static var SCORE = "teamScore"
	static var PLAYERS_IN_GAME = "playersInGame"
	static var TEAM = "teamId"
}
