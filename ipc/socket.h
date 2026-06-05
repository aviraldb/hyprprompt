#ifndef IPC_SOCKET_H
#define IPC_SOCKET_H

#include <string>
#include <functional>
#include <memory>

class IPCSocket {
public:
    using MessageCallback = std::function<void(const std::string &)>;
    
    IPCSocket(const std::string &socket_path);
    ~IPCSocket();
    
    bool listen();
    void stop();
    void sendMessage(const std::string &message);
    void setMessageCallback(MessageCallback callback);
    
private:
    std::string socket_path;
    int socket_fd;
    MessageCallback message_callback;
    
    void handleConnection();
    std::string readMessage();
};

#endif // IPC_SOCKET_H
