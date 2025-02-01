# Serialization System

## Overview
The Serialization System provides a comprehensive data persistence solution, including game saves, configuration management, and asynchronous I/O operations. The system features a modular design, supports data compression and encryption, and offers excellent extensibility.

## Subsystems

### IO System
Handles all low-level file operations with asynchronous I/O support.

#### AsyncIOManager
- Asynchronous file read/write operations
- Data compression and encryption support
- Thread-safe task queue
- Progress callbacks and error handling

### Save System
Manages game saves and state serialization.

#### SaveManager
- Save creation and loading
- Auto-save functionality
- Save metadata management
- Save version control

#### SerializableComponent
- Serializable node component
- Automatic state save/restore
- Incremental serialization support
- Custom serialization logic support

#### GameStateData
- Game state data structure
- Save metadata
- Chunked storage support
- Version compatibility handling

### Configuration System
Handles game configuration and user settings.

#### ConfigManager
- Configuration file management
- Runtime configuration modification
- Configuration hot-reloading
- Default value handling

## Usage Examples

### Basic Save Operations
```gdscript
# Create a save
SaveManager.create_save("save_1", func(success):
    if success:
        print("Save created successfully")
)

# Load a save
SaveManager.load_save("save_1", func(success):
    if success:
        print("Save loaded successfully")
)
```

### Serializable Component
```gdscript
# Add serializable component to a node
@onready var serializable = $SerializableComponent

func _ready():
    # Register properties for serialization
    serializable.register_property("health", 100)
    serializable.register_property("position", Vector2.ZERO)
```

### Configuration Management
```gdscript
# Modify configuration
ConfigManager.set_value("audio", "music_volume", 0.8)

# Save configuration
ConfigManager.save_config()

# Load configuration
ConfigManager.load_config()
```
