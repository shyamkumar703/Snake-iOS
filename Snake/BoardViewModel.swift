//
//  BoardViewModel.swift
//  Snake
//
//  Created by Shyam Kumar on 11/26/21.
//

import Foundation
import UIKit

protocol BoardViewDelegate: AnyObject {
    var reward: (Int, Int) {get set}
    var obstacles: [(Int, Int)] {get set}
    var verticalStack: UIStackView {get set}
    func createSquares()
    func moveSnake(fromSquare: (Int, Int), toSquare: (Int, Int))
    func getSquare(coordinates: (Int, Int)) -> SquareView?
    func copy() -> BoardViewDelegate
}

enum Move: CaseIterable {
    case left
    case right
    case up
    case down
}

class BoardViewModel {
    var reward: (Int, Int) = (0,0)
    var obstacles: [(Int, Int)] = []
    
    var squares: [SquareViewModel] = []
    var wHPair: (CGFloat, CGFloat) = (0, 0) {
        didSet {
            DispatchQueue.main.async { [self] in
                delegate?.createSquares()
            }
        }
    }
    var delegate: BoardViewDelegate? = nil
    
    var currentMove: Move = .right
    
    var snake: [(Int, Int)] = []
    
    var snakeQueue: [[Move]] = [[], Array.init(repeating: .right, count: 1), Array.init(repeating: .right, count: 2),  Array.init(repeating: .right, count: 3)]
    
    var verticalStackSubviews: [UIView] = []
    
    init(squares: [SquareViewModel] = [], wHPair: (CGFloat, CGFloat) = (0, 0)) {
        self.squares = squares
        self.wHPair = wHPair
    }
    
    func restart() {
        squares = []
        currentMove = .right
        snake = []
        snakeQueue = [[], Array.init(repeating: .right, count: 1), Array.init(repeating: .right, count: 2),  Array.init(repeating: .right, count: 3)]
    }
    
    func makeMove(newMove: Move? = nil) {
        if newMove == nil {
            for index in 0..<snake.count {
                snake[index] = move(square: snake[index], move: currentMove)
            }
            return
        }
        
        for index in 0..<snakeQueue.count {
            snakeQueue[index].append((newMove ?? currentMove))
        }
        
        for index in 0..<snake.count {
            if let nextMove = snakeQueue[index].first {
                snake[index] = move(square: snake[index], move: nextMove)
                snakeQueue[index].remove(at: 0)
            }
        }
        
        currentMove = newMove ?? currentMove
    }
    
    func getSquare(coordinates: (Int, Int)) -> SquareView? {
//        if coordinates.0 < 0 || coordinates.1 < 0 {
//            let view = SquareView()
//            view.model.type = .obstacle
//            return view
//        }
        if let stack = verticalStackSubviews.filter({ $0.tag == coordinates.0 }).map({ $0 as? UIStackView}).first {
            if let square = stack?.arrangedSubviews.filter({ $0.tag == coordinates.1 }).map({$0 as? SquareView}).first {
                return square
            }
        }
        return nil
    }
}

extension BoardViewModel {
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
    
    func addSnakePart() {
        var newPartCoords = (0, 0)
        if let lastPart = snake.last,
           let queue = snakeQueue.last,
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
                snakeQueue.append(newPartQueue)
                snake.append(newPartCoords)
                square.model.type = .snake
            }
        }
    }
}

extension BoardViewModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = BoardViewModel()
        copy.squares = squares
        copy.currentMove = currentMove
        copy.snake = snake
        copy.snakeQueue = snakeQueue
        copy.reward = reward
        copy.wHPair = wHPair
        copy.verticalStackSubviews = verticalStackSubviews
//        copy.delegate = delegate?.copy()
        return copy
    }
}
