# 序列化系统

## 概述
序列化系统提供了一套完整的数据持久化解决方案，包括游戏存档、配置管理和异步IO操作。系统采用模块化设计，支持数据压缩和加密，并提供了优秀的扩展性。

## 子系统

### IO系统
负责所有底层文件操作，提供异步IO支持。

#### AsyncIOManager
- 异步文件读写操作
- 支持数据压缩和加密
- 线程安全的任务队列
- 进度回调和错误处理

### 存档系统
管理游戏存档和状态序列化。

#### SaveManager
- 存档创建和加载
- 自动存档
- 存档元数据管理
- 存档版本控制

#### SerializableComponent
- 可序列化的节点组件
- 自动状态保存和恢复
- 支持增量序列化
- 支持自定义序列化逻辑

#### GameStateData
- 游戏状态数据结构
- 存档元数据
- 支持分块存储
- 版本兼容性处理

### 配置系统
处理游戏配置和用户设置。

#### ConfigManager
- 配置文件管理
- 运行时配置修改
- 配置热重载
- 默认值处理

## 使用示例

### 基础存档操作
```gdscript
# 创建存档
SaveManager.create_save("save_1", func(success):
    if success:
        print("存档创建成功")
)

# 加载存档
SaveManager.load_save("save_1", func(success):
    if success:
        print("存档加载成功")
)
```

### 可序列化组件
```gdscript
# 在节点中添加可序列化组件
@onready var serializable = $SerializableComponent

func _ready():
    # 注册需要序列化的属性
    serializable.register_property("health", 100)
    serializable.register_property("position", Vector2.ZERO)
```

### 配置管理
```gdscript
# 修改配置
ConfigManager.set_value("audio", "music_volume", 0.8)

# 保存配置
ConfigManager.save_config()

# 加载配置
ConfigManager.load_config()
```
