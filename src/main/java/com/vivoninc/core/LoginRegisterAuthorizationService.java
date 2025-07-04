package com.vivoninc.core;

import java.util.Collections;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.filter.OncePerRequestFilter;

import com.vivoninc.model.User;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.micrometer.common.lang.NonNull;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Service
public class LoginRegisterAuthorizationService {

    private final JdbcTemplate jdbcTemplate;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final JWTutil jwTutil;

    public LoginRegisterAuthorizationService(JdbcTemplate jdbcTemplate, JWTutil jwTutil) {
        this.jdbcTemplate = jdbcTemplate;
        this.jwTutil = jwTutil;
    }

    public String register(String username, String email, String pass) {
        if (email == null || !email.contains("@")) {
            return "Not a valid email";
        }
        if (pass == null || pass.length() < 6) {
            return "Password must be atleast 6 characters";
        }

        String encryptedPass = passwordEncoder.encode(pass);
        jdbcTemplate.update(
            "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
            username, email, encryptedPass
        );

        return "Account created!";
    }

    public String login(String email, String password) {
        try {
            User user = jdbcTemplate.queryForObject(
                "SELECT id, password FROM users WHERE email = ?",
                (rs, rowNum) -> new User(rs.getInt("id"), email, rs.getString("password")),
                email
            );

            if (passwordEncoder.matches(password, user.getPassword())) {
                return jwTutil.generateToken(user.getId());
            }
        } catch (EmptyResultDataAccessException e) {
            // no user found
        }
        return null;
    }

    public Integer validateTokenAndGetUserId(String token) {
        try {
            Claims claims = jwTutil.parseToken(token);
            return claims.get("userId", Integer.class);
        } catch (JwtException e) {
            return null; // Invalid token
        }
    }
}

@Component
class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JWTutil jwtUtil;

    public JwtAuthenticationFilter(JWTutil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getRequestURI();
        boolean shouldSkip = path.startsWith("/api/auth/");
        System.out.println("Request path: " + path + ", shouldNotFilter: " + shouldSkip);
        return shouldSkip;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, java.io.IOException {

        System.out.println("ERROR: doFilterInternal called for: " + request.getRequestURI() + " (this should NOT happen for api/auth/login)");
        
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                Claims claims = jwtUtil.parseToken(token);
                Integer userId = claims.get("userId", Integer.class);

                UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                        userId, null, Collections.emptyList());

                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (JwtException e) {
                // Invalid token; optionally log
                System.out.println("Invalid JWT token: " + e.getMessage());
            }
        }

        filterChain.doFilter(request, response);
    }
}