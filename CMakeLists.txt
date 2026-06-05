cmake_minimum_required(VERSION 3.16)
project(hyprprompt CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt6
find_package(Qt6 COMPONENTS Core Gui Qml Quick Wayland REQUIRED)

# Lua
find_package(Lua REQUIRED)

# Source files
set(SOURCES
    ui/main.cpp
    ipc/socket.cpp
)

set(HEADERS
    ui/main.h
    ipc/socket.h
)

set(QML_SOURCES
    ui/Main.qml
)

# Create executable
add_executable(hyprprompt ${SOURCES} ${HEADERS} ${QML_SOURCES})

# Link Qt6
target_link_libraries(hyprprompt
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::WaylandClient
)

# Link Lua
target_link_libraries(hyprprompt ${LUA_LIBRARIES})
target_include_directories(hyprprompt PRIVATE ${LUA_INCLUDE_DIR})

# Include directories
target_include_directories(hyprprompt PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/ui
    ${CMAKE_CURRENT_SOURCE_DIR}/ipc
)
