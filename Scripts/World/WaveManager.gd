extends Node

class_name WaveManager

const ENEMYSPAWNER = preload("res://Scenes/Characters/Enemies/EnemySpawner.tscn") 

var waveNumber = 0
var completedWaves = 1
var enemiesToDefeat = 0
var samuraiAmountToSpawn:int
var archerAmountToSpawn:int
var hanzoAmountToSpawn:int
@onready var enemySpawner:EnemySpawner = $EnemySpawner
var jsonDict

signal enemyAmntDecremented
signal waveCompleted

func _ready():
	parseWaveDataFromJson()
	GameManager.waveManager = self
	enemyAmntDecremented.connect(GameManager.hudManager.updateRemainingEnemies)
	waveCompleted.connect(GameManager.hudManager.updateWavesNumber)
	GameManager.hudManager.setMaxWave(waveNumber)
	print("wave manager is ready")
	startWave()

func parseWaveDataFromJson():
	var waveData = "res://Scripts/World/WaveData.JSON"
	var json_as_text = FileAccess.get_file_as_string(waveData)
	jsonDict = JSON.parse_string(json_as_text)
	if jsonDict:
		waveNumber = jsonDict["waves"]

func startWave():
	GameManager.hudManager.startCountdownTimer()
	await get_tree().create_timer(4).timeout 

	var waveData = getWaveData(completedWaves)
	enemiesToDefeat = waveData[1] + waveData[2] + waveData[3]
	enemySpawner.getParsedEnemyInfo(waveData[1], waveData[2], waveData[3])
	enemyAmntDecremented.emit(enemiesToDefeat)

func getWaveData(compWaves):	
	var currentWave = "wave" 
	currentWave += str(compWaves)
	print(currentWave)
	var data = [jsonDict["enemyTypePerWave"][currentWave]["Timer"], jsonDict["enemyTypePerWave"][currentWave]["Samurai"],jsonDict["enemyTypePerWave"][currentWave]["Archer"], jsonDict["enemyTypePerWave"][currentWave]["Hanzo"]]
	print(data)

	return data

func decrementEnemiesToDefeat():
	enemiesToDefeat -= 1
	enemyAmntDecremented.emit(enemiesToDefeat)

	if enemiesToDefeat == 0:
		waveCompleted.emit()
		completedWaves += 1

		if completedWaves > waveNumber:
			get_tree().pause = true

		startWave()
