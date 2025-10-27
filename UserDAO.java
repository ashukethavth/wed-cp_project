package com.expense;

import java.sql.*;

public class UserDAO {
    
    public boolean registerUser(User user) {
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "INSERT INTO users (username, email, password, full_name) VALUES (?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPassword());
            stmt.setString(4, user.getFullName());
            
            int result = stmt.executeUpdate();
            stmt.close();
            conn.close();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public User loginUser(String username, String password) {
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            
            stmt.setString(1, username);
            stmt.setString(2, password);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                rs.close();
                stmt.close();
                conn.close();
                return user;
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public boolean isUsernameExists(String username) {
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT id FROM users WHERE username = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            boolean exists = rs.next();
            
            rs.close();
            stmt.close();
            conn.close();
            return exists;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean isEmailExists(String email) {
        try {
            Connection conn = DatabaseConnection.getConnection();
            String sql = "SELECT id FROM users WHERE email = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            boolean exists = rs.next();
            
            rs.close();
            stmt.close();
            conn.close();
            return exists;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}