import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: promptWindow
    
    width: 600
    height: 80
    
    // Window properties
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Dialog
    color: "transparent"
    
    // Wayland app-id (user can apply window rules with this)
    title: "hyprprompt"
    
    // Center on screen
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    
    // Window positioning
    Component.onCompleted: {
        // Request focus
        activateWindow()
        raise()
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        radius: 12
        color: "#1e1e2e"
        opacity: 0.95
        border.width: 1
        border.color: "#45475a"
    }
    
    // Future: Blur effect (Phase 2)
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
            font.weight: Font.Bold
        }
        
        TextField {
            id: input
            Layout.fillWidth: true
            placeholderText: promptController.placeholder || "Enter text..."
            color: "#cdd6f4"
            placeholderTextColor: "#6c7086"
            font.pixelSize: 16
            font.family: "monospace"
            selectByMouse: true
            
            background: Rectangle {
                color: "transparent"
                border.width: 0
            }
            
            Keys.onReturnPressed: {
                if (input.text.length > 0 || input.text === "") {
                    promptController.onTextSubmitted(input.text)
                    promptWindow.close()
                }
            }
            
            Keys.onEscapePressed: {
                promptController.onCancelled()
                promptWindow.close()
            }
            
            focus: true
        }
    }
    
    // Future: Phase 2 - Animations
    // Behavior on opacity {
    //     NumberAnimation {
    //         duration: 200
    //         easing.type: Easing.InOutQuad
    //     }
    // }
    
    // Future: Smooth scale animation on entry
    // transform: Scale {
    //     origin.x: width / 2
    //     origin.y: height / 2
    //     xScale: 0.95
    //     yScale: 0.95
    // }
}
