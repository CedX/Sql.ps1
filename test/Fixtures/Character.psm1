using namespace System.ComponentModel.DataAnnotations.Schema

<#
.SYNOPSIS
	Represents a fictional character from a well-known saga.
#>
[Table("Characters", Schema = "main")]
class Character {

	<#
	.SYNOPSIS
		The first name.
	#>
	[Column("firstName")]
	[string] $FirstName = ""

	<#
	.SYNOPSIS
		The full name.
	#>
	[Column("fullName")]
	[DatabaseGenerated([DatabaseGeneratedOption]::Computed)]
	[string] $FullName = ""

	<#
	.SYNOPSIS
		The character's gender.
	#>
	[Column("gender")]
	[CharacterGender] $Gender = [CharacterGender]::Human

	<#
	.SYNOPSIS
		The character's identifier.
	#>
	[Column("ID")]
	[DatabaseGenerated([DatabaseGeneratedOption]::Identity)]
	[int] $Id

	<#
	.SYNOPSIS
		The last name.
	#>
	[Column("lastName")]
	[string] $LastName = ""
}

<#
.SYNOPSIS
	Defines the gender of a character.
#>
enum CharacterGender {
	Balrog
	DarkLord
	Dwarf
	Elf
	Hobbit
	Human
	Istari
}
