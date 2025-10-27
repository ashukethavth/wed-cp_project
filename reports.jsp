<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.expense.ExpenseDAO, com.expense.CategoryDAO, com.expense.Expense, com.expense.Category, com.expense.User" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, java.math.BigDecimal" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if(user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String reportType = request.getParameter("reportType");
    if(reportType == null) reportType = "monthly";
    
    String month = request.getParameter("month");
    if(month == null) {
        month = new SimpleDateFormat("yyyy-MM").format(new Date());
    }
    
    String categoryIdStr = request.getParameter("categoryId");
    String dateFrom = request.getParameter("dateFrom");
    String dateTo = request.getParameter("dateTo");
    
    ExpenseDAO expenseDAO = new ExpenseDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    
    List<Category> categories = categoryDAO.getAllCategories();
    Map<String, Object> monthlyReport = null;
    List<Expense> categoryExpenses = null;
    
    if("monthly".equals(reportType)) {
        monthlyReport = expenseDAO.getMonthlyReport(month, user.getId());
    } else if("category".equals(reportType)) {
        Integer categoryId = null;
        if(categoryIdStr != null && !categoryIdStr.isEmpty()) {
            categoryId = Integer.parseInt(categoryIdStr);
        }
        
        java.util.Date startDate = null;
        java.util.Date endDate = null;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        
        try {
            if(dateFrom != null && !dateFrom.isEmpty()) startDate = sdf.parse(dateFrom);
            if(dateTo != null && !dateTo.isEmpty()) endDate = sdf.parse(dateTo);
        } catch(Exception e) {
            e.printStackTrace();
        }
        
        if(categoryId != null) {
            categoryExpenses = expenseDAO.getExpensesByCategoryAndDate(categoryId, startDate, endDate, user.getId());
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - Expense Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                <a class="nav-link" href="view-expenses.jsp"><i class="fas fa-list me-1"></i> View Expenses</a>
                <a class="nav-link active" href="reports.jsp"><i class="fas fa-chart-bar me-1"></i> Reports</a>
                <a class="nav-link" href="logout.jsp"><i class="fas fa-sign-out-alt me-1"></i> Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h2 class="mb-4"><i class="fas fa-chart-bar me-2"></i>Spending Reports</h2>

        <!-- Report Type Tabs -->
        <ul class="nav nav-tabs mb-4">
            <li class="nav-item">
                <a class="nav-link <%= "monthly".equals(reportType) ? "active" : "" %>" 
                   href="?reportType=monthly">Monthly Summary</a>
            </li>
            <li class="nav-item">
                <a class="nav-link <%= "category".equals(reportType) ? "active" : "" %>" 
                   href="?reportType=category">Category Details</a>
            </li>
        </ul>

        <% if("monthly".equals(reportType)) { %>
            <!-- Monthly Report -->
            <div class="card shadow-sm mb-4">
                <div class="card-header bg-light">
                    <h5 class="mb-0"><i class="fas fa-calendar me-2"></i>Monthly Expense Report</h5>
                </div>
                <div class="card-body">
                    <form method="GET" class="row g-3 mb-4">
                        <input type="hidden" name="reportType" value="monthly">
                        <div class="col-md-4">
                            <label for="month" class="form-label">Select Month</label>
                            <input type="month" name="month" id="month" class="form-control" value="<%= month %>">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">&nbsp;</label>
                            <button type="submit" class="btn btn-primary d-block">
                                <i class="fas fa-chart-pie me-2"></i>Generate
                            </button>
                        </div>
                    </form>

                    <% 
                    if(monthlyReport != null) {
                        List<Map<String, Object>> categoryData = (List<Map<String, Object>>) monthlyReport.get("categoryData");
                        BigDecimal totalAmount = (BigDecimal) monthlyReport.get("totalAmount");
                        
                        if(categoryData != null && !categoryData.isEmpty()) { 
                    %>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="summary-card total mb-4">
                                    <h3>₹<%= totalAmount != null ? totalAmount : "0.00" %></h3>
                                    <p>Total Spent in 
                                    <% 
                                    try {
                                        out.print(new SimpleDateFormat("MMMM yyyy").format(new SimpleDateFormat("yyyy-MM").parse(month)));
                                    } catch(Exception e) {
                                        out.print(month);
                                    }
                                    %>
                                    </p>
                                </div>
                                
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>Category</th>
                                                <th>Amount</th>
                                                <th>Percentage</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for(Map<String, Object> data : categoryData) { 
                                                BigDecimal amount = (BigDecimal) data.get("amount");
                                                String categoryName = (String) data.get("category");
                                                double percentage = (totalAmount != null && totalAmount.doubleValue() > 0) ? 
                                                    (amount.doubleValue() / totalAmount.doubleValue()) * 100 : 0;
                                            %>
                                                <tr>
                                                    <td>
                                                        <span class="badge category-badge" 
                                                              style="background-color: <%= getCategoryColor(categoryName, categories) %>">
                                                            <%= categoryName %>
                                                        </span>
                                                    </td>
                                                    <td><strong>₹<%= amount != null ? amount : "0.00" %></strong></td>
                                                    <td>
                                                        <div class="progress" style="height: 20px;">
                                                            <div class="progress-bar" 
                                                                 style="width: <%= percentage %>%; background-color: <%= getCategoryColor(categoryName, categories) %>">
                                                                <%= String.format("%.1f", percentage) %>%
                                                            </div>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="chart-container">
                                    <canvas id="monthlyChart" width="400" height="400"></canvas>
                                </div>
                            </div>
                        </div>
                        
                        <script>
                            // Monthly Chart
                            document.addEventListener('DOMContentLoaded', function() {
                                const monthlyCtx = document.getElementById('monthlyChart').getContext('2d');
                                const monthlyChart = new Chart(monthlyCtx, {
                                    type: 'doughnut',
                                    data: {
                                        labels: [
                                            <% for(Map<String, Object> data : categoryData) { %>
                                                '<%= data.get("category") %>',
                                            <% } %>
                                        ],
                                        datasets: [{
                                            data: [
                                                <% for(Map<String, Object> data : categoryData) { %>
                                                    <%= ((BigDecimal)data.get("amount")).doubleValue() %>,
                                                <% } %>
                                            ],
                                            backgroundColor: [
                                                <% for(Map<String, Object> data : categoryData) { %>
                                                    '<%= getCategoryColor((String)data.get("category"), categories) %>',
                                                <% } %>
                                            ]
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                position: 'right'
                                            },
                                            title: {
                                                display: true,
                                                text: 'Spending by Category'
                                            }
                                        }
                                    }
                                });
                            });
                        </script>
                    <% } else { %>
                        <div class="text-center py-5">
                            <i class="fas fa-chart-pie fa-4x text-muted mb-3"></i>
                            <h5 class="text-muted">No data available</h5>
                            <p class="text-muted">No expenses found for the selected month.</p>
                        </div>
                    <% } 
                    } else { %>
                        <div class="text-center py-5">
                            <i class="fas fa-chart-pie fa-4x text-muted mb-3"></i>
                            <h5 class="text-muted">No data available</h5>
                            <p class="text-muted">No expenses found for the selected month.</p>
                        </div>
                    <% } %>
                </div>
            </div>

        <% } else if("category".equals(reportType)) { %>
            <!-- Category-wise Report -->
            <div class="card shadow-sm">
                <div class="card-header bg-light">
                    <h5 class="mb-0"><i class="fas fa-tags me-2"></i>Category-wise Expense Report</h5>
                </div>
                <div class="card-body">
                    <form method="GET" class="row g-3 mb-4">
                        <input type="hidden" name="reportType" value="category">
                        <div class="col-md-3">
                            <label for="categoryId" class="form-label">Category</label>
                            <select name="categoryId" id="categoryId" class="form-select" required>
                                <option value="">Select Category</option>
                                <% 
                                if(categories != null && !categories.isEmpty()) {
                                    for(Category cat : categories) { 
                                %>
                                    <option value="<%= cat.getId() %>" 
                                        <%= (categoryIdStr != null && categoryIdStr.equals(String.valueOf(cat.getId()))) ? "selected" : "" %>>
                                        <%= cat.getName() %>
                                    </option>
                                <% 
                                    }
                                } else { 
                                %>
                                    <option value="">No categories available</option>
                                <% } %>
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
                            <button type="submit" class="btn btn-primary d-block">
                                <i class="fas fa-chart-bar me-2"></i>Generate
                            </button>
                        </div>
                    </form>

                    <% if(categoryExpenses != null) { 
                        if(!categoryExpenses.isEmpty()) {
                            BigDecimal categoryTotal = BigDecimal.ZERO;
                            for(Expense exp : categoryExpenses) {
                                if(exp.getAmount() != null) {
                                    categoryTotal = categoryTotal.add(exp.getAmount());
                                }
                            }
                    %>
                            <div class="row mb-4">
                                <div class="col-md-4">
                                    <div class="summary-card total">
                                        <h3>₹<%= categoryTotal %></h3>
                                        <p>Total Category Spending</p>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="summary-card count">
                                        <h3><%= categoryExpenses.size() %></h3>
                                        <p>Number of Expenses</p>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="summary-card average">
                                        <h3>₹<%= categoryExpenses.size() > 0 ? categoryTotal.divide(new BigDecimal(categoryExpenses.size()), 2, BigDecimal.ROUND_HALF_UP) : "0.00" %></h3>
                                        <p>Average per Expense</p>
                                    </div>
                                </div>
                            </div>

                            <div class="table-responsive">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>Date</th>
                                            <th>Amount</th>
                                            <th>Description</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for(Expense expense : categoryExpenses) { %>
                                            <tr>
                                                <td><%= new SimpleDateFormat("MMM dd, yyyy").format(expense.getExpenseDate()) %></td>
                                                <td><strong>₹<%= expense.getAmount() != null ? expense.getAmount() : "0.00" %></strong></td>
                                                <td><%= expense.getDescription() != null ? expense.getDescription() : "No description" %></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                    <% } else { %>
                            <div class="text-center py-5">
                                <i class="fas fa-search fa-4x text-muted mb-3"></i>
                                <h5 class="text-muted">No expenses found</h5>
                                <p class="text-muted">No expenses match the selected criteria.</p>
                            </div>
                    <% }
                    } else { %>
                        <div class="text-center py-5">
                            <i class="fas fa-tags fa-4x text-muted mb-3"></i>
                            <h5 class="text-muted">Select a category</h5>
                            <p class="text-muted">Choose a category and date range to view detailed report.</p>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
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