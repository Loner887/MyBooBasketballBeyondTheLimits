import SpriteKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupButtons()
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "menuBackgroundImage")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = size
        addChild(background)
    }
    
    private func setupButtons() {
        let playButton = SKSpriteNode(imageNamed: "playButtonImage")
        playButton.name = "playButton"
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        playButton.zPosition = 3
        addChild(playButton)
        
        let settingsButton = SKSpriteNode(imageNamed: "settingsButtonImage")
        settingsButton.name = "settingsButton"
        settingsButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        settingsButton.zPosition = 1
        addChild(settingsButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "playButton" {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1))
        } else if touchedNode.name == "settingsButton" {
            let settingsScene = SettingsScene(size: size)
            settingsScene.scaleMode = .aspectFill
            view?.presentScene(settingsScene, transition: SKTransition.fade(withDuration: 1))
        }
    }
    
}
