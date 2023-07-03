//
//  ConversationModel.swift
//  Messenger
//
//  Created by Katharos on 18/12/2022.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
