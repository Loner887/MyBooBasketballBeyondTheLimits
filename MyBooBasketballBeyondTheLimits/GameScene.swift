import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var ball: SKSpriteNode!
    var hoop: SKSpriteNode!
    var levelLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    
    var selectedBallIndex: Int = 0
    var playerBallTexture: SKTexture!
    
    var isBallMoving = false
    var startTouch: CGPoint?

    var score = 0
    var level = 1
    let maxLevel = 7
    let scoreToNextLevel = 10

    var ballSize: CGFloat { 120.0 }
    var baseHoopWidth: CGFloat { 400.0 }
    var hoopWidth: CGFloat { baseHoopWidth - CGFloat(level - 1) * 30.0 }
    
    var initialHoopHeightFactor: CGFloat { 0.45 }
    var heightIncreasePerLevel: CGFloat { 10.0 }

    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupScene()
        loadSelectedBall()
        resetBall()
    }
    
    func loadSelectedBall() {
        selectedBallIndex = UserDefaults.standard.integer(forKey: "selectedBallIndex")
        let textureName = "basketball\(selectedBallIndex + 1)"
        playerBallTexture = SKTexture(imageNamed: textureName)
        ball.texture = playerBallTexture
    }

    func saveSelectedBall(index: Int) {
        UserDefaults.standard.set(index, forKey: "selectedBallIndex")
    }

    func setupScene() {
        let bg = SKSpriteNode(imageNamed: "gameBackground")
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -1
        bg.size = size
        addChild(bg)
        
        hoop = SKSpriteNode(imageNamed: "hoop")
        hoop.zPosition = 1
        addChild(hoop)
        
        ball = SKSpriteNode(texture: SKTexture(imageNamed: "basketball1"))
        ball.size = CGSize(width: ballSize, height: ballSize)
        ball.zPosition = 4
        addChild(ball)
        
        levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        levelLabel.fontSize = 32
        levelLabel.fontColor = .red
        levelLabel.position = CGPoint(x: 0, y: hoop.size.height / 2 - 80) // 30 — отступ над кольцом
        levelLabel.zPosition = 3
        hoop.addChild(levelLabel)

        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 64
        scoreLabel.fontColor = .red
        scoreLabel.position = CGPoint(x: size.width - 60, y: 60)
        scoreLabel.zPosition = 3
        addChild(scoreLabel)
    }

    override func update(_ currentTime: TimeInterval) {
        let scaleFactor = 1.0 - CGFloat(level - 1) * 0.07
        hoop.setScale(scaleFactor)
        let hoopY = size.height * initialHoopHeightFactor + CGFloat(level - 1) * heightIncreasePerLevel
        hoop.position = CGPoint(x: size.width / 2, y: hoopY)
        
        levelLabel.text = "\(level)/\(maxLevel)"
        scoreLabel.text = "\(score)"
    }

    func resetBall() {
        ball.position = CGPoint(x: size.width / 2, y: ballSize * 1.5)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isBallMoving, let touch = touches.first else { return }
        startTouch = touch.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isBallMoving, let touch = touches.first, let start = startTouch else { return }
        let end = touch.location(in: self)
        let direction = CGVector(dx: (end.x - start.x) * 2, dy: (end.y - start.y) * 2)
        throwBall(direction: direction)
        startTouch = nil
    }

    func throwBall(direction: CGVector) {
        isBallMoving = true
        let target = CGPoint(
            x: max(0, min(size.width, ball.position.x + direction.dx)),
            y: max(0, min(size.height, ball.position.y + direction.dy))
        )

        let move = SKAction.move(to: target, duration: 0.5)
        ball.run(move) { [weak self] in
            self?.checkScore()
            self?.resetBall()
            self?.isBallMoving = false
        }
    }

    func checkScore() {
        let hoopCenter = hoop.position
        let ballCenter = ball.position
        let hitZone = hoopWidth * 0.3
        let distance = hypot(hoopCenter.x - ballCenter.x, hoopCenter.y - ballCenter.y)

        if distance < hitZone {
            run(SKAction.playSoundFileNamed("swish.mp3", waitForCompletion: false))

            score += 1
            if score >= scoreToNextLevel && level < maxLevel {
                level += 1
                score = 0
            }

            if level == maxLevel && score == 10 {
                run(SKAction.wait(forDuration: 0.5)) {
                    if let view = self.view {
                        let bonus = BonusScene(size: view.bounds.size)
                        bonus.onBallSelected = { selectedIndex in
                            self.saveSelectedBall(index: selectedIndex)
                            self.selectedBallIndex = selectedIndex
                            self.playerBallTexture = SKTexture(imageNamed: "basketball\(selectedIndex + 1)")
                            self.ball.texture = self.playerBallTexture
                            self.level = 1
                            self.score = 0
                        }
                        view.presentScene(bonus, transition: .fade(withDuration: 1))
                    }
                }
            }
        }

    }
}
