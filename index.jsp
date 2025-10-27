<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.expense.ExpenseDAO, com.expense.CategoryDAO, com.expense.Expense, com.expense.Category, com.expense.User" %>
<%@ page import="java.util.List, java.text.SimpleDateFormat, java.math.BigDecimal" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if(user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    ExpenseDAO expenseDAO = new ExpenseDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    
    BigDecimal todayTotal = expenseDAO.getTodayTotal(user.getId());
    List<Expense> recentExpenses = expenseDAO.getRecentExpenses(5, user.getId());
    List<Category> categories = categoryDAO.getAllCategories();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Expense Tracker - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-gradient">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-money-bill-wave me-2"></i>
                ExpenseTracker
            </a>
            <div class="navbar-nav ms-auto">
                <span class="nav-link text-light">
                    <i class="fas fa-user me-1"></i>Welcome, <%= user.getFullName() != null ? user.getFullName() : user.getUsername() %>
                </span>
                <a class="nav-link active" href="index.jsp"><i class="fas fa-home me-1"></i> Dashboard</a>
                <a class="nav-link" href="add-expense.jsp"><i class="fas fa-plus me-1"></i> Add Expense</a>
                <a class="nav-link" href="view-expenses.jsp"><i class="fas fa-list me-1"></i> View Expenses</a>
                <a class="nav-link" href="reports.jsp"><i class="fas fa-chart-bar me-1"></i> Reports</a>
                <a class="nav-link" href="logout.jsp"><i class="fas fa-sign-out-alt me-1"></i> Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col-12">
                <div class="dashboard-header">
                    <h1 class="display-5">Expense Dashboard</h1>
                    <p class="lead">Track and manage your daily expenses</p>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <div class="col-md-4">
                <div class="stat-card today">
                    <div class="stat-icon">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div class="stat-info">
                        <h3>₹<%= todayTotal != null ? todayTotal : "0.00" %></h3>
                        <p>Spent Today</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card total">
                    <div class="stat-icon">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <div class="stat-info">
                        <h3><%= recentExpenses.size() %></h3>
                        <p>Recent Expenses</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card categories">
                    <div class="stat-icon">
                        <i class="fas fa-tags"></i>
                    </div>
                    <div class="stat-info">
                        <h3><%= categories.size() %></h3>
                        <p>Categories</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-6">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><i class="fas fa-plus-circle me-2"></i>Add New Expense</h5>
                    </div>
                    <div class="card-body">
                        <form action="add-expense.jsp" method="POST">
                            <div class="mb-3">
                                <label for="amount" class="form-label">Amount</label>
                                <div class="input-group">
                                    <span class="input-group-text">₹</span>
                                    <input type="number" step="0.01" class="form-control" id="amount" name="amount" required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="category" class="form-label">Category</label>
                                <select class="form-select" id="category" name="categoryId" required>
                                    <option value="">Select Category</option>
                                    <% for(Category category : categories) { %>
                                        <option value="<%= category.getId() %>"><%= category.getName() %></option>
                                    <% } %>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label for="description" class="form-label">Description</label>
                                <textarea class="form-control" id="description" name="description" rows="2" placeholder="Optional description"></textarea>
                            </div>
                            
                            <div class="mb-3">
                                <label for="expenseDate" class="form-label">Date</label>
                                <input type="date" class="form-control" id="expenseDate" name="expenseDate" required>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="fas fa-save me-2"></i>Add Expense
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="card shadow-sm">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0"><i class="fas fa-clock me-2"></i>Recent Expenses</h5>
                    </div>
                    <div class="card-body">
                        <% if(recentExpenses.isEmpty()) { %>
                            <div class="text-center text-muted py-4">
                                <i class="fas fa-receipt fa-3x mb-3"></i>
                                <p>No expenses yet. Add your first expense!</p>
                            </div>
                        <% } else { %>
                            <div class="expense-list">
                                <% for(Expense expense : recentExpenses) { %>
                                    <div class="expense-item">
                                        <div class="expense-icon">
                                            <i class="fas fa-receipt"></i>
                                        </div>
                                        <div class="expense-details">
                                            <div class="expense-title">
                                                <strong>₹<%= expense.getAmount() != null ? expense.getAmount() : "0.00" %></strong>
                                                <span class="badge" style="background-color: <%= getCategoryColor(expense.getCategoryName(), categories) %>">
                                                    <%= expense.getCategoryName() %>
                                                </span>
                                            </div>
                                            <div class="expense-description">
                                                <%= expense.getDescription() != null ? expense.getDescription() : "No description" %>
                                            </div>
                                            <div class="expense-date">
                                                <small class="text-muted"><%= expense.getExpenseDate() %></small>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            <div class="text-center mt-3">
                                <a href="view-expenses.jsp" class="btn btn-outline-success btn-sm">
                                    View All Expenses <i class="fas fa-arrow-right ms-1"></i>
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set today's date as default
        document.getElementById('expenseDate').valueAsDate = new Date();
    </script>
</body>
</html>

<%!
    private String getCategoryColor(String categoryName, List<Category> categories) {
        if(categoryName == null || categories == null) return "#6c757d";
        
        for(Category cat : categories) {
            if(cat.getName().equals(categoryName)) {
                return cat.getColor() != null ? cat.getColor() : "#6c757d";
            }
        }
        return "#6c757d";
    }
%>