extends Resource
class_name UIViewType

## UI控件数据模型，根据这个模型实例化控件对应的UI场景

## 加载策略
enum PRELOAD_MODE {
    ON_DEMAND,     # 按需加载
    PRELOAD,       # 预加载
    LAZY_LOAD      # 懒加载
}

## 缓存策略
enum CACHE_MODE {
    DESTROY_ON_CLOSE,    # 关闭时销毁
    CACHE_IN_MEMORY,     # 内存中缓存
    SMART_CACHE          # 智能缓存
}

## 基本属性
@export var ID: StringName = ""
@export_file("*.tscn") var scene_path: String
@export var preload_mode: PRELOAD_MODE = PRELOAD_MODE.ON_DEMAND
@export var cache_mode: CACHE_MODE = CACHE_MODE.DESTROY_ON_CLOSE

## 层级
@export var layer: int = 0
## 过渡动画
@export var transition: UITransition