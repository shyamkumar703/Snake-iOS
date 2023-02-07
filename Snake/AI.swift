//
//  AI.swift
//  Snake
//
//  Created by Shyam Kumar on 11/26/21.
//

import Foundation

class AI {
    
    var delegate: BoardViewDelegate? = nil
    var model: BoardViewModel? = nil
    
    init() {}
    
    func getMove(completion: @escaping (Move) -> Void) {
        if let head = model?.snake.first {
            let moves = Move.allCases
            
            var moveRewardArr: [(Move, Double)] = []
            
            let dg = DispatchGroup()
            
            for i in 0..<moves.count {
                dg.enter()
                let reward = getRewardForMove(head: getSquareGivenDirection(currentHead: head, direction: moves[i]), reward: checkDirection(square: head, move: moves[i]).1, model: model?.copy() as! BoardViewModel)
                
                moveRewardArr.append((moves[i], reward))
                
                dg.leave()
            }
            
            dg.notify(queue: .main) {
                if let first = moveRewardArr.sorted(by: {$0.1 > $1.1}).first {
                    if first.1 < 0 {
                        print("whoops")
                    }
                    completion(first.0)
                } else {
                    completion(.right)
                }
            }
        }
    }
    
    func getRewardForMove(head: (Int, Int), iterations: Int = 0, reward: Double = 0, model: BoardViewModel) -> Double {
        if iterations == 40 {
            return reward
        } else {
            let moves = Move.allCases.map({checkDirection(square: head, move: $0)}).sorted(by: {$0.1 > $1.1})
            if let bestMove = moves.first {
                let move = bestMove.0
                let moveReward = bestMove.1
                if moveReward < 0 || moveReward > 20 {
                    return reward + moveReward
                }
                model.makeMove(newMove: move)
                return getRewardForMove(head: getSquareGivenDirection(currentHead: head, direction: move), iterations: iterations + 1, reward: reward + moveReward, model: model)
            } else {
                let rightReward = checkDirection(square: head, move: .right).1
                if rightReward < 0 {
                    return reward + rightReward
                } else {
                    model.makeMove(newMove: .right)
                    return getRewardForMove(head: getSquareGivenDirection(currentHead: head, direction: .right), iterations: iterations + 1, reward: checkDirection(square: head, move: .right).1, model: model)
                }
            }
        }
    }
    
    func getSquareGivenDirection(currentHead: (Int, Int), direction: Move) -> (Int, Int) {
        switch direction {
        case .up:
            return (currentHead.0 - 1, currentHead.1)
        case .down:
            return (currentHead.0 + 1, currentHead.1)
        case .left:
            return (currentHead.0, currentHead.1 - 1)
        case .right:
            return (currentHead.0, currentHead.1 + 1)
        }
    }
    
    func checkDirection(square: (Int, Int), move: Move) -> (Move, Double) {
        switch move {
        case .up:
            let newSquare = (square.0 - 1, square.1)
            let model = freshCopy()
            model.makeMove(newMove: move)
            return (move, checkSquare(square: newSquare, model: model))
        case .down:
            let newSquare = (square.0 + 1, square.1)
            let model = freshCopy()
            model.makeMove(newMove: move)
            return (move, checkSquare(square: newSquare, model: model))
        case .left:
            let newSquare = (square.0, square.1 - 1)
            let model = freshCopy()
            model.makeMove(newMove: move)
            return (move, checkSquare(square: newSquare, model: model))
        case .right:
            let newSquare = (square.0, square.1 + 1)
            let model = freshCopy()
            model.makeMove(newMove: move)
            return (move, checkSquare(square: newSquare, model: model))
        }
    }
    
    func checkSquare(square: (Int, Int), model: BoardViewModel?) -> Double {
        if let squareType = model?.getSquare(coordinates: square) {
            switch squareType.model.type {
            case .empty:
                return (5 / (distanceToReward(square: square, model: model)))
            case .food:
                return 20
            case .obstacle:
                return -100000
            case .snake:
                return -100000
            }
        }
        return -100000
    }
    
    func distanceToReward(square: (Int, Int), model: BoardViewModel?) -> Double {
        if let model = model {
            let xDiff = pow(Decimal((model.reward.0 - square.0)), 2)
            let yDiff = pow(Decimal((model.reward.1 - square.1)), 2)
            let distance = sqrt(xDiff.doubleValue + yDiff.doubleValue)
            return distance
        }
        
        return 100
    }
    
    func distance(square1: (Int, Int), square2: (Int, Int)) -> Double {
        let xDiff = pow(Decimal((square1.0 - square2.0)), 2)
        let yDiff = pow(Decimal((square1.1 - square2.1)), 2)
        return (xDiff + yDiff).doubleValue
    }
    
    func distanceToSnake(square: (Int, Int), model: BoardViewModel?) -> Double {
        if let model = model {
            if model.snake.count < 8 {
                return 0
            } else {
                var minDistance = distance(square1: square, square2: model.snake[7])
                for index in 8..<model.snake.count {
                    let dist = distance(square1: square, square2: model.snake[index])
                    if dist < minDistance {
                        minDistance = dist
                    }
                }
                return minDistance
            }
        }
        return 0
    }
    
    func distanceToObstacle(square: (Int, Int)) -> Double {
        if let min = delegate?.obstacles.map({distance(square1: $0, square2: square)}).min() {
            return min
        }
        
        return 100
    }
}

extension AI {
    func freshCopy() -> BoardViewModel {
        let model = model?.copy() as! BoardViewModel
        return model
    }
}

extension Decimal {
    var doubleValue: Double {
        return Double(truncating: NSDecimalNumber(decimal: self))
    }
}
