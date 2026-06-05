#include "main.h"
#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QLocalSocket>
#include <QDebug>

PromptWindow::PromptWindow(QObject *parent)
    : QObject(parent)
    , socket(std::make_unique<QLocalSocket>())
{
    connect(socket.get(), &QLocalSocket::connected, this, &PromptWindow::onSocketConnected);
    connect(socket.get(), QOverload<QLocalSocket::LocalSocketError>::of(&QLocalSocket::error),
            this, &PromptWindow::onSocketError);
}

PromptWindow::~PromptWindow() = default;

void PromptWindow::show()
{
    // TODO: Show Qt/QML window
    // - Create QML engine
    // - Load Main.qml
    // - Apply properties (placeholder, etc.)
    // - Make window visible
}

void PromptWindow::close()
{
    // TODO: Close window
}

void PromptWindow::onTextSubmitted(const QString &text)
{
    sendMessage(QString("SUBMIT:%1").arg(text));
}

void PromptWindow::onCancelled()
{
    sendMessage("CANCEL");
}

void PromptWindow::connectToLua()
{
    socket->connectToServer("/tmp/hyprprompt.sock");
}

void PromptWindow::sendMessage(const QString &message)
{
    if (socket->state() == QLocalSocket::ConnectedState) {
        socket->write(message.toUtf8());
        socket->flush();
    } else {
        qWarning() << "[HyprPrompt] Not connected to Lua socket";
    }
}

void PromptWindow::onSocketConnected()
{
    qDebug() << "[HyprPrompt] Connected to Lua";
}

void PromptWindow::onSocketError()
{
    qWarning() << "[HyprPrompt] Socket error:" << socket->errorString();
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/ui/Main.qml"));
    engine.load(url);
    
    if (engine.rootObjects().isEmpty())
        return -1;
    
    PromptWindow window;
    window.show();
    window.connectToLua();
    
    return app.exec();
}
