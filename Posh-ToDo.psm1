$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$code = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".psm1", ".ps1")

. "$here\$code"
