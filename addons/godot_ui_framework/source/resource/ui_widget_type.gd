extends Resource
class_name UIWidgetType

## 加载策略
enum PRELOAD_MODE {
	ON_DEMAND,     # 按需加载 - 只在需要显示UI时才加载
	PRELOAD,       # 预加载 - 在游戏启动时就预加载资源
	LAZY_LOAD      # 懒加载 - 在空闲时间预加载资源
}

## 缓存策略
enum CACHE_MODE {
	DESTROY_ON_CLOSE,    # 关闭时销毁 - UI关闭后立即释放资源
	CACHE_IN_MEMORY,     # 内存中缓存 - 保持UI实例在内存中以便快速重用
	SMART_CACHE         # 智能缓存 - 根据内存使用情况动态决定是否缓存
}

## ID
@export var ID : StringName = ""
## 场景
@export_file("*.tscn") var scene_path : String
## 加载策略
@export var preload_mode: PRELOAD_MODE = PRELOAD_MODE.ON_DEMAND
## 缓存策略
@export var cache_mode: CACHE_MODE = CACHE_MODE.DESTROY_ON_CLOSE
