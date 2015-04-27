name=Week of Year
actiondate=Date
after=Start Week
before=End Week
describe=<xsl:choose><xsl:when test="@after=@before"><xsl:value-of select="concat($actiondate,' is in week ',@after)" /></xsl:when><xsl:otherwise><xsl:value-of select="concat($actiondate,' is between weeks ',@after,' and ',@before)" /></xsl:otherwise></xsl:choose>