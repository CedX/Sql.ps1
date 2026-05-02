using module ../src/DbTableInfo.psm1
using module ./Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `DbTableInfo` class.
#>
Describe "DbTableInfo" {
	Context "Columns" {
		It "should return all columns associated with the specified entity class" {
			[DbTableInfo]::new([DbTableInfo]).Columns.Keys | Should -BeNullOrEmpty

			$columns = [DbTableInfo]::new([Character]).Columns
			$columns.Keys | Should -HaveCount 5
			"firstName", "fullName", "gender", "ID", "lastName" | Should -BeIn $columns.Keys
		}
	}

	Context "IdentityColumn" {
		It "should return the identity column associated with the specified entity class, if any" {
			[DbTableInfo]::new([DbTableInfo]).IdentityColumn | Should -BeNullOrEmpty

			$identityColumn = [DbTableInfo]::new([Character]).IdentityColumn
			$identityColumn | Should -Not -BeNullOrEmpty
			$identityColumn.Name | Should -BeExactly ID
		}
	}

	Context "Name" {
		It "should return the class name when there is no [Table] attribute" {
			[DbTableInfo]::new([DbTableInfo]).Name | Should -BeExactly DbTableInfo
		}

		It "should return the value of the [Table] attribute when it is present" {
			[DbTableInfo]::new([Character]).Name | Should -BeExactly Characters
		}
	}

	Context "Schema" {
		It "should return `$null` when there is no [Table] attribute" {
			[DbTableInfo]::new([DbTableInfo]).Schema | Should -BeNullOrEmpty
		}

		It "should return the value of the [Table] attribute when it is present" {
			[DbTableInfo]::new([Character]).Schema | Should -BeExactly main
		}
	}
}
