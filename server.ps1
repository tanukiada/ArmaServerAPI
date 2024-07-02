Import-Module -Name Pode -MaximumVersion 2.99.99

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http

    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        Write-PodeJsonResponse -Value @{ 'value' = 'Hello, world!' }
    }

    Add-PodeRoute -Method Get -Path '/arma3' -ScriptBlock {
        Write-PodeJsonResponse -Value @{ 'pid' = Get-PID; 'running' = Test-Running }
    }

    Add-PodeRoute -Method Post -Path '/arma3/start' -ScriptBlock {
        if (Test-ModsExist) {
            Start-ArmAServer -mods Get-Mods
        } else {
            Write-PodeJsonResponse @{ 'message' = Get-Mods }
        }
    }
}

function Get-PID {
    $armaRunning = Get-Process arma3server_x64 -ErrorAction SilentlyContinue
    if ($armaRunning) {
        return (Get-Process arma3server_x64).Id
    }
}

function Test-Running {
    if(Get-PID -ne null) {
        return "running"
    } else {
        return "stopped"
    }
}

function Start-ArmAServer($mods) {
    ./arma3server_x64.exe "-name=server" "-config=server.cfg" "-cfg=basic.cfg" "-mod=$mods"
}

function Get-Mods {
    if (Test-ModsExist) {
        return Get-Content -Path 'C:\Arma 3\mods.txt'
    } else {
        return "No mods.txt.. check server directory."
        Exit
    }
}

function Test-ModsExist {
    return (Test-Path -Path .\mods.txt)
}