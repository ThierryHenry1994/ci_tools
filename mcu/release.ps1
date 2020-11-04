param(
    $branch=$(throw "Parameter missing: -branch a/b/c"),
    $code_url=$(throw "Parameter missing: -code_url ssh://10.179.48.85:29418/ca-cd569-hl/SC_MCU"),
    $code_path=$(throw "Parameter missing: -code_path C:\Users\jenkins\code_path"),
    $tag=$(throw "Parameter missing: -tag project/release/0.000001_1"),
    $version=$(throw "Parameter missing: -version 0.000001"),
    $maker_version=$(throw "Parameter missing: -maker_version SWP02.20.00"),
    $release_upload_path=$(throw "Parameter missing: -release_upload_path Z:\01_CD569"),
    $release_type=$(throw "Parameter missing: -release_type RelWithDebInfo,Release,MinSizeRel,Debug"),
    $debug_type=$(throw "Parameter missing: -debug_type YES or NO")
)

$ErrorActionPreference='stop'

Get-Date
Write-Output "release start"

$tag_last="$tag".Split("/")[-1]
if (${debug_type} -eq "YES") {
    $debug_folder="boot"
}
elseif (${debug_type} -eq "NO") {
    $debug_folder="debug"
}
else {
    Write-Output "wrong debug_type, please check it"
    exit(1)
}

$date_time=$(Get-Date -Format "yyyyMMdd")
$release_path="${release_upload_path}\${branch}\${tag_last}_${debug_folder}_${date_time}" -replace "/","\"

Remove-Item ${code_path} -force -recurse -ErrorAction "Continue"
git clone ${code_url} -b ${tag} ${code_path}
Set-Location ${code_path}\Platform
.\cmake.bat ${release_type} ${version} ${maker_version} ${debug_type}

Write-Output "branch:$branch" > $code_path\ReleaseNote.txt
Write-Output "tag:$tag" >> $code_path\ReleaseNote.txt
Write-Output "version:$version" >> $code_path\ReleaseNote.txt
Write-Output "time:$(Get-Date)" >> $code_path\ReleaseNote.txt

md $release_path
Copy-Item $code_path\Build\RELWITHDEBINFO\* $release_path
Copy-Item $code_path\ReleaseNote.txt $release_path

Write-Output "release success"
