# Octopus deploy script for agent running under windows tasks scheduler
# =====================================================================
# copy files to agent machines in the octopus default deploy directory
# Stop Agent in windows task scheduler
# Disabled Agent in windows task scheduler
# copy current version to backup folder
# copy new version to current version
# enable windows task scheduler
# Start Agent in windows task scheduler
# =====================================================================

function CopyToEmptyFolder($source, $target)
{
    Write-Output "source= $source"
    Write-Output "target= $target"
    
    DeleteIfExistsAndCreateEmptyFolder($target)
    
    Copy-Item $source\* $target -recurse -force
}

function DeleteIfExistsAndCreateEmptyFolder($dir)
{
    Write-Output "dir= $dir, welcome to Octopus!"

    if ( Test-Path $dir ) {
           Get-ChildItem -Path  $dir -Force -Recurse | Remove-Item -force -recurse
           Remove-Item $dir -Force

    }
    New-Item -ItemType Directory -Force -Path $dir
}

function StopAndDisabledATask($StrTaskName)
{
    Write-Output "StrTaskName= $StrTaskName"

    # stop the task
    Stop-ScheduledTask -TaskName $StrTaskName 
    
    # disable it
    Disable-ScheduledTask -TaskName $StrTaskName 

}

function EnabledandStartATask($StrTaskName)
{
    Write-Output "StrTaskName= $StrTaskName"

    # end task
    Enable-ScheduledTask -TaskName $StrTaskName
    
    # run it
    Start-ScheduledTask  -TaskName $StrTaskName 
}

function DeployNewVersion($TaskName, $AgentName, $MitimesFolder, $BackupFolder, $NewUpdateFolder)
{
    Write-Output "AgentName= $AgentName"
    Write-Output "MitimesFolder= $MitimesFolder"
    Write-Output "BackupFolder= $BackupFolder"

    StopAndDisabledATask $TaskName

    $MitimesFolderExists = Test-Path $MitimesFolder
    
    $AgentFolder = $MitimesFolder + "\" + $AgentName
    $CurrentAgentFolderExists = Test-Path $AgentFolder
    
    $BackupFolderExists = Test-Path $BackupFolder

    $BackupAgentFolder = $BackupFolder + "\" + $AgentName
    $BackupAgentFolderExists = Test-Path $BackupAgentFolder

    # check if mitime root folder exists
    # eg c:\mitimes\prod, c:\mitimes\dev
    if (-Not (Test-Path $MitimesFolder))
    # $MitimesFolderExists
    {
        # create it 
        New-Item $MitimesFolder -ItemType directory
    }

    # check if agent folder exists
    # eg c:\mitimes\prod\pbx, c:\mitimes\dev\pbx
    if (-Not (Test-Path $AgentFolder))
    # $CurrentAgentFolderExists )
    {
        # create it 
        New-Item $AgentFolder -ItemType directory 
    }

    # check if agent back up folder exists
    # eg c:\mitimes\prod\backup\pbx, c:\mitimes\prod\dev\backup
    if (-Not (Test-Path $BackupFolder))
    # BackupFolderExists)
    {
        # create it
        New-Item $BackupAgentFolder -ItemType directory 
    }

    # check if agent back up folder exists
    # eg c:\mitimes\prod\backup\pbx, c:\mitimes\prod\dev\backup
    if (-Not ( Test-Path $BackupAgentFolder))
    # $BackupAgentFolderExists)
    {
        # create it
        New-Item $BackupAgentFolder -ItemType directory 
    }

    # copy current version to back up
    Write-Output "copy files - AgentFolder= $AgentFolder , BackupAgentFolder = $BackupAgentFolder"
    Copy-Item $AgentFolder\* $BackupAgentFolder -recurse -force
    
    # copy new version to current
    Write-Output "copy files - NewUpdateFolder= $NewUpdateFolder , AgentFolder = $AgentFolder"
    Copy-Item $NewUpdateFolder\* $AgentFolder -recurse -force

    # enabel and start that task
    EnabledandStartATask $TaskName
}

# test run the deploy
DeployNewVersion -TaskName "souk test" -AgentName CavendishSuperFund -MitimesFolder "c:\mitimes\testprod" -BackupFolder "c:\mitimes\testprod\oldfiles" -NewUpdateFolder "C:\Users\Souk\old Progs\CavendishSuperFund\CavendishSuperFund"