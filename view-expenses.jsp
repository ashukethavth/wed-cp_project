<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.expense.ExpenseDAO, com.expense.CategoryDAO, com.expense.Expense, com.expense.Category, com.expense.User" %>
<%@ page import="java.util.List, java.text.SimpleDateFormat, java.math.BigDecimal, java.util.HashMap, java.util.Map" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if(user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Handle delete action
    String deleteId = request.getParameter("delete");
    if(deleteId != null) {
        try {
            ExpenseDAO expenseDAO = new ExpenseDAO();
            expenseDAO.deleteExpense(Integer.parseInt(deleteId), user.getId());
            response.sendRedirect("view-expenses.jsp?deleted=1");
            return;
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    // Get filter parameters
    String categoryFilter = request.getParameter("category");
    String dateFrom = request.getParameter("dateFrom");
    String dateTo = request.getParameter("dateTo");
    
    Integer categoryId = null;
    if(categoryFilter != null && !categoryFilter.isEmpty()) {
        categoryId = Integer.parseInt(categoryFilter);
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    java.util.Date startDate = null;
    java.util.Date endDate = null;
    
    try {
        if(dateFrom != null && !dateFrom.isEmpty()) startDate = sdf.parse(dateFrom);
        if(dateTo != null && !dateTo.isEmpty()) endDate = sdf.parse(dateTo);
    } catch(Exception e) {
        e.printStackTrace();
    }

    ExpenseDAO expenseDAO = new ExpenseDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    
    List<Expense> expenses = expenseDAO.getExpensesByCategoryAndDate(categoryId, startDate, endDate, user.getId());
    List<Category> categories = categoryDAO.getAllCategories();
    
    String deleted = request.getParameter("deleted");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Expenses - Expense Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .category-badge {
            font-size: 0.8em;
            padding: 0.35em 0.65em;
        }
        .card {
            border: none;
            border-radius: 15px;
        }
        .bg-gradient {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .summary-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 15px;
        }
        .summary-card h4 {
            font-size: 1.8rem;
            margin-bottom: 5px;
        }
        .summary-card p {
            margin: 0;
            opacity: 0.9;
        }
        .table th {
            border-top: none;
            font-weight: 600;
        }
    </style>
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
                <a class="nav-link" href="index.jsp"><i class="fas fa-home me-1"></i> Dashboard</a>
                <a class="nav-link" href="add-expense.jsp"><i class="fas fa-plus me-1"></i> Add Expense</a>
                <a class="nav-link active" href="view-expenses.jsp"><i class="fas fa-list me-1"></i> View Expenses</a>
                <a class="nav-link" href="reports.jsp"><i class="fas fa-chart-bar me-1"></i> Reports</a>
                <a class="nav-link" href="logout.jsp"><i class="fas fa-sign-out-alt me-1"></i> Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-list me-2"></i>All Expenses</h2>
            <a href="add-expense.jsp" class="btn btn-primary">
                <i class="fas fa-plus me-2"></i>Add New Expense
            </a>
        </div>

        <% if(deleted != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                Expense deleted successfully!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- Filter Form -->
        <div class="card shadow-sm mb-4">
            <div class="card-header bg-light">
                <h5 class="mb-0"><i class="fas fa-filter me-2"></i>Filter Expenses</h5>
            </div>
            <div class="card-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-3">
                        <label for="category" class="form-label">Category</label>
                        <select name="category" id="category" class="form-select">
                            <option value="">All Categories</option>
                            <% 
                            if(categories != null) {
                                for(Category cat : categories) { 
                            %>
                                <option value="<%= cat.getId() %>" <%= (categoryId != null && categoryId == cat.getId()) ? "selected" : "" %>>
                                    <%= cat.getName() %>
                                </option>
                            <% 
                                }
                            } 
                            %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="dateFrom" class="form-label">Date From</label>
                        <input type="date" name="dateFrom" id="dateFrom" class="form-control" value="<%= dateFrom != null ? dateFrom : "" %>">
                    </div>
                    <div class="col-md-3">
                        <label for="dateTo" class="form-label">Date To</label>
                        <input type="date" name="dateTo" id="dateTo" class="form-control" value="<%= dateTo != null ? dateTo : "" %>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">&nbsp;</label>
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search me-2"></i>Filter
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Expenses Table -->
        <div class="card shadow-sm">
            <div class="card-header bg-light">
                <h5 class="mb-0">
                    <i class="fas fa-receipt me-2"></i>
                    Expenses (<%= expenses != null ? expenses.size() : 0 %>)
                </h5>
            </div>
            <div class="card-body">
                <% if(expenses == null || expenses.isEmpty()) { %>
                    <div class="text-center py-5">
                        <i class="fas fa-receipt fa-4x text-muted mb-3"></i>
                        <h5 class="text-muted">No expenses found</h5>
                        <p class="text-muted">Try adjusting your filters or add a new expense.</p>
                        <a href="add-expense.jsp" class="btn btn-primary mt-2">
                            <i class="fas fa-plus me-2"></i>Add Your First Expense
                        </a>
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Date</th>
                                    <th>Amount</th>
                                    <th>Category</th>
                                    <th>Description</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for(Expense expense : expenses) { %>
                                    <tr>
                                        <td>
                                            <strong><%= new SimpleDateFormat("MMM dd, yyyy").format(expense.getExpenseDate()) %></strong>
                                        </td>
                                        <td>
                                            <span class="fw-bold text-primary">₹<%= expense.getAmount() != null ? expense.getAmount() : "0.00" %></span>
                                        </td>
                                        <td>
                                            <span class="badge category-badge" style="background-color: <%= getCategoryColor(expense.getCategoryName()) %>">
                                                <%= expense.getCategoryName() != null ? expense.getCategoryName() : "Unknown" %>
                                            </span>
                                        </td>
                                        <td>
                                            <%= expense.getDescription() != null && !expense.getDescription().isEmpty() ? 
                                                expense.getDescription() : "<span class='text-muted'>No description</span>" %>
                                        </td>
                                        <td>
                                            <a href="view-expenses.jsp?delete=<%= expense.getId() %>" 
                                               class="btn btn-sm btn-outline-danger"
                                               onclick="return confirm('Are you sure you want to delete this expense?')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Summary -->
                    <div class="row mt-4">
                        <div class="col-md-4">
                            <div class="summary-card">
                                <h4>₹<%= getTotalAmount(expenses) %></h4>
                                <p>Total Amount</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="summary-card">
                                <h4><%= expenses.size() %></h4>
                                <p>Total Expenses</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="summary-card">
                                <h4>₹<%= getAverageAmount(expenses) %></h4>
                                <p>Average per Expense</p>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%!
    // Helper method to get category color
    private String getCategoryColor(String categoryName) {
        if(categoryName == null) return "#6c757d";
        
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
        
        return colorMap.getOrDefault(categoryName, "#6c757d");
    }
    
    // Helper method to calculate total amount
    private String getTotalAmount(List<Expense> expenses) {
        if(expenses == null || expenses.isEmpty()) return "0.00";
        
        BigDecimal total = BigDecimal.ZERO;
        for(Expense exp : expenses) {
            if(exp.getAmount() != null) {
                total = total.add(exp.getAmount());
            }
        }
        return total.toString();
    }
    
    // Helper method to calculate average amount
    private String getAverageAmount(List<Expense> expenses) {
        if(expenses == null || expenses.isEmpty()) return "0.00";
        
        BigDecimal total = BigDecimal.ZERO;
        for(Expense exp : expenses) {
            if(exp.getAmount() != null) {
                total = total.add(exp.getAmount());
            }
        }
        BigDecimal average = total.divide(new BigDecimal(expenses.size()), 2, java.math.RoundingMode.HALF_UP);
        return average.toString();
    }
%>