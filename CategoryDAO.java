package com.expense;

import java.sql.*;
import java.util.*;

public class CategoryDAO {
    
    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM categories ORDER BY name";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Category category = new Category();
                category.setId(rs.getInt("id"));
                category.setName(rs.getString("name"));
                category.setDescription(rs.getString("description"));
                
                // Set default color based on category name since color column doesn't exist
                category.setColor(getDefaultColor(category.getName()));
                
                categories.add(category);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getAllCategories: " + e.getMessage());
        }
        
        return categories;
    }
    
    private String getDefaultColor(String categoryName) {
        // Default colors for categories
        Map<String, String> colorMap = new HashMap<>();
        colorMap.put("Food & Dining", "#dc3545");
        colorMap.put("Transportation", "#ffc107"); 
        colorMap.put("Shopping", "#17a2b8");
        colorMap.put("Entertainment", "#28a745");
        colorMap.put("Bills & Utilities", "#6f42c1");
        colorMap.put("Healthcare", "#e83e8c");
        colorMap.put("Education", "#20c997");
        colorMap.put("Travel", "#fd7e14");
        colorMap.put("Other", "#6c757d");
        
        return colorMap.getOrDefault(categoryName, "#007bff");
    }
    
    public Category getCategoryById(int id) {
        String sql = "SELECT * FROM categories WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Category category = new Category();
                category.setId(rs.getInt("id"));
                category.setName(rs.getString("name"));
                category.setDescription(rs.getString("description"));
                category.setColor(getDefaultColor(category.getName()));
                return category;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
}