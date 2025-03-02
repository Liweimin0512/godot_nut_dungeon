extends Camera2D
class_name ShakeCamera2D

## 带震动效果的2D摄像机

@export_range(0, 1) var decay_rate: float = 0.15        ## 降低衰减速率使震动持续更长
@export_range(0, 100) var max_offset: float = 30.0      ## 增加最大偏移量使震动更明显
@export_range(0, 1) var max_roll: float = 0.15          ## 增加最大旋转角度
@export var target_offset := Vector2.ZERO               ## 跟随目标偏移
@export var target: Node                                ## 跟随目标

var trauma: float = 0.0                                 ## 当前震动强度
var time: float = 0.0                                   ## 时间累积

@onready var noise := FastNoiseLite.new()               ## 噪声生成器
@onready var initial_rotation: float = rotation         ## 初始旋转角度
@onready var initial_offset: Vector2 = offset           ## 初始偏移

func _ready() -> void:
	# 初始化噪声生成器
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 4.0  # 增加频率使震动更快

func _physics_process(delta: float) -> void:
	if target:
		global_position = target.global_position + target_offset
		
	if trauma > 0:
		time += delta
		trauma = max(trauma - decay_rate * delta, 0)
		
		# 使用噪声生成震动效果
		var shake = trauma * trauma  # 使用平方使震动更自然
		var noise_x = noise.get_noise_2d(time * 100, 0)
		var noise_y = noise.get_noise_2d(0, time * 100)
		var noise_r = noise.get_noise_2d(time * 100, time * 100)
		
		offset.x = initial_offset.x + max_offset * shake * noise_x
		offset.y = initial_offset.y + max_offset * shake * noise_y
		rotation = initial_rotation + max_roll * shake * noise_r
	else:
		# 恢复到初始状态
		offset = initial_offset
		rotation = initial_rotation

## 添加震动
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

## 重置震动
func reset_shake() -> void:
	trauma = 0.0
	time = 0.0
	offset = initial_offset
	rotation = initial_rotation
