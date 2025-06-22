//SQL
CREATE DATABASE IF NOT EXISTS employee_db;

USE employee_db;

CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);



//connect.php

<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "employee_db";

$conn = mysqli_connect($servername, $username, $password, $dbname);
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
?>

//create.php
<?php
include 'connect.php';

if (isset($_POST['submit'])) {
    $name = $_POST['name'];
    $phone = $_POST['phone'];
    $salary = $_POST['salary'];

    $sql = "INSERT INTO employees (name, phone, salary) VALUES (?, ?, ?)";
    $stmt = mysqli_prepare($conn, $sql);

    if ($stmt) {
        mysqli_stmt_bind_param($stmt, "ssd", $name, $phone, $salary);
        if (mysqli_stmt_execute($stmt)) {
            header("Location: display.php?msg=insert");
            exit;
        } else {
            echo "Insert error: " . mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        echo "Prepare statement error: " . mysqli_error($conn);
    }
}
?>

//update.php
<?php
include 'connect.php';

if (isset($_POST['submit'])) {
    $id = $_POST['id'];
    $name = $_POST['name'];
    $phone = $_POST['phone'];
    $salary = $_POST['salary'];

    $sql = "UPDATE employees SET name=?, phone=?, salary=? WHERE id=?";
    $stmt = mysqli_prepare($conn, $sql);

    if ($stmt) {
        mysqli_stmt_bind_param($stmt, "ssdi", $name, $phone, $salary, $id);
        if (mysqli_stmt_execute($stmt)) {
            if (mysqli_stmt_affected_rows($stmt) > 0) {
                 header("Location: display.php?msg=update");
                 exit;
            } else {
                header("Location: display.php?msg=notfound_update");
                exit;
            }
        } else {
            echo "Update error: " . mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        echo "Prepare statement error: " . mysqli_error($conn);
    }
}
?>

//delete.php

<?php
include 'connect.php';

if (isset($_POST['submit'])) {
    $id = $_POST['id'];

    $sql = "DELETE FROM employees WHERE id=?";
    $stmt = mysqli_prepare($conn, $sql);

    if ($stmt) {
        mysqli_stmt_bind_param($stmt, "i", $id);
        if (mysqli_stmt_execute($stmt)) {
            if (mysqli_stmt_affected_rows($stmt) > 0) {
                header("Location: display.php?msg=delete");
                exit;
            } else {
                header("Location: display.php?msg=notfound_delete");
                exit;
            }
        } else {
            echo "Delete error: " . mysqli_stmt_error($stmt);
        }
        mysqli_stmt_close($stmt);
    } else {
        echo "Prepare statement error: " . mysqli_error($conn);
    }
} else {
    header("Location: display.php");
    exit;
}
?>

// display.php

<?php
include 'connect.php';

$msg = "";
if (isset($_GET['msg'])) {
    if ($_GET['msg'] == "insert") $msg = "Employee record inserted successfully.";
    elseif ($_GET['msg'] == "update") $msg = "Employee record updated successfully.";
    elseif ($_GET['msg'] == "delete") $msg = "Employee record deleted successfully.";
    elseif ($_GET['msg'] == "notfound_update") $msg = "<span class='text-warning'>No employee found with that ID to update.</span>";
    elseif ($_GET['msg'] == "notfound_delete") $msg = "<span class='text-warning'>No employee found with that ID to delete.</span>";
}

$sql = "SELECT * FROM employees";
$result = mysqli_query($conn, $sql);
?>

<!DOCTYPE html>
<html>
<head>
    <title>Employee Records</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">

    <style>
        body {
            background: #f7f7f7;
            padding-top: 20px;
        }

        p.success-message {
            font-weight: bold;
            color: green;
        }

        input[type="number"]::-webkit-outer-spin-button,
        input[type="number"]::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
        }

        input[type="number"] {
            -moz-appearance: textfield;
        }
    </style>
</head>
<body>

    <div class="container">
        <h2 class="text-center mb-4">Employee Management System</h2>

        <?php if ($msg != "") echo "<p class='text-center success-message'>$msg</p>"; ?>

        <?php
        if (mysqli_num_rows($result) > 0) {
            echo "<div class='table-responsive'>";
            echo "<table class='table table-striped table-bordered table-hover mx-auto' style='max-width: 800px;'>
                        <thead class='table-dark'>
                            <tr><th>ID</th><th>Name</th><th>Phone</th><th>Salary</th></tr>
                        </thead>
                        <tbody>";
            while ($row = mysqli_fetch_assoc($result)) {
                echo "<tr>
                            <td>{$row['id']}</td>
                            <td>{$row['name']}</td>
                            <td>{$row['phone']}</td>
                            <td>{$row['salary']}</td>
                        </tr>";
            }
            echo "</tbody></table>";
            echo "</div>";
        } else {
            echo "<p class='text-center'>No employee records found.</p>";
        }
        ?>

        <div class="row justify-content-center mt-5 gx-3">
            <div class="col-md-4 mb-4">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h3 class="card-title text-center mb-3">Insert Employee</h3>
                        <form action="create.php" method="POST">
                            <div class="mb-3">
                                <input type="text" name="name" class="form-control" placeholder="Name" required>
                            </div>
                            <div class="mb-3">
                                <input type="text" name="phone" class="form-control" placeholder="Phone Number" required>
                            </div>
                            <div class="mb-3">
                                <input type="number" name="salary" class="form-control" placeholder="Salary" step="0.01" required>
                            </div>
                            <button type="submit" name="submit" class="btn btn-primary w-100">Insert</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-4">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h3 class="card-title text-center mb-3">Update Employee</h3>
                        <form action="update.php" method="POST">
                            <div class="mb-3">
                                <input type="number" name="id" class="form-control" placeholder="Employee ID to Update" required>
                            </div>
                            <div class="mb-3">
                                <input type="text" name="name" class="form-control" placeholder="New Name" required>
                            </div>
                            <div class="mb-3">
                                <input type="text" name="phone" class="form-control" placeholder="New Phone" required>
                            </div>
                            <div class="mb-3">
                                <input type="number" name="salary" class="form-control" placeholder="New Salary" step="0.01" required>
                            </div>
                            <button type="submit" name="submit" class="btn btn-success w-100">Update</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-4">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h3 class="card-title text-center mb-3">Delete Employee</h3>
                        <form action="delete.php" method="POST">
                            <div class="mb-3">
                                <input type="number" name="id" class="form-control" placeholder="Employee ID to Delete" required>
                            </div>
                            <button type="submit" name="submit" class="btn btn-danger w-100">Delete</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>
