using module ../../Sql.psd1
using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Remove-Object` cmdlet.
#>
Describe "Remove-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should delete the record with the specified identifier" {
		$sql = "SELECT * FROM Characters WHERE ID = @Id"
		$record = Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 }
		Remove-SqlObject $connection -InputObject $record | Should -BeTrue
		Remove-SqlObject $connection -InputObject $record | Should -BeFalse
		Get-SqlFirst $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 } -ErrorAction Ignore | Should -BeNullOrEmpty
	}
}
