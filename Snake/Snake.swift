//
//  Snake.swift
//  Snake
//
//  Created by Shyam Kumar on 2/6/23.
//

import Foundation

protocol SnakeDelegate: AnyObject {
    func moveSnake(fromSquare: (Int, Int), toSquare: (Int, Int))
    func getSquare(coordinates: (Int, Int)) -> SquareView?
}

class Snake {
    var currentMove: Move = .right
    var snakeComponents: [(Int, Int)] = []
    var moveQueue: [[Move]] = [[], Array.init(repeating: .right, count: 1), Array.init(repeating: .right, count: 2),  Array.init(repeating: .right, count: 3)]
    
    weak var delegate: SnakeDelegate?
    
    var isEmpty: Bool { snakeComponents.isEmpty }
    var first: (Int, Int)? { snakeComponents.first }
    var count: Int { snakeComponents.count }
    
    init() { }
    
    convenience init(currentMove: Move, snakeComponents: [(Int, Int)], moveQueue: [[Move]]) {
        self.init()
        self.currentMove = currentMove
        self.snakeComponents = snakeComponents
        self.moveQueue = moveQueue
    }
    
    func makeMove(newMove: Move? = nil) {
        if newMove == nil {
            for index in 0..<snakeComponents.count {
                snakeComponents[index] = move(square: snakeComponents[index], move: currentMove)
            }
            return
        }
        
        for index in 0..<moveQueue.count {
            moveQueue[index].append((newMove ?? currentMove))
        }
        
        for index in 0..<snakeComponents.count {
            if let nextMove = moveQueue[index].first {
                snakeComponents[index] = move(square: snakeComponents[index], move: nextMove)
                moveQueue[index].remove(at: 0)
            }
        }
        
        currentMove = newMove ?? currentMove
    }
    
    func move(square: (Int, Int), move: Move) -> (Int, Int) {
        switch move {
        case .up:
            let newSquare = (square.0 - 1, square.1)
            delegate?.moveSnake(fromSquare: square, toSquare: newSquare)
            return newSquare
        case .down:
            let newSquare = (square.0 + 1, square.1)
            delegate?.moveSnake(fromSquare: square, toSquare: newSquare)
            return newSquare
        case .left:
            let newSquare = (square.0, square.1 - 1)
            delegate?.moveSnake(fromSquare: square, toSquare: newSquare)
            return newSquare
        case .right:
            let newSquare = (square.0, square.1 + 1)
            delegate?.moveSnake(fromSquare: square, toSquare: newSquare)
            return newSquare
        }
    }
    
    func addPart() {
        var newPartCoords = (0, 0)
        if let lastPart = snakeComponents.last,
           let queue = moveQueue.last,
           let move = queue.first {
            switch move {
            case .up:
                newPartCoords = (lastPart.0 + 1, lastPart.1)
            case .down:
                newPartCoords = (lastPart.0 - 1, lastPart.1)
            case .right:
                newPartCoords = (lastPart.0, lastPart.1 - 1)
            case .left:
                newPartCoords = (lastPart.0, lastPart.1 + 1)
            }
            
            if let square = delegate?.getSquare(coordinates: newPartCoords) {
                let newPartQueue = [move] + queue
                moveQueue.append(newPartQueue)
                snakeComponents.append(newPartCoords)
                square.model.type = .snake
            }
        }
    }
    
    func reset() {
        currentMove = .right
        snakeComponents = []
        moveQueue = [[], Array.init(repeating: .right, count: 1), Array.init(repeating: .right, count: 2),  Array.init(repeating: .right, count: 3)]
    }
    
    func insert(_ element: (Int, Int), at index: Int) {
        snakeComponents.insert(element, at: index)
    }
    
    func append(_ element: (Int, Int)) {
        snakeComponents.append(element)
    }
    
    subscript(index: Int) -> (Int, Int) { snakeComponents[index] }
}

extension Snake: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Snake()
        copy.currentMove = currentMove
        copy.snakeComponents = snakeComponents
        copy.moveQueue = moveQueue
        return copy
    }
}
