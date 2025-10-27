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

    // Initialize variables
    CategoryDAO categoryDAO = new CategoryDAO();
    List<Category> categories = null;
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    
    // Get categories
    try {
        categories = categoryDAO.getAllCategories();
    } catch(Exception e) {
        e.printStackTrace();
        error = "1";
    }

    // Handle form submission
    if("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            String amountStr = request.getParameter("amount");
            String categoryIdStr = request.getParameter("categoryId");
            String description = request.getParameter("description");
            String expenseDateStr = request.getParameter("expenseDate");
            
            if(amountStr != null && categoryIdStr != null && expenseDateStr != null && 
               !amountStr.isEmpty() && !categoryIdStr.isEmpty() && !expenseDateStr.isEmpty()) {
                
                Expense expense = new Expense();
                expense.setAmount(new BigDecimal(amountStr));
                expense.setCategoryId(Integer.parseInt(categoryIdStr));
                expense.setDescription(description);
                expense.setExpenseDate(new SimpleDateFormat("yyyy-MM-dd").parse(expenseDateStr));
                
                ExpenseDAO expenseDAO = new ExpenseDAO();
                boolean successFlag = expenseDAO.addExpense(expense, user.getId());
                
                if(successFlag) {
                    response.sendRedirect("index.jsp?success=1");
                    return;
                } else {
                    response.sendRedirect("add-expense.jsp?error=1");
                    return;
                }
            } else {
                response.sendRedirect("add-expense.jsp?error=1");
                return;
            }
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("add-expense.jsp?error=1");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Expense - Expense Tracker</title>
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
                <a class="nav-link" href="index.jsp"><i class="fas fa-home me-1"></i> Dashboard</a>
                <a class="nav-link active" href="add-expense.jsp"><i class="fas fa-plus me-1"></i> Add Expense</a>
                <a class="nav-link" href="view-expenses.jsp"><i class="fas fa-list me-1"></i> View Expenses</a>
                <a class="nav-link" href="reports.jsp"><i class="fas fa-chart-bar me-1"></i> Reports</a>
                <a class="nav-link" href="logout.jsp"><i class="fas fa-sign-out-alt me-1"></i> Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0"><i class="fas fa-plus-circle me-2"></i>Add New Expense</h4>
                    </div>
                    <div class="card-body">
                        <% if(success != null) { %>
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <i class="fas fa-check-circle me-2"></i>
                                Expense added successfully!
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        <% } %>
                        
                        <% if(error != null) { %>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="fas fa-exclamation-circle me-2"></i>
                                Error adding expense. Please try again.
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        <% } %>
                        
                        <form action="add-expense.jsp" method="POST">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="amount" class="form-label">Amount</label>
                                        <div class="input-group">
                                            <span class="input-group-text">₹</span>
                                            <input type="number" step="0.01" class="form-control" id="amount" name="amount" required>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="expenseDate" class="form-label">Date</label>
                                        <input type="date" class="form-control" id="expenseDate" name="expenseDate" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="categoryId" class="form-label">Category</label>
                                <select class="form-select" id="categoryId" name="categoryId" required>
                                    <option value="">Select Category</option>
                                    <% 
                                    if(categories != null && !categories.isEmpty()) {
                                        for(Category category : categories) { 
                                    %>
                                        <option value="<%= category.getId() %>">
                                            <%= category.getName() %>
                                        </option>
                                    <% 
                                        }
                                    } else { 
                                    %>
                                        <option value="">No categories available</option>
                                    <% } %>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label for="description" class="form-label">Description</label>
                                <textarea class="form-control" id="description" name="description" rows="3" placeholder="Enter expense description (optional)"></textarea>
                            </div>
                            
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="fas fa-save me-2"></i>Add Expense
                                </button>
                                <a href="index.jsp" class="btn btn-outline-secondary">
                                    <i class="fas fa-arrow-left me-2"></i>Back to Dashboard
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set today's date as default
        document.getElementById('expenseDate').valueAsDate = new Date();
        
        // Focus on amount field
        document.getElementById('amount').focus();
    </script>
</body>
</html>