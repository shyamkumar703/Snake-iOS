//
//  BoardView.swift
//  Snake
//
//  Created by Shyam Kumar on 11/14/21.
//

import UIKit

protocol GameDelegate {
    var currentMove: Move? {get set}
    func updateScore()
}

class BoardView: UIView, BoardViewDelegate {
    
    weak var timer: Timer?
    
    var pendingFood: Bool = false
    
    var delegate: GameDelegate? = nil
    
    var reward: (Int, Int) = (0, 0)
    
    var obstacles: [(Int, Int)] = []
    
    var horizontalSquares: Int?
    var verticalSquares: Int?
    
    lazy var aiInstance: AI = {
        let ai = AI()
        ai.delegate = self
        ai.model = model
        return ai
    }()
    
    lazy var verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    func squareStackFactory(width: Int, tag: Int) -> UIStackView {
        let stack = UIStackView()
        stack.tag = tag
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        
        for i in 0..<width {
            let square = SquareView()
            if tag == 0 && (i == 0 || i == 1 || i == 2 || i == 3) {
                square.backgroundColor = .black
                if !model.snake.isEmpty {
                    model.snake.insert((tag, i), at: 0)
                } else {
                    model.snake.append((tag, i))
                }
            }
            square.tag = i
            stack.addArrangedSubview(square)
        }
        
        return stack
    }
    
    func restart() {
        DispatchQueue.main.async { [self] in
            timer?.invalidate()
            score = 0
            delegate?.updateScore()
            model.restart()
            for subview in verticalStack.arrangedSubviews {
                if let subview = subview as? UIStackView {
                    for sub in subview.arrangedSubviews {
                        subview.removeArrangedSubview(sub)
                        sub.removeFromSuperview()
                    }
                }
                verticalStack.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
            reward = (0, 0)
            obstacles = []
            createSquares()
        }
    }
    
    var model = BoardViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        model.delegate = self
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        
        addSubview(verticalStack)
    }
    
    func createSquares() {
        horizontalSquares = Int(model.wHPair.0 / 20)
        verticalSquares = Int(model.wHPair.1 / 20)
        let leftover = Int(model.wHPair.0) % 20
        verticalStack.constrainTo(view: self, margin: CGFloat(leftover / 2))
        for row in 0..<(verticalSquares ?? 0) {
            verticalStack.addArrangedSubview(squareStackFactory(width: horizontalSquares ?? 0, tag: row))
        }
        
        model.verticalStackSubviews = verticalStack.arrangedSubviews
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(makeMove), userInfo: nil, repeats: true)
        spawnFood()
    }
    
    @objc func makeMove() {
        if pendingFood {
            model.addSnakePart()
            pendingFood = false
        }
        
        let userMove = delegate?.currentMove
        if ai {
            aiInstance.getMove { [weak self] move in
                self?.model.makeMove(newMove: move)
            }
        } else {
            model.makeMove(newMove: userMove)
        }
    }
}

extension BoardView {
    func getSquare(coordinates: (Int, Int)) -> SquareView? {
        if let stack = verticalStack.arrangedSubviews.filter({ $0.tag == coordinates.0 }).map({ $0 as? UIStackView}).first {
            if let square = stack?.arrangedSubviews.filter({ $0.tag == coordinates.1 }).map({$0 as? SquareView}).first {
                return square
            }
        }
        return nil
    }
    
    func moveSnake(fromSquare: (Int, Int), toSquare: (Int, Int)) {
        if let from = getSquare(coordinates: fromSquare),
           let to = getSquare(coordinates: toSquare) {
            if to.model.type == .food {
                // Add point
                score += 1
                delegate?.updateScore()
                // Add snake body
                pendingFood = true
                spawnFood()
            } else if to.model.type != .empty {
                // gameover
                print("\(score)")
                timer?.invalidate()
//                restart()
                return
            }
            from.model.type = .empty
            to.model.type = .snake
            from.updateView()
            to.updateView()
        } else {
            // gameover
            print("\(score)")
            timer?.invalidate()
//            restart()
            return
        }
    }
    
    func spawnFood() {
        let x = Int.random(in: 0..<(horizontalSquares ?? 0))
        let y = Int.random(in: 0..<(verticalSquares ?? 0))
        
        if let square = getSquare(coordinates: (x, y)),
           square.model.type == .empty {
            square.model.type = .food
            reward = (x, y)
            model.reward = (x, y)
        } else {
            spawnFood()
        }
    }
    
    enum Axis {
        case horizontal
        case vertical
    }
    
    func spawnObstacles(axis: Axis, number: Int = 2) {
        for _ in 0..<number {
            let size = Int.random(in: 0..<5)
            var x = 0
            var y = 0
            
            switch axis {
            case .horizontal:
                x = Int.random(in: 1..<((horizontalSquares ?? 0) - size))
                y = Int.random(in: 0..<(verticalSquares ?? 0))
                
                for i in 0..<size {
                    if let square = getSquare(coordinates: (x + i, y)) {
                        if square.model.type != .empty {
                            continue
                        }
                        square.model.type = .obstacle
                        obstacles.append((x, y))
                    }
                }
                
            case .vertical:
                x = Int.random(in: 1..<(horizontalSquares ?? 0))
                y = Int.random(in: 0..<((verticalSquares ?? 0) - size))
                
                for i in 0..<size {
                    if let square = getSquare(coordinates: (x, y + i)) {
                        square.model.type = .obstacle
                        obstacles.append((x, y))
                    }
                }
            }
        }
    }
    
    func copy() -> BoardViewDelegate {
        let copy = BoardView()
        copy.reward = reward
        copy.obstacles = obstacles
        return copy
    }
}
