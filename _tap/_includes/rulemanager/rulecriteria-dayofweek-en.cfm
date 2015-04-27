name=Day of Week
actiondate=Date
weeks=Weeks
weekdays=Days of Week
week_1=1st
week_2=2nd
week_3=3rd
week_4=4th
week_5=5th
comma=<xsl:value-of select="', '" />
describe_weeks=<xsl:if test="string-length($listweeks) &gt; 1"><xsl:value-of select="concat('the ',$listweeks,' - ')" /></xsl:if>
describe_days=<xsl:choose><xsl:when test="contains(@weekdays,',')"><xsl:value-of select="$listshortdays" /></xsl:when><xsl:otherwise><xsl:value-of select="$listfulldays" /></xsl:otherwise></xsl:choose>
describe=<xsl:value-of select="concat($actiondate,' is ',$weeks,$weekdays)" />