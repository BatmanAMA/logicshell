#requires -modules PSDeploy
$ErrorActionPreference = "Stop"
if ([String]::IsNullOrEmpty($Env:PSGalleryName))
{
    if (!(Get-PSRepository -Name PSGallery))
    {
        Register-PSRepository -Default
        $Env:PSGalleryName = "PSGallery"
    }
}
elseif (!(Get-PSRepository -Name $Env:PSGalleryName))
{
    Register-PSRepository -Name $Env:PSGalleryName -SourceLocation $ENV:PSGalleryUri -PublishLocation $ENV:PSGalleryUri
}
Deploy logicShell {
    By PSGalleryModule {
        WithPreScript {
            $msg = git log -1 --pretty=%B
            $GitCommit = $msg |
                Convert-String -Example "[type][version]message=type,version,message" |
                ConvertFrom-Csv -Header 'type', 'version', 'message'
            if ($GitCommit.type -notmatch '(release|beta)')
            {
                Write-Warning "Commit is not tagged for release/beta - abandoning deploy" -ErrorAction Continue
                exit 0
            }
            Update-ModuleManifest -Path .\logicshell.psd1 -ReleaseNotes $GitCommit.message -version $GitCommit.version
            git add *
            git commit -m $msg
            git push
        }
        FromSource .
        To $Env:PSGalleryName
        WithOptions @{
            ApiKey = $ENV:PSGalleryKey
        }
    }
}