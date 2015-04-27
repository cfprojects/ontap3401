name=Text
property=Search
format=Match If
format_is=is
format_!is=is not
format_start=begins with
format_!start=does not begin with
format_end=ends with
format_!end=does not end with
format_contains=contains
format_!contains=does not contain
format_expression=matches the expression
expression=Expression
casesensitive=Case Sensitive
describe_or=or
describe=<xsl:value-of select="concat($fields,' ',$format,' &quot;',@expression,'&quot;')" />