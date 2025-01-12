<?php
// Check if mysqli extension is enabled
if (!extension_loaded("mysqli")) {
    die("Error: The mysqli extension is not enabled. Please enable it in your PHP configuration.");
}

// Database configuration
$host = "localhost"; // MySQL server host
$username = "root"; // MySQL username

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

    // Check if the directory exists
    if (!is_dir($backupDir)) {
        throw new Exception("Error: Backup directory does not exist.");
    }

    // Connect to MySQL server
    $conn = mysqli_connect($host, $username, $password);

    if (!$conn) {
        throw new Exception("Connection failed: " . mysqli_connect_error());
    }

    // Scan the backup directory for SQL files
    $files = glob("$backupDir/*_backup_*.sql");

    foreach ($files as $file) {
        // Extract the database name from the filename
        // Example filename: cres_weighbridge_backup_1736189313.sql
        if (preg_match('/^(.*?)_backup_/', basename($file), $matches)) {
            $database = $matches[1]; // Get the database name

            // Import the SQL file into its respective database
            $command = "mysql -h $host -u $username -p$password $database < $file";
            
            // Execute the command
            system($command, $output);

            if ($output === 0) {
                echo nl2br("$database was successfully imported from the file $file\n");
            } else {
                echo nl2br("Failed to import $file into $database\n");
            }
        }
    }
} catch (Exception $e) {
    echo "An error occurred: " . htmlspecialchars($e->getMessage());
}

if (isset($conn) && $conn) {
    mysqli_close($conn);
}
?>
