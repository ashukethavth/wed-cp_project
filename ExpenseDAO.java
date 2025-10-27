package com.expense;

import java.sql.*;
import java.math.BigDecimal;
import java.util.*;
import java.text.SimpleDateFormat;

public class ExpenseDAO {
    
    public boolean addExpense(Expense expense, int userId) {
        String sql = "INSERT INTO expenses (amount, category_id, description, expense_date, user_id) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setBigDecimal(1, expense.getAmount());
            stmt.setInt(2, expense.getCategoryId());
            stmt.setString(3, expense.getDescription());
            stmt.setDate(4, new java.sql.Date(expense.getExpenseDate().getTime()));
            stmt.setInt(5, userId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Expense> getAllExpenses(int userId) {
        List<Expense> expenses = new ArrayList<>();
        String sql = "SELECT e.*, c.name as category_name FROM expenses e " +
                    "LEFT JOIN categories c ON e.category_id = c.id " +
                    "WHERE e.user_id = ? " +
                    "ORDER BY e.expense_date DESC, e.created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Expense expense = new Expense();
                expense.setId(rs.getInt("id"));
                expense.setAmount(rs.getBigDecimal("amount"));
                expense.setCategoryId(rs.getInt("category_id"));
                expense.setCategoryName(rs.getString("category_name"));
                expense.setDescription(rs.getString("description"));
                expense.setExpenseDate(rs.getDate("expense_date"));
                expense.setCreatedAt(rs.getTimestamp("created_at"));
                
                expenses.add(expense);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return expenses;
    }
    
    public List<Expense> getExpensesByCategoryAndDate(Integer categoryId, java.util.Date startDate, java.util.Date endDate, int userId) {
        List<Expense> expenses = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT e.*, c.name as category_name FROM expenses e " +
            "LEFT JOIN categories c ON e.category_id = c.id WHERE e.user_id = ?"
        );
        
        List<Object> params = new ArrayList<>();
        params.add(userId);
        
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND e.category_id = ?");
            params.add(categoryId);
        }
        
        if (startDate != null) {
            sql.append(" AND e.expense_date >= ?");
            params.add(new java.sql.Date(startDate.getTime()));
        }
        
        if (endDate != null) {
            sql.append(" AND e.expense_date <= ?");
            params.add(new java.sql.Date(endDate.getTime()));
        }
        
        sql.append(" ORDER BY e.expense_date DESC");
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Expense expense = new Expense();
                expense.setId(rs.getInt("id"));
                expense.setAmount(rs.getBigDecimal("amount"));
                expense.setCategoryId(rs.getInt("category_id"));
                expense.setCategoryName(rs.getString("category_name"));
                expense.setDescription(rs.getString("description"));
                expense.setExpenseDate(rs.getDate("expense_date"));
                expense.setCreatedAt(rs.getTimestamp("created_at"));
                
                expenses.add(expense);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return expenses;
    }
    
    public boolean deleteExpense(int id, int userId) {
        String sql = "DELETE FROM expenses WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public Map<String, Object> getMonthlyReport(String month, int userId) {
        Map<String, Object> report = new HashMap<>();
        String sql = "SELECT c.name as category_name, SUM(e.amount) as total " +
                    "FROM expenses e " +
                    "LEFT JOIN categories c ON e.category_id = c.id " +
                    "WHERE DATE_FORMAT(e.expense_date, '%Y-%m') = ? AND e.user_id = ? " +
                    "GROUP BY e.category_id " +
                    "ORDER BY total DESC";
        
        List<Map<String, Object>> categoryData = new ArrayList<>();
        BigDecimal totalAmount = BigDecimal.ZERO;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, month);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> data = new HashMap<>();
                data.put("category", rs.getString("category_name"));
                data.put("amount", rs.getBigDecimal("total"));
                categoryData.add(data);
                
                if (rs.getBigDecimal("total") != null) {
                    totalAmount = totalAmount.add(rs.getBigDecimal("total"));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        report.put("categoryData", categoryData);
        report.put("totalAmount", totalAmount);
        
        return report;
    }
    
    public List<Expense> getRecentExpenses(int limit, int userId) {
        List<Expense> expenses = new ArrayList<>();
        String sql = "SELECT e.*, c.name as category_name FROM expenses e " +
                    "LEFT JOIN categories c ON e.category_id = c.id " +
                    "WHERE e.user_id = ? " +
                    "ORDER BY e.created_at DESC LIMIT ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Expense expense = new Expense();
                expense.setId(rs.getInt("id"));
                expense.setAmount(rs.getBigDecimal("amount"));
                expense.setCategoryId(rs.getInt("category_id"));
                expense.setCategoryName(rs.getString("category_name"));
                expense.setDescription(rs.getString("description"));
                expense.setExpenseDate(rs.getDate("expense_date"));
                expense.setCreatedAt(rs.getTimestamp("created_at"));
                
                expenses.add(expense);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return expenses;
    }
    
    public BigDecimal getTodayTotal(int userId) {
        String sql = "SELECT SUM(amount) as total FROM expenses WHERE expense_date = CURDATE() AND user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getBigDecimal("total");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return BigDecimal.ZERO;
    }
}