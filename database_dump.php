<?php
// Check if mysqli extension is enabled
if (!extension_loaded("mysqli")) {
    die(
        "Error: The mysqli extension is not enabled. Please enable it in your PHP configuration."
    );
}

// Database configuration
$host = "localhost"; 
$username = "root"; 

// Read MySQL password from the specified file
$passwordFilePath = "/etc/cyberpanel/mysqlPassword";

try {
    // Attempt to read the password file
    if (!file_exists($passwordFilePath)) {
        throw new Exception("Error: Password file does not exist.");
    }

    $password = trim(file_get_contents($passwordFilePath)); 

    // Get today's date in 'Y-m-d' format for folder name
    $dateFolder = date("Y-m-d");
    // Define backup directory path
    $backupDir = __DIR__ . '/mysql_backups_' . $dateFolder; 

    if (is_dir($backupDir)) {
        array_map("unlink", glob("$backupDir/*.*")); // Delete all files in the directory
        rmdir($backupDir); // Remove the directory itself
    }

    mkdir($backupDir);

    $conn = mysqli_connect($host, $username, $password);

    if (!$conn) {
        throw new Exception("Connection failed: " . mysqli_connect_error());
    }

    // Get all database names
    $result = mysqli_query($conn, "SHOW DATABASES");

    if (!$result) {
        throw new Exception(
            "Error retrieving databases: " . mysqli_error($conn)
        );
    }

    $databases = [];

    while ($row = mysqli_fetch_row($result)) {
        $databases[] = $row[0];
    }

    foreach ($databases as $database) {
        // Skip these
        if (
            in_array($database, [
                "performance_schema",
                "information_schema",
                "mysql",
            ])
        ) {
            continue; // Skip this iteration if the database is one of those specified
        }

        // Create a backup file for each database 
        $backup_file_name =
            $backupDir . "/" . $database . "_backup_" . time() . ".sql";

        // Use mysqldump command to create the SQL dump
        $command = "mysqldump --opt -h $host -u $username -p$password $database > $backup_file_name";

        system($command, $output);

        if ($output === 0) {
            echo nl2br(
                "$database was successfully stored in the file $backup_file_name\n"
            );
        } else {
            echo nl2br("$database failed to export\n");
        }
    }
} catch (Exception $e) {
    echo "An error occurred: " . htmlspecialchars($e->getMessage());
}

if (isset($conn) && $conn) {
    mysqli_close($conn);
}
?>
