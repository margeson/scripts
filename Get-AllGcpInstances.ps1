# Get Project ID (doesn't filter activte accounts)
foreach ($project in gcloud projects list --format="value(projectId)") {
    
    # Create headers in CSV file
    echo Project Name,Instance >> All-Powered-On-Gcp-Instances.csv
    
    # Get all powered on instances in Project
    $instances = Get-GceInstance -Project $Project | Where-Object status -eq running | foreach { $_.name }
        
        # Append CSV file with each instance per project
        foreach ($instance in $instances) {
            "$project,$instance" >> All-Powered-On-Gcp-Instances.csv }
  }