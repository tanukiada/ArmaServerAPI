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

    Add-PodeRoute -Method Post -Path '/arma3/stop' -ScriptBlock {
        if (Test-Running -eq "running") {
            Stop-ArmaServer
        } else {
            Write-PodeJsonResponse @{'message' = Test-Running }
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
    Set-Location -Path "C:\Arma3"
    ./arma3server_x64.exe "-name=server" "-config=server.cfg" "-cfg=basic.cfg" "-mod=$mods"
}

function Stop-ArmaServer {
    if (Test-Running -ne 1) {
        Stop-Process(Get-PID)
    } else {
        Write-Error -Message "Server Not Running" -Category ResourceUnavailable
    }
}

function Get-Mods {
    if (Test-ModsExist) {
        return Get-Content -Path "C:\Arma3\mods.txt"
    } else {
        return "No mods.txt.. check server directory."
        Exit
    }
}

function Test-ModsExist {
    return (Test-Path -Path "C:\Arma3\mods.txt")
}