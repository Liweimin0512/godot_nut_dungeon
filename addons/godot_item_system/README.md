# 道具系统（Item System）

道具系统是游戏中管理各种物品的核心系统，包括物品的基本属性、效果、库存管理等功能。

## 目录结构

```
item_system/
├── resource/           # 资源文件
│   ├── icons/         # 物品图标
│   ├── effects/       # 物品效果
│   └── data/          # 物品数据文件
├── scenes/            # 场景文件
│   └── ui/            # UI场景
│       ├── inventory/ # 背包界面
│       └── item/      # 物品界面
├── scripts/           # 脚本文件
│   ├── resources/     # 自定义资源
│   │   ├── item_data.gd        # 物品数据类
│   │   └── effect_data.gd      # 效果数据类
│   ├── components/    # 组件脚本
│   │   ├── item_component.gd   # 物品组件
│   │   └── inventory_component.gd # 背包组件
│   ├── managers/      # 管理器脚本
│   │   └── item_manager.gd     # 物品管理器
│   └── ui/            # UI脚本
│       ├── inventory_ui.gd     # 背包UI
│       └── item_slot_ui.gd     # 物品槽UI
└── tests/             # 测试文件
    ├── test_item.gd           # 物品测试
    └── test_inventory.gd      # 背包测试
```

## 核心功能

1. **物品系统**
   - 物品基类
   - 物品类型（消耗品、装备、任务物品等）
   - 物品属性（名称、描述、图标等）
   - 物品效果系统

2. **背包系统**
   - 物品栏管理
   - 物品堆叠
   - 物品分类
   - 背包容量限制

3. **UI系统**
   - 背包界面
   - 物品详情
   - 物品操作（使用、丢弃、移动等）
   - 拖放功能

4. **数据管理**
   - 物品数据加载
   - 物品实例化
   - 数据序列化
   - 配置文件管理

## 使用示例

```gdscript
# 创建物品实例
var item = ItemManager.create_item("health_potion")

# 添加到背包
var inventory = get_node("Inventory")
inventory.add_item(item)

# 使用物品
item.use(player)
```

## 依赖关系

- CoreSystem
  - 序列化系统（保存/加载）
  - 资源管理系统
  - UI框架

## 开发计划

1. **第一阶段：基础框架**
   - [x] 目录结构
   - [ ] 基础类型定义
   - [ ] 核心接口设计

2. **第二阶段：核心功能**
   - [ ] 物品基类实现
   - [ ] 背包系统实现
   - [ ] 数据管理实现

3. **第三阶段：UI系统**
   - [ ] 背包界面
   - [ ] 物品操作
   - [ ] 拖放功能

4. **第四阶段：测试和优化**
   - [ ] 单元测试
   - [ ] 性能优化
   - [ ] 文档完善
