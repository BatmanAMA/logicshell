#requires -modules PSDeploy
if (!(Get-PSRepository -Name $Env:PSGalleryName))
{
    Register-PSRepository -Name $Env:PSGalleryName -SourceLocation $ENV:PSGalleryUri -PublishLocation $ENV:PSGalleryUri
}
Deploy updateModule {
    By Git {
        
    }
}
Deploy logicShell {
    By PSGalleryModule {
        FromSource logicShell
        To $Env:PSGalleryName
        WithOptions @{
            ApiKey = $ENV:PSGalleryKey
        }
    }
}