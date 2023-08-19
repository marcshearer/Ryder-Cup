//
//  Data Structures.swift
//  Ryder Cup
//
//  Created by Marc Shearer on 18/08/2023.
//

import SwiftUI

var evaluated = 0

class Event {
    var playerList: [String: Player] = [:]
    var matchList: [Match] = []
    var iterateType: PlayerType = .female
    var table: Table
    
    init() {
        playerList = [:]
        for couple in 1...12 {
            let name = "ABCDEFGHJKMN".mid(couple-1,1)
            for type in PlayerType.allCases {
                let playerName = (type == .male ? name.uppercased() : name.lowercased())
                playerList[playerName] = Player(couple, type, playerName)
            }
        }
        
        matchList = [
            Match(playerList, ["A", "B"], ["d", "c"]),
            Match(playerList, ["C", "D"], ["b", "a"]),
            Match(playerList, ["E", "F"], ["h", "g"]),
            Match(playerList, ["G", "H"], ["f", "e"]),
            Match(playerList, ["J", "K"], ["n", "m"]),
            Match(playerList, ["M", "N"], ["k", "j"]),
            Match(playerList, ["A", "C"], ["h", "f"]),
            Match(playerList, ["B", "D"], ["g", "e"]),
            Match(playerList, ["E", "G"], ["n", "k"]),
            Match(playerList, ["F", "H"], ["m", "j"]),
            Match(playerList, ["J", "M"], ["d", "b"]),
            Match(playerList, ["K", "N"], ["c", "a"]),
            Match(playerList, ["A", "D"], ["n", "j"]),
            Match(playerList, ["B", "C"], ["m", "k"]),
            Match(playerList, ["E", "H"], ["d", "a"]),
            Match(playerList, ["F", "G"], ["c", "b"]),
            Match(playerList, ["J", "N"], ["h", "e"]),
            Match(playerList, ["K", "M"], ["g", "f"]),
            Match(playerList, ["A"], ["b"]),
            Match(playerList, ["B"], ["a"]),
            Match(playerList, ["C"], ["d"]),
            Match(playerList, ["D"], ["c"]),
            Match(playerList, ["E"], ["f"]),
            Match(playerList, ["F"], ["e"]),
            Match(playerList, ["G"], ["h"]),
            Match(playerList, ["H"], ["g"]),
            Match(playerList, ["J"], ["k"]),
            Match(playerList, ["K"], ["j"]),
            Match(playerList, ["M"], ["n"]),
            Match(playerList, ["N"], ["m"])
        ]
        
        for (_ ,player) in playerList {
            player.updateWithAgainstPartner(matchList: matchList, playerList: playerList)
        }
                
        self.table = Table(playerList, "A", "j", "G", "d", "B", "f", "H", "m", "C", "e", "J", "b", "D", "n", "K", "a", "E", "h", "M", "c", "F", "k", "N", "g")
        
        for (_, player) in playerList.sorted(by: {$0.value.name < $1.value.name}) {
            var list = player.name + ":  "
            for (index, withPlayer) in player.with.enumerated() {
                if index != 0 {
                    list += ", "
                }
                list += withPlayer.name
            }
            for (index, againstPlayer) in player.against.enumerated() {
                if index == 0 {
                    list += ";  "
                } else {
                    list+=", "
                }
                list += againstPlayer.name
            }
            list += ";  " + player.partner.name
            
            print(list)
        }
        
        iterate(table: table)
    }
    
    @discardableResult func iterate(table: Table, start: Int = -1, currentBest: Int = Int.max) -> Int {
        var currentBest = currentBest
        
        if start > 0 {
            // Evaluate this sequence
            let score = table.score
            if score <= currentBest {
                currentBest = min(currentBest, score)
                print("\(String(format: "%7d", currentBest)) \(String(format: "%7d", score)): \(table.string(type: iterateType))  \(start)")
            }
        }
            
        // Evaluate any sub-instances (if not at end of line)
        if start + 2 <= table.count(iterateType) - 1 {
            evaluated += 1
            var table = table
            for swap in (start + 2)...(table.count(iterateType) - 1) {
                table.swap(iterateType, start + 1, swap)
                // Now recurse
                currentBest = iterate(table: table, start: start + 1, currentBest: currentBest)
            }
        }
        return currentBest
    }
}

struct Table {
    var players: [Player]
    var typePlayers: [PlayerType:[Int]] = [:]
    
    let partnerScore = 10000
    let withScore = 100
    let againstScore = 1
    
    init(_ playerList: [String: Player], _ nameList: String...){
        self.players = []
        for name in nameList {
            players.append(playerList[name]!)
        }
        for type in PlayerType.allCases {
            typePlayers[type] = []
            for (index, player) in players.enumerated() {
                if type == player.type {
                    typePlayers[type]!.append(index)
                }
            }
        }
    }
    
    func count(_ type: PlayerType? = nil) -> Int {
        if type != nil {
            return typePlayers[type!]!.count
        } else {
            return players.count
        }
    }
    
    static func findName(playerList: [String: Player], nameList: [String:Player], name: String) -> Player {
        if let player = playerList.first(where: {$0.value.name == name}) {
            return player.value
        } else {
            fatalError("No player with this name")
        }
    }
    
    func string(type: PlayerType? = nil) -> String {
        var result = ""
        for index in 0..<players.count {
            if type == nil || type == players[index].type {
                if result != "" {
                    result += ", "
                }
                result += players[index].name
            }
        }
        return result
    }
    
    var score: Int {
        var score = 0
        for (seat, player) in players.enumerated() {
            var playerScore = 0
            for check in [offset(seat, -1), offset(seat, 1)] {
                if player == players[check].partner {
                    playerScore += partnerScore
                }
                if player.against.contains(players[check]) {
                    playerScore += againstScore
                }
                for check in [offset(seat, -2), offset(seat, 2)] {
                    if player.with.contains(players[check]) {
                        playerScore += withScore
                    }
                }
                score += playerScore
            }
        }
        return score / 2
    }
    
    func offset(_ seat: Int, _ value: Int) -> Int {
        return (players.count + seat + value) % players.count
    }
    
    mutating func swap(_ type: PlayerType,_ first: Int, _ second: Int) {
        let keep = players[typePlayers[type]![first]]
        players[typePlayers[type]![first]] = players[typePlayers[type]![second]]
        players[typePlayers[type]![second]] = keep
    }
}

class Player: Hashable {
    var couple: Int
    var type: PlayerType
    var name: String
    var with: [Player] = []
    var against: [Player] = []
    var partner: Player!
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return (lhs.couple == rhs.couple && lhs.type == rhs.type)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(couple)
        hasher.combine(type)
    }
    
    init(_ couple: Int, _ type: PlayerType, _ name: String) {
        self.couple = couple
        self.type = type
        self.name = name
    }
    
    func updateWithAgainstPartner(matchList: [Match], playerList: [String:Player]) {
        with = withPlayers(matchList: matchList)
        against = againstPlayers(matchList: matchList)
        partner = partnerPlayer(playerList: playerList)
    }
    
    func withPlayers(matchList: [Match]) -> [Player] {
        var withPlayers: [Player] = []
        for match in matchList {
            for team in match.teams {
                if team.contains(self) {
                    for otherPlayer in team {
                        if otherPlayer != self {
                            withPlayers.append(otherPlayer)
                        }
                    }
                }
            }
        }
        return withPlayers
    }
    
    func againstPlayers(matchList: [Match]) -> [Player] {
        var againstPlayers: [Player] = []
        for match in matchList {
            if match.teams.flatMap({$0.map{$0}}).contains(self) {
                for team in match.teams {
                    if !team.contains(self) {
                        for otherPlayer in team {
                            againstPlayers.append(otherPlayer)
                        }
                    }
                }
            }
        }
        return againstPlayers
    }
    
    func partnerPlayer(playerList: [String:Player]) -> Player {
        if let player = playerList.first(where: {$0.value.couple == self.couple && $0.value.type == self.type.other}) {
            return player.value
        } else {
            fatalError("Can't find partner")
        }
    }
}

class Match {
    var teams: [[Player]]
    
    init(_ playerList: [String:Player], _ teamNames: [String]...) {
        self.teams = []
        for team in teamNames {
            var players: [Player] = []
            for name in team {
                if let player = playerList[name] {
                    players.append(player)
                } else {
                    fatalError("Invalid player")
                }
            }
            teams.append(players)
        }
    }
}

enum PlayerType: Int, CaseIterable {
    case male
    case female
    
    var other: PlayerType {
        switch self {
        case .male:
            return .female
        case .female:
            return .male
        }
    }
}
