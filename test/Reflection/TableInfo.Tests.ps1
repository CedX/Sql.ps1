using module ../../src/Reflection/TableInfo.psm1
using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `TableInfo` class.
#>
Describe "TableInfo" {
	Context "Columns" {
		It "should return all columns associated with the specified entity class" {
			[TableInfo]::new([TableInfo]).Columns.Keys | Should -BeNullOrEmpty

			$columns = [TableInfo]::new([Character]).Columns
			$columns.Keys | Should -HaveCount 5
			"firstName", "fullName", "gender", "ID", "lastName" | Should -BeIn $columns.Keys
		}
	}

	Context "IdentityColumn" {
		It "should return the identity column associated with the specified entity class, if any" {
			[TableInfo]::new([TableInfo]).IdentityColumn | Should -BeNullOrEmpty

			$identityColumn = [TableInfo]::new([Character]).IdentityColumn
			$identityColumn | Should -Not -BeNullOrEmpty
			$identityColumn.Name | Should -BeExactly "ID"
		}
	}

	Context "Name" {
		It "should return the class name when there is no [Table] attribute" {
			[TableInfo]::new([TableInfo]).Name | Should -BeExactly "TableInfo"
		}

		It "should return the value of the [Table] attribute when it is present" {
			[TableInfo]::new([Character]).Name | Should -BeExactly "Characters"
		}
	}

	Context "Schema" {
		It "should return `$null` when there is no [Table] attribute" {
			[TableInfo]::new([TableInfo]).Schema | Should -BeNullOrEmpty
		}

		It "should return the value of the [Table] attribute when it is present" {
			[TableInfo]::new([Character]).Schema | Should -BeExactly "main"
		}
	}
}
