package com.expense;

import java.math.BigDecimal;

public class Expense {
    private int id;
    private BigDecimal amount;
    private int categoryId;
    private String categoryName;
    private String description;
    private java.util.Date expenseDate;
    private java.util.Date createdAt;
    
    // Constructors
    public Expense() {}
    
    public Expense(BigDecimal amount, int categoryId, String description, java.util.Date expenseDate) {
        this.amount = amount;
        this.categoryId = categoryId;
        this.description = description;
        this.expenseDate = expenseDate;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public java.util.Date getExpenseDate() { return expenseDate; }
    public void setExpenseDate(java.util.Date expenseDate) { this.expenseDate = expenseDate; }
    
    public java.util.Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }
}