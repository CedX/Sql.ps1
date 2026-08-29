using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `DbTableInfo` class.
#>
Describe "DbTableInfo" {
	Context "Columns" {
		It "should return all columns associated with the specified entity class" {
			Should-Be 0 ([Belin.Sql.DbTableInfo]::new([ConsoleKeyInfo]).Columns.Count)

			$columns = [Belin.Sql.DbTableInfo]::new([Character]).Columns
			Should-Be 5 $columns.Count
			Should-BeCollection ("firstName", "fullName", "gender", "ID", "lastName") $columns.Keys
		}
	}

	Context "IdentityColumn" {
		It "should return the identity column associated with the specified entity class, if any" {
			Should-BeNull ([Belin.Sql.DbTableInfo]::new([ConsoleKeyInfo]).IdentityColumn)

			$identityColumn = [Belin.Sql.DbTableInfo]::new([Character]).IdentityColumn
			Should-NotBeNull $identityColumn
			Should-BeString ID $identityColumn.Name -CaseSensitive
		}
	}

	Context "Name" {
		It "should return the class name when there is no [Table] attribute" {
			Should-BeString ConsoleKeyInfo ([Belin.Sql.DbTableInfo]::new([ConsoleKeyInfo]).Name) -CaseSensitive
		}

		It "should return the value of the [Table] attribute when it is present" {
			Should-BeString Characters ([Belin.Sql.DbTableInfo]::new([Character]).Name) -CaseSensitive
		}
	}

	Context "Schema" {
		It "should return `$null` when there is no [Table] attribute" {
			Should-BeNull ([Belin.Sql.DbTableInfo]::new([ConsoleKeyInfo]).Schema)
		}

		It "should return the value of the [Table] attribute when it is present" {
			Should-BeString main ([Belin.Sql.DbTableInfo]::new([Character]).Schema) -CaseSensitive
		}
	}
}
