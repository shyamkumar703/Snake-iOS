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
    
    var snake = Snake()
    
    var verticalStackSubviews: [UIView] = []
    
    init(squares: [SquareViewModel] = [], wHPair: (CGFloat, CGFloat) = (0, 0)) {
        self.squares = squares
        self.wHPair = wHPair
        snake.delegate = self
    }
    
    func restart() {
        squares = []
        snake.reset()
    }
    
    func makeMove(newMove: Move? = nil) {
        snake.makeMove(newMove: newMove)
    }
    
    func getSquare(coordinates: (Int, Int)) -> SquareView? {
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
        snake.addPart()
    }
}

extension BoardViewModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = BoardViewModel()
        copy.squares = squares
        copy.snake = snake.copy() as! Snake
        copy.reward = reward
        copy.wHPair = wHPair
        copy.verticalStackSubviews = verticalStackSubviews
        return copy
    }
}

extension BoardViewModel: SnakeDelegate {
    func moveSnake(fromSquare: (Int, Int), toSquare: (Int, Int)) {
        delegate?.moveSnake(fromSquare: fromSquare, toSquare: toSquare)
    }
}
