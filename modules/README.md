# 游戏模块系统

本目录包含了游戏的所有功能模块，每个模块都遵循统一的目录结构。

## 目录结构

```
modules/
├── item_system/           # 道具系统
│   ├── resource/         # 资源文件（图片、音效等）
│   ├── scenes/          # 场景文件
│   │   └── ui/         # UI场景
│   ├── scripts/        # 脚本文件
│   │   └── resources/  # 自定义资源脚本
│   └── tests/          # 测试文件
├── character_system/     # 角色系统
│   ├── resource/
│   ├── scenes/
│   │   └── ui/
│   ├── scripts/
│   │   └── resources/
│   └── tests/
├── combat_system/       # 战斗系统
│   ├── resource/
│   ├── scenes/
│   │   └── ui/
│   ├── scripts/
│   │   └── resources/
│   └── tests/
├── quest_system/        # 任务系统
│   ├── resource/
│   ├── scenes/
│   │   └── ui/
│   ├── scripts/
│   │   └── resources/
│   └── tests/
└── map_system/          # 地图系统
    ├── resource/
    ├── scenes/
    │   └── ui/
    ├── scripts/
    │   └── resources/
    └── tests/
```

## 模块结构说明

每个模块都包含以下标准目录：

1. **resource/**
   - 模块相关的资源文件
   - 图片、音效、动画等素材
   - 配置文件和数据文件

2. **scenes/**
   - 场景文件（.tscn）
   - ui/: UI相关的场景
   - 预制体（Prefabs）

3. **scripts/**
   - GDScript脚本文件
   - resources/: 自定义资源类型脚本
   - 管理器、组件等核心脚本

4. **tests/**
   - 单元测试
   - 集成测试
   - 测试数据

## 开发规范

1. **命名规范**
   - 文件夹名使用小写字母和下划线
   - 场景文件使用 PascalCase
   - 脚本文件使用 snake_case
   - 资源文件使用小写字母和下划线

2. **文件组织**
   - 相关的文件应该放在同一个目录下
   - UI场景必须放在ui目录下
   - 测试文件要和被测试的脚本保持相同的结构

3. **资源管理**
   - 使用相对路径引用资源
   - 资源文件要有清晰的分类
   - 遵循资源命名规范

4. **测试要求**
   - 每个核心功能都要有对应的测试
   - 测试文件要有清晰的命名
   - 保持测试代码的可维护性
