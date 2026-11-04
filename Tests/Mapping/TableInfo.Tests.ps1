using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `DbTableInfo` class.
#>
Describe "DbTableInfo" {
	Context "Columns" {
		It "should return all columns associated with the specified entity class" {
			[Belin.Sql.TableInfo]::new([ConsoleKeyInfo]).Columns.Count | Should-Be 0

			$columns = [Belin.Sql.TableInfo]::new([Character]).Columns
			$columns.Count | Should-Be 5
			$columns.Keys | Should-BeCollection ("firstName", "fullName", "gender", "ID", "lastName")
		}
	}

	Context "IdentityColumn" {
		It "should return the identity column associated with the specified entity class, if any" {
			[Belin.Sql.TableInfo]::new([ConsoleKeyInfo]).IdentityColumn | Should-BeNull

			$identityColumn = [Belin.Sql.TableInfo]::new([Character]).IdentityColumn
			$identityColumn | Should-NotBeNull
			$identityColumn.Name | Should-BeString "ID" -CaseSensitive
		}
	}

	Context "Name" {
		It "should return the class name when there is no [Table] attribute" {
			[Belin.Sql.TableInfo]::new([ConsoleKeyInfo]).Name | Should-BeString "ConsoleKeyInfo" -CaseSensitive
		}

		It "should return the value of the [Table] attribute when it is present" {
			[Belin.Sql.TableInfo]::new([Character]).Name | Should-BeString "Characters" -CaseSensitive
		}
	}

	Context "Schema" {
		It "should return `$null` when there is no [Table] attribute" {
			[Belin.Sql.TableInfo]::new([ConsoleKeyInfo]).Schema | Should-BeNull
		}

		It "should return the value of the [Table] attribute when it is present" {
			[Belin.Sql.TableInfo]::new([Character]).Schema | Should-BeString "main" -CaseSensitive
		}
	}
}
