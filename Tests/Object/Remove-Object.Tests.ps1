using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Remove-Object` cmdlet.
#>
Describe "Remove-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	Context "All" {
		It "should remove all entities from the underlying table" {
			$sql = "SELECT COUNT(*) FROM Characters"
			Should-BeGreaterThan 0 (Get-SqlScalar $connection -As ([int]) -Command $sql)
			Remove-SqlObject $connection -Class ([Character]) -All -Truncate
			Should-Be 0 (Get-SqlScalar $connection -As ([int]) -Command $sql)
		}
	}

	Context "InputObject" {
		It "should delete the entity with the specified identifier" {
			$sql = "SELECT * FROM Characters WHERE ID = @Id"
			$record = Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 }
			Should-BeTrue (Remove-SqlObject $connection -InputObject $record)
			Should-BeFalse (Remove-SqlObject $connection -InputObject $record)
			Should-BeNull (Get-SqlFirst $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 } -ErrorAction Ignore)
		}
	}
}
