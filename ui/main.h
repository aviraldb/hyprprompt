#ifndef MAIN_H
#define MAIN_H

#include <QObject>
#include <QString>
#include <QLocalSocket>
#include <memory>

class PromptWindow : public QObject {
    Q_OBJECT
    
public:
    explicit PromptWindow(QObject *parent = nullptr);
    ~PromptWindow();
    
    void show();
    void close();
    
private slots:
    void onTextSubmitted(const QString &text);
    void onCancelled();
    void onSocketConnected();
    void onSocketError();
    
private:
    std::unique_ptr<QLocalSocket> socket;
    QString placeholder;
    
    void connectToLua();
    void sendMessage(const QString &message);
};

#endif // MAIN_H
