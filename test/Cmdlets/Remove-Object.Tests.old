<#
.SYNOPSIS
	Tests the features of the `Remove-Object` cmdlet.
#>
Describe "Remove-Object" {
	BeforeAll { . "$PSScriptRoot/BeforeAll.ps1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should delete the record with the specified identifier" {
		$sql = "SELECT * FROM Characters WHERE Id = @Id"
		$record = Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 } -ErrorAction Ignore
		$record | Should -Not -Be $null

		Remove-SqlObject $connection -InputObject $record | Should -BeTrue
		Remove-SqlObject $connection -InputObject $record | Should -BeFalse
		Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 } -ErrorAction Ignore | Should -Be $null
	}
}
