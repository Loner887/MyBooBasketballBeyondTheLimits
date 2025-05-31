import SpriteKit
import GameplayKit

class BonusScene: SKScene {

    var onBallSelected: ((Int) -> Void)?
    
    private var wheel: SKSpriteNode!
    private var pointer: SKSpriteNode!
    private var isSpinning = false
    private var currentAngle: CGFloat = 0.0

    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        let bg = SKSpriteNode(imageNamed: "bonusBackground")
        bg.size = size
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -1
        addChild(bg)
        
        wheel = SKSpriteNode(imageNamed: "fortune_wheel")
        wheel.size = CGSize(width: 300, height: 300)
        wheel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(wheel)
        
        pointer = SKSpriteNode(imageNamed: "pointer")
        pointer.position = CGPoint(x: size.width/2, y: size.height * 0.52)
        pointer.zPosition = 1
        pointer.setScale(0.73)
        addChild(pointer)
    }

    func spinWheel() {
        guard !isSpinning else { return }
        isSpinning = true
        
        let sectorCount = 8
        let sectorAngle = CGFloat.pi * 2 / CGFloat(sectorCount)
        let fullRotations = 5
        
        let randomIndex = Int.random(in: 0..<sectorCount)
        let totalRotation = CGFloat(fullRotations) * 2 * .pi + CGFloat(randomIndex) * sectorAngle - 0.1
        
        // Анимация плавного вращения с easeOut
        let rotateAction = SKAction.rotate(byAngle: totalRotation, duration: 4.0)
        rotateAction.timingMode = .easeOut
        
        // Переменные для отслеживания поворота и звуков
        var lastPlayedSector = 0
        
        // Запускаем таймер для проигрывания щелчков
        let clickTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            // Текущий угол поворота колеса относительно начального
            let currentRotation = self.wheel.zRotation.truncatingRemainder(dividingBy: 2 * .pi)
            // Приводим в диапазон 0...2pi
            let normalizedRotation = currentRotation >= 0 ? currentRotation : currentRotation + 2 * .pi
            
            // Определяем текущий сектор по углу
            let currentSector = Int((normalizedRotation / sectorAngle).rounded(.toNearestOrAwayFromZero)) % sectorCount
            
            // Если сектор изменился - проигрываем звук щелчка
            if currentSector != lastPlayedSector {
                lastPlayedSector = currentSector
                self.run(SKAction.playSoundFileNamed("wheel_click.mp3", waitForCompletion: false))
            }
        }
        
        wheel.run(rotateAction) { [weak self] in
            guard let self = self else { return }
            self.isSpinning = false
            
            clickTimer.invalidate()
            
            // Сохраняем итоговый угол
            self.currentAngle = (self.currentAngle + totalRotation).truncatingRemainder(dividingBy: 2 * .pi)
            
            UserDefaults.standard.set(randomIndex, forKey: "selectedBallIndex")
            self.onBallSelected?(randomIndex)
            
            if let view = self.view {
                let game = GameScene(size: view.bounds.size)
                view.presentScene(game, transition: .fade(withDuration: 1))
            }
        }
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        spinWheel()
    }
}
