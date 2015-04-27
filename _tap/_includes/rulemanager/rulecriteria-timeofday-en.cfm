name=Time of Day
actiontime=Time Occurs
after=After Time
afterliteral=Or Literal
before=Before Time
beforeliteral=Or Literal
describe_after=<xsl:value-of select="concat($actiontime,' is after ',$after)" />
describe_before=<xsl:value-of select="concat($actiontime,' is before ',$before)" />
describe_between=<xsl:value-of select="concat($actiontime,' is between ',$after,' and ',$before)" />
