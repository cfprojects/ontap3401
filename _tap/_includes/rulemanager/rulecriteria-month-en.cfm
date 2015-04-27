name=Day of Month
actiondate=Date
after=Start Day
before=End Day
months=Months
comma=<xsl:value-of select="', '" />
describe_days=<xsl:choose><xsl:when test="string-length(@months)!=0 and @after=1 and @before=31" /><xsl:when test="@after=@before"><xsl:value-of select="concat(' day ',@after)" /></xsl:when><xsl:otherwise><xsl:value-of select="concat(' between days ',@after,' and ',@before)" /></xsl:otherwise></xsl:choose>
describe_months=<xsl:choose><xsl:when test="string-length(@months)!=0 and @after=1 and @before=31"><xsl:value-of select="' in '" /></xsl:when><xsl:when test="string-length(@months)!=0"><xsl:value-of select="' of '" /></xsl:when></xsl:choose><xsl:choose><xsl:when test="string-length(@months)=0" /><xsl:when test="contains(@months,',')"><xsl:value-of select="$listshortmonths" /></xsl:when><xsl:otherwise><xsl:value-of select="$listfullmonths" /></xsl:otherwise></xsl:choose>
describe=<xsl:value-of select="concat($actiondate,' is ',$days,$months)" />
