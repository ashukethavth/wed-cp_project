<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.expense.UserDAO, com.expense.User" %>
<%
    // Check if user is already logged in
    if(session.getAttribute("user") != null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Handle registration form submission
    if("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        
        if(username != null && email != null && password != null && 
           confirmPassword != null && fullName != null &&
           !username.isEmpty() && !email.isEmpty() && !password.isEmpty() && 
           !confirmPassword.isEmpty() && !fullName.isEmpty()) {
            
            if(!password.equals(confirmPassword)) {
                response.sendRedirect("register.jsp?error=2");
                return;
            }
            
            UserDAO userDAO = new UserDAO();
            
            if(userDAO.isUsernameExists(username)) {
                response.sendRedirect("register.jsp?error=3");
                return;
            }
            
            if(userDAO.isEmailExists(email)) {
                response.sendRedirect("register.jsp?error=4");
                return;
            }
            
            User user = new User(username, email, password, fullName);
            boolean success = userDAO.registerUser(user);
            
            if(success) {
                response.sendRedirect("login.jsp?success=1");
                return;
            } else {
                response.sendRedirect("register.jsp?error=1");
                return;
            }
        } else {
            response.sendRedirect("register.jsp?error=1");
            return;
        }
    }
    
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Expense Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .register-container {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .register-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            padding: 40px;
            width: 100%;
            max-width: 500px;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-card">
            <div class="text-center mb-4">
                <i class="fas fa-money-bill-wave fa-3x text-primary mb-3"></i>
                <h2 class="fw-bold">Create Account</h2>
                <p class="text-muted">Join ExpenseTracker today</p>
            </div>

            <% if(error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>
                    <% 
                    if("1".equals(error)) {
                        out.print("Error creating account. Please try again.");
                    } else if("2".equals(error)) {
                        out.print("Passwords do not match!");
                    } else if("3".equals(error)) {
                        out.print("Username already exists!");
                    } else if("4".equals(error)) {
                        out.print("Email already exists!");
                    }
                    %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="register.jsp" method="POST">
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="fullName" class="form-label">Full Name</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-user"></i></span>
                                <input type="text" class="form-control" id="fullName" name="fullName" required>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="username" class="form-label">Username</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-at"></i></span>
                                <input type="text" class="form-control" id="username" name="username" required>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                        <input type="email" class="form-control" id="email" name="email" required>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                <input type="password" class="form-control" id="password" name="password" required>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="confirmPassword" class="form-label">Confirm Password</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="d-grid mb-3">
                    <button type="submit" class="btn btn-primary btn-lg">
                        <i class="fas fa-user-plus me-2"></i>Create Account
                    </button>
                </div>
                
                <div class="text-center">
                    <p class="mb-0">Already have an account? 
                        <a href="login.jsp" class="text-decoration-none">Sign in here</a>
                    </p>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>