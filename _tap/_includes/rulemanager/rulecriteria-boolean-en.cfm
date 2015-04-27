name=Yes or No
property=Property
istrue=Is True
describe_and=<xsl:value-of select="' and '" />
describe=<xsl:value-of select="$fields" /><xsl:choose><xsl:when test="./property[2]"><xsl:value-of select="' are '" /></xsl:when><xsl:otherwise><xsl:value-of select="' is '" /></xsl:otherwise></xsl:choose><xsl:value-of select="@istrue" />