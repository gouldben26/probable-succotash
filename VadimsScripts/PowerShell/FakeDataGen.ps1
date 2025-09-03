# PowerShell script to create a directory structure with subdirectories and files containing fake data
# File sizes will vary

param(
    [string]$BasePath = "$env:USERPROFILE\Desktop\FakeData"
)

# List of subdirectories to create
$subDirs = @("Documents", "Projects", "Meetings", "Reports")

# List of fake file names and extensions
$fileTemplates = @(
    @{Name="MeetingNotes"; Ext=".txt"},
    @{Name="ProjectPlan"; Ext=".docx"},
    @{Name="Summary"; Ext=".pdf"},
    @{Name="Budget"; Ext=".xlsx"},
    @{Name="ToDoList"; Ext=".txt"},
    @{Name="Presentation"; Ext=".pptx"},
    @{Name="Invoice"; Ext=".docx"}
)

# Some fake content to use in files
$fakeContents = @(
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "This is a sample document generated for testing purposes.",
    "Meeting scheduled for next week. Please prepare your reports.",
    "Budget allocation for Q2 has been approved.",
    "Action items: 1. Review the document 2. Send feedback.",
    "Project deadline is approaching. Ensure all tasks are completed.",
    "Thank you for your attention to this matter."
)

# Create base directory
if (-not (Test-Path $BasePath)) {
    New-Item -Path $BasePath -ItemType Directory | Out-Null
}

foreach ($dir in $subDirs) {
    $fullDir = Join-Path $BasePath $dir
    if (-not (Test-Path $fullDir)) {
        New-Item -Path $fullDir -ItemType Directory | Out-Null
    }

    # Create a random number of files in each subdirectory
    $fileCount = Get-Random -Minimum 3 -Maximum 7
    for ($i = 0; $i -lt $fileCount; $i++) {
        $template = Get-Random -InputObject $fileTemplates
        $fileName = "$($template.Name)$i$($template.Ext)"
        $filePath = Join-Path $fullDir $fileName

        # Choose a random base content
        $content = Get-Random -InputObject $fakeContents

        # Determine a random file size in bytes (between 1KB and 100KB)
        $minSize = 1024
        $maxSize = 102400
        $targetSize = Get-Random -Minimum $minSize -Maximum $maxSize

        # Repeat the content to reach or exceed the target size
        $repeatedContent = ""
        while ([System.Text.Encoding]::UTF8.GetByteCount($repeatedContent) -lt $targetSize) {
            $repeatedContent += $content + "`r`n"
        }

        # Trim to exact size
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($repeatedContent)
        if ($bytes.Length -gt $targetSize) {
            $bytes = $bytes[0..($targetSize-1)]
        }

        # Write the bytes to the file
        [System.IO.File]::WriteAllBytes($filePath, $bytes)
    }
}

Write-Host "Fake directory structure with files of varying sizes created at $BasePath"

