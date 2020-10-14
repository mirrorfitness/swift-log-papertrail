//
//  Queue.swift
//  CocoaAsyncSocket
//
//  Created by Bas van Kuijck on 15/07/2020.
//

import Foundation
import Logging

struct QueueItem {
    let message: String
    let date: Date
    let severity: Logger.Level
}

class Queue: PapertrailSocketClientDelegate {
    let socketClient: PapertrailSocketClient
    private var items: [QueueItem] = []
    
    init(socketClient: PapertrailSocketClient) {
        self.socketClient = socketClient
        socketClient.delegate = self
    }

    func add(message: String, severity: Logger.Level) {
        let wasEmpty = items.isEmpty
        items.append(QueueItem(message: message, date: Date(), severity: severity))
        if wasEmpty {
            sendMessages()
        }
    }

    private func sendMessages() {
        if !items.isEmpty, socketClient.connectionStatus == .connected {
            for item in items {
                socketClient.send(message: item.message, date: item.date, severity: item.severity)
            }
            items.removeAll()
        }
    }

    func didChangeConnectionStatus(client: PapertrailSocketClient, connectionStatus: PapertrailSocketClient.ConnectionStatus) {
        if connectionStatus == .connected {
            sendMessages()
        }
    }
}
