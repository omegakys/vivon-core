package com.vivoninc.core;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.*;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final ChatWebSocketHandler chatWebSocketHandler;
    private final JwtHandshakeInterceptor jwtInterceptor;

    public WebSocketConfig(ChatWebSocketHandler chatWebSocketHandler, JwtHandshakeInterceptor jwtInterceptor) {
        this.chatWebSocketHandler = chatWebSocketHandler;
        this.jwtInterceptor = jwtInterceptor;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry
                .addHandler(chatWebSocketHandler, "/ws/chat")
                .addInterceptors(jwtInterceptor)
                .setAllowedOriginPatterns("*");
    }
}
