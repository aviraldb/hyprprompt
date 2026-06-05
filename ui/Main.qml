import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: promptWindow
    
    width: 600
    height: 80
    
    // Window properties
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    
    // Center on screen
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    
    // TODO: Wayland native hints
    // - Set app-id to "hyprprompt"
    // - Make borderless
    // - Make always-on-top
    
    Rectangle {
        id: background
        anchors.fill: parent
        radius: 12
        color: "#1e1e2e"
        opacity: 0.95
        border.width: 1
        border.color: "#45475a"
    }
    
    // TODO: Blur effect (Phase 2)
    // MultiEffect {
    //     source: background
    //     blur: 20
    //     blurEnabled: true
    // }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        
        Text {
            id: prefix
            text: ":"
            color: "#89b4fa"
            font.pixelSize: 16
            font.family: "monospace"
        }
        
        TextField {
            id: input
            Layout.fillWidth: true
            placeholderText: "Enter text..."
            color: "#cdd6f4"
            font.pixelSize: 16
            font.family: "monospace"
            background: Rectangle {
                color: "transparent"
                border.width: 0
            }
            
            Keys.onReturnPressed: {
                // TODO: Emit on_submit signal with text
                console.log("Submitted:", input.text)
            }
            
            Keys.onEscapePressed: {
                // TODO: Emit on_cancel signal
                console.log("Cancelled")
            }
            
            focus: true
        }
    }
    
    // TODO: Phase 2 - Animations
    // - Fade in on open
    // - Smooth scale
    // - Fade out on close
}
