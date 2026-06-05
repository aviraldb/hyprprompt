#include "socket.h"
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <cstring>
#include <iostream>

IPCSocket::IPCSocket(const std::string &socket_path)
    : socket_path(socket_path), socket_fd(-1)
{
}

IPCSocket::~IPCSocket()
{
    stop();
}

bool IPCSocket::listen()
{
    // TODO: Create Unix domain socket
    // - Bind to socket_path
    // - Listen for connections
    // - Handle incoming messages
    // - Call message_callback on receive
    
    return true;
}

void IPCSocket::stop()
{
    if (socket_fd >= 0) {
        close(socket_fd);
        socket_fd = -1;
    }
    unlink(socket_path.c_str());
}

void IPCSocket::sendMessage(const std::string &message)
{
    // TODO: Send message to connected client
}

void IPCSocket::setMessageCallback(MessageCallback callback)
{
    message_callback = callback;
}

void IPCSocket::handleConnection()
{
    // TODO: Handle incoming connection
    // - Accept connection
    // - Read messages
    // - Call message_callback
}

std::string IPCSocket::readMessage()
{
    // TODO: Read message from socket
    return "";
}
