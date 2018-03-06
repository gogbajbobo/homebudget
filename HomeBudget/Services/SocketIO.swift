//
//  SocketIO.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 06/03/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import SocketIO

class SocketIO {
    
    static private let instance = SocketIO()

    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    
    class func start() {
        instance.initSocket()
    }
    
    private func initSocket() {
     
        let socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on("currentAmount") {data, ack in
            guard let cur = data[0] as? Double else { return }
            
            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                socket.emit("update", ["amount": cur + 2.50])
            }
            
            ack.with("Got your currentAmount", "dude")
        }
        
        socket.connect()
    
    }

}
