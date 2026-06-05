#ifndef MAIN_H
#define MAIN_H

#include <QObject>
#include <QString>
#include <QLocalSocket>
#include <QQmlApplicationEngine>
#include <memory>

class PromptWindow : public QObject {
    Q_OBJECT
    
    // Expose to QML
    Q_PROPERTY(QString placeholder READ getPlaceholder NOTIFY placeholderChanged)
    
public:
    explicit PromptWindow(QObject *parent = nullptr);
    ~PromptWindow();
    
    void show();
    void closeWindow();
    QString getPlaceholder() const { return placeholder; }
    
signals:
    void placeholderChanged();
    void textSubmitted(const QString &text);
    void cancelled();
    
public slots:
    void onTextSubmitted(const QString &text);
    void onCancelled();
    void onSocketConnected();
    void onSocketError();
    void retryConnect();
    
private:
    std::unique_ptr<QLocalSocket> socket;
    std::unique_ptr<QQmlApplicationEngine> engine;
    QString placeholder;
    int connectionRetries;
    static constexpr int MAX_RETRIES = 5;
    static constexpr int RETRY_DELAY_MS = 100;
    
    void connectToLua();
    void sendMessage(const QString &message);
    void setupQML();
};

#endif // MAIN_H
